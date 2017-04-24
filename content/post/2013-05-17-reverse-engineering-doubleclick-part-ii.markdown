---
author: camerazn
comments: true
date: 2013-05-17 15:27:30+00:00
layout: post
slug: reverse-engineering-doubleclick-part-ii
title: Reverse Engineering Doubleclick Part II
wordpress_id: 99
categories:
  - hacking
---

Once every three seconds, that's the magic number.



Some more interesting information: I pointed a Doubleclick click counter at a super-simple web service I wrote, running on a web server I rent, and I ran a test that follows the DLCK redirect. Here are the results:

[![Delay_Between_Requests](http://www.agocs.org/wp-content/uploads/2013/05/Delay_Between_Requests-300x113.png)](http://www.agocs.org/wp-content/uploads/2013/05/Delay_Between_Requests.png)



I ran 300 clicks at 4s per click, then 500 clicks at 2s per click. As you can see, almost all of the first 300 clicks made it to the web service, but only around 380/500 2s per click clicks made it. Here's the same graph with a log scale y axis:



[![Delay_Between_Requests_log_scale](http://www.agocs.org/wp-content/uploads/2013/05/Delay_Between_Requests_log_scale-300x113.png)](http://www.agocs.org/wp-content/uploads/2013/05/Delay_Between_Requests_log_scale.png)



You can see that the first 300 clicks made it with roughly 3 seconds between clicks (modulo some variance in the first 100 because I was using a gaussian random delay, and a hiccough at #100 because I stopped and restarted the test). The 380 clicks that made it at 2s per click mostly showed up in 2s intervals, but there were at least seven delays of greater than 10 seconds. In fact, I determined that if there was a delay of >4 seconds, it was almost certain that clicks received during this delay would not be delivered. This indicates to me that DLCK is actively watching for clickthrough rates of greater than a certain amount from a certain IP address, and dropping clicks.

Neat!

I tried spoofing DLCK cookies. I have yet to be successful.
