---
author: camerazn
comments: true
date: 2013-05-07 17:44:16+00:00
layout: post
slug: reverse-engineering-doubleclick-ad-statistics-part-1
title: Reverse Engineering Doubleclick Ad Statistics (Part 1)
wordpress_id: 96
categories:
  - hacking
---

One of the projects I'm on seeks to proxy web beacons. Basically, I have a WSGI app that serves a 1x1 px gif, and then triggers a Celery app that goes out and actually "clicks" on the intended web beacon. During preliminary load testing with a Doubleclick beacon (actually a Doubleclick link counter), we discovered that requesting that beacon 1000 times in 5 minutes (one request ever 1/3 second) only reported around 30 "clicks." We've been throwing tests at Doubleclick to see what it reports under different scenarios:



	
  * 1000 clicks evenly distributed over 5 minutes: 30 clicks

	
  * 1000 clicks chunked into 50 groups of 20 (I misunderstood how JMeter works): 50 clicks

	
  * 300 clicks over an hour (1 per 12 seconds): 300 clicks

	
  * 500 clicks with spoofed User_agent strings (1 per 12 seconds): 500 clicks


So it appears that Doubleclick has a "cooldown" between clicks and doesn't really care about the User_agent. How long is that cooldown? We know it's greater than 1/3 second and less than 12 seconds.

Today, I'm running a test that looks like this:








**Number of clicks**


**Rate of clicks**


**Delay between clicks**


**Total time**






10240


240 per minute


.25 seconds


2560 s (42.6m)






5120


120 per minute


.5 seconds


2560 s (42.6m)






2560


80 per minute


.75 seconds


1920 s (32m)






1280


40 per minute


1.5 seconds


1920 s (32m)****






640


20 per minute


3 seconds


1920 s (32m)






320


10 per minute


6 seconds


1920 s (32m)




By taking the total number of clicks recorded today (which I'll know tomorrow), I'll be able to start approximating the cooldown (for example, if I see 2240 and change clicks, I'll know that the cooldown is between 1.5 and .75 seconds).

Will update later.
