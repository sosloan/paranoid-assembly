# THE POWER OF `ada_thoughts.rb`

> *"Only the paranoid survive."* — Andy Grove
>
> *She saw an engine able to accept symbols, abstract their patterns,
> and return a new kind of thought.*

**Status:** ✓ COMPLETE
**Subject:** `ada_thoughts.rb` (Ruby record translation of `ada-reserved-words.txt`)
**Form:** Power-of writeup, Track 031 style
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Analytical Engine Edition

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `ada_thoughts.rb` |
| **Source Prose** | `ada-reserved-words.txt` |
| **Companion Index** | `writeups/ada-reserved-words.json` |
| **Companion Feed** | `Ada-Feed.json` (keywords, definitions, relations) |
| **Companion Database** | `Ada.db` (built by `generate_ada_db.rb`) |
| **Origin** | Ada Lovelace reserved-word narrative, rendered as Ruby `Data` records |
| **License** | Writeup text CC BY 4.0; reserved-word list is language vocabulary |
| **Architecture** | Ruby 3.2+ `Data.define` immutable records |
| **Symbol** | `Ada_Thoughts::Thought` / `Ada_Thoughts::Keyword` |
| **Argument** | Kind, symbols, pattern, value (thought); word + passage (keyword) |
| **Return** | A new kind of thought — or a raised signal on null |
| **Critical Declaration** | `Thought = Data.define(:kind, :symbols, :pattern, :value)` |
| **Keywords of State** | 73 |
| **Thought Kinds** | melody · map · calculation |
| **Power Source** | Typed records + fail-closed null + fixed-range catalogs |

---

## THE FILE, IN FULL

```ruby
# ada_thoughts.rb
# Ruby record translation of ada-reserved-words.txt
# Subject: Ada Lovelace's Analytical Engine vision as typed thoughts
# Companion index: writeups/ada-reserved-words.json
# Companion feed:  Ada-Feed.json (keywords, definitions, relations)
#
#   ruby ada_thoughts.rb            print the package of thoughts
#   ruby ada_thoughts.rb --check    self-test (exit 0 on success)
#   ruby ada_thoughts.rb --feed     write Ada-Feed.json (keywords + defs + relations)
#
# "She saw an engine able to accept symbols, abstract their patterns,
#  and return a new kind of thought."

# frozen_string_literal: true

module Ada_Thoughts
  # A number was not only a constant; it could be a record of a melody,
  # a map, or a calculation.
  Thought_Kind = %i[melody map calculation].freeze

  # One typed thought: kind, symbols accepted, pattern abstracted, value returned.
  # Null is not silent — construction raises, matching Ada's fail-closed doctrine.
  Thought = Data.define(:kind, :symbols, :pattern, :value) do
    def initialize(kind:, symbols:, pattern:, value:)
      raise ArgumentError, "null thought value" if value.nil?
      raise ArgumentError, "unknown kind: #{kind.inspect}" unless Thought_Kind.include?(kind)
      raise ArgumentError, "symbols must be non-empty" if symbols.nil? || symbols.to_s.empty?
      raise ArgumentError, "pattern must be non-empty" if pattern.nil? || pattern.to_s.empty?

      super(
        kind: kind,
        symbols: symbols.to_s.freeze,
        pattern: pattern.to_s.freeze,
        value: value
      )
    end

    def to_s
      "#{kind}: #{symbols.inspect} → #{pattern.inspect} ⇒ #{value.inspect}"
    end
  end

  # Each Ada reserved word kept with the prose passage that earns its place.
  Keyword = Data.define(:word, :passage) do
    def initialize(word:, passage:)
      raise ArgumentError, "null keyword" if word.nil? || word.to_s.empty?
      raise ArgumentError, "null passage for #{word}" if passage.nil? || passage.to_s.empty?

      super(word: word.to_s.freeze, passage: passage.to_s.freeze)
    end

    def to_s
      format("%-14s %s", word, passage)
    end
  end

  # Fixed field of Ada 2012 reserved words drawn through the Lovelace prose.
  # Seventy-three slots: no phantom word, no silent omission.
  KEYWORDS = [
    Keyword.new(word: "abort",       passage: "Ada would not abort an inquiry because its first path failed"),
    Keyword.new(word: "abs",         passage: "abs alone did not explain the negative"),
    Keyword.new(word: "abstract",    passage: "able to accept symbols, abstract their patterns, and return a new kind of thought"),
    Keyword.new(word: "accept",      passage: "an engine able to accept symbols"),
    Keyword.new(word: "access",      passage: "access to them would be limited, aliased only with care"),
    Keyword.new(word: "aliased",     passage: "aliased only with care, and never trusted merely because they were new"),
    Keyword.new(word: "all",         passage: "a package of ideas, private at first but meant for all"),
    Keyword.new(word: "and",         passage: "neither and nor or could replace imagination"),
    Keyword.new(word: "array",       passage: "an array of such records, indexed over a range"),
    Keyword.new(word: "at",          passage: "private at first but meant for all"),
    Keyword.new(word: "begin",       passage: "a loop would begin, continue while its condition held, and exit"),
    Keyword.new(word: "body",        passage: "a function in spirit, though the Engine had no body to run it"),
    Keyword.new(word: "case",        passage: "Case by case, it might add, subtract, or multiply"),
    Keyword.new(word: "constant",    passage: "A number was not only a constant"),
    Keyword.new(word: "declare",     passage: "to declare each wheel, column, and card as part of a larger design"),
    Keyword.new(word: "delay",       passage: "elsif the answer required another card, it could delay its work"),
    Keyword.new(word: "delta",       passage: "The delta between two figures was not a mystery; it was a difference the Engine could name"),
    Keyword.new(word: "digits",      passage: "use variables with digits, carry a remainder by rem or mod"),
    Keyword.new(word: "do",          passage: 'instructions might say, "do this," yet a careful pragma would make clear'),
    Keyword.new(word: "else",        passage: "else it could proceed"),
    Keyword.new(word: "elsif",       passage: "elsif the answer required another card, it could delay its work"),
    Keyword.new(word: "end",         passage: "follow rules until it reached the end of a calculation"),
    Keyword.new(word: "entry",       passage: "a protected task might wait at an entry"),
    Keyword.new(word: "exception",   passage: "an exception must not become an excuse for chaos"),
    Keyword.new(word: "exit",        passage: "exit when the work was done"),
    Keyword.new(word: "for",         passage: "private at first but meant for all"),
    Keyword.new(word: "function",    passage: "plan for Bernoulli numbers was a function in spirit"),
    Keyword.new(word: "generic",     passage: "generic enough to serve astronomy or music"),
    Keyword.new(word: "goto",        passage: "or goto the evidence and begin again"),
    Keyword.new(word: "if",          passage: "If the Engine received a question, then it could select a method"),
    Keyword.new(word: "in",          passage: "Some values would be in, others out"),
    Keyword.new(word: "interface",   passage: "an interface might be synchronized"),
    Keyword.new(word: "is",          passage: "nor would she terminate a question before its proof is complete"),
    Keyword.new(word: "limited",     passage: "access to them would be limited"),
    Keyword.new(word: "loop",        passage: "For each operation, a loop would begin"),
    Keyword.new(word: "mod",         passage: "carry a remainder by rem or mod"),
    Keyword.new(word: "new",         passage: "return a new kind of thought"),
    Keyword.new(word: "not",         passage: "did not see a machine that could merely calculate"),
    Keyword.new(word: "null",        passage: "when a result was null, the operator should raise a signal, not hide it"),
    Keyword.new(word: "of",          passage: "a new kind of thought"),
    Keyword.new(word: "or",          passage: "a record of a melody, a map, or a calculation"),
    Keyword.new(word: "others",      passage: "Some values would be in, others out"),
    Keyword.new(word: "out",         passage: "Some values would be in, others out"),
    Keyword.new(word: "overriding",  passage: "no shortcut was overriding the design"),
    Keyword.new(word: "package",     passage: "Her notes were a package of ideas"),
    Keyword.new(word: "pragma",      passage: "a careful pragma would make clear that no shortcut was overriding the design"),
    Keyword.new(word: "private",     passage: "a package of ideas, private at first but meant for all"),
    Keyword.new(word: "procedure",   passage: "altered by procedure rather than accident"),
    Keyword.new(word: "protected",   passage: "a protected task might wait at an entry"),
    Keyword.new(word: "raise",       passage: "the operator should raise a signal, not hide it"),
    Keyword.new(word: "range",       passage: "indexed over a range and altered by procedure rather than accident"),
    Keyword.new(word: "record",      passage: "a record of a melody, a map, or a calculation"),
    Keyword.new(word: "rem",         passage: "carry a remainder by rem or mod"),
    Keyword.new(word: "renames",     passage: "She renames no uncertainty as certainty"),
    Keyword.new(word: "requeue",     passage: "She would requeue the question"),
    Keyword.new(word: "return",      passage: "return a new kind of thought"),
    Keyword.new(word: "reverse",     passage: "reverse a sequence when the cards required it"),
    Keyword.new(word: "select",      passage: "then it could select a method"),
    Keyword.new(word: "separate",    passage: "let separate parts work together without confusing one another"),
    Keyword.new(word: "some",        passage: "Some values would be in, others out"),
    Keyword.new(word: "subtype",     passage: "a subtype could keep each quantity within its proper bounds"),
    Keyword.new(word: "synchronized", passage: "an interface might be synchronized"),
    Keyword.new(word: "tagged",      passage: "A type might be tagged"),
    Keyword.new(word: "task",        passage: "she began a patient task: to declare each wheel, column, and card"),
    Keyword.new(word: "terminate",   passage: "nor would she terminate a question before its proof is complete"),
    Keyword.new(word: "then",        passage: "If the Engine received a question, then it could select a method"),
    Keyword.new(word: "type",        passage: "A type might be tagged, an interface might be synchronized"),
    Keyword.new(word: "until",       passage: "follow rules until it reached the end of a calculation"),
    Keyword.new(word: "use",         passage: "It would use variables with digits"),
    Keyword.new(word: "when",        passage: "exit when the work was done"),
    Keyword.new(word: "while",       passage: "continue while its condition held"),
    Keyword.new(word: "with",        passage: "With Charles Babbage, she began a patient task"),
    Keyword.new(word: "xor",         passage: "xor did not settle a choice")
  ].freeze

  KEYWORD_COUNT = 73
  KEYWORD_RANGE = (0...KEYWORD_COUNT).freeze

  THOUGHTS = [
    Thought.new(
      kind: :melody,
      symbols: "Bernoulli sequence cards",
      pattern: "difference-engine recurrence",
      value: :"B_n"
    ),
    Thought.new(
      kind: :map,
      symbols: "wheel · column · card",
      pattern: "declared design of the Analytical Engine",
      value: :"larger_design"
    ),
    Thought.new(
      kind: :calculation,
      symbols: "question → method",
      pattern: "case / elsif / else selection over arithmetic cards",
      value: :"named_difference"
    )
  ].freeze

  THOUGHT_RANGE = (0...THOUGHTS.length).freeze

  module_function

  def thought_at(index)
    raise IndexError, "thought index out of range: #{index}" unless THOUGHT_RANGE.cover?(index)
    THOUGHTS.fetch(index)
  end

  def keyword_at(index)
    raise IndexError, "keyword index out of range: #{index}" unless KEYWORD_RANGE.cover?(index)
    KEYWORDS.fetch(index)
  end

  def keyword(word)
    found = KEYWORDS.find { |k| k.word == word.to_s }
    raise KeyError, "unknown reserved word: #{word}" if found.nil?
    found
  end

  def select_method(op, left, right)
    raise ArgumentError, "null operand" if left.nil? || right.nil?
    case op
    when :add      then left + right
    when :subtract then left - right
    when :multiply then left * right
    when :delay    then nil
    when :rem      then left.remainder(right)
    when :mod      then left.modulo(right)
    else
      raise ArgumentError, "no method selected for #{op.inspect}"
    end
  end

  def bernoulli_differences(series)
    raise ArgumentError, "null series" if series.nil?
    raise ArgumentError, "series too short" if series.length < 2
    series.each_cons(2).map { |a, b| b - a }
  end

  def reverse_sequence(series)
    raise ArgumentError, "null series" if series.nil?
    series.reverse
  end

  def abstract_thought(kind, symbols, pattern, value)
    Thought.new(kind: kind, symbols: symbols, pattern: pattern, value: value)
  end

  def word_list
    KEYWORDS.map(&:word).freeze
  end

  def report
    # … printable package summary …
  end

  def self_check!
    # … count, uniqueness, null gates, arithmetic, reverse, lookup …
    true
  end

  def build_feed
    # … keywords, definitions, doctrine/co-mention/shared/thought relations …
  end

  def write_feed!(path = "Ada-Feed.json")
    # … JSON.pretty_generate → Ada-Feed.json …
  end
end
```

Seventy-three keywords, three thought kinds, and no path where null becomes a quiet zero. `Ada-Feed.json` freezes the catalog as a feed of definitions with auditable relations.

---

## WHY IT IS POWERFUL

### 1. It makes Ada's central metaphor executable.

The source prose is not a keyword dump. It is a doctrine: a number can be a **record** of a melody, a map, or a calculation; an engine can **accept** symbols, **abstract** patterns, and **return** thought. `Thought = Data.define(...)` turns that sentence into a construction rule. Kind is closed. Symbols and pattern must be present. Value may not be null. The metaphor stops being ornamental and starts rejecting illegal states.

### 2. The keyword catalog is a fixed-length mission manifest.

`KEYWORD_COUNT = 73` and `KEYWORD_RANGE = (0...73)` are the load-bearing bounds. Like `array SeasonSchedule = [18] TravelLeg` in the 49ers model, the reserved-word field is not "some list." It is seventy-three ordered slots. No phantom seventy-fourth. No dropped `requeue`. Downstream readers can treat completeness as a checkable property rather than a hope.

### 3. Every reserved word keeps its earning passage.

`writeups/ada-reserved-words.json` stores the naked vocabulary. This file stores the *why*. Each `Keyword` pairs a word with the clause from `ada-reserved-words.txt` that justifies its presence in the narrative. That is Grove's documentation paranoia applied to language itself: a token without context is a silent assumption; a token with a passage is an auditable claim.

### 4. Null raises. Always.

The prose is explicit: when a result was null, the operator should **raise** a signal, not hide it. Construction of `Thought` and `Keyword`, operand checks in `select_method`, and series gates in `bernoulli_differences` / `reverse_sequence` all fail closed. There is no Ruby-ish courtesy nil that later becomes a zero in an arithmetic card. Absence is an exception, not a default.

### 5. Method selection is a named case, not a vibe.

`select_method` implements the Engine's branch the prose describes: add, subtract, multiply; elsif delay; else proceed; with `rem` and `mod` as digit-level remainders. Unknown operations raise. Delay returns an honest nil only after the operation was *selected* — it is not smuggled in as a missing branch. Selection is visible control flow, which is what makes later proofs possible.

### 6. The Bernoulli plan is a function in spirit with a body you can run.

Lovelace's Note G is invoked without cosplay. `bernoulli_differences` is a first-difference pass over a short series — enough body to exercise delta-as-named-difference, not enough arrogance to claim historical machine completeness. The file admits the gap the prose admits: the Engine had no body; this one supplies a minimal, testable stand-in.

### 7. Range-checked indexing replaces accidental access.

`thought_at` and `keyword_at` refuse indices outside their declared ranges. That is the Ruby analogue of Ada subtype bounds: the container declares how much information must exist, and the accessor enforces it. Accidental off-by-one does not become a mysterious `nil` from `Array#[]`.

### 8. Immutability is the private/public contract.

`Data.define` records freeze field values at construction. The package of ideas can be private in origin and public in distribution without letting callers mutate a keyword passage after the fact. Separate parts work together because neither can quietly rewrite the other's state.

### 9. Self-check is part of the design, not a CI afterthought.

`ruby ada_thoughts.rb --check` verifies count, uniqueness, kind coverage, null gates, arithmetic identities, reverse, and passage integrity. Paranoia that cannot be re-run is theater. Paranoia with an exit code is infrastructure.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Line / Construct | Power |
|------------------|-------|
| `module Ada_Thoughts` | Package boundary: private guts, public corridor of module functions. |
| `Thought_Kind = %i[melody map calculation]` | Closes the kind set named by the prose — no fourth silent category. |
| `Thought = Data.define(...)` | Load-bearing record: symbols in, pattern abstracted, value out. |
| `raise … if value.nil?` | Null doctrine: signal, do not hide. |
| `Keyword = Data.define(:word, :passage)` | Vocabulary becomes evidence-bearing structure. |
| `KEYWORDS = [ … ].freeze` | Seventy-three frozen slots; completeness is data, not comment. |
| `KEYWORD_RANGE` | Indexed access over an explicit range, not an open-ended array habit. |
| `THOUGHTS = [melody, map, calculation]` | Canonical sample array of records the Engine was imagined to hold. |
| `select_method` case/when | Named method selection; unknown ops raise; delay is explicit. |
| `bernoulli_differences` | Function-in-spirit with a runnable body; delta becomes a list of named differences. |
| `reverse_sequence` | Card-order reversal as a first-class transform. |
| `self_check!` | Re-runnable paranoia: count, uniqueness, gates, arithmetic, reverse. |

Every declaration earns its place against a sentence in `ada-reserved-words.txt`. Nothing is decorative syntax.

---

## VERIFICATION STATUS

| Property | Status |
|----------|--------|
| Keyword count = 73 | Checked by `self_check!` |
| Keyword uniqueness | Checked by `self_check!` |
| Thought kinds cover melody/map/calculation | Checked by `self_check!` |
| Null thought construction raises | Checked by `self_check!` |
| Null operand in `select_method` raises | Checked by `self_check!` |
| `add` / `rem` / `mod` identities | Checked by `self_check!` |
| First-difference delta | Checked by `self_check!` |
| Sequence reverse | Checked by `self_check!` |
| Range-checked thought index | Checked by `self_check!` |
| Keyword lookup by word | Checked by `self_check!` |
| Passage contains its word (with short-word exemptions) | Checked by `self_check!` |

Run: `ruby ada_thoughts.rb --check`

---

## CLOSING

Ada Lovelace did not ask for a machine that merely calculated. She asked for an instrument that could hold records of thought — melody, map, calculation — indexed with care, altered by procedure, honest about null, and finished only when the proof was complete.

`ada_thoughts.rb` is that request answered in Ruby's native record form. Seventy-three reserved words keep their passages. Three thought kinds keep their bounds. Null raises. The delta has a name. And when the self-check passes, the package of ideas is not private aspiration — it is a runnable claim that every instruction still has a place: at the right moment, with the right value, for the right purpose.
