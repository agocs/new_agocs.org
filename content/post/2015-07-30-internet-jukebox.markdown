---
title: "Internet Jukebox"
date: "2015-07-30"
categories: 
  - "Hacking"
---

One of the hackerspaces at which I am a member installed a Beaglebone Black on their door and put a speaker outside. 

<a href="http://imgur.com/v3esU7N"><img src="http://i.imgur.com/v3esU7Nl.jpg" title="source: imgur.com" /></a><a href="http://imgur.com/Pyb5A9A"><img src="http://i.imgur.com/Pyb5A9Al.jpg" title="source: imgur.com" /></a>

<!--more-->

Now we can play sounds to the street, but to do so, you have to ssh into the Beaglebone. That's not bad, but it's a hassle. Okay, so can I make a REST endpoint that plays music?

(The answer is yes.)

Here's the [repo](https://github.com/agocs/bbb_sound_server). Let's go through it.


## Structure

There are two endpoints, `/` and `/play/`. `/` returns a simple HTML form that lets the user upload a sound file. When the user clicks `Submit`, a `POST` request is made to `/play/`. The sound file is extracted from the form data, and asynchronously processed.

The sound file process is thus: it is saved to a temporary file on disk, `mplayer` is called on that file, and then when that process terminates, the sound file is removed.

### Serving a static html page

is easy.

	controlfs := http.FileServer(http.Dir("control"))
	http.Handle("/", controlfs)

There's a directory called `control`, and it contains `index.html`. When you hit `/`, you get index.html. Wildly easy.

### Creating that REST endpoint

	http.HandleFunc("/play/", func(w http.ResponseWriter, req *http.Request) {
		if req.Method == "POST" {

			if req.ContentLength > 10485760 {
				w.WriteHeader(http.StatusBadRequest)
				w.Write([]byte("File size capped at 10mb"))
				return
			}

			soundFile, headers, err := req.FormFile("soundFile")
			if err != nil {
				log.Printf("Error getting soundFile from Form. \n %s", err.Error())
				w.WriteHeader(http.StatusServiceUnavailable)
				return
			}
			log.Printf("Recieved %s", headers.Filename)
			w.Write([]byte("All done!"))
			go playASound(soundFile)

		} else {
			w.WriteHeader(http.StatusMethodNotAllowed)

			//TODO(cagocs): maybe return 200 with the name of the sound playing?
		}
	})

Briefly, here's what we're doing:

- Setting up a url pattern, `/play`/.
- Defining an anonymous function that runs when you hit `/play`/
- Checking the request method.
	- if it's `POST`
		- Check the content-length. If it's greater than 10 MiB, return a status code 400.
		- Get the `soundFile` out of the form.
		- Log the filename
		- Return a status code 200
		- Asynchronously play the file
	- if it isn't
		- Return a status code 405
		- I considered returning a string representation of all the files playing, but didn't.

*One quick point:* Yes, it's possible to spoof the content-length in a request. I didn't check for that. If you decide to run this in any sort of mission critical sense, maybe watch out for that.


### Playing a sound

func playASound(file multipart.File) {
		soundFile, err0 := ioutil.TempFile("", "sound_")
		if err0 != nil {
			log.Printf("Error initializing new file")
		}

		buffer, err1 := ioutil.ReadAll(file)
		if err1 != nil {
			log.Printf("Error reading mime multipart file")
		}

		err2 := ioutil.WriteFile(soundFile.Name(), buffer, os.ModeTemporary)
		if err2 != nil {
			log.Printf("Error writing file to disk")
		}

		cmd := exec.Command("mplayer", soundFile.Name())

		err3 := cmd.Run()
		if err3 != nil {
			log.Printf("Error playing file %s", soundFile.Name())
		}

		soundFile.Close()
		err4 := os.Remove(soundFile.Name())
		if err4 != nil {
			log.Println("Error deleting %s", soundFile.Name())
		}

	}

So now we have a sound file in memory. How do we get it to the speakers? I spent a long time screwing around trying to figure out a "pure Go" solution, gave up, and decided to cheat. The Beaglebone Black will probably ship with [MPlayer](https://en.wikipedia.org/wiki/MPlayer); why not use that?

I skimmed through some code examples and came up with the solution above. `playASound` is running asynchronously, so it can spend some time doing what it needs to do. It creates a new `TempFile`, and writes the sound file there. It then creates a `Command` that calls `mplayer` and passes the name of the temporary file to `mplayer` as an argument. `Mplayer` plays the file, and when the `mplayer` process completes, our goroutine closes and removes the temporary file.

## Running

I decided to not take my own advice and open this up to the general internet a few days ago. I used port forwarding on my router to forward :3030 on my external IP address to port :3030 on my laptop, and ran the program. I posted about it on IRC, forums, and made an Imgur post, and I got a few people participating. 

I found it to be incredibly stable. No crashing, no issues running 4 to 6 instances of mplayer on top of one another. I was pleased with how the server handled unexpected EOFs and connection timeouts. Lastly, I discovered that letting people assault my ears with a barrage of mp3s is fun!
