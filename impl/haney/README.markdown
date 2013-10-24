`haney`
=======

`haney` is an implementation of Pixley in Haskell.  It compiles under `ghc`
to an executable on my system (32-bit Linux) which, after stripping, is a
mere 918 kilobytes.

`haney` uses the Parsec parser combinator library to define the parser, so
you'll need that installed to build it.  You can probably do that with a
simple `cabal install parsec`.

`haney` takes its input from the file named by the first argument on the
command line.  There is no usage or help or fancy command-line parsing.  In
fact, in general, if something goes wrong, you will get a Haskell error
instead of a nice readable Pixley-like error.
