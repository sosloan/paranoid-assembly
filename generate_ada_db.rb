#!/usr/bin/env ruby
# generate_ada_db.rb
# Build Ada.db — SQLite catalog of Ada reserved-word keywords, definitions,
# thoughts, and relations — from ada_thoughts.rb.
#
#   ruby generate_ada_db.rb            write ./Ada.db (overwrite)
#   ruby generate_ada_db.rb --check    verify existing Ada.db and exit
#   ruby generate_ada_db.rb path.db    write to a custom path
#
# Schema:
#   keywords(id, word, position)           73 reserved words, fixed range
#   definitions(keyword_id, passage, source) earning passage per keyword
#   thoughts(id, kind, symbols, pattern, value) melody / map / calculation
#   relation_types(name, description)      shared_passage | co_mention
#   relations(from_id, to_id, relation_type, weight, note)
#   keyword_categories(keyword_id, category)  Ada language facets (taxonomy)
#
# Relations are derived from ada_thoughts.rb passages, not hand-waved:
#   shared_passage — identical definition passages (symmetric edges)
#   co_mention     — A's passage names B's word (directed; glue-word exempt)
# Categories live in keyword_categories (membership), not as clique edges.

# frozen_string_literal: true

begin
  require "sqlite3"
rescue LoadError
  warn "generate_ada_db.rb requires the sqlite3 gem (gem install sqlite3)"
  raise
end
require_relative "ada_thoughts"

DB_PATH_DEFAULT = File.expand_path("Ada.db", __dir__).freeze

# Ada 2012 reserved-word facets used for category relations.
# A word may belong to more than one facet.
CATEGORIES = {
  "control_flow" => %w[
    if then else elsif case when loop while for exit goto begin end do
    return reverse select
  ],
  "concurrency" => %w[
    task entry accept select delay abort requeue terminate protected
    synchronized
  ],
  "types_and_data" => %w[
    type subtype range digits delta tagged abstract limited new access
    aliased record array null constant
  ],
  "program_unit" => %w[
    package private body procedure function pragma generic interface
    overriding separate with use declare is of
  ],
  "operators_and_names" => %w[
    and or xor not abs mod rem in out others all some at renames
  ],
  "exception_and_null" => %w[
    exception raise null abort terminate
  ],
  "engine_vision" => %w[
    abstract accept return new record array range package private all
    null raise function body procedure delta
  ]
}.freeze

# co_mention skips these as *targets*: structural shorts (same set
# ada_thoughts.rb exempts from passage checks) plus English-glue reserved
# words that appear as ordinary prose rather than intentional keyword cites.
CO_MENTION_SKIP_TARGETS = %w[
  at for of is in or do if and not all with new then else when some
].freeze

def open_db(path)
  if File.exist?(path)
    File.delete(path)
  end
  SQLite3::Database.new(path)
end

def create_schema(db)
  db.execute_batch <<~SQL
    PRAGMA foreign_keys = ON;

    CREATE TABLE meta (
      key   TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );

    CREATE TABLE keywords (
      id       INTEGER PRIMARY KEY,
      word     TEXT    NOT NULL UNIQUE COLLATE NOCASE,
      position INTEGER NOT NULL UNIQUE
        CHECK (position >= 0 AND position < 73)
    );

    CREATE TABLE definitions (
      keyword_id INTEGER PRIMARY KEY
        REFERENCES keywords(id) ON DELETE CASCADE,
      passage    TEXT NOT NULL
        CHECK (length(passage) > 0),
      source     TEXT NOT NULL DEFAULT 'ada_thoughts.rb'
    );

    CREATE TABLE thoughts (
      id      INTEGER PRIMARY KEY,
      kind    TEXT NOT NULL UNIQUE
        CHECK (kind IN ('melody', 'map', 'calculation')),
      symbols TEXT NOT NULL CHECK (length(symbols) > 0),
      pattern TEXT NOT NULL CHECK (length(pattern) > 0),
      value   TEXT NOT NULL CHECK (length(value) > 0)
    );

    CREATE TABLE relation_types (
      name        TEXT PRIMARY KEY,
      description TEXT NOT NULL
    );

    CREATE TABLE relations (
      id            INTEGER PRIMARY KEY,
      from_id       INTEGER NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
      to_id         INTEGER NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
      relation_type TEXT    NOT NULL REFERENCES relation_types(name),
      weight        REAL    NOT NULL DEFAULT 1.0 CHECK (weight > 0),
      note          TEXT,
      CHECK (from_id != to_id),
      UNIQUE (from_id, to_id, relation_type)
    );

    CREATE TABLE keyword_categories (
      keyword_id INTEGER NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
      category   TEXT    NOT NULL,
      PRIMARY KEY (keyword_id, category)
    );

    CREATE INDEX idx_relations_from ON relations(from_id);
    CREATE INDEX idx_relations_to   ON relations(to_id);
    CREATE INDEX idx_relations_type ON relations(relation_type);
    CREATE INDEX idx_definitions_passage ON definitions(passage);
  SQL
end

def seed_meta(db)
  {
    "source" => "ada_thoughts.rb",
    "prose_source" => "ada-reserved-words.txt",
    "keyword_count" => Ada_Thoughts::KEYWORD_COUNT.to_s,
    "thought_count" => Ada_Thoughts::THOUGHTS.length.to_s,
    "generator" => "generate_ada_db.rb",
    "description" =>
      "Ada reserved-word keywords, Lovelace prose definitions, and derived relations"
  }.each do |k, v|
    db.execute("INSERT INTO meta(key, value) VALUES (?, ?)", [k, v])
  end
end

def seed_relation_types(db)
  {
    "shared_passage" =>
      "Keywords whose definition passages are identical (symmetric)",
    "co_mention" =>
      "Source keyword's passage names the target reserved word (directed)"
  }.each do |name, desc|
    db.execute(
      "INSERT INTO relation_types(name, description) VALUES (?, ?)",
      [name, desc]
    )
  end
end

def seed_keywords_and_definitions(db)
  Ada_Thoughts::KEYWORDS.each_with_index do |kw, idx|
    db.execute(
      "INSERT INTO keywords(id, word, position) VALUES (?, ?, ?)",
      [idx, kw.word, idx]
    )
    db.execute(
      "INSERT INTO definitions(keyword_id, passage, source) VALUES (?, ?, ?)",
      [idx, kw.passage, "ada_thoughts.rb"]
    )
  end
end

def seed_thoughts(db)
  Ada_Thoughts::THOUGHTS.each_with_index do |t, idx|
    db.execute(
      "INSERT INTO thoughts(id, kind, symbols, pattern, value) VALUES (?, ?, ?, ?, ?)",
      [idx, t.kind.to_s, t.symbols, t.pattern, t.value.to_s]
    )
  end
end

def seed_categories(db)
  word_to_id = {}
  db.execute("SELECT id, word FROM keywords") do |id, word|
    word_to_id[word] = id
  end

  CATEGORIES.each do |category, words|
    words.each do |word|
      id = word_to_id[word]
      raise "category #{category} references unknown word #{word}" if id.nil?

      db.execute(
        "INSERT OR IGNORE INTO keyword_categories(keyword_id, category) VALUES (?, ?)",
        [id, category]
      )
    end
  end
end

def insert_relation(db, from_id, to_id, type, weight, note)
  return if from_id == to_id

  db.execute(
    <<~SQL,
      INSERT OR IGNORE INTO relations(from_id, to_id, relation_type, weight, note)
      VALUES (?, ?, ?, ?, ?)
    SQL
    [from_id, to_id, type, weight, note]
  )
end

def derive_shared_passage_relations(db)
  # Group keyword ids by exact passage text.
  groups = Hash.new { |h, k| h[k] = [] }
  db.execute("SELECT keyword_id, passage FROM definitions") do |kid, passage|
    groups[passage] << kid
  end

  groups.each do |passage, ids|
    next if ids.length < 2

    note = "shared passage (#{ids.length} keywords)"
    ids.combination(2).each do |a, b|
      insert_relation(db, a, b, "shared_passage", 1.0, note)
      insert_relation(db, b, a, "shared_passage", 1.0, note)
    end
  end
end

def word_boundary_match?(passage, word)
  # Case-insensitive whole-word match; avoid "in" hitting "begin".
  /\b#{Regexp.escape(word)}\b/i.match?(passage)
end

def derive_co_mention_relations(db)
  keywords = db.execute("SELECT id, word FROM keywords")
  defs = {}
  db.execute("SELECT keyword_id, passage FROM definitions") do |kid, passage|
    defs[kid] = passage
  end

  keywords.each do |from_id, from_word|
    passage = defs.fetch(from_id)
    keywords.each do |to_id, to_word|
      next if from_id == to_id
      next if CO_MENTION_SKIP_TARGETS.include?(to_word)

      next unless word_boundary_match?(passage, to_word)

      insert_relation(
        db,
        from_id,
        to_id,
        "co_mention",
        1.0,
        "#{from_word.inspect} passage names #{to_word.inspect}"
      )
    end
  end
end

def build_db(path)
  Ada_Thoughts.self_check!

  db = open_db(path)
  begin
    db.transaction do
      create_schema(db)
      seed_meta(db)
      seed_relation_types(db)
      seed_keywords_and_definitions(db)
      seed_thoughts(db)
      seed_categories(db)
      derive_shared_passage_relations(db)
      derive_co_mention_relations(db)
    end
  ensure
    db.close
  end
  path
end

def check_db!(path)
  raise "missing database: #{path}" unless File.exist?(path)

  db = SQLite3::Database.new(path, readonly: true)
  db.execute("PRAGMA foreign_keys = ON")

  kw_count = db.get_first_value("SELECT COUNT(*) FROM keywords")
  def_count = db.get_first_value("SELECT COUNT(*) FROM definitions")
  th_count = db.get_first_value("SELECT COUNT(*) FROM thoughts")
  rel_count = db.get_first_value("SELECT COUNT(*) FROM relations")
  type_count = db.get_first_value("SELECT COUNT(*) FROM relation_types")

  raise "keyword count #{kw_count} != #{Ada_Thoughts::KEYWORD_COUNT}" if kw_count != Ada_Thoughts::KEYWORD_COUNT
  raise "definition count #{def_count} != #{kw_count}" if def_count != kw_count
  raise "thought count #{th_count} != #{Ada_Thoughts::THOUGHTS.length}" if th_count != Ada_Thoughts::THOUGHTS.length
  raise "expected 2 relation types, got #{type_count}" if type_count != 2
  raise "no relations derived" if rel_count < 1

  # Every keyword from ada_thoughts must match word + passage.
  Ada_Thoughts::KEYWORDS.each_with_index do |kw, idx|
    row = db.get_first_row(
      "SELECT k.word, d.passage FROM keywords k JOIN definitions d ON d.keyword_id = k.id WHERE k.id = ?",
      [idx]
    )
    raise "missing keyword id #{idx}" if row.nil?
    raise "word mismatch at #{idx}: #{row[0]} vs #{kw.word}" if row[0] != kw.word
    raise "passage mismatch at #{idx} (#{kw.word})" if row[1] != kw.passage
  end

  # shared_passage must be symmetric.
  asym = db.get_first_value(<<~SQL)
    SELECT COUNT(*) FROM relations a
    WHERE a.relation_type = 'shared_passage'
      AND NOT EXISTS (
        SELECT 1 FROM relations b
        WHERE b.from_id = a.to_id
          AND b.to_id = a.from_id
          AND b.relation_type = 'shared_passage'
      )
  SQL
  raise "asymmetric shared_passage edges: #{asym}" if asym != 0

  # No self-loops (enforced by CHECK; re-verify).
  loops = db.get_first_value("SELECT COUNT(*) FROM relations WHERE from_id = to_id")
  raise "self-loop relations: #{loops}" if loops != 0

  # Orphan FKs should be impossible with PRAGMA; still check.
  orphan = db.get_first_value(<<~SQL)
    SELECT COUNT(*) FROM relations r
    WHERE r.from_id NOT IN (SELECT id FROM keywords)
       OR r.to_id NOT IN (SELECT id FROM keywords)
  SQL
  raise "orphan relation endpoints: #{orphan}" if orphan != 0

  summary = {
    path: path,
    keywords: kw_count,
    definitions: def_count,
    thoughts: th_count,
    relation_types: type_count,
    relations: rel_count,
    shared_passage: db.get_first_value("SELECT COUNT(*) FROM relations WHERE relation_type = 'shared_passage'"),
    co_mention: db.get_first_value("SELECT COUNT(*) FROM relations WHERE relation_type = 'co_mention'"),
    category_memberships: db.get_first_value("SELECT COUNT(*) FROM keyword_categories"),
    categories: db.get_first_value("SELECT COUNT(DISTINCT category) FROM keyword_categories")
  }
  db.close
  summary
end

def report(summary)
  lines = []
  lines << "Ada.db · keywords, definitions, relations"
  lines << "  path:            #{summary[:path]}"
  lines << "  keywords:        #{summary[:keywords]}"
  lines << "  definitions:     #{summary[:definitions]}"
  lines << "  thoughts:        #{summary[:thoughts]}"
  lines << "  relation_types:  #{summary[:relation_types]}"
  lines << "  relations:       #{summary[:relations]} " \
           "(shared_passage=#{summary[:shared_passage]}, " \
           "co_mention=#{summary[:co_mention]})"
  lines << "  facets:          #{summary[:categories]} " \
           "(#{summary[:category_memberships]} memberships)"
  lines.join("\n")
end

if $PROGRAM_NAME == __FILE__
  args = ARGV.dup
  check_only = args.delete("--check")
  path = args.shift || DB_PATH_DEFAULT

  if check_only
    summary = check_db!(path)
    puts report(summary)
    puts "Ada.db check passed."
    exit 0
  end

  build_db(path)
  summary = check_db!(path)
  puts report(summary)
  puts "Ada.db written."
end
