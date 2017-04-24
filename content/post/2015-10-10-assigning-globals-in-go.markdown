---
title: "Assigning Globals in Go"
date: "2015-10-10"
---

This has bitten me in the butt a few times this week, so I figured I'd blog about it.

### Be careful with your scope when you're assigning values to global variables in Go!


Here's a quick little example. We have a globally scoped variable, `foo`. In our `main()`, we call `makeSomething()`, which returns to us, we hope, a `something` and a `nil` error. Then we make that global `foo` variable point to that variable.

<!--more-->

``` go
package main

var foo int

func anInt()(int, error){
	return 7, nil
}

func main(){
	foo, err := anInt()
	if err != nil {
		print ("Oh god!")
	}
	println("foo was assigned the value of", foo)
	printFoo()
}

func printFoo(){
	println("I see foo as", foo)
}
```

Easy peasy, right? Nope. 

```
$ go run stuff.go
foo was assigned the value of 7
I see foo as 0
```


What we've done is created a **locally scoped** variable `foo` that disappears once we exit `main()`! That's because `:=` is a short-form variable declaration and assignment. The compiler believes we are declaring a variable `foo` and assigning it the value returned by `anInt()`.

Let's run through a few possible variations:

### foo alreay exists

``` go
func main(){
        foo := 3
        foo, err := anInt()			// Weirdly, no error here
        if err != nil {					// Local foo is delcared,
                print ("Oh god!")		// assigned 3, then assigned 7.
        }
        println("foo was assigned the value of ", foo)
        printFoo()
}
```

### Just assign

``` go
func main(){
        foo, err = anInt()			// Compiler error!
        if err != nil {				// undefined: err
                print ("Oh god!")
        }
        println("foo was assigned the value of", foo)
        printFoo()
}
```


### Use a temporary variable

Of course, if we do this:

``` go
func main(){
        f, err := anInt()
        if err != nil {
                print ("Oh god!")
        }
	foo = f
        println("foo was assigned the value of", foo)
        printFoo()
}
```

we see:

```
$ go run stuff.go
foo was assigned the value of  7
I see foo as 7
```

...which is what we'd expect. However, that's a little fugly. Let's tidy that up a bit.


### Pre-declare your error

``` go
func main(){
        var err error
        foo, err = anInt()
        if err != nil {
                print ("Oh god!")
        }
        println("foo was assigned the value of ", foo)
        printFoo()
}
```

Declare an `error` called `err`, do the assignment, and then go on with your day. 


Anyway, lesson learned. When you're dealing with globally scoped variables and multiple return values and something doesn't behave the way you think it should, make sure you're using the variable you think you're using.
