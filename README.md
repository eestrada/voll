# VOLL

<a title="Original by Soebe, edited by Fashionslide [CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/)], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Bank_vole.jpg"><img width="512" alt="Bank vole" src="https://upload.wikimedia.org/wikipedia/commons/6/60/Bank_vole.jpg"></a>

The **V**ery **O**bvious **L**ine-delimited **L**anguage. To be used as a
config language (like JSON, YAML, or TOML, except simpler. Simpler is often better).

I once ran across a discussion thread
([on Google+](https://plus.google.com/+LinusTorvalds/posts/X2XVf9Q7MfV)) of
Linus Torvalds complaining about the unnecessary complexity of modern file
formats, specifically XML. The comments focused on that fact that even
line-delimited key=value pairs are often better than XML and JSON. It got me
thinking about simplifying a configuration language down to its simplest form.
The relatively recent creation of [TOML](https://en.wikipedia.org/wiki/TOML)
(another KISS language) inspired me further. And for yet further inspiration,
I have recently been working with many of the configuration languages of FreeBSD,
which are almost all based on line-delimited `key=value` pair style configuration.
How much can we reduce and still be useful? Can we write parsers in multiple
languages to help standardize the format? Can we make it so simple that people
can quickly write their own parsers and still expect them to deal with the
format(s) reasonably well?

I began to realize that even `key=value\n` pairs have confusing edgecases that
are not always well specified. For example, can the `key` have spaces in it? If
it has spaces, does it need to be surrounded in double quotes or some other
delimiting markup? What about hyphens, underscores, or other non-whitespace,
non-alphanumeric characters? What about nested keys? How do you deal with lists
of values? Do you allow for square brackets (`[]`) and commas(`,`) to
deliminate members of the list? Do you use a special format to add new members
on subsequent lines (e.g. `+=`) so that long lists are not painfully long by
being split across multiple lines? Does splitting across multiple lines defeat
the purpose of a line-delimited language? Does one just use POSIX shell syntax
for declaring environment variables? What about all of the programatic features
of POSIX shell that can be injected into the declaration of variables (e.g.
injecting values by referencing other variables, calling out to external
utilities, etc.)? In a language agnostic, cross platform syntax we would want
to eliminate those features, right? Or would some basic programmability would
be good?

As I pondered more, I realized that even a simple problem like this wasn't so
simple. Perhaps I can come upon a solution (or several co-existing solutions)
that will satisfy the needs of an incredibly simple, easy to parse,
well-defined, line-delimited configuration format. This code repo is an
exploration of this concept. Hopefully something useful comes out of it. :fingers_crossed:

## License/Copyright/Copying

This code is made available under the [UNLICENSE](https://unlicense.org/), a
public domain dedication with fallback [copyfree](http://copyfree.org/) license
terms for places where public domain is not usable.
