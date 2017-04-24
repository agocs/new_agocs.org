---
author: Chris Agocs
date: 2013-04-23
slug: how-to-urlencode-a-string-in-c-using-net-4-0-or-less
title: How to UrlEncode a String in C# using .Net 4.0 or less
---

The boffins over at Microsoft added a handy method to .Net 4.5: [Webutility.UrlEncode](http://msdn.microsoft.com/en-us/library/system.net.webutility.urlencode.aspx). Unfortunately for those of us who don't have Visual Studio 2012, we can't use it! How then can we properly encode strings for use in URLs?

(What do I mean? Let's say I want to pass a URL inside another URL as an argument. So, for example, I want to pass http://www.bar.com/?a=b&c=d _as a query string variable_ to foo.com. I'd want the following URL: http://foo.com/?url=http%3A//www.bar.com/%3Fa%3Db%26c%3Dd  )

Here's how I did it:



I start by instantiating a StringBuilder with assumed length of 100 (I'm not going to create a URL much longer than 100 characters, am I?). Then, for each character in the input URL, I call the replace(char c) function. Replace returns the string that the character _should_ be, and that value gets appended to the StringBuilder. When we're done, the StringBuilder spits out the string.

I thought about doing an in-place replace, but that would have lead to a lot of shuffling within the string. My intuition told me the runtime would be somewhere along the lines of O(n^2). I also thought about chaining a bunch of String.replace().replace().replace()... calls together, but that would have been a mess as well as a slow performer.

I wound up traded some space for time (yes, I am initializing a bunch of Strings), but I'm effectively performing this encoding in O(n) time.
