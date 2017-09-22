# Calvin

**TOO EARLY TO BE USEFUL, CHECK BACK LATER.**

## Overview

Future home to a collection of RFC compliant parsers for iCalendar and other
related calendar/event standards. Parsers will use the original ABNF
definitions provided in their specifications when available.

* [RFC5545: Internet Calendaring and Scheduling Core Object Specification (iCalendar)](https://tools.ietf.org/html/rfc5545)
* [RFC5546: iCalendar Transport-Independent Interoperability Protocol (iTIP)](https://tools.ietf.org/html/rfc5546)
* [RFC6868: Parameter Value Encoding in iCalendar and vCard](https://tools.ietf.org/html/rfc6868)
* [RFC7529: Non-Gregorian Recurrence Rules in the Internet Calendaring and Scheduling Core Object Specification (iCalendar)](https://tools.ietf.org/html/rfc7529)
* [RFC7953: Calendar Availability](https://tools.ietf.org/html/rfc7953)
* [RFC7986: New Properties for iCalendar](https://tools.ietf.org/html/rfc7986)

Right now the project is being used as a testbed for developing an ABNF
parser that is friendly for the developer to build upon. Eventually hooks
will be developed for defining rules on how to flatten tokens and send
messages to a GenServer-based domain-specific parser that can build up
the final resulting objects. Knowing how tokens should be flattened when
reading a specification's ABNF may also allow for optimizing the AST for
performance that is closer to a customized parser.

Hopefully what is learned from developing an ABNF parser from scratch will
feed back into design changes for one of the existing parsers already being
developed elsewhere to reduce duplication.


## Related Hex Projects

### ABNF Parsers / Tokenizers

There are currently two ABNF parsers available on Hex; this project may
eventually standardize on using once of them once they have the ability to
provide more descriptive parse errors and debugging support.

* [abnf](https://hex.pm/packages/abnf)
* [ex_abnf](https://hex.pm/packages/ex_abnf)

### iCalendar

Neither of the available iCalendar parsers are RFC compliant, and both have
limitations that were run into immediately; neither able to parse multi-line
descriptions. Rather than patch up an existing partial implementation, this
project aims to focus on taking advantage of the ABNF grammar that is already
defined in the RFC5445 stanard to generate a parser. The parser may eventually
become the backbone of one of the existing iCalenar libraries.

* [ex_ical](https://hex.pm/packages/ex_ical)
* [icalendar](https://hex.pm/packages/icalendar)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `calvin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calvin, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/calvin](https://hexdocs.pm/calvin).

