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
and values can be coerced into unexpected types without warning.

[Some parsers](https://hitchdev.com/strictyaml/why/implicit-typing-removed/)
have explicitly chosen to **not** be compliant with the spec
just so that users can have a sane experience editing files.

YAML is so complicated that there are literally paid
[educational courses](https://www.educative.io/courses/introduction-to-yaml)
on how to read and use it.

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

If you want the full story, read the [specification](SPECIFICATION.md)
(it is not very long).

A short example is worth more than short description.
This code snippet is marked as `dotenv`, since no voll syntax currently exists for GFM.
If you want a better example of highlighting,
see the vim syntax file in this repo.

```dotenv
# Commented lines start with a pound sign (AKA hash).
    # Leading whitespace on a line is not significant

# Blank lines are ignored

# Keys and values are separated by an equals sign
key = value

# Be default, everything after the equals sign until the next newline is the value, including *ALL* whitespace
key2 =                   value with lots of white space

# keys can be repeated. By default, new key declarations overrule older ones.
# This makes it trivial for tools to append lines to a config
# and know that their changes will be picked up
# (assuming another tool does not do the same thing later).
key = a new value overwrites the old value

# The spec allows for values to be parsed as JSON scalar values instead of raw values.
# This is optional. There are no "malformed values" by default.
json_string = "Hello string"
json_null = null
json_bool_true = true
json_bool_false = false
json_int = 123
json_float = 123.0

# Keys can use dots to indicate nesting.
# Advanced parsers can put this into a nested dictionary-like structure, mimicking JSON.
# Alternatively, you can just look up the raw key directly using the full key.
parent.child1 = true
parent.child2 = false

# Other than nested key structures,
# more complicated arrays and objects are not directly supported.
# But parsers can do whatever they want with values.
# Again, it is just raw keys and values at the end of the day.
json_array = ["Parsing", "a", "JSON", "array", "value", "is", "a", "bit", "confusing", "but", "you", "can", "do", "it"]

# There is no string concatenation in the official spec. You can only replace previous key/value pairs.
# However, the format is so simple, you can use your own imagination
# to implement a parser that does this for your specific application's needs.
# So long as your parser supports the default syntax and behavior,
# it is still considered a compliant implementation.
#
# For example, you could treat a plus sign after an equals sign as concatenation for strings.
cat_key = "Base string"
cat_key =+" can be append to with some imagination!"

# You could treat square brackets as appending JSON scalar values to an array.
ary_key =[]"one"
ary_key =[]"two"

# So long as you comply with the format <key> <equal sign> <value>,
# you can do whatever you want, really.
```

## License/Copyright/Copying

This specification and accompanying code are made available under the
[0BSD license](https://landley.net/toybox/license.html).
