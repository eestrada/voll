# VOLL Specification

## Vocabulary

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL"
in this document are to be interpreted as
described in [BCP 14](https://www.rfc-editor.org/info/bcp14)
\[[RFC2119](https://www.rfc-editor.org/rfc/rfc2119)\]
\[[RFC8174](https://www.rfc-editor.org/rfc/rfc8174)\]
when, and only when, they appear in all capitals, as shown here.

There are three entities or personas referred to:
implementations, applications, and users.

- Implementations should be understood to be libraries and tools to parse, print,
  and/or manipulate files of the format specified in this document.
- Applications should be understood to be programs
  or tools which use the previously defined
  implementations to access files of this format for configuration purposes;
  sometimes an implementation and application will be one and the same.
- User should be understood to be an end user
  who utilizes the file format
  to configure an application as previously defined.

## Requirements

### Format Requirements

Files and text streams MUST be encoded in UTF-8.
Text streams and files SHOULD NOT include a byte order mark.

All configuration values are line delimited;
keys and values SHALL NOT cross multiple lines.
There is no such thing as a multiline string.

Configuration values are of the format `<key>=<value>` followed by a newline.
There MAY be whitespace between the start of the line and the key:
its presence is ignored and it is not part of the key.
There MAY be whitespace between the key and the equals sign:
its presence is ignored and it is not part of the key.
Whitespace characters following the equals sign
that precede non-whitespace characters
MUST be included in the parsed value string.
Trailing whitespace following any non-whitespace characters,
but preceding the newline
MUST be included in the parsed value string.

In other words, all characters following the first equals sign,
but before the newline
are included in the parsed value.

Keys MUST adhere to the following regex:

```regex
[a-zA-Z][a-zA-Z0-9_.]*
```

In written language, this is an ASCII letter for the first
character, and all subsequent characters must be ASCII alphanumeric values
or underscore (`_`) or dot (`.` AKA "period").
A key MUST contain at least one character.
There is no upper limit to the length of a key.

Keys MUST be considered case sensitive by default.

Values after the equals sign may hold any UTF-8 code points
except newline (`\n`) and NUL (`\0`).
This includes double quotation marks (`"`) and single quotation marks (`'`);
these values MUST NOT be automatically stripped out.

In short, implementations MUST NOT treat any value characters specially other
than newline or NUL.

All values are always strings.
Values MUST NOT be implicitly cast to another type.

Line comments are allowed.
They are ignored.
Lines where the first non-whitespace character is a hash (`#`)
are considered a comment line and are ignored.
Comments SHALL NOT trail behind a value on a line;
comments MUST be specified alone on a line.
Any hash characters in a value MUST be included as part of the value;
these do not indicate a comment.

Blank lines containing only whitespace are allowed.
They are ignored.

Keys MAY be repeated multiple times in a single file/stream.
Later values MUST overwrite previous values.
This has the effect that automated tools can blindly append to a file
and know that the new value will take precedence over any prior declarations.

#### Value Arrays

The array specification has not been finalized.
Below are some thoughts on the subject.

Voll arrays thoughts:

- I can't figure out an easy way to stream it without backtracking.
  You could begin by creating an array if you only find number strings as keys,
  and then change back to a JSON object once a non-number key is encountered.
  Regardless, the logic gets a bit difficult.
- I think the simplest is,
  after all parsing into a JSON-like object is complete,
  walk the hierarchy
  and find any objects where all keys can be interpreted
  as decimal integer numbers
  (numbers padded with leading zeros are acceptable).
  Once this situation is encountered,
  first sort alphabetically,
  then sort numerically.
  The second sort should be a stable sort so as not to lose relative ordering.
  The first sort need not be a stable sort
  since there are no repeated keys possible anyway.
  Then dedupe,
  favoring the first(?) number found.
  Finally, build an array with the deduped sorted values.
  Replace the object with the array.
  This can be done top down.
- The idea behind which is sorted first:
  - If the user has values with leading zeros for padding,
    should those be chosen? They would sort first.
    Or what if automated tools append a value to the config and don't pad with zeros,
    should those be chosen?
    They would be chosen as the second value.
    Repeat values of either type with identical keys
    would already have been deduped in the initial hashmap creation.

#### Concatenating values

VOLL does not support string concatenation.
This would go against the idempotent,
"last-value-wins" approach taken in the specification.

### Implementation Requirements

All implementations are REQUIRED to provide an interface
to look up values using the entire, unmodified key.
This MUST default to being case sensitive.

Implementations MAY allow for case-insensitive direct key lookup.
This MAY be implemented as a separate procedure
or as an optional parameter to the primary procedure.
Either way, it MUST NOT be the primary form of lookup.

Implementations MAY provide an interface to look up values in a nested fashion.

Implementations that provide a full nested interface
MUST allow for the possibility that both a value
*and* nested children can be assigned to a single key.
An example interface in Python might be:

```python
import voll

cfg_str = """
p=v1
p.c1=v2
p.c2=v3
"""

cfg = voll.loads(cfg_str)

parent = cgf.get('p')

print(parent.value) # 'v1'
print(list(parent.children.keys())) # ['c1', 'c2']
```

Implementations MAY provide a simplified nested interface
that ignores assigned values,
but to do so it MUST clearly document
that the interface can/will throw away config data.

Implementations that supply a simplified nested interface
are NOT REQUIRED to supply a full nested interface.
It is only REQUIRED that the implementation clearly communicate whether
a particular interfaces is full or simplified.

Implementations MUST collapse adjacent dots down to a single dot
for nested interfaces.
Adjacent dots are assumed to be a user error
that is silently adjusted for.

Implementations MUST strip all trailing dots for nested interfaces.
Trailing dots are assumed to be a user error
that is silently adjusted for.

Implementations MAY error on adjacent dots upon user request.
This error MAY be at parse time.
If an implementation does allow for erroring on adjacent dots,
this MUST NOT be the default mode of operation.

Implementations MAY error on trailing dots upon user request.
This error MAY be at parse time.
If an implementation does allow for erroring on trailing dots,
this MUST NOT be the default mode of operation.

Implementations MUST NOT automatically collapse adjacent dots
for the direct key lookup interface.

Implementations MUST NOT automatically strip trailing dots
for the direct key lookup interface.

Implementations MAY allow an option
to collapse adjacent dots for direct key lookup.
This option MUST default to off (i.e. no collapsing by default).
This option, if present SHOULD NOT be a parse time option.
All keys SHOULD be parsed and loaded unmodified.
The option SHOULD only be used during lookup time.

Implementations MAY allow an option
to strip trailing dots for direct key lookup.
This option MUST default to off (i.e. no stripping by default).
This option, if present SHOULD NOT be a parse time option.
All keys SHOULD be parsed and loaded unmodified.
The option SHOULD only be used during lookup time.

Implementations MAY internally convert values
to some type other than strings upon parsing.
However, if values are converted, the implementation MUST be
able to reconstruct the same value exactly as it was parsed.
This includes quotation marks
(i.e. surrounding quotations marks MUST NOT be automatically stripped from values).

The best example of this is positive base 10 integers with no leading zeros,
as well as the value zero (`0`);
these can safely be converted back and forth between integers
and strings with no loss of precision.
Other possible examples values are welcome.

Thus, these could be automatically, and silently,
converted between an integer and string:

```sh
some_number_config=10
another_number_config=0
```

These could not:

```sh
# Keep these as strings
ambiguous_config="10"
another_ambiguous_config=+10
yet_another_ambiguous_config=-0
```

Even if this silent conversion takes place internally,
the primary external interface to access all values MUST return a string.

Implementations MAY offer convenience methods to access values
as types other than strings.
If a value cannot be unambiguously converted to the requested type,
the implementation MUST raise an exception
or return an error value
or return a sentinel value indicating failure,
such as `null`, `nil`, `None`, etc.

It is NOT RECOMMENDED to return a simple sentinel value
like a `null`,
as this does not communicate much
(the failure may be due to the value not being present in the first place).
Whenever possible,
it is RECOMMENDED to return/raise a catchable error or exception.

If an implementation offers convenience procedures to access values as booleans,
it MUST only consider the following values as booleans
(all other values MUST NOT be implicitly converted
and MUST cause an error to be returned,
in accordance with the prior paragraph):
`true`, `false`, `TRUE`, `FALSE`, `on`, `off`, `ON`, `OFF`, `0`, `1`.
Surrounding these values with quote marks, parentheses,
or any other characters
will cause them to fail to parse as booleans.

An implementation MAY offer other boolean conversion methods
with different conditions,
but in these cases the implementation MUST communicate
how this differs from the default boolean conversion procedures.
For example,
a procedure may be supplied to only parse the values `true` and `false` as booleans,
which are the only allowable boolean values in JSON.
Such a procedure should be clearly named such as `parseAsJsonBoolean`.
An implementation may instead use an optional parameter
on the main boolean conversion procedure to enable this behavior.

Implementations MUST NOT allow the convenience procedures
to instead return a default value when the implementation fails to parse a value
as the requested type.
This is because it is ambiguous whether the failure happened because
the value was not present at all
or happened because the value was present
but could not be parsed to the requested type.

Implementations MAY allow conversion procedures to strip off surrounding
whitespace and quotation marks prior to conversion.
This is OPTIONAL,
and if present MUST NOT be the default mode of operation of these procedures.
The caller of the procedure must explicitly request the behavior
(i.e. this functionality must be opt-in, not opt-out).
Any whitespace within quotation marks MUST be preserved.
The functionality MUST only strip off one set of quotation marks.
The quotation marks stripped MUST match.
The implementation MAY allow the user
to specify which type of quotation marks to strip
or the implementation MAY choose the type automatically
or the implementation MAY support both modes (automatic or explicit).
In any case, the behavior MUST be communicated/documented.
If no surrounding whitespace or quotation marks are present,
this SHOULD silently succeed without raising an error.

The same quote stripping behavior described in the previous paragraph
MAY be implemented for the default string retrieval procedures(s) as well.
Again, this MUST NOT be the default mode of retrieval.

Implementations MAY allow procedures
that return the value in its original string form
to optionally allow the caller to provide a default fallback value.
This is because this is less ambiguous.
There is only one possible error condition:
the value was not present.

Implementations MAY also allow procedures that return the original string value
to return a `null` type value when the value is not present.
Again, this is because it is less ambiguous than in the case of conversion.

Implementations SHOULD treat an empty value
(i.e. there are no characters between the equals sign and the newline)
as an empty string.
Languages and frameworks that do not differentiate between the empty string
and a `null` type value may return a `null`.
However, this is NOT RECOMMENDED, and the implementation should find another
way to implement this that clearly communicates the difference.
If an implementation has relaxed this requirement,
it MUST communicate this in the documentation for the procedure.

An implementation that cannot differentiate between the empty string and `null`
SHOULD offer a procedure to check for the presence of a particular key.

It is OPTIONAL for an implementation to support writing out the file format,
or support modifying existing files in place.
To be considered compliant,
an implementation only MUST support reading/parsing of the format.

An implementation MAY offer a convenience feature to convert a file/stream
to another format, such as JSON or YAML,
or to parse the file in such a way as to easily convert it later to another format.
This is NOT REQUIRED functionality.
So long as the implementation also implements the requirements of this specification,
it is considered a compliant implementation.
More thought is needed around this. This is not finalized.

An implementation MAY offer a procedure to parse values as JSON values.
If such a procedure is implemented,
it MUST strictly adhere to JSON syntax for the values.
For example, strings MUST be surrounded with double quotes,
and all other unquoted values must unambiguously map
to valid literals for other non-string JSON types.
In other words, YAML style implicit conversions MUST NOT ever happen.
If values cannot be properly parsed,
then parsing should halt and an error MUST be returned.

If such a procedure is supplied,
it MUST NOT allow for excess whitespace around values.
The syntax parsing around the key and the first equals sign
MUST NOT change in this mode.
The only thing that changes is how values are interpreted.

Such a procedure is NOT REQUIRED to returned this parsed result in the default
datatype or structure used to return regular parsing results.
For example, in Python this may just return a plain old nested Python dict.
This could then be written out to JSON using the builtin JSON module.

### Application Requirements

Applications SHOULD NOT specify/require any configuration values
with two dots directly next to each other.
For example `config1..config2=value`.
This is confusing.
Adjacent dots are silently ignored by implementations for nested interfaces,
because they are assumed to be a user error.
Implementations may silently collapse adjacent dots under other circumstances.
Thus, do not make adjacent dots part of your application config spec.

Applications SHOULD NOT specify/require nested configuration values
where the parent also has a value assigned.
For example:

```sh
# We want to enable/disable some nested child features.
parent.child1=false
parent.child2=true

# This key now has a value assigned AND children nested beneath it.
# This is potentially confusing.
parent=true
```

In a VOLL to JSON transformation,
the value assigned to the parent will be silently dropped.

This would be better defined this way:

```sh
parent.child1.enabled=false
parent.child2.enabled=true
parent.enabled=true

# or

parent.child1=false
parent.child2=true
parent.enabled=true
```

### User Recommendations

Because VOLL uses the hash character for specifying comments,
VOLL files can easily include a shebang (AKA hashbang)
at the beginning of the file.
This, along with setting the execute flag on the file
will allow invoking the VOLL config with an external script or application.

For example:

```sh
#!/usr/bin/env my_interpreter --config_file

setting1=true
setting2=false
```

This way, multiple invocations of an interpreter or tool
can be configured differently with different VOLL files
and be invoked easily.

See [the wikipedia article on shebangs](<https://en.wikipedia.org/wiki/Shebang_(Unix)>)
for more details.

### References

- [ASCII character reference along with Unicode names](https://github.com/eestrada/lookup-computer/blob/master/ascii.csv)
