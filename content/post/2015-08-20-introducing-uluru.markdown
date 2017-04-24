---
title: "Introducing Uluru"
date: "2015-08-20"
categories: 
  - "Hacking"
  - "Programming"
---


<img src="https://upload.wikimedia.org/wikipedia/commons/3/3e/Uluru_Panorama.jpg" />

I don't work for [Backstop](https://www.backstopsolutions.com/careers) any more (but you should), but back when I did, we discovered we had no idea how long it took our users to load our tools. Hell, we couldn't even figure out how many clicks per month we had! I was working with New Relic trying to get a quote from them, and the best I could do was 2 million plus or minus 800 thousand. We had insight into how long it took our servers to respond to requests, but no thought was given to DNS, loading outside resources, rendering DOM, etc.

<!--more-->

We tried New Relic Browser, but that failed for two reasons. First, something in the few-hundred-kilobytes of minified JavaScript was conflicting with something in our JavaScript in a way that broke automated testing. Second, on a sales call, we determined that Browser really wasn't going to tell us the information we wanted to know. It's a good tool, for sure, but it didn't expose the depth of data we wanted.

[Colin](https://twitter.com/alarmingcow) found a tool called [Yahoo Boomerang](https://github.com/yahoo/boomerang) which seemed to do what we needed. It would collect metrics on how long it took the page, and various resources on the page, to load, and it would report those data back to a server over here. Simple, right?

I took two issues with Boomerang. First, it again broke our testing. Second, it used some ridiculous scheme of a GET request with URL parameters inside of an invisible iframe to get data back to the server without any cross-site request issues. This seemed entirely too complicated, and simplicity was one of my overarching goals. I decided to roll my own.

I was sitting in the audience at [Monitorama](http://monitorama.com/), and one of the speakers mentioned logging how long clients spent loading pages. I asked him about it, and he mentioned something in Vanilla JavaScript that allowed for that. I did some research, found out about `window.performance.Timing`, and thus Uluru was born.

The name, incidentally, came from back when I was experimenting with Boomerang. I needed a server to throw Boomerang data at, so I picked the famous Australian sandstone formation Uluru.

Design goals
------------

There exist other solutions, commercial and open source, for recording and reporting on browser telemetry. It was found, however, that these solutions were significantly complex, and in many cases interfered with JavaScript we were already using, causing JavaScript errors and preventing the browser from rendering UI elements. Therefore, the design goals of Uluru became:

- Minimalism: Uluru.js is 47 lines of whitespace-heavy JavaScript. It should be extremely readable.
- Light weight: When minified, Uluru.js squishes down under 500 bytes.
- Speed: Uluru.js has no dependencies on other JS libraries. 
- No hacks: Uluru.js makes a single POST request to a remote server. It does not e.g. cram metrics into query parameters and make a series of requests GETting hidden images or iframes.

Implementation
--------------

### Client side ###

Uluru is a function that, when called, gets the time since navigation started and some other metrics, and sends those to an endpoint. We've set it up such that `uluru(endpoint)` is called when `window.onload` fires, under the assumption that most of our product is useful by that point.

Uluru collects the following data:

- url: the `window.location.href`
- connectionTime: the time (ms since UNIX epoch) the connection was initiated.
- connectionDelta: the time spent establishing a connection to the server
- firstByte: the time spent waiting for the server to respond with the first byte of data
- responseDelta: the time the server spent sending a response to the client
- loadTime: time between the `navigationStart` and `window.onload` events.

It also calls `window.performance.getEntries()` to provide specific timing on every resource (script, image, stylesheet, etc.) included in the page load.

### Server side ###

Uluru rolls all the data it collects up into one PUT request. The easiest way to collect Uluru data is to include a data collection REST endpoint in your existent web application (or, if you're feeling clever, make your web proxy route Uluru requests to a specific Uluru logging server. 

Alternatively, you could set the `Access-Control-Allow-Origin` header to allow the browser to make POST requests to a separate server you've spun up for this purpose.

Either way, what we've wound up doing is writing the Uluru data out to Splunk, and aggregating it there in interesting ways.

Data
----

Here's some of the data we were able to collect!

### Page loads and Appdexes

<a href="https://agocs.smugmug.com/Other/Misc/i-6PnMZv4/A"><img src="https://agocs.smugmug.com/Other/Misc/i-6PnMZv4/0/M/Screen%20Shot%202015-09-04%20at%201.57.31%20PM-M.png" alt="Photo &amp; Video Sharing by SmugMug"></a>

One neat thing we didn't have before is an easy way to count how many page loads our system saw, how many unique users we had actively using our system, or how many clients were logged in on a given day. When you start making changes to system performance, you start thinking about things differently when you consider the 1ms wait you just removed will be multiplied by 73,000 over the course of a day.

Appdex is an interesting measure of system speed. You select a goal speed (2 seconds on the left, 4 seconds on the right), and you count page loads. Every page load that took under the goal speed counts for 1. Every load that took greater than the goal speed but under twice the goal speed counts for .5, and the rest count for 0. You divide the counted page loads by the total page loads, and you get a number between 0 and 1 that gives you a decent metric for how happy or sad your users are.

One really interesting thing we saw from this, we found by looking at individual clients. One of our clients had a significantly lower Appdex than the rest. We did some digging, and found that a condition in their data made every JSP load a huge number of records from the database to generate a list they never used. We disabled that for them, and they got much happier without ever realizing they were sad!

### Speed breakdown

<a href="https://agocs.smugmug.com/Other/Misc/i-trpgpLZ/A"><img src="https://agocs.smugmug.com/Other/Misc/i-trpgpLZ/0/M/Screen%20Shot%202015-09-04%20at%201.58.09%20PM-M.png" alt="Photo &amp; Video Sharing by SmugMug"></a>

This is a bit more boring, but it lets us know how many page loads are fast, acceptable, slow, or super slow. Comparing, e.g., last hour with last 7 days lets us see any system wide problems before our clients call in.

### Page load histograms

<a href="https://agocs.smugmug.com/Other/Misc/i-sh6FZWC/A"><img src="https://agocs.smugmug.com/Other/Misc/i-sh6FZWC/0/M/Screen%20Shot%202015-09-04%20at%201.59.35%20PM-M.png" alt="Photo &amp; Video Sharing by SmugMug"></a>

These let us know at a glance how our page loads are distributed. We could, for example, notice a bi-modal distribution. It wouldn't affect our average or median scores, but it would be indicative of something fishy.

I once noticed a particular user sending back negative page load speeds. I investigated it for a little bit and decided it was just one of those weird things that happen when you rely on multiple sources of time.

### Slow pages

<a href="https://agocs.smugmug.com/Other/Misc/i-X5dKdQs/A"><img src="https://agocs.smugmug.com/Other/Misc/i-X5dKdQs/0/M/Screen%20Shot%202015-09-04%20at%201.59.45%20PM-M.png" alt="Photo &amp; Video Sharing by SmugMug"></a>

This report gives us some neat insight into what's been taking a long time to load. You look at each one, make sure it makes sense, and then use this graph to help prioritize your projects.

### Time sinks

<a href="https://agocs.smugmug.com/Other/Misc/i-RJRsk3M/A"><img src="https://agocs.smugmug.com/Other/Misc/i-RJRsk3M/0/M/Screen%20Shot%202015-09-04%20at%201.59.53%20PM-M.png" alt="Photo &amp; Video Sharing by SmugMug"></a>

Likewise, just counting the total amount of time sunk into a resource is helpful. You might (much like we do) have a page that clients hit all the time. It might load in under two seconds, but if you can shave 10 % off of that, you're saving 20 hours per week aggregated across all of your users.

You can get a lot of really interesting data from visualizations like this. Use these to help justify speed projects.

Further directions
------------------

Currently, the Uluru project includes some stub code for a generic REST endpoint. I want to flush this out into something that writes logs for splunkd or logstash, or forwards data to services like Sensu or Riemann.
