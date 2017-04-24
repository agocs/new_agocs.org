---
author: Chris Agocs
comments: true
date: 2013-05-05 04:05:48+00:00
layout: post
slug: mergesort-spices
title: Mergesort on all the spices in the kitchen
wordpress_id: 92
categories:
- kitchen
- programming
---

It bothered me that the spices in the kitchen were out of order. So, I sorted them using my favorite sorting algorithm, Mergesort. My cats helped.

[![2013-05-04_23-33-19_905](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-33-19_905-300x168.jpg)](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-33-19_905.jpg)



I started with an un-ordered list of spices.

[![2013-05-04_23-34-08_418](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-34-08_418-300x168.jpg)](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-34-08_418.jpg)

Then I started to divide the list up into smaller lists. Panther helped.

31 elements became 15 and 16.

Then 7, 8, 8, 8.

Then 3, 4, 4, 4, 4, 4, 4, 4.

Then 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

[![2013-05-04_23-35-32_948](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-35-32_948-300x168.jpg)](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-35-32_948.jpg)



Then the sorting began. Each two element group, I sorted. Then I treated each one as a queue. For each set of two queues, I dequeued the head element of lowest alphabetical value, and enqueued it into a result queue. I repeated this until there was only one, sorted queue remaining.

[![2013-05-04_23-46-38_85](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-46-38_85-300x168.jpg)](http://www.agocs.org/wp-content/uploads/2013/05/2013-05-04_23-46-38_85.jpg)



Then I put it back into the spice cabinet! When Sabrina asks, "Who got my spices out of order," I will reply, "I got them _in_ order."


