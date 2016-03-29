package main

import "fmt"

func fizzbuzz(in chan int, out chan string) {
	for {
		var num int
		num = <-in

		switch {
		case num%3 == 0 && num%5 == 0:
			out <- "FizzBuzz"
		case num%3 == 0:
			out <- "Fizz"
		case num%5 == 0:
			out <- "Buzz"
		default:
			out <- fmt.Sprintf("%d", num)
		}
	}
}

func main() {
	in := make(chan int)
	out := make(chan string)

	go fizzbuzz(in, out)

	for i := 0; i < 100; i++ {
		in <- i
		display := <-out
		fmt.Println(display)
	}
}
