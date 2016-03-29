package main

import "fmt"

type Result struct {
	num     int
	display string
}

func fizzbuzz(out chan Result, die chan bool) {
outerLoop:
	for num := 0; ; num++ {
		var res Result

		switch {
		case num%3 == 0 && num%5 == 0:
			res = Result{num, "FizzBuzz"}
		case num%3 == 0:
			res = Result{num, "Fizz"}
		case num%5 == 0:
			res = Result{num, "Buzz"}
		default:
			res = Result{num, fmt.Sprintf("%d", num)}
		}

		select {
		case <-die:
			break outerLoop
		case out <- res:
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

	for res := range out {
		if res.num >= 100 {
			break
		}

		fmt.Println(res.display)
	}
}
