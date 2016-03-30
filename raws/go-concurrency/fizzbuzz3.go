package main

import (
	"fmt"
	"time"
)

type Result struct {
	num     int
	display string
}

func fizzbuzz(out chan Result, done chan struct{}) {
outerLoop:
	for num := 0; ; num++ {
		switch {
		case num%3 == 0 && num%5 == 0:
			select {
			case <-done:
				break outerLoop
			case out <- Result{num, "FizzBuzz"}:
			}
		case num%3 == 0:
			select {
			case <-done:
				break outerLoop
			case out <- Result{num, "Fizz"}:
			}
		case num%5 == 0:
			select {
			case <-done:
				break outerLoop
			case out <- Result{num, "Buzz"}:
			}
		default:
			select {
			case <-done:
				break outerLoop
			case out <- Result{num, fmt.Sprintf("%d", num)}:
			}
		}
	}

	fmt.Println("Left FizzBuzz.")
}

func main() {
	out := make(chan Result)
	done := make(chan struct{})

	go fizzbuzz(out, done)

	for res := range out {
		if res.num >= 100 {
			break
		}

		fmt.Println(res.display)
	}

	close(done)
	time.Sleep(1 * time.Second)
}
