History of Pixley Distribution
------------------------------

While [The Pixley Programming Language][] notes the changes, over
time, to the Pixley language itself, this file notes the changes
to this distribution: implementation, documentation,
example programs, and other "goodies".

### 1.0 ###

*   Initial distribution, implementing Pixley 1.0.

### 1.1 ###

*   Changed implementations to implement Pixley 1.1.

*   An enlarged test suite (previously mentioned).

*   A REPL (read-eval-print loop, or "interactive mode" interpreter), written
    in Scheme.

*   A statistics generator, written in Scheme, which counts the cons cells,
    symbol instances, and unique symbols present in a given s-expression.
    This was to measure the complexity of the Pixley interpreter.

*   A Mini-Scheme driver.  During my adventures in getting programs to run
    under AmigaOS 1.3, I compiled Mini-Scheme thereunder, and got Pixley to
    run under it by including the Pixley interpreter in Mini-Scheme's
    `init.scm` file and invoking it therein.  From this I conclude that,
    although I have not confirmed this is in a solid way by looking at the
    spec or anything, Pixley is also a strict subset of R4RS Scheme.

### 2.0 ###

*   Changed implementations to implement Pixley 2.0.
*   Bourne Shell scripts to run Pixley programs which are stored in individual
    files.  `pixley.sh` runs either a self-contained Pixley program from a
    single file, or evaluates a Pixley file to a function value and applies it
    to an S-expression stored in a second file.  `scheme.sh` does the same
    thing, but with Scheme, as a sanity-check.  By default these scripts use
    `plt-r5rs` for the Scheme interpreter, but that can be changed with an
    environment variable.

*   A P-Normalizer written in Pixley, probably the first non-trivial Pixley
    program to be written, aside from the Pixley interpreter itself.  P-Normal
    Pixley is a simplified version of Pixley where `let*` can only bind one
    identifer to one value and `cond` can only make one test, like Scheme's
    `if`.  This form is described more fully in the
    [Falderal literate test suite for the P-Normalizer][].

*   Test suites, written in [Falderal][], for both Pixley and the P-Normalizer.
    The original test suite written in Scheme, which runs successively deeper
    nested copies of the Pixley interpreter, is still included in the
    distribution.

*   A few other standalone Pixley examples, including `reverse.pix`,
    which reverses the given list.

### 2.0 revision 2012.0219 ###

*   The Bourne shell scripts `pixley.sh` and `scheme.sh` were replaced by a
    single script `tower.sh`.  The idea behind this script is that it lets
    you constuct a "tower of interpreters" from a sequence of text files
    which contain S-expressions.  The first such S-expression is interpreted
    as Scheme, and may evaluate to a function value; the second such will be
    interpreted by that function, and may evaluate to another function value,
    and so forth, until there is an S-expression that evaluates to something
    besides a function value (and that result will be printed to standard
    output and `tower.sh` will terminate.)

*   `tower.sh` officially supports three implementations of Scheme that can
    be used as the base interpreter: `plt-r5rs` from the Racket distribution,
    `tinyscheme`, and `miniscm` version 0.85p1 (from our fork of the project
    on GitHub.)  Support for Scheme implementations is (more or less)
    capability-based, so adding support for other implementations should not
    be difficult (especially if they are similar to the three already
    supported.)

*   The test suite was put into Falderal 0.6 format and now uses `tower.sh`
    to run each test case.  By default, it uses `plt-r5rs`, but can be told
    to use any of the Scheme implementations that `tower.sh` supports.
    (Note: there is currently a failure when running one of the tests on a
    Pixley interpreter on a Pixley interpreter on `miniscm` that I have yet
    to track down.)

*   To match the expectations of `tower.sh`, the Pixley self-interpreter was
    refactored to evaluate to a function value of one argument.  It was also
    simplified slightly, removing an unnecessary nested `cond`.

*   Various dialects of Pixley have been defined and described, and collected
    in the `dialect` directory of the distribution.  The dialects include
    Pifxley, which supports an `if` construct instead of `cond`; there is a
    Pixley interpreter written in Pifxley, and a Pifxley self-interpreter.
    There is also a dialect called Crabwell which allows values to be bound
    to, not just symbols, but arbitrary S-expressions.

*   A bug (a missing case) was fixed in the P-Normalizer.

*   The main Pixley documentation (what you're reading now) was converted
    to Markdown format.

*   Source code in the Pixley distribution was placed under a BSD-style
    license.

### 2.0 revision 2013.1024 ###

*   Funny story!  Remember when I said I was writing writing stuff in C to
    compile with DICE C under AmigaOS 1.3, and that what I decided to write
    was a Pixley interpreter in C?  Well, that implementation of Pixley,
    called `mignon`, has finally been included in the Pixley distribution.

*   Another implementation of Pixley, this time in Haskell and called `haney`,
    has also been included in the Pixley distribution.

*   The `tower.sh` script has been refactored, since honestly it was kind of
    grody.  The abstraction layer which tries to make different implementations
    of Scheme behave the same has been split off into `scheme-adapter.sh`,
    while the responsibility of `tower.sh` itself is only to build and run the
    tower of interpreters.  In addition to `plt-r5rs`, Mini-Scheme, and
    Tinyscheme, `scheme-adapter.sh` also supports the Husk Scheme interpreter.
    Finally, `scheme-adapter.sh` supports `mignon` and `haney` as well; even
    though they're not proper Scheme interpreters, they can be used as the
    base interpreter for a tower of Pixley interpreters.

*   The test suite has been modernized (for whatever "modern" means for
    Falderal) and enriched to handle testing these extra implementations.

### 2.0 revision 2015.0101 ###

(This also includes updates from revision 2014.0819 which I neglected to
list here previously.)

*   A new implementation of Pixley, in Javascript, which runs in a web browser
    which supports Web Workers.  As a bonus, it can depict the Pixley program
    as a series of nested, coloured rectangles.  You can see it online here:
    [Pixley installation at Cat's Eye Technologies][].

*   Wrappers to allow `pixley.scm` to be run under Scheme48 and the CHICKEN
    Scheme interpreter.

*   The test suite tries to find a reasonable Scheme implementation to run
    under.

*   Syntax for tests updated to Falderal 0.10.

*   `with-input-from-file` is an optional R5RS, so change the Scheme programs
    to not rely on it.

### 2.0 revision 2015.0723 ###

*   Small changes to the Javascript implementation.

### 2.0 revision 2017.1110 ###

*   Put all example programs as discrete files in the `eg/` directory.

*   Small changes to the Javascript implementation.

### 2.0 revision 2018.???? ###

*   Added a `build.seq` which details how to build `mignon` under
    AmigaDOS 1.3 using DICE C.
*   Added a `launch-pixley.js` file to the pixley.js demo, which creates
    a UI, etc.
*   Split this HISTORY file off from [The Pixley Programming Language][].

[The Pixley Programming Language]: doc/Pixley.markdown
[Falderal literate test suite for the P-Normalizer]: dialect/P-Normal.markdown
[Pixley installation at Cat's Eye Technologies]: http://catseye.tc/ix/Pixley
[Falderal]: http://catseye.tc/node/Falderal
