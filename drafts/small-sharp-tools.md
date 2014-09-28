Upon joining Heroku a few years back, one of the central maxims that I heard cited quited frequently was that of _small, sharp tools_, essentially the idea of building minimalist, composable programs that could work in concert to a degree of effectiveness that was more than the sum of their parts, such as providing a highly effective operating environment like a Unix shell. Although the idea was originally applied to the Unix environment, a number of people at Heroku including a founder and a few lead engineers, had found that it lent itself quite naturally to building modern web platforms as well.

The best documented original source for this idea is the book [_The Art of Unix Programming_](http://www.catb.org/esr/writings/taoup/) written by Eric S. Raymond. In the book, the author boils down the overarching philosophies of Unix into a number of digestible rules, three of which are highly applicable to the idea of small, sharp tools:

1. **Rule of Modularity:** Write simple parts connected by clean interfaces.
2. **Rule of Composition:** Design programs to be connected to other programs.
3. **Rule of Parsimony:** Write a big program only when it is clear by demonstration that nothing else will do.

More background for the idea is described under a section on Unix philosophy titled _Tradeoffs between Interface and Implementation Complexity_:

> One strain of Unix thinking emphasizes small sharp tools, starting designs from zero, and interfaces that are simple and consistent. This point of view has been most famously championed by Doug McIlroy. Another strain emphasizes doing simple implementations that work, and that ship quickly, even if the methods are brute-force and some edge cases have to be punted. Ken Thompson’s code and his maxims about programming have often seemed to lean in this direction.

One example of the Unix-based small, sharp tools that are being referred to here are the basic shell primitives like `cd`, `ls`, `cat`, `grep`, and `tail` that can be composed in the context of with pipelines, redirections, the shell, and the file system itself to work in tandem towards a particular goal. The simple and consistent interfaces are the conventions like common idioms between programs for specifying input to consume, and [exit codes](/exit-statuses) that are re-used between programs.

Notably, it's never claimed that this is a fundamental of value of Unix, but more one of the competing philosophies that's been baked into the system.

The web.

## The Catch

Unfortunately, rather than being a solution that's perfectly applicable to all problems, the trade-offs small, sharp tools are fairly well understood. In a section discussing the "compromise between the minimalism of ed and the all-singing-all-dancing comprehensiveness of Emacs", Raymond talks about how building tools that too small can result in an increased burden on their users:

> Then the religion of “small, sharp tools”, the pressure to keep interface complexity and codebase size down, may lead right to a manularity trap — the user has to maintain all the shared context himself, because the tools won’t do it for him.

He continues with another passage on the subject under the section titled _The Right Size of Software_:

> Small, sharp tools in the Unix style have trouble sharing data, unless they live inside a framework that makes communication among them easy. Emacs is such a framework, and unified management of shared context is what the optional complexity of Emacs is buying.

Once again, it's incredible how well this carries over to building modern service-oriented systems as well. Consider for instance two small programs that handle account management and billing. Although each is small and sharp in it's own right with concise areas of responsibility and boundaries, an operator may find that even if each is well-encapsulated, complexity may arise from the shared context between the programs rather than either program in its own right. Where a monolithic system might be able guarantee data integrity and consistency by virtue of having a single ACID data store, two separate programs suddenly have to consider overhead like drifts between data sets, and the acknowledged complexity of distributed transactions.

## Reconciliation

As a general rule to help select tool boundaries, Raymond goes on to suggest the **Rule of Minimality**:

> This suggests a Rule of Minimality: Choose the shared context you want to manage, and build your programs as small as those boundaries will allow. This is “as simple as possible, but no simpler”, but it focuses attention on the choice of shared context. It applies not just to frameworks, but to applications and program systems.

This applies quite well to almost any software that you'd want to build. Although in some cases it may be easier said than done, especially when individual programs may be systems of large complexity in their own right, trying to identify the optimal boundaries for a set of interoperating systems is always certain to be a useful exercise.
