Synchronous Concurrency
===

I remembered code looks like complete nonsense coming from C-based languages. A helper:

```
C-based     --->    LISP-based

f()         --->    (f)
1 + 1       --->    (+ 1 1)
a.b()       --->    (.b a)
```

Running
---

To run you need the [JDK 8+](https://adoptopenjdk.net/) and [Leiningen](https://leiningen.org/). Once you have those you can run:

    $ lein run

Learnings
---

- Clojure has a great library for writing concurrenct code `core.async`
- it took a while to get my head around the concepts and how to actually make them happen
- it's based on the same [theory](https://en.wikipedia.org/wiki/Communicating_sequential_processes) as Golang's concurrency system (if anyone has a Golang implementation we should compare!)
- when I got it working it _really_ felt great and I had a lot of ideas about how good it could be to have such a good library for concurrency
- the simple version is kind of beautiful as well
