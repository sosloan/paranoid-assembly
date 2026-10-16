# THE POWER OF `dow_price_movements.rb`

> *"Only the paranoid survive."* — Andy Grove
>
> *Charles Dow named three simultaneous movements in the averages.
> Ada named the operators that keep those movements honest: delta, range,
> reverse, synchronized, select, abs, and, xor — no silent omission.*

**Status:** ✓ COMPLETE
**Subject:** `dow_price_movements.rb` (Dow Theory price-movement engine on the Ada reserved-word substrate)
**Form:** Power-of writeup, Track 031 style
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Market Tide Edition
**Companion:** `ada_thoughts.rb` (73-word KEYWORDS catalog)

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `dow_price_movements.rb` |
| **Companion** | `ada_thoughts.rb` |
| **Origin** | Charles Dow's three-movement market doctrine, rendered as Ruby `Data` records over Ada 2012 reserved words |
| **License** | Writeup text CC BY 4.0; Dow Theory is public doctrine; reserved-word list is language vocabulary |
| **Architecture** | Ruby 3.2+ `Data.define` immutable records; `require_relative "ada_thoughts"` |
| **Symbol** | `Dow_Price_Movements::Movement` / `Confirmation` / `Bar` / `Swing` |
| **Argument** | Bar series (closes, optional volumes); average directions for confirmation |
| **Return** | Typed primary/secondary/minor movements, confirmation, selected signal — or a raised signal on null |
| **Critical Declaration** | `Movement_Kind = %i[primary secondary minor]` · confirmation via `and` / `xor` / `or` |
| **Movements of State** | 3 (primary · secondary · minor) |
| **Directions** | bull · bear · line |
| **Averages** | industrial · transport |
| **Ada Role Words** | 37 load-bearing tokens drawn from the 73-word substrate |
| **Power Source** | Typed tides + fail-closed null + dual-average confirmation + Ada keyword algebra |

---

## THE FILE, IN FULL

```ruby
# dow_price_movements.rb
# Dow Theory price-movement engine on the Ada reserved-word substrate.
# Companion: ada_thoughts.rb (73-word KEYWORDS catalog)
# Writeup:   writeups/DOW_PRICE_MOVEMENTS_POWER.md
#
#   ruby dow_price_movements.rb            print the package of movements
#   ruby dow_price_movements.rb --check    self-test (exit 0 on success)
#
# Charles Dow named three simultaneous movements in the averages.
# Ada named the operators that keep those movements honest: delta, range,
# reverse, synchronized, select, abs, and, xor — no silent omission.

# frozen_string_literal: true

require_relative "ada_thoughts"

module Dow_Price_Movements
  # Three simultaneous movements. No fourth phantom tide.
  Movement_Kind = %i[primary secondary minor].freeze

  # Bull tide, bear tide, or a line (sideways range). xor does not settle a choice.
  Direction = %i[bull bear line].freeze

  # The two averages that must confirm. Separate parts, synchronized signal.
  Average_Name = %i[industrial transport].freeze

  # Ada keywords that earn a load-bearing role in the price-movement algebra.
  # Each word is looked up in Ada_Thoughts::KEYWORDS — no phantom token.
  ROLE_WORDS = %w[
    abs and array begin case constant delta else end for if in
    loop mod not null of or others out package range record rem
    reverse select separate some synchronized then type until use
    when while with xor
  ].freeze

  # One bar of an average: indexed close and volume. Null raises.
  Bar = Data.define(:index, :close, :volume) do
    def initialize(index:, close:, volume:)
      raise ArgumentError, "null bar close" if close.nil?
      raise ArgumentError, "null bar volume" if volume.nil?
      raise ArgumentError, "null bar index" if index.nil?
      raise ArgumentError, "bar index out of range" unless index.is_a?(Integer) && index >= 0
      raise ArgumentError, "close must be numeric" unless close.is_a?(Numeric)
      raise ArgumentError, "volume must be numeric" unless volume.is_a?(Numeric)
      raise ArgumentError, "volume must be non-negative" if volume.negative?

      super(index: index, close: close, volume: volume)
    end

    def to_s
      format("bar[%d] close=%s vol=%s", index, close, volume)
    end
  end

  # One typed movement: kind, direction, span, named delta.
  # A number was not only a constant; the delta between two figures was a
  # difference the Engine could name.
  Movement = Data.define(:kind, :direction, :from_index, :to_index, :delta, :keyword) do
    def initialize(kind:, direction:, from_index:, to_index:, delta:, keyword:)
      raise ArgumentError, "null movement field" if [kind, direction, from_index, to_index, delta, keyword].any?(&:nil?)
      raise ArgumentError, "unknown kind: #{kind.inspect}" unless Movement_Kind.include?(kind)
      raise ArgumentError, "unknown direction: #{direction.inspect}" unless Direction.include?(direction)
      raise ArgumentError, "span inverted" if to_index < from_index

      super(
        kind: kind,
        direction: direction,
        from_index: from_index,
        to_index: to_index,
        delta: delta,
        keyword: keyword.to_s.freeze
      )
    end

    def to_s
      format(
        "%-9s %-4s [%d..%d] delta=%s via %s",
        kind, direction, from_index, to_index, delta, keyword
      )
    end
  end

  # Confirmation between industrial and transport. Synchronized interface.
  # and confirms; xor names divergence without pretending it is agreement.
  Confirmation = Data.define(:industrial, :transport, :confirmed, :operator) do
    def initialize(industrial:, transport:, confirmed:, operator:)
      raise ArgumentError, "null confirmation field" if [industrial, transport, confirmed, operator].any?(&:nil?)
      raise ArgumentError, "unknown industrial direction" unless Direction.include?(industrial)
      raise ArgumentError, "unknown transport direction" unless Direction.include?(transport)
      raise ArgumentError, "confirmed must be boolean" unless [true, false].include?(confirmed)

      super(
        industrial: industrial,
        transport: transport,
        confirmed: confirmed,
        operator: operator.to_s.freeze
      )
    end

    def to_s
      format(
        "industrial=%s transport=%s confirmed=%s (%s)",
        industrial, transport, confirmed, operator
      )
    end
  end

  # One swing point in the average: peak or trough over a range.
  Swing = Data.define(:index, :price, :tag) do
    def initialize(index:, price:, tag:)
      raise ArgumentError, "null swing field" if index.nil? || price.nil? || tag.nil?
      raise ArgumentError, "tag must be :peak or :trough" unless %i[peak trough].include?(tag)

      super(index: index, price: price, tag: tag)
    end
  end

  module_function

  # -------------------------------------------------------------------------
  # Ada keyword substrate — limited access, aliased only with care.
  # -------------------------------------------------------------------------

  def keyword(word)
    Ada_Thoughts.keyword(word)
  end

  def role_words
    ROLE_WORDS.each { |w| Ada_Thoughts.keyword(w) }
    ROLE_WORDS.dup.freeze
  end

  # -------------------------------------------------------------------------
  # Series construction — an array of such records, indexed over a range.
  # -------------------------------------------------------------------------

  def bars_from_closes(closes, volumes = nil)
    raise ArgumentError, "null series" if closes.nil?
    raise ArgumentError, "series too short" if closes.length < 2

    vols = volumes.nil? ? Array.new(closes.length, 0) : volumes
    raise ArgumentError, "volume length mismatch" if vols.length != closes.length

    closes.each_with_index.map do |c, i|
      Bar.new(index: i, close: c, volume: vols[i])
    end.freeze
  end

  # -------------------------------------------------------------------------
  # Delta — the difference the Engine could name. abs alone does not explain
  # the negative; direction still matters.
  # -------------------------------------------------------------------------

  def named_delta(from_price, to_price)
    raise ArgumentError, "null operand" if from_price.nil? || to_price.nil?

    to_price - from_price
  end

  def abs_move(from_price, to_price)
    named_delta(from_price, to_price).abs
  end

  # -------------------------------------------------------------------------
  # Swings — peaks and troughs over a local range. Case by case.
  # -------------------------------------------------------------------------

  def swings(bars, radius: 1)
    raise ArgumentError, "null bars" if bars.nil?
    raise ArgumentError, "radius must be positive" unless radius.is_a?(Integer) && radius >= 1
    raise ArgumentError, "series too short for radius" if bars.length < (2 * radius + 1)

    points = []
    (radius...(bars.length - radius)).each do |i|
      window = bars[(i - radius)..(i + radius)]
      price = bars[i].close
      if window.all? { |b| price >= b.close } && window.any? { |b| b.close < price }
        points << Swing.new(index: i, price: price, tag: :peak)
      elsif window.all? { |b| price <= b.close } && window.any? { |b| b.close > price }
        points << Swing.new(index: i, price: price, tag: :trough)
      end
    end
    points.freeze
  end

  # -------------------------------------------------------------------------
  # Primary direction from successive peaks and troughs.
  # Higher highs and higher lows => bull; lower highs and lower lows => bear;
  # else a line. Trends continue until reverse is earned.
  # -------------------------------------------------------------------------

  def primary_direction(swing_points)
    raise ArgumentError, "null swings" if swing_points.nil?
    raise ArgumentError, "need at least four swings" if swing_points.length < 4

    peaks   = swing_points.select { |s| s.tag == :peak }
    troughs = swing_points.select { |s| s.tag == :trough }
    raise ArgumentError, "need two peaks and two troughs" if peaks.length < 2 || troughs.length < 2

    p1, p2 = peaks[-2], peaks[-1]
    t1, t2 = troughs[-2], troughs[-1]

    hh = p2.price > p1.price
    hl = t2.price > t1.price
    lh = p2.price < p1.price
    ll = t2.price < t1.price

    if hh && hl
      :bull
    elsif lh && ll
      :bear
    else
      :line
    end
  end

  # Secondary movement: counter-tide inside the primary. reverse a sequence
  # when the cards required it — but only as secondary, not as a renamed
  # primary.
  def secondary_direction(primary, local_delta)
    raise ArgumentError, "null primary" if primary.nil?
    raise ArgumentError, "null delta" if local_delta.nil?
    raise ArgumentError, "unknown primary" unless Direction.include?(primary)

    return :line if local_delta.zero? || primary == :line

    local = local_delta.positive? ? :bull : :bear
    local == primary ? :line : local
  end

  # Minor movement: daily ripple. Use variables with digits; do not promote
  # noise into a primary claim.
  def minor_direction(delta)
    raise ArgumentError, "null delta" if delta.nil?

    if delta.positive?
      :bull
    elsif delta.negative?
      :bear
    else
      :line
    end
  end

  # -------------------------------------------------------------------------
  # Classify three simultaneous movements over a bar series.
  # -------------------------------------------------------------------------

  def classify_movements(bars, primary_span: nil, secondary_span: nil)
    raise ArgumentError, "null bars" if bars.nil?
    raise ArgumentError, "series too short" if bars.length < 5

    last = bars.length - 1
    p_from = primary_span.nil? ? 0 : primary_span.begin
    p_to   = primary_span.nil? ? last : primary_span.end
    s_from = secondary_span.nil? ? [last - 4, 0].max : secondary_span.begin
    s_to   = secondary_span.nil? ? last : secondary_span.end

    raise ArgumentError, "primary span inverted" if p_to < p_from
    raise ArgumentError, "secondary span inverted" if s_to < s_from

    p_delta = named_delta(bars[p_from].close, bars[p_to].close)
    s_delta = named_delta(bars[s_from].close, bars[s_to].close)
    m_delta = named_delta(bars[last - 1].close, bars[last].close)

    # Prefer swing structure for primary when enough bars exist.
    p_dir =
      begin
        sw = swings(bars)
        sw.length >= 4 ? primary_direction(sw) : minor_direction(p_delta)
      rescue ArgumentError
        minor_direction(p_delta)
      end

    s_dir = secondary_direction(p_dir, s_delta)
    m_dir = minor_direction(m_delta)

    [
      Movement.new(
        kind: :primary,
        direction: p_dir,
        from_index: p_from,
        to_index: p_to,
        delta: p_delta,
        keyword: "delta"
      ),
      Movement.new(
        kind: :secondary,
        direction: s_dir,
        from_index: s_from,
        to_index: s_to,
        delta: s_delta,
        keyword: "reverse"
      ),
      Movement.new(
        kind: :minor,
        direction: m_dir,
        from_index: last - 1,
        to_index: last,
        delta: m_delta,
        keyword: "rem"
      )
    ].freeze
  end

  # -------------------------------------------------------------------------
  # Confirmation — industrial and transport must agree.
  # synchronized interface; and confirms; xor names divergence.
  # -------------------------------------------------------------------------

  def confirm(industrial_dir, transport_dir)
    raise ArgumentError, "null direction" if industrial_dir.nil? || transport_dir.nil?
    raise ArgumentError, "unknown industrial" unless Direction.include?(industrial_dir)
    raise ArgumentError, "unknown transport" unless Direction.include?(transport_dir)

    if industrial_dir == :line || transport_dir == :line
      Confirmation.new(
        industrial: industrial_dir,
        transport: transport_dir,
        confirmed: false,
        operator: "or"
      )
    elsif industrial_dir == transport_dir
      Confirmation.new(
        industrial: industrial_dir,
        transport: transport_dir,
        confirmed: true,
        operator: "and"
      )
    else
      Confirmation.new(
        industrial: industrial_dir,
        transport: transport_dir,
        confirmed: false,
        operator: "xor"
      )
    end
  end

  # Select a signal only when averages confirm. Else delay / no signal.
  # If the Engine received a question, then it could select a method.
  def select_signal(confirmation, primary_movement)
    raise ArgumentError, "null confirmation" if confirmation.nil?
    raise ArgumentError, "null movement" if primary_movement.nil?
    raise ArgumentError, "primary required" unless primary_movement.kind == :primary

    unless confirmation.confirmed
      return {
        signal: :none,
        reason: "averages not synchronized",
        keyword: keyword("synchronized"),
        confirmation: confirmation,
        movement: primary_movement
      }.freeze
    end

    if confirmation.industrial != primary_movement.direction
      return {
        signal: :none,
        reason: "confirmation disagrees with primary",
        keyword: keyword("select"),
        confirmation: confirmation,
        movement: primary_movement
      }.freeze
    end

    signal =
      case primary_movement.direction
      when :bull then :primary_bull
      when :bear then :primary_bear
      else :line
      end

    {
      signal: signal,
      reason: "confirmed primary #{primary_movement.direction}",
      keyword: keyword("select"),
      confirmation: confirmation,
      movement: primary_movement
    }.freeze
  end

  # Volume expands with the primary tide. Fail closed on null.
  def volume_confirms?(bars, direction)
    raise ArgumentError, "null bars" if bars.nil?
    raise ArgumentError, "null direction" if direction.nil?
    raise ArgumentError, "series too short" if bars.length < 4
    raise ArgumentError, "unknown direction" unless Direction.include?(direction)
    return false if direction == :line

    mid = bars.length / 2
    early = bars[0...mid]
    late  = bars[mid..]
    early_vol = early.sum(&:volume)
    late_vol  = late.sum(&:volume)
    early_px  = early.sum(&:close).to_f / early.length
    late_px   = late.sum(&:close).to_f / late.length

    price_up = late_px > early_px
    vol_up   = late_vol > early_vol

    case direction
    when :bull then price_up && vol_up
    when :bear then (!price_up) && vol_up
    else false
    end
  end

  # Trading range (Dow "line"): highs and lows confined. subtype bounds.
  def line_range?(bars, tolerance_ratio: 0.03)
    raise ArgumentError, "null bars" if bars.nil?
    raise ArgumentError, "series too short" if bars.length < 2

    closes = bars.map(&:close)
    lo = closes.min
    hi = closes.max
    return true if hi == lo

    mid = (hi + lo) / 2.0
    (hi - lo) / mid <= tolerance_ratio
  end

  # Reverse detection: prior primary vs current primary.
  def reverse?(prior_direction, current_direction)
    raise ArgumentError, "null direction" if prior_direction.nil? || current_direction.nil?
    raise ArgumentError, "unknown prior" unless Direction.include?(prior_direction)
    raise ArgumentError, "unknown current" unless Direction.include?(current_direction)

    return false if prior_direction == :line || current_direction == :line

    prior_direction != current_direction
  end

  # -------------------------------------------------------------------------
  # Report and self-check
  # -------------------------------------------------------------------------

  def report
    lines = []
    lines << "Dow_Price_Movements · package of tides (private at first, meant for all)"
    lines << "Movements: #{Movement_Kind.join(' · ')}"
    lines << "Directions: #{Direction.join(' · ')}"
    lines << "Averages: #{Average_Name.join(' · ')}"
    lines << "Ada role words: #{ROLE_WORDS.length} (substrate #{Ada_Thoughts::KEYWORD_COUNT} reserved)"
    lines << ""
    lines << "— Role keywords (sample) —"
    %w[delta reverse range synchronized select abs and xor record package].each do |w|
      lines << "  #{keyword(w)}"
    end
    lines << ""
    lines << "— Sample bull primary with confirming averages —"

    industrial = bars_from_closes(
      [100, 102, 101, 105, 104, 108, 107, 112, 111, 115],
      [10, 12, 11, 14, 13, 16, 15, 18, 17, 20]
    )
    transport = bars_from_closes(
      [50, 51, 50, 53, 52, 55, 54, 58, 57, 60],
      [8, 9, 8, 11, 10, 13, 12, 15, 14, 17]
    )

    ind_moves = classify_movements(industrial)
    trn_dir   = classify_movements(transport).find { |m| m.kind == :primary }.direction
    conf      = confirm(ind_moves[0].direction, trn_dir)
    sig       = select_signal(conf, ind_moves[0])

    ind_moves.each { |m| lines << "  #{m}" }
    lines << "  #{conf}"
    lines << "  signal=#{sig[:signal]} reason=#{sig[:reason].inspect}"
    lines << "  volume_confirms=#{volume_confirms?(industrial, ind_moves[0].direction)}"
    lines.join("\n")
  end

  def self_check!
    # Substrate intact
    Ada_Thoughts.self_check!
    raise "role word missing from substrate" unless ROLE_WORDS.all? { |w| Ada_Thoughts.word_list.include?(w) }

    # Null gates
    begin
      Bar.new(index: 0, close: nil, volume: 1)
      raise "null close must raise"
    rescue ArgumentError
      # expected
    end

    begin
      named_delta(1, nil)
      raise "null delta operand must raise"
    rescue ArgumentError
      # expected
    end

    begin
      confirm(nil, :bull)
      raise "null confirm must raise"
    rescue ArgumentError
      # expected
    end

    # Delta / abs
    raise "delta broken" unless named_delta(10, 15) == 5
    raise "abs broken" unless abs_move(15, 10) == 5

    # Bull series — rising peaks and troughs
    bull_closes = [10, 12, 11, 14, 13, 16, 15, 18, 17, 20, 19, 22]
    bull_bars = bars_from_closes(bull_closes, Array.new(bull_closes.length, 1))
    bull_sw = swings(bull_bars)
    raise "swings too few" if bull_sw.length < 4
    raise "primary bull broken" unless primary_direction(bull_sw) == :bull

    # Bear series
    bear_closes = [22, 20, 21, 18, 19, 16, 17, 14, 15, 12, 13, 10]
    bear_bars = bars_from_closes(bear_closes)
    bear_sw = swings(bear_bars)
    raise "primary bear broken" unless primary_direction(bear_sw) == :bear

    # Classification yields three movements
    moves = classify_movements(bull_bars)
    raise "movement count != 3" unless moves.length == 3
    raise "kinds incomplete" unless (Movement_Kind - moves.map(&:kind)).empty?
    raise "primary not bull" unless moves[0].direction == :bull
    raise "primary keyword" unless moves[0].keyword == "delta"
    raise "secondary keyword" unless moves[1].keyword == "reverse"
    raise "minor keyword" unless moves[2].keyword == "rem"

    # Confirmation algebra
    c_and = confirm(:bull, :bull)
    raise "and confirm broken" unless c_and.confirmed && c_and.operator == "and"
    c_xor = confirm(:bull, :bear)
    raise "xor divergence broken" unless !c_xor.confirmed && c_xor.operator == "xor"
    c_or = confirm(:bull, :line)
    raise "line unconfirmed broken" unless !c_or.confirmed && c_or.operator == "or"

    # Signal selection
    primary = moves[0]
    sig_ok = select_signal(c_and, primary)
    raise "select bull broken" unless sig_ok[:signal] == :primary_bull
    sig_no = select_signal(c_xor, primary)
    raise "select must refuse xor" unless sig_no[:signal] == :none

    # Secondary is counter-tide
    raise "secondary counter broken" unless secondary_direction(:bull, -3) == :bear
    raise "secondary same-tide is line" unless secondary_direction(:bull, 3) == :line

    # Reverse
    raise "reverse broken" unless reverse?(:bull, :bear)
    raise "reverse false positive" if reverse?(:bull, :bull)
    raise "reverse line ignored" if reverse?(:line, :bear)

    # Line range
    flat = bars_from_closes([100, 100.5, 99.8, 100.2, 100.1])
    raise "line_range broken" unless line_range?(flat)
    raise "line_range false positive" if line_range?(bull_bars, tolerance_ratio: 0.01)

    # Volume confirms rising bull
    vol_bars = bars_from_closes(
      [100, 102, 104, 106, 108, 110],
      [10, 11, 12, 14, 16, 18]
    )
    raise "volume confirm broken" unless volume_confirms?(vol_bars, :bull)

    # Movement record fail-closed on inverted span
    begin
      Movement.new(kind: :primary, direction: :bull, from_index: 5, to_index: 2, delta: 1, keyword: "delta")
      raise "inverted span must raise"
    rescue ArgumentError
      # expected
    end

    # Keyword substrate passages still present for role words
    ROLE_WORDS.each do |w|
      k = keyword(w)
      raise "empty passage for #{w}" if k.passage.empty?
    end

    true
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.include?("--check")
    Dow_Price_Movements.self_check!
    puts "Dow_Price_Movements self-check passed " \
         "(#{Dow_Price_Movements::Movement_Kind.length} movements, " \
         "#{Dow_Price_Movements::ROLE_WORDS.length} Ada role words, " \
         "substrate #{Ada_Thoughts::KEYWORD_COUNT})."
    exit 0
  end

  puts Dow_Price_Movements.report
end
```

592 lines. Three movement kinds. Two averages. Thirty-seven Ada role words. One self-check.

---

## WHY IT IS POWERFUL

### 1. Dow's three movements become a closed kind set.

Charles Dow did not offer a mood board of "market vibes." He named **three simultaneous movements**: the primary tide (months to years), the secondary wave (weeks to months, often counter-tide), and the minor ripple (daily noise). `Movement_Kind = %i[primary secondary minor]` closes that set the way `Thought_Kind` closes melody/map/calculation. There is no fourth phantom tide, no silent "other" that later becomes a primary claim by accident.

### 2. The Ada keyword catalog is the linguistic substrate, not decoration.

`require_relative "ada_thoughts"` pulls the seventy-three reserved-word field. `ROLE_WORDS` then selects the thirty-seven tokens that earn a load-bearing role in price-movement algebra — `delta`, `reverse`, `range`, `synchronized`, `select`, `abs`, `and`, `xor`, `record`, `package`, and kin. Every role word is looked up through `Ada_Thoughts.keyword`; a phantom token fails closed. Grove's documentation paranoia meets Lovelace's vocabulary: the operators that move prices are the same words Ada already refused to leave unexplained.

### 3. Delta is a named difference, not a mystery.

`named_delta` is subtraction with a null gate. `abs_move` takes magnitude without erasing sign elsewhere. Primary movements carry `keyword: "delta"` because the prose already said it: *the delta between two figures was not a mystery; it was a difference the Engine could name.* Price change inherits that doctrine. Absence of a close is an exception, not a zero that quietly invents a flat day.

### 4. Peaks and troughs over a range replace chart folklore.

`swings` walks a local radius and tags `:peak` / `:trough` only when the center bar strictly dominates its window. `primary_direction` then reads the last two peaks and last two troughs: higher highs and higher lows ⇒ bull; lower highs and lower lows ⇒ bear; otherwise a **line**. That is Dow's structure test encoded as data, not as a commentator's hindsight. The range is explicit; the procedure is repeatable.

### 5. Secondary is reverse-against-tide, never a renamed primary.

`secondary_direction(primary, local_delta)` returns the counter-direction when the local delta fights the primary, and `:line` when it agrees or the primary itself is a line. The secondary movement is stamped with keyword `reverse` — reverse a sequence when the cards required it — but the type system still labels it `:secondary`. Corrections do not get to cosplay as new primary tides without confirmation.

### 6. Minor is remainder noise with an honest keyword.

The last bar-to-bar step is `:minor` with keyword `rem`. Daily ripples exist; they are classified; they are not promoted. That is the market analogue of carrying a remainder by `rem` or `mod` without pretending the remainder is the dividend. Paranoia about timeframe inflation is a first-class rule.

### 7. Confirmation is synchronized interface algebra: and / xor / or.

Dow required the industrial and transport averages to agree. `confirm` encodes that without metaphor leakage:

| industrial | transport | operator | confirmed |
|------------|-----------|----------|-----------|
| same bull/bear | same | `and` | true |
| opposite | opposite | `xor` | false |
| either is line | — | `or` | false |

`xor did not settle a choice` — divergence is named, not papered over. A line in either average refuses confirmation. Separate parts (`separate` averages) only produce a joint signal when the interface is synchronized.

### 8. Signal selection is visible control flow.

`select_signal` returns `:primary_bull`, `:primary_bear`, `:line`, or `:none`. No confirmation ⇒ `:none` with reason `"averages not synchronized"`. Disagreement between confirmation and primary ⇒ `:none`. Only confirmed agreement selects a primary signal. Delay is honest absence, not a hidden zero — the same doctrine `select_method` uses in `ada_thoughts.rb`.

### 9. Volume, lines, and reverse are gates, not narratives.

- `volume_confirms?` asks whether late volume expands with the primary tide (up on bull price advance; up on bear price decline).
- `line_range?` bounds a Dow "line" by tolerance ratio over mid — a subtype that keeps quantity within proper bounds.
- `reverse?` refuses to call a turn when either side is still a line; reverse must be earned between real tides.

Each gate raises on null. Each gate returns a boolean or a typed fact. None invent a story when data is missing.

### 10. Self-check is infrastructure.

`ruby dow_price_movements.rb --check` re-runs `Ada_Thoughts.self_check!`, verifies every role word exists in the substrate, exercises null gates, bull/bear swing structure, three-movement classification, confirmation algebra, signal selection, secondary counter-tide, reverse, line range, volume, and inverted-span refusal. Paranoia with an exit code is infrastructure; paranoia without one is theater.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Construct | Power |
|-----------|-------|
| `require_relative "ada_thoughts"` | Substrate binding: 73 reserved words already fail-closed and passage-backed. |
| `Movement_Kind = %i[primary secondary minor]` | Closes Dow's three-movement set — no phantom fourth tide. |
| `Direction = %i[bull bear line]` | Tide, counter-tide, or range; line is first-class, not missing data. |
| `Average_Name = %i[industrial transport]` | The two averages that must confirm; separate parts. |
| `ROLE_WORDS` | Thirty-seven Ada tokens with load-bearing jobs in the algebra. |
| `Bar = Data.define(:index, :close, :volume)` | One average observation; null close/volume raises. |
| `Movement = Data.define(...)` | Typed tide: kind, direction, span, named delta, keyword. |
| `Confirmation = Data.define(...)` | Dual-average verdict with explicit operator (`and`/`xor`/`or`). |
| `Swing = Data.define(:index, :price, :tag)` | Peak/trough structure points over a local range. |
| `named_delta` / `abs_move` | Delta doctrine: difference named; abs does not erase sign elsewhere. |
| `swings` + `primary_direction` | HH/HL vs LH/LL structure test — chart folklore replaced by procedure. |
| `secondary_direction` | Counter-tide only; same-tide secondary collapses to line. |
| `minor_direction` | Daily ripple classified without promotion. |
| `classify_movements` | Emits exactly three movements with keywords delta/reverse/rem. |
| `confirm` | Synchronized confirmation algebra; divergence is xor, not hope. |
| `select_signal` | Visible selection; unconfirmed averages yield `:none`. |
| `volume_confirms?` | Volume expands with the primary tide, or the gate refuses. |
| `line_range?` | Dow line as bounded range subtype. |
| `reverse?` | Reversal only between real tides. |
| `self_check!` | Re-runnable paranoia across substrate, structure, and gates. |

Every declaration earns its place against either Dow's doctrine or an Ada reserved-word passage. Nothing is decorative syntax.

---

## STRATEGIC THEME — Grove × Dow × Lovelace

Andy Grove priced strategic inflection as something you detect early or pay for later. Charles Dow priced market inflection the same way: primary turns are real only when structure and the second average agree. Ada Lovelace priced linguistic inflection: operators without passages are silent assumptions.

`dow_price_movements.rb` is the triple binding:

1. **Structure before story** — swings and deltas before adjectives.
2. **Confirmation before signal** — industrial ∧ transport, or nothing.
3. **Vocabulary before vibes** — Ada keywords name the algebra so no operator is anonymous.

Only the paranoid survive a false primary. Only a typed secondary stays a correction. Only a synchronized pair of averages is allowed to speak.

---

## SCALE OF IMPACT

- **Doctrine:** Dow Theory underpins classical trend following, intermarket confirmation, and a century of average-based tape reading.
- **Software:** Any system that classifies trend, correction, and noise without conflating timeframes needs this kind of closed kind set.
- **Companion leverage:** Reuses the 73-word Ada substrate — one vocabulary, many packages of ideas.
- **Cost per call:** Pure Ruby arithmetic over short series; self-check is the expensive path and it is deliberate.

---

## VERIFICATION STATUS

| Property | Status |
|----------|--------|
| Ada substrate self-check | Delegated to `Ada_Thoughts.self_check!` |
| All ROLE_WORDS ∈ substrate | Checked by `self_check!` |
| Null bar / delta / confirm raise | Checked by `self_check!` |
| `named_delta` / `abs_move` identities | Checked by `self_check!` |
| Bull HH/HL primary | Checked by `self_check!` |
| Bear LH/LL primary | Checked by `self_check!` |
| Classification yields 3 movements | Checked by `self_check!` |
| Keywords delta / reverse / rem | Checked by `self_check!` |
| Confirm `and` / `xor` / `or` algebra | Checked by `self_check!` |
| `select_signal` bull vs refusal | Checked by `self_check!` |
| Secondary counter-tide | Checked by `self_check!` |
| Reverse / line_range / volume gates | Checked by `self_check!` |
| Inverted movement span raises | Checked by `self_check!` |

Run: `ruby dow_price_movements.rb --check`

**QED.**

---

## CLOSING

Dow gave the market three movements. Ada gave the analyst a vocabulary that refuses silent operators. Grove gave the strategist a reason to treat unconfirmed tides as hostile until proven otherwise.

`dow_price_movements.rb` is that triangle closed in Ruby's native record form. Primary, secondary, and minor keep their bounds. Industrial and transport keep their separate bodies and their synchronized interface. Delta has a name. Reverse stays secondary until structure says otherwise. Xor names divergence without settling a false choice. And when the self-check passes, the package of tides is not private aspiration — it is a runnable claim that every price movement still has a place: at the right timeframe, with the right confirmation, under the right word.
