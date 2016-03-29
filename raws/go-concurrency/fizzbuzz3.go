package main

import "fmt"

type Result struct {
	num     int
	display string
}

func fizzbuzz(out chan Result, die chan bool) {
outerLoop:
	for num := 0; ; num++ {
		switch {
		case num%3 == 0 && num%5 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- Result{num, "FizzBuzz"}:
			}
		case num%3 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- Result{num, "Fizz"}:
			}
		case num%5 == 0:
			select {
			case <-die:
				break outerLoop
			case out <- Result{num, "Buzz"}:
			}
		default:
			select {
			case <-die:
				break outerLoop
			case out <- Result{num, fmt.Sprintf("%d", num)}:
			}
		}
	}
}

func main() {
	out := make(chan Result)
	die := make(chan bool)

	go fizzbuzz(out, die)
	defer func() {
		die <- true
	}()

	for {
		res := <-out

		if res.num >= 100 {
			break
		}

		fmt.Println(res.display)
	}
}
