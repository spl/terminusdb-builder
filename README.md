# TerminusDB Builder

This repository contains a [`Dockerfile`][Dockerfile] with everything needed to
build [TerminusDB][] from [source][]:

* core system packages
* [SWI-Prolog][]
* [Rust][]

The `Dockerfile` provides a way for you to experiment with changes to TerminusDB
without requiring you to install all the libraries and tools needed to build it.

## Usage

First, check out the TerminusDB repository:

```sh
git clone https://github.com/terminusdb/terminusdb.git terminusdb
cd terminusdb
```

You can either build the TerminusDB executable or use TerminusDB interactively
with the SWI-Prolog interpreter.

### Building and running TerminusDB

Build TerminusDB and create an image for it:

```sh
docker run \
  --name terminusdb \
  --rm \
  --volume $(pwd):/app/terminusdb ghcr.io/terminusdb/terminusdb-builder:latest \
  bash -c 'make install-deps && make'
docker commit terminusdb termnusdb/terminusdb-server:local
```

Initialize the store:

```sh
docker run --rm termnusdb/terminusdb-server:local ./terminusdb store init
```

Run the server:

```sh
docker run --rm termnusdb/terminusdb-server:local ./terminusdb serve
```

### Using TerminusDB interactively

Run the SWI-Prolog REPL:


```sh
docker run \
  --rm \
  -it \
  --volume $(pwd):/app/terminusdb \
  ghcr.io/terminusdb/terminusdb-builder:latest \
  bash -c 'make install-deps && make i'
```

At the REPL prompt, you can, among other things, run the server:

```sh
?- terminus_server([], false).
```

## Versioning

We use a simple incrementing number for a version tag. The latest version of
`terminusdb-builder` should always build the latest `terminusdb`.

[Dockerfile]: ./Dockerfile
[TerminusDB]: https://terminusdb.com/
[source]: https://github.com/terminusdb/terminusdb
[SWI-Prolog]: https://www.swi-prolog.org/
[Rust]: https://www.rust-lang.org/
