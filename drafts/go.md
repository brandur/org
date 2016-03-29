## The Important Things

### Simple, but Verbose

Building new programs requires typing **a lot**. The language is incredibly
verbose and has few shortcuts. The upside is that once you have typed out
that initial code, it's eminently readable and relatively easy to maintain
compared to many other languages.

This design decision to favor longevity turns out to be a good one in many
practical cases given that once a program is deployed, it tends to change very
little compared to its development phase.

### Concurrency

Green threads (Goroutines) and channels is the only way that concurrency should
work.

When working in languages like Ruby (to pick an example of one that I'm very
familiar with), even with experience, doing any work with concurrency is
incredibly frustrating. It's tempting to think that this is because concurrency
is inherently difficult, but it's more to do with dull primitives that are
error prone by default.

Conversely, when working in Go, it's amazing how many programs you can write
where your concurrent code will work _perfectly_ the first time. I also find
that even in cases where it doesn't, it's far more often due to a conceptual
mistake that I've made than it is to a poorly designed language feature.

### Speed

Speed is absolutely critical, not just for the runtime, but _for the
tooling_. Being able to compile and run your entire test suite in under a
second [1] changes the entire development experience in such a fundamental way
that it's hard to describe.

This is still a key place where Go stands apart even from other modern
languages which tend to focus on runtime speed or sophisticated runtime
features while ignoring the development cycle completely.

### Deployment

If every language was as easy to deploy as Go, Heroku would never have been
invented.

Deploying a Go program is orders of magnitude easier than most other modern
stacks. No Bundler. No weird environment problems. Just a static binary.
Deployment takes seconds and is as pain free as you'll ever see it.

## Other

### The Good

* **Defer:** I love this abstraction. Although not quite as safe as something
  like a C# `using` block (in that you might accidentally remove the line and
  not notice), it's far less cluttering.
* **Import:** I'm firmly convinced now that importing packages with a short
  canonical identifier (e.g. `fmt` or `http` from "net/http") and then having
  only have one option for referencing that package in code is the One True
  Way. No more symbols with unknown and dubious origin (Haskell) or custom
  blends of qualified and non-qualified names (C#/Java/other).
* **Labels:** Incredibly useful for breaking out of an outer loop without
  introducing boilerplate. When used carefully, `goto` is also tremendously
  powerful.
* **Select:** Although decisions like using `default:` to make a `select`
  blocking or non-blocking are a little obtuse, overall this construct is
  incredibly powerful.
* **No metaprogramming and minimal OO:** Sometimes the costs of what seem like
  good features on the surface outweigh their benefits. I'll gladly write a
  little more code if it means that someone else will be able to understand it.
* **Static linking:** Go didn't invent this, but they did make it default.
  Static linking introduces some headaches in a few cases, but vastly improves
  the lives of the other 99% of users.
* **Standard library in Go:** It's an amazing feature to be able to check the
  implementation of core packages in the standard libraries. This isn't all
  that unusual for newer languages these days, but it's becoming increasingly
  harder to justify languages like Ruby and Python that insist that having a
  standard library written in C is just fine.
* **Nice documentation features:** Go has some neat innovations in
  documentation that solve real problems that are observable in almost every
  other language and framework. For example, [testable
  examples][testable-examples] mean that examples in documentation get run with
  the test suite so that they don't fall out of date.

### The Surprisingly Good

* **Dependency management:** It took me a while to warm up to Go's design
  around dependency management, but not having to run and manage everything
  through a slow and complex system like Bundler hugely improves the
  development experience.
* **Gofmt:** I really thought that I wouldn't like this, but having a single
  convention for the language makes collaboration easier, and makes my own
  coding faster (in that I can rely on gofmt to correct certain things).
* **Errors on unused variables:** This can be very annoying, but I can't deny
  that these error messages have saved me from what would otherwise have been a
  bug multiple times now.
* **No generics:** Having types only on special data structures like slices and
  maps gets you surprisingly far. Although not having generics does make using
  the language for certain things difficult, I was amazed after having built a
  multi-thousand LOC program to realize that I hadn't wanted for them once.

### The Bad

I really did make an effort, but even so, some parts of the language are just
hard to love:

* **Error handling:** I like that generally my programs don't crash, but
  dealing with errors requires an incredible level of micro-management. Worse
  yet, the encouraged patterns of passing errors around through returns can
  occasionally make it very difficult to identify the original site of a
  problem.
* **The commmunity:** Reading the mailings lists can be still be pretty
  depressing. Every critique of the language or suggestion for improvement, no
  matter how valid, is met with a barrage of a "you're doing it wrongs".
  Previously this level of zealotry had been reserved for holy crusades and
  text editors.
* **Error handling:** Passing errors around and avoiding panics mean that
  generally my programs don't crash, but dealing with errors requires an
  incredible level of micro-management. Worse yet though is that the encouraged
  patterns of passing errors around through returns can occasionally make it
  very difficult to identify the original site of a problem.
* **Debugging:** gdb does work with Go, but it's an experience that's so rough
  around the edes that you'll find yourself resorting to print-debugging just
  to avoid the hassle.
* **Noisy diffs:** The downside of gofmt is the possibility of noisy diffs. If
  someone adds a new field with a long name to a large struct, all the spacing
  changes and you end up with a huge block of red and a slow review (`?w=1` on
  GitHub to hide whitespace changes helps mitigate this problem, but is not the
  default and doesn't allow comments to be added).
* **Quirky syntax:** Go is littered with quirky syntax that's fine once you
  know it, but is unnecessarily opaque. Some examples:
    1. Interfaces are always references.
    2. Symbols that start with capital letters are exported from packages.
    3. Channels created without a size are blocking.
    4. `select` blocks with a `default` case become non-blocking.
    5. You check if a key exists in a map by using a rare second return value
       of a normal lookup with square brackets.
    6. Comparing interfaces to `nil` is apparently not kosher and can lead to
       some strange bugs.
    7. Named return values.
* **JSON:** Is [as slow as reported][slow-json] due to its extensive use of
  reflection. This wouldn't seem like it should be a problem, but can lead to
  bottlenecks in otherwise fast programs.

### The Ugly

* **Assertions:** Although mostly palatable, the omission of a collection of
  meaningful assert functions (and the corresponding expectation that a
  custom-tailored message should be written every time you want to check that
  an error is nil) isn't great to say the least. The verbosity of tests acts as
  a deterrent to writing tests in any project. I've been using the [testify
  require package][testify] to ease this problem, but there should be answer in
  the standard library.

[1] Without tricks like Zeus that come with considerable gotchas and side
    effects.

[slow-json]: https://github.com/golang/go/issues/5683
[testable-examples]: https://blog.golang.org/examples
[testify]: https://github.com/stretchr/testify#require-package
