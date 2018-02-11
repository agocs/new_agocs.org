---
author: "Chris Agocs"
title: "Using command line tools to analyze a crash"
date: "2018-02-10 11:50:00 -0500"
categories:
  - "Programming"
---

<a href="https://agocs.smugmug.com/Other/Norway/i-SLPwjgK/A"><img src="https://photos.smugmug.com/Other/Norway/i-SLPwjgK/1/808af843/XL/IMG_20170924_070751-XL.jpg" alt=""></a>

At [Nautilus Labs](https://nautiluslabs.co), we're advancing the efficiency
of maritime transportation by collecting data and recognizing patterns. An
interesting side effect of this is that we have insight into a ships' actions,
not just day-by-day, but second-by-second. It's not as simple as dots on a 
map either; engine power, wind, rate-of-turn, it's all important. 

We worked with one of our clients to take advantage of this recently. A few 
days ago, one of their ships struck a jetty during a berthing maneuver. 

<!--more-->

According to an email from the client:

> Everyone’s fine – another avoidable mistake that’s going to keep our 
> insurance premiums the highest amongst our peers.

They asked for a high-resolution dump of data from that day so they could begin
investigating. That's a straightforward request, but we keep raw data encrypted
in AWS S3 buckets. Pulling it down is easy (`aws s3 sync ...`), but it has to
be decrypted and parsed. Fortunately, we've written the software to do that. 
Here's how we used common tools to visualize the data.

<br /><div style="background-color:#cccccc"><emph>Please understand, this is not an accident investigation.
I'm purposefully obscuring the crash location and date, and I'm intentionally 
avoiding making any statements about cause or fault. My intention here is to 
write about command line tools.</emph></div><br />

Decrypting and parsing the data is all a matter of internal tooling, so I'll
skip these steps. Suffice to say I've got a binary called `client_parser` that
outputs these data points in a comma separated value format.

`client_parser | ( head -n 1 && tail -n +2 | sort ) > ship-data.csv`

The data coming out of `client_parser` is not necessarily ordered, so we want
to fix that. The first line is always the CSV header, so
we pull that off of the output stream with `head -n 1`. Lines 2 and greater are 
selected with `tail -n +2`, and passed through `sort`. Fortunately, we chose
to use RFC 3339 timestamps as the first column in that file, so `sort` puts the
lines passed to it in order from earliest to latest. Finally, we're writing the
headers and the sorted data to `ship-data.csv`. 

This file now contains a few hundred thousand lines,
each with over a hundred values. To make the data set easier to 
understand, we want to narrow it down some. The client told us the crash 
occurred on, say, the night of January 15th, so I'm going to limit the dataset 
to that.

```
$ grep -n 2018-01-15T12:00:00 ship-data.csv
318995:2018-01-15T12:00:00Z,...
$
$ grep -n 2018-01-16T12:00:00 ship-data.csv
321875:2018-01-16T12:00:00Z,...
```

Remember, we're using RFC 3339 timestamps as the first column in our data. I
know that `2018-01-15T12:00:00` is going to appear exactly once in that dataset,
so I figure out which line it's on using `grep -n`. I can do the same thing for
January 16th, and determine that I only care about lines `318995` through
`321875`. Let's make an easier to handle file that only has those.

```
sed -n '1p;318995,321875p' ship-data.csv > ship-jan-15.csv
```

This prints the first line, and lines 318995-321875. The output is redirected
to a new file.
This is much better. Already I can load up that file in a spreadsheet program and begin
to poke around. An interesting visualization I found was the absolute value
of the ship's change in speed every 30 seconds.

<a href="https://agocs.smugmug.com/Other/Misc/i-gpM9nxT/A"><img src="https://photos.smugmug.com/Other/Misc/i-gpM9nxT/0/c60c4d21/L/Screen%20Shot%202018-02-10%20at%201.50.09%20PM-L.png" alt=""></a>

That big spike happened at 18:35:00, so let's see what was happening then.

```
$ grep -n T18:34:30 ship-data-day.csv
791:2018-01-15T18:35:00Z
$
$ sed -n '1p;786,796p' ship-jan-15.csv
```

You might be tempted to pipe the result of that `sed` to `less`, but the result
is an impenetrable wall of text. We need a way to manipulate CSV data on the 
command line. Enter [CSVKit](https://csvkit.readthedocs.io/en/1.0.2/tutorial/1_getting_started.html#installing-csvkit).

Let's pipe that through CSVCut instead, to show us just a couple columns. To 
start, let's go for timestamp and speed through water.

```
$ sed -n '1p;786,796p' ship-jan-15.csv | csvcut -c "Timestamp,Speed TW"
Timestamp,Speed TW
2018-01-15T18:32:00Z,3.200000047683716
2018-01-15T18:32:31Z,3.299999952316284
2018-01-15T18:33:00Z,3.200000047683716
2018-01-15T18:33:30Z,3.0999999046325684
2018-01-15T18:34:00Z,3
2018-01-15T18:34:30Z,2.200000047683716
2018-01-15T18:35:00Z,1.2999999523162842
2018-01-15T18:35:30Z,0.20000000298023224
2018-01-15T18:36:00Z,-0.5
2018-01-15T18:36:30Z,-0.20000000298023224
2018-01-15T18:37:00Z,0.10000000149011612
```

Between 18:34:00 and 18:36:00, we see a sharp drop in speed. The biggest change
is, exactly as the chart predicted, between 18:35:00 and 18:35:30. 

I'm confident enough to try putting this on a map. Let's pick about 100 points
around 18:35:00 and generate a CSV. 

```
sed -n '1p;736,836p' ship-jan-15.csv | csvcut -c "Timestamp,GPS Latitude,GPS Longitude,Speed TW" > ship-jan-15-map.csv
```

I learned that Google MyMaps can understand CSV data if you tell it which 
columns are latitude and longitude, so I was able to put these points on a map
quickly.

<a href="https://agocs.smugmug.com/Other/Misc/i-cpD9dNT/A"><img src="https://photos.smugmug.com/Other/Misc/i-cpD9dNT/0/48b38551/L/Screen%20Shot%202018-02-10%20at%205.27.55%20PM-L.png" alt=""></a>

This is pretty clearly the incident in question. I added a few more columns 
(heading, RPM, engine power, wind speed, wind direction, etc.) and
shared the map with the client. He loved it, and asked if we could compare this
incident with a berthing the same ship made a few days prior. I went through
most of the same steps and generated this:

<a href="https://agocs.smugmug.com/Other/Misc/i-kqwzhgK/A"><img src="https://photos.smugmug.com/Other/Misc/i-kqwzhgK/0/28433dd5/L/Screen%20Shot%202018-02-10%20at%205.37.54%20PM-L.png" alt=""></a>

That's obviously a very different profile. I'm not an accident investigator
or a mariner, so I'm hesitant to say what I think was the reason for the 
difference between the two approaches. 

Nevertheless, I enjoyed the exercise. Working with these data sets is always 
interesting. This is the feedback I got from the client:

> Chris – thanks for spearheading the Google map, it’s exactly what we needed 
> right now.  Our Head Counsel said, “Wow. This is incredibly useful.” when I 
> showed him your map.

Obviously nobody's happy this ship is out of service, but I believe we can 
collect the data and effect the changes necessary to make incidents like these
a thing of the past.
