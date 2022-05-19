# TerminusDB Builder

This repository contains a [`Dockerfile`][Dockerfile] with everything needed to
build [TerminusDB][] from [source][]:

* core system packages
* [SWI-Prolog][]
* [Rust][]

The `Dockerfile` serves two main purposes:

* Speed up TerminusDB continuous integration using a pre-built image to quickly
  build and test.
* Provide a platform similar to the published TerminusDB image for development
  and debugging.

We use a simple incrementing number for a version tag.

[Dockerfile]: ./Dockerfile
[TerminusDB]: https://terminusdb.com/
[source]: https://github.com/terminusdb/terminusdb
[SWI-Prolog]: https://www.swi-prolog.org/
[Rust]: https://www.rust-lang.org/
