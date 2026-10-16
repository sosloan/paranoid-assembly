# ada_thoughts.rb
# Ruby record translation of ada-reserved-words.txt
# Subject: Ada Lovelace's Analytical Engine vision as typed thoughts
# Companion index: writeups/ada-reserved-words.json
# Companion feed:  Ada-Feed.json (keywords, definitions, relations)
#
#   ruby ada_thoughts.rb            print the package of thoughts
#   ruby ada_thoughts.rb --check    self-test (exit 0 on success)
#   ruby ada_thoughts.rb --feed     write Ada-Feed.json (keywords + defs + relations)
# Companion database: Ada.db (via generate_ada_db.rb)
#
#   ruby ada_thoughts.rb            print the package of thoughts
#   ruby ada_thoughts.rb --check    self-test (exit 0 on success)
#   ruby generate_ada_db.rb         build Ada.db keywords/definitions/relations
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

  # Canonical sample thoughts — melody, map, calculation — the three
  # record kinds the prose names explicitly.
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

  # Array of records, indexed over a range.
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

  # Select a method case by case: add, subtract, or multiply;
  # elsif delay; else proceed. Null raises.
  def select_method(op, left, right)
    raise ArgumentError, "null operand" if left.nil? || right.nil?

    case op
    when :add      then left + right
    when :subtract then left - right
    when :multiply then left * right
    when :delay
      nil  # caller must not treat delay as a hidden zero
    when :rem then left.remainder(right)
    when :mod then left.modulo(right)
    else
      raise ArgumentError, "no method selected for #{op.inspect}"
    end
  end

  # Bernoulli-plan spirit: first differences over a short integer series.
  # The Engine had no body; Ruby supplies one without claiming historical
  # fidelity to Note G.
  def bernoulli_differences(series)
    raise ArgumentError, "null series" if series.nil?
    raise ArgumentError, "series too short" if series.length < 2

    series.each_cons(2).map { |a, b| b - a }
  end

  def reverse_sequence(series)
    raise ArgumentError, "null series" if series.nil?

    series.reverse
  end

  # Return a new kind of thought from accepted symbols.
  def abstract_thought(kind, symbols, pattern, value)
    Thought.new(kind: kind, symbols: symbols, pattern: pattern, value: value)
  end

  def word_list
    KEYWORDS.map(&:word).freeze
  end

  def report
    lines = []
    lines << "Ada_Thoughts · package of ideas (private at first, meant for all)"
    lines << "Keywords: #{KEYWORDS.length} reserved words over range #{KEYWORD_RANGE}"
    lines << "Thoughts: #{THOUGHTS.length} records over range #{THOUGHT_RANGE}"
    lines << ""
    lines << "— Thoughts —"
    THOUGHTS.each_with_index { |t, i| lines << format("  [%d] %s", i, t) }
    lines << ""
    lines << "— Reserved words (sample: record, return, null, raise) —"
    %w[record return null raise package array range].each do |w|
      lines << "  #{keyword(w)}"
    end
    lines.join("\n")
  end

  def self_check!
    raise "keyword count #{KEYWORDS.length} != #{KEYWORD_COUNT}" if KEYWORDS.length != KEYWORD_COUNT
    raise "duplicate words" if word_list.uniq.length != KEYWORDS.length
    raise "thought kinds incomplete" unless (Thought_Kind - THOUGHTS.map(&:kind)).empty?

    # Fail-closed null
    begin
      Thought.new(kind: :melody, symbols: "x", pattern: "y", value: nil)
      raise "null thought must raise"
    rescue ArgumentError
      # expected
    end

    begin
      select_method(:add, 1, nil)
      raise "null operand must raise"
    rescue ArgumentError
      # expected
    end

    raise "add broken" unless select_method(:add, 2, 3) == 5
    raise "rem broken" unless select_method(:rem, 11, 4) == 3
    raise "mod broken" unless select_method(:mod, -11, 4) == 1
    raise "delta broken" unless bernoulli_differences([1, 2, 4, 7]) == [1, 2, 3]
    raise "reverse broken" unless reverse_sequence([1, 2, 3]) == [3, 2, 1]
    raise "index broken" unless thought_at(0).kind == :melody
    raise "keyword lookup broken" unless keyword("record").word == "record"

    # Every keyword passage must mention its word (case-insensitive),
    # except short structural words folded into longer clauses.
    KEYWORDS.each do |k|
      next if %w[at for of is in or].include?(k.word)
      unless k.passage.downcase.include?(k.word.downcase)
        raise "passage for #{k.word} lacks the word"
      end
    end

    true
  end

  # Narrative doctrine clusters used when building Ada-Feed.json relations.
  DOCTRINE_CLUSTERS = [
    { id: "engine_of_thought", words: %w[accept abstract return new of],
      note: "accept symbols, abstract patterns, return a new kind of thought" },
    { id: "null_doctrine", words: %w[null raise exception when],
      note: "when null, raise a signal — never hide it" },
    { id: "package_of_ideas", words: %w[package private all at for],
      note: "package of ideas, private at first but meant for all" },
    { id: "protected_bay", words: %w[protected task entry],
      note: "protected task waits at an entry" },
    { id: "method_selection", words: %w[if then select case elsif else delay],
      note: "if/then select; case/elsif delay; else proceed" },
    { id: "loop_lifecycle", words: %w[loop begin while exit when until end],
      note: "loop begin, while condition, exit when done, until end" },
    { id: "array_of_records", words: %w[array range record procedure constant],
      note: "array of records indexed over a range, altered by procedure" },
    { id: "digit_remainder", words: %w[use digits rem mod reverse],
      note: "use digits; rem or mod; reverse sequence" },
    { id: "parameter_modes", words: %w[in out others some access limited aliased],
      note: "in/out/others/some; access limited, aliased with care" },
    { id: "typed_interface", words: %w[type tagged interface synchronized subtype generic],
      note: "tagged type, synchronized interface, subtype bounds, generic instrument" },
    { id: "design_pragma", words: %w[pragma do overriding],
      note: "do this, yet pragma forbids overriding the design" },
    { id: "inquiry_persistence", words: %w[abort requeue goto begin terminate renames is],
      note: "not abort; requeue or goto evidence; never terminate before proof" },
    { id: "function_spirit", words: %w[function body],
      note: "Bernoulli plan was a function in spirit; Engine had no body" },
    { id: "logic_connectives", words: %w[and or xor not abs],
      note: "and/or/xor/abs cannot replace imagination" },
    { id: "with_babbage", words: %w[with task declare],
      note: "With Babbage, began a patient task to declare each part" },
    { id: "separate_parts", words: %w[separate],
      note: "separate parts work together without confusing one another" },
    { id: "delta_named", words: %w[delta],
      note: "delta is a difference the Engine could name" }
  ].freeze

  def word_in_text?(text, word)
    text.to_s.downcase.match?(/(?<![a-z])#{Regexp.escape(word.to_s.downcase)}(?![a-z])/)
  end

  def primary_relation_kind(kinds)
    return "shared_definition" if kinds.include?("shared_definition")
    return "doctrine" if kinds.include?("doctrine")
    return "thought_context" if kinds.include?("thought_context")

    "co_mentioned"
  end

  # Keywords + definitions + relations feed (Ada-Feed.json).
  def build_feed
    words = word_list
    word_set = words.each_with_object({}) { |w, h| h[w] = true }

    definitions = KEYWORDS.each_with_index.map do |k, i|
      {
        "id" => "def:#{k.word}",
        "keyword" => k.word,
        "index" => i,
        "text" => k.passage
      }
    end

    edge_set = {}
    add_edge = lambda do |a, b, kind, evidence: nil, **extra|
      x, y = [a, b].minmax
      key = "#{x}::#{y}"
      e = edge_set[key] ||= { "source" => x, "target" => y, "kinds" => [], "evidence" => [] }
      e["kinds"] << kind unless e["kinds"].include?(kind)
      Array(evidence).each { |ev| e["evidence"] << ev unless e["evidence"].include?(ev) }
      extra.each { |mk, mv| e[mk.to_s] = mv }
      e
    end

    KEYWORDS.each do |k|
      words.each do |w|
        next if w == k.word
        next unless word_in_text?(k.passage, w)

        add_edge.call(k.word, w, "co_mentioned", evidence: "definition of #{k.word}")
      end
    end

    KEYWORDS.group_by(&:passage).each do |passage, ks|
      next if ks.length < 2

      ks.combination(2).each do |ka, kb|
        add_edge.call(ka.word, kb.word, "shared_definition", evidence: passage, definition: passage)
      end
    end

    DOCTRINE_CLUSTERS.each do |cluster|
      present = cluster[:words].select { |w| word_set[w] }
      present.combination(2).each do |a, b|
        add_edge.call(a, b, "doctrine", evidence: cluster[:note], cluster: cluster[:id])
      end
    end

    thoughts = THOUGHTS.each_with_index.map do |t, i|
      blob = [t.kind, t.symbols, t.pattern, t.value].join(" ")
      related = words.select { |w| word_in_text?(blob, w) }
      # Prose: a record of a melody, a map, or a calculation.
      related |= %w[record or constant]
      {
        "id" => "thought:#{t.kind}",
        "index" => i,
        "kind" => t.kind.to_s,
        "symbols" => t.symbols,
        "pattern" => t.pattern,
        "value" => t.value.to_s,
        "related_keywords" => related.uniq.sort
      }
    end

    thoughts.each do |t|
      t["related_keywords"].combination(2).each do |a, b|
        next unless word_set[a] && word_set[b]

        add_edge.call(a, b, "thought_context", evidence: t["id"], thought: t["id"])
      end
    end

    relations = edge_set.values.map do |e|
      e["kinds"] = e["kinds"].uniq.sort
      e["evidence"] = Array(e["evidence"]).uniq
      e["kind"] = primary_relation_kind(e["kinds"])
      e
    end.sort_by { |e| [e["source"], e["target"]] }

    rel_index = Hash.new { |h, k| h[k] = [] }
    relations.each do |e|
      rel_index[e["source"]] << e
      rel_index[e["target"]] << e
    end

    keywords = KEYWORDS.each_with_index.map do |k, i|
      rels = rel_index[k.word]
        .map { |e| e["source"] == k.word ? e["target"] : e["source"] }
        .zip(rel_index[k.word])
        .group_by(&:first)
        .map do |other, pairs|
          kinds = pairs.flat_map { |(_, e)| e["kinds"] }.uniq.sort
          { "keyword" => other, "kind" => primary_relation_kind(kinds), "kinds" => kinds }
        end
        .sort_by { |r| r["keyword"] }

      {
        "id" => k.word,
        "index" => i,
        "keyword" => k.word,
        "definition_id" => "def:#{k.word}",
        "definition" => k.passage,
        "relations" => rels
      }
    end

    thought_links = thoughts.flat_map do |t|
      t["related_keywords"].map do |w|
        { "source" => w, "target" => t["id"], "kind" => "keyword_to_thought" }
      end
    end.sort_by { |l| [l["source"], l["target"]] }

    {
      "feed" => "Ada-Feed",
      "version" => "1.0",
      "title" => "Ada Lovelace Keyword Feed",
      "description" => "Keywords, definitions, and relations generated from ada_thoughts.rb (Ada_Thoughts::KEYWORDS / THOUGHTS), grounded in ada-reserved-words.txt.",
      "source" => {
        "module" => "Ada_Thoughts",
        "ruby" => "ada_thoughts.rb",
        "prose" => "ada-reserved-words.txt",
        "companion_index" => "writeups/ada-reserved-words.json"
      },
      "counts" => {
        "keywords" => keywords.length,
        "definitions" => definitions.length,
        "relations" => relations.length,
        "thoughts" => thoughts.length,
        "thought_links" => thought_links.length,
        "doctrine_clusters" => DOCTRINE_CLUSTERS.length
      },
      "thought_kinds" => Thought_Kind.map(&:to_s),
      "doctrine_clusters" => DOCTRINE_CLUSTERS.map { |c|
        { "id" => c[:id], "keywords" => c[:words].select { |w| word_set[w] }, "note" => c[:note] }
      },
      "keywords" => keywords,
      "definitions" => definitions,
      "relations" => relations,
      "thoughts" => thoughts,
      "thought_links" => thought_links
    }
  end

  def write_feed!(path = "Ada-Feed.json")
    require "json"

    feed = build_feed
    raise "feed keyword count #{feed["keywords"].length} != #{KEYWORD_COUNT}" if feed["keywords"].length != KEYWORD_COUNT
    raise "feed definition count mismatch" if feed["definitions"].length != KEYWORD_COUNT

    File.write(path, JSON.pretty_generate(feed) + "\n")
    feed
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.include?("--check")
    Ada_Thoughts.self_check!
    puts "Ada_Thoughts self-check passed (#{Ada_Thoughts::KEYWORD_COUNT} keywords, #{Ada_Thoughts::THOUGHTS.length} thoughts)."
    exit 0
  end

  if ARGV.include?("--feed")
    Ada_Thoughts.self_check!
    path = "Ada-Feed.json"
    feed = Ada_Thoughts.write_feed!(path)
    puts "Wrote #{path} (#{feed["counts"]["keywords"]} keywords, #{feed["counts"]["definitions"]} definitions, #{feed["counts"]["relations"]} relations)."
    exit 0
  end

  puts Ada_Thoughts.report
end
