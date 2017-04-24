---
layout: post
title: "Intro to Golang"
date: 2014-03-16 15:15:39 -0500
comments: true
categories: 
  - golang
  - talks
---

Hey everybody, check out this intro to the Go programming language I put together for a talk at Backstop the other week!

[Golang Slides](http://go-talks.appspot.com/github.com/agocs/GolangIntro/golangIntro.slide#1)

I tried to keep the slides content-light, since I find that having too many things on the screen distracts from what I'm saying. I'll recapitulate my notes below.

1. Title slide. Blah blah blah.
2. 
	- **Around since 2009** 
Go started as a research project at Google in 2007. It was released as an open source project in 2009, and Go 1.0 dropped in March of 2012. It's a real-live language!

	- **Static Typing** 
Kinda --> Go uses Type Inference, but variables are statically typed once the type has been inferred. This is a reaction to the popularity of languages like JavaScript and Python, and gets away from the "cumbersome type systems" used in the C family and Java.

	- **Object Oriented**
Kinda --> Go is object oriented, but it doesn't have classes. I'll get into this later.

	- **Garbage Collected**
Yes.

3. What is it good at? Some of the notable features are quick compile times (which it achieves through clean dependency analysis and no wasted imports or declarations), creation of statically linked binaries, and concurrency, which I dive into later.

4. Why Go?
 	- **Systems Programming** Go represents a next big step in systems programming. Systems programming is the creation of OSes, utilities, drivers, and so-forth. It has to be fast, resource-conscious, and rock solid. C has been the big name in systems programming, but that came out in 1972. C++ came out in 79, and since there, what has there been? D? PL/8? Go and Mozilla Rust are the two up and coming names in systems programming for this century.

	- **Multicore Computers** Moore's law no longer applies. We're making computers faster by cramming more and more cores onto a processor and more and more processors onto a motherboard. If you look at concurrency support in C or Java or any other enterprise language, it's all abysmal. Go has primitives for concurrency built in. It's so beautiful, it's crazy.

	- **Make Programming Fun** I think so, at least. At the end of the talk, we wrote a little application that measures response time to a handful of websites and screwed around with it for a while. Not to toot my own horn, but a fellow dev told me it was "one of the best live coding exercises he had ever seen."

5. **Hello World** Nothing special here. 'fmt' is the formatting package in Go's standard library, much like Stdio.h.

6. **Basic syntax** What I wanted to call out here is the difference between Go's function declaration syntax and that in the C family. C-style declaration is really focused on what a variable / function evaluates to, while Go is more focused on what the thing *is*. I talked a little bit about the Clockwise-Spiral rule.

7. **Static Typing and Type Inference** I talked about how you declare variables. `myName` is in the global address space, while `myAge` is local to the `main` method. Some key points:

	- `myAge := 26` -- `:=` is a shorthand form of declaration and assignment that only works in the local scope. Here, Go's type inference is assuming that I want `myAge` to be an int.

	- `var myAge = 26` is just a longhand version of the above.

	- `var myAge int64 = 26` -- Let's say we live in a world where people live a very long time. Here, I'm overriding Go's type inference and telling Go that `myAge` will be a 64 bit int.

	- `myAge := 28 / myAge= := 26` Let's say I made a mistake and went to reassign 26 to `myAge`. I can't do it this way; the compiler says "You already declared `myAge`, dumbass." If you erase the `:` on the  second line, you can reassign `myAge`.

	- `myBrother := "Rob"` -- We can't declare a variable without using it. It throws a compiler error. This is part of how Go keeps compile times down.

8. Object Orientation -- Here's a quick example of how Go is object oriented. We're declaring a struct called littleBox that holds a couple of ints. We can create a litteBox and use it.

9. More Object Orientation -- Here, we're declaring a littleBox and a bigBox that holds a littleBox. The function

	<pre>func (bb bigBox) makeString() string {
		return fmt.Sprintf("contains %d books and %d baseball cards", bb.numBooks, bb.little.numBaseballCards)
	}</pre>

	creates a function on bigBox that makes it into a string. This is how Go is object oriented, but eschews classes. Whats *neat* is, if you change `func (bb bigBox) makeString()` into `func (bb bigBox) String()`, and change `fmt.Println(myBigBox.makeString())` into `fmt.Println(myBigBox)`, you've made bigBox *implement* the Stringer interface! Did you explicitly do this? No! But you did it anyway! Isn't that awesome?

10. Compile times are quick. I wish I had a really big example to show you, but suffice to say that, every time you click "Run" on the presentation, the code is being sent back to the server, compiled, run, and the result is sent back to you.

11. Go compiles to native binaries. To demonstrate this, I opened iTerm, ran `go build hello_world.go`, then ran `file hello_world` to demonstrate that `hello_world` had compiled to a binary. Then I moved `hello_world` to `/opt/local/bin` and ran `hello_world`, which, of course, output:

	<pre>
	cagocs:~ christopheragocs$ hello_world
	Hello, world!
	</pre>

12. Go comes with a number of primitives to handle concurrency. They are:

	- **Goroutines** -- you can think of these as being super light, cheap threads. What really happens is a new stack frame is created in the same address space as the parent, and concurrent goroutines are multiplexed using threads. All of the actual thread juggling is handled behind the scenes. 

	- **Channels** -- these are concurrency-safe buffers used for communication between goroutines.

	- **Select** -- selects between receiving channels.

13. Here's a purposefully slow example. `aBigNumber` calls a naive recursive implementation of the Fibonacci function, which delays execution for a few seconds. `aSmallNumber` either never gets a chance to execute, or executes much later.

14. In this one, we've created a channel called `results`. We've prefixed the calls to `aSmallNumber()` and `aBigNumber()` with the `go` keyword, which tells Go to execute them in separate goroutines. Both functions put the result onto the `results` channel, and the main method reads the results off of the channel in that order. In this instance, it will print "7" first, and then whatever the huge fib(42) is (or else execution on the remote server will time out first).

15. This was the programming exercise. You can look at the code on Github. In short, it accesses 24 different websites concurrently, and prints out the site, the access time, and the status code in order of completion. I wrote this with a really great group of developers, and we went off on a number of tangents trying different things to figure out some deep implementation details of Go (which explains the `time.Sleep(1000000000)` on line 30.

I used the "Present" tool, which is part of the Golang tool kit. I enjoyed using it, as it lets you use code examples pretty heavily, and the code examples can be modified in-browser and executed live. When I posted the talk on Facebook, an old professor of mine asked me about that, which I thought was pretty cool.

Giving the talk to the developers I work with was a lot of fun. Backstop Solutions employs a bunch of really smart people, and it's a pleasure when they ask deep probing questions that go beyond your knowledge. A++++, 10 stars, would present again.  
