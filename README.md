# VOLL

## The **V**ery **O**bvious **L**ine-delimited **L**anguage.

[![Original by Soebe, edited by Fashionslide [CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/)], via Wikimedia Commons](https://upload.wikimedia.org/wikipedia/commons/6/60/Bank_vole.jpg "Original by Soebe, edited by Fashionslide [CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/)], via Wikimedia Commons")](https://commons.wikimedia.org/wiki/File:Bank_vole.jpg)

To be used as a config language
like JSON, YAML, or TOML, except simpler.
Simpler is better.

VOLL is pronounced like [vole](https://en.wikipedia.org/wiki/Vole)
(the North America field mouse).

Many years ago, I came across a discussion thread
(~~[on Google+](https://plus.google.com/+LinusTorvalds/posts/X2XVf9Q7MfV "like so many other Google products Google+ is now dead, and so this link is dead too")~~
dead link)
of Linus Torvalds complaining
about the unnecessary complexity of modern file formats,
specifically XML.
The comments focused on the fact
that simple line-delimited key=value pairs are often better than XML and JSON.
I agree.

It got me thinking about reducing a configuration language
down to its simplest form.
The (relatively) recently created [TOML](https://en.wikipedia.org/wiki/TOML)
inspired the name.

This repo holds the specification of such a reduced configuration language: VOLL.
To date, I do not know of a portable,
well defined,
widely available configuration file format that is line delimited.
`dotenv` exists, but it is not strictly specified and implementations differ.
FreeBSD configuration files have a fairly standard format that is similar to VOLL
(this was actually one of the inspirations for VOLL),
but other than the FreeBSD implementation that parses them,
I do not know if there is a specification for them.
Voll is meant to be tightly specified enough
to be easily portable between implementations and systems, like JSON,
but also simple enough that someone with only a text editor and no tooling
can be fairly certain they are formatting the file correctly.

![Just use regex parseable line-delimited key/value pairs](./static/config_bell_curve.jpg "Just use regex parseable line-delimited key/value pairs")

This repo also holds a reference implementation in POSIX shell.
The rationale is: if it cannot be simply implemented in plain old shell
using standard POSIX utilities
then the language is too complicated.

The guiding principle is
"Software is not done when there is nothing left to add,
but when there is nothing left to take away."
VOLL is meant to be the simplest configuration language possible
while still being useful.

## Why not XYZ?

### Why not TOML?

TOML isn't actually very obvious or simple.
It is meant to supplant YAML
and it does that okay in some ways.
But in other ways it is hardly an improvement at all.

For example, it still offers several ways to specify arrays
some of which are not very obvious (ala YAML).
In fact, there are two or three ways to specify nearly everything;
this is a terrible idea.
For a configuration format there should be one way to specify things.
Less is more here.

Also, it includes an implicitly parsed datetime format,
which is a footgun.

### Why not YAML?

YAML may be the worst configuration language ever foisted upon us all.
Its semantics are not clear
and many values get coerced into unexpected types without warning.

[Some parsers](https://hitchdev.com/strictyaml/why/implicit-typing-removed/)
have explicitly chosen to **not** be compliant with the spec
just so that users can have a sane experience editing files.

Don't choose YAML.

### Why not INI?

INI is simple, but has no standard specification.
Also, it isn't line delimited so a more intelligent parser is needed.

### Why not dotenv?

Simple, but no standard specification.
Also, it only supports basic key=value data shape, not nested structures.

### Why not JSON?

No comments, no trailing commas,
requires a more advanced parser to retrieve values.

### Why not JSON5?

Has comments and trailing commas (hurray!),
but requires an even *more* advanced parser than even plain old JSON.

### Are you just a curmudgeon about file formats?

Yes.

## Tell me more!

Read the [specification](SPECIFICATION.md).

## License/Copyright/Copying

This code is made available under the [0BSD license](https://landley.net/toybox/license.html).
