package main

import "fmt"

func fizzbuzz(in chan int, out chan string, die chan bool) {
outerLoop:
	for {
		var num int
		select {
		case <-die:
			break outerLoop
		case num = <-in:
		}

		switch {
		case num%3 == 0 && num%5 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- "FizzBuzz":
			}
		case num%3 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- "Fizz":
			}
		case num%5 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- "Buzz":
			}
		default:
			select {
			case <-die:
				break outerLoop
			case out <- fmt.Sprintf("%d", num):
			}
		}
	}
}

func main() {
	die := make(chan bool)
	in := make(chan int)
	out := make(chan string)

	go fizzbuzz(in, out, die)
	defer func() {
		die <- true
	}()

	for i := 0; i < 100; i++ {
		in <- i
		display := <-out
		fmt.Println(display)
	}
}
