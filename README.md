# hdl_string_format

[![Build Status](https://travis-ci.org/suoto/hdl_string_format.svg?branch=master)](https://travis-ci.org/suoto/hdl_string_format)
[![.](https://ga-beacon.appspot.com/UA-68153177-5/README.md?pixel)](https://github.com/suoto/hdl_string_format)

hdl_string_format is based on Easics' [PCK_FIO][pck_fio] and aims to provide
C-like string formatting.

## Usage

Please note that the original PCK_FIO manual can be found at [Easics'
site][pck_fio_manual].

### fprint

The `fprint` procedure writes a formatted string to a `line`:

```vhdl
variable L : line;
fprint(L, "It's %d now", fo(2016));

report L.all;
```

Should print

```
It's 2016 now
```

### sformat

Very similar to `fprint`, only that it returns a string. The example above
would look like

```vhdl
report sformat("It's %d now", fo(2016));
```

### printf

Like `fprint` and `sformat`, but prints (`report`s) directly to console:

```vhdl
printf("It's %d now", fo(2016));
```

### Format specifiers

The general format of a format specifier is:

```
%[-][n]c
```

The optional - sign specifies left justified output; default is right justified.

The optional number n specifies a field width. If it is not specified, fprint
does something reasonable.

**c** is the conversion specifier. Currently the following conversion specifiers
are supported:

* **r**: Reasonable output

  Prints the "most reasonable" representation e.g. hex for unsigned, signed and
  other bit-like vectors (not preferred for integers)

* **b**: Bit-oriented output
* **d**: Decimal output
* **s**: string output (e.g. in combination with 'IMAGE for enum types)
* **q**: "qualified" string output (shows internal representation from fo)
* **{}**: Iteration operator, used as follows:

  ```
  %n{<format-string>}
  ```

  In this case, n is the iteration count and is mandatory. Iteration can be nested.
  Special characters

To print a double quote, use `""` in the format string (VHDL convention). To
print the special characters, `\`, and `%`, escape them with `\`. To prevent `{`
and `}` from being interpreted as opening and closing brackets in iteration
strings, escape them with `\`.

## Copyright

1995, 2001 by Jan Decaluwe/Easics NV (under the name PCK_FIO)

2016 by Andre Souto (suoto)

## License

This software is licensed under the [GPL v2 license][gpl].

[pck_fio]: https://www.easics.com/products/freesics
[pck_fio_manual]: https://www.easics.com/pckfio-revision-20027-manual
[gpl]: https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

