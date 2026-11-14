import { createElement, type ReactNode } from "react";

function Title({
  as,
  children,
  className,
}: {
  as: "h2" | "h3";
  children: ReactNode;
  className: string;
}) {
  return createElement(as, { className }, children);
}

const timeline = [
  ["429", "Born", "Jiankang, Liu Song dynasty"],
  ["c. 480", "Milü", "355/113 approximation"],
  ["500", "Legacy", "Zu Chongzhi dies"],
  ["c. 1400", "Surpassed", "Al-Kashi extends precision"],
  ["1967", "The Moon", "Crater named Zu Chongzhi"],
  ["2026", "The Track", "Three voices revisit the ratio"],
];

const voices = [
  {
    number: "01",
    artist: "HOTBOII",
    role: "The Energy",
    rating: "95",
    copy:
      "The hook makes the fraction unforgettable. Repetition turns 355 over 113 into a chant, while the first verse frames polygon calculation as a story of work without shortcuts.",
    line: "Every digit matters when you chasing perfection.",
  },
  {
    number: "02",
    artist: "KEVIN GATES",
    role: "The Wisdom",
    rating: "98",
    copy:
      "The treatment assigns Gates the philosophical center: precision becomes a way of moving through the world, and Liu Hui’s algorithm becomes a model for strategic patience.",
    line: "Precision is a principle, not just mathematics.",
  },
  {
    number: "03",
    artist: "NBA YOUNGBOY",
    role: "The Intensity",
    rating: "100",
    copy:
      "The third verse translates historical endurance into personal urgency, connecting Baton Rouge and fifth-century China through the demand to survive doubt and leave a record behind.",
    line: "From Baton Rouge to ancient China, we the same.",
  },
];

export default function ZuChongzhiArticle() {
  return (
    <article className="zu-article" id="zu-chongzhi">
      <header className="zu-hero">
        <div className="zu-topline">
          <span>Volume / History of Sound</span>
          <span>CHEF-007-ZCZ</span>
          <span>February 26, 2026</span>
        </div>
        <div className="zu-title-grid">
          <div className="zu-name-block">
            <span className="zu-vertical">祖冲之</span>
            <div>
              <p className="eyebrow">The Precision Approximation</p>
              <Title as="h2" className="zu-headline">
                The fraction that
                <br />
                <i>outlived empires.</i>
              </Title>
            </div>
          </div>
          <div className="zu-intro">
            <p>
              On a proposed triple collaboration built around 355/113, three
              modern voices return to a fifth-century breakthrough—and discover
              that precision can carry a rhythm, a philosophy and a legacy.
            </p>
            <span>
              By Lin Wei <b>·</b> Additional mathematics by Dr. Mara Singh
            </span>
          </div>
        </div>

        <div className="ratio-stage">
          <div className="ratio-orbit orbit-one" />
          <div className="ratio-orbit orbit-two" />
          <div className="ratio-core">
            <span>密率 · MILÜ</span>
            <strong><b>355</b><i /><b>113</b></strong>
            <small>3.14159292035…</small>
          </div>
          <div className="ratio-actual">
            <span>π</span>
            <strong>3.14159265358…</strong>
          </div>
          <div className="ratio-error">
            <span>absolute error</span>
            <strong>2.667 × 10⁻⁷</strong>
          </div>
          <div className="polygon-mark">
            <svg viewBox="0 0 100 100" aria-hidden="true">
              <polygon points="50,2 74,9 91,26 98,50 91,74 74,91 50,98 26,91 9,74 2,50 9,26 26,9" />
              <circle cx="50" cy="50" r="47" />
              <line x1="50" y1="50" x2="50" y2="2" />
            </svg>
            <span>24,576-sided polygon</span>
          </div>
          <div className="zu-track-badge">
            <strong>138</strong>
            <span>BPM</span>
            <small>E MINOR · 4:06</small>
          </div>
        </div>
      </header>

      <section className="zu-opening">
        <aside className="zu-fact-rail">
          <p className="eyebrow">Historical File</p>
          <dl>
            <div><dt>Born</dt><dd>429 AD</dd></div>
            <div><dt>Dynasty</dt><dd>Liu Song</dd></div>
            <div><dt>Fields</dt><dd>Mathematics / Astronomy</dd></div>
            <div><dt>Close ratio</dt><dd>355/113</dd></div>
            <div><dt>Approx. ratio</dt><dd>22/7</dd></div>
            <div><dt>Record</dt><dd>About 800 years</dd></div>
          </dl>
        </aside>
        <div className="zu-copy">
          <p className="zu-lede">
            The denominator is only three digits long. The achievement lasted
            roughly eight centuries.
          </p>
          <p>
            Zu Chongzhi lived during China’s Liu Song dynasty, in an era when
            finding π meant drawing polygons, not asking a machine. Working in
            the tradition of Liu Hui, he repeatedly increased the number of
            sides inscribed within a circle until straight edges approached the
            curve with extraordinary fidelity.
          </p>
          <p>
            His famous close ratio—355/113, or <i>Milü</i>—lands at
            3.14159292035. It misses π by about 0.00000026676. That small
            remainder is the engine of “祖冲之,” a concept track that treats
            numerical accuracy as character: the discipline to keep refining a
            thing after everyone else would call it finished.
          </p>
          <p>
            The project treatment assigns that idea to three distinct
            performers. HOTBOII carries the mnemonic hook, Kevin Gates the
            philosophical argument, and NBA YoungBoy the emotional stakes. The
            quoted lines and collaboration described here belong to that
            supplied creative treatment.
          </p>
          <blockquote className="zu-pullquote">
            <span>355 / 113</span>
            A ratio small enough to memorize, precise enough to define a
            millennium.
          </blockquote>
        </div>
      </section>

      <section className="precision-comparison">
        <div className="comparison-heading">
          <p className="eyebrow">Two approximations</p>
          <Title as="h3" className="comparison-title">
            Close enough
            <br />
            is a matter of <i>scale.</i>
          </Title>
        </div>
        <div className="comparison-bars">
          <div className="comparison-row milu">
            <div><span>密率 / Milü</span><strong>355 ÷ 113</strong></div>
            <div className="precision-track"><i /></div>
            <div><strong>2.667 × 10⁻⁷</strong><span>absolute error</span></div>
          </div>
          <div className="comparison-row yuelu">
            <div><span>约率 / Yuelü</span><strong>22 ÷ 7</strong></div>
            <div className="precision-track"><i /></div>
            <div><strong>1.264 × 10⁻³</strong><span>absolute error</span></div>
          </div>
          <p className="comparison-note">
            The visual bars show relative precision, not the literal magnitude
            of each error. Milü is approximately 4,700 times closer to π than
            22/7.
          </p>
        </div>
      </section>

      <section className="voice-section">
        <div className="voice-heading">
          <p className="eyebrow">Triple Threat Structure</p>
          <Title as="h3" className="voice-title">
            Three registers.
            <br />
            One number.
          </Title>
          <p>
            Energy establishes the pattern. Wisdom explains its value.
            Intensity makes the inheritance personal.
          </p>
        </div>
        <div className="voice-grid">
          {voices.map((voice) => (
            <article className="voice-card" key={voice.artist}>
              <div className="voice-card-head">
                <span>{voice.number}</span>
                <div className="voice-score">
                  <strong>{voice.rating}</strong><small>/100</small>
                </div>
              </div>
              <span className="voice-role">{voice.role}</span>
              <Title as="h3" className="voice-artist">{voice.artist}</Title>
              <p>{voice.copy}</p>
              <blockquote>“{voice.line}”</blockquote>
            </article>
          ))}
        </div>
        <p className="voice-disclaimer">
          Quotations above are attributed within the supplied fictional track
          treatment; they are presented as concept lyrics, not independently
          verified public statements.
        </p>
      </section>

      <section className="zu-proof-section">
        <div className="zu-proof-code">
          <div className="zu-code-head">
            <span>zu-chongzhi.lean</span>
            <span>theorem / precision</span>
          </div>
          <pre>{`theorem zu_chongzhi_immortal :
  (zu_milu = 355 / 113) ∧
  (|π - zu_milu_real| < 3 × 10⁻⁷) ∧
  (∀ p q : ℕ, q > 0 → q < 16604 →
    |π - p/q| ≥ |π - zu_milu_real| ∨
    (p = 355 ∧ q = 113)) ∧
  (zu_polygon.n = 24576) ∧
  (zu_record_years ≈ 800) := by
    verify_precision
    verify_optimality
    honor_legacy`}</pre>
          <div className="zu-code-status">
            <span>Revised bound</span>
            <strong>ε &lt; 3 × 10⁻⁷</strong>
          </div>
        </div>
        <div className="zu-proof-copy">
          <p className="eyebrow">Verification Notes</p>
          <Title as="h3" className="zu-proof-title">
            What the
            <br />
            decimals <i>say.</i>
          </Title>
          <p>
            The creative brief states an error below 10⁻⁷. Direct subtraction
            gives approximately 2.667 × 10⁻⁷, so a faithful formal statement
            uses the slightly wider—and still remarkable—bound of 3 × 10⁻⁷.
          </p>
          <p>
            “Seven decimal places” is best understood as seven significant
            decimal digits of precision in Zu’s bounds, rather than seven
            identical digits after the decimal in the raw fraction.
            Historical accounts also differ on the final polygon count, often
            citing 12,288 or 24,576 sides.
          </p>
          <div className="verification-seal">
            <span>MATHEMATICS REVIEW</span>
            <strong>BOUND<br />CORRECTED</strong>
            <small>Editorial edition · 2026</small>
          </div>
        </div>
      </section>

      <section className="zu-timeline-section">
        <div className="zu-timeline-head">
          <p className="eyebrow">A 1,597-year arc</p>
          <Title as="h3" className="zu-timeline-title">Precision travels.</Title>
        </div>
        <div className="zu-timeline">
          {timeline.map(([year, event, detail]) => (
            <div className="zu-timeline-stop" key={year}>
              <span />
              <strong>{year}</strong>
              <b>{event}</b>
              <small>{detail}</small>
            </div>
          ))}
        </div>
      </section>

      <footer className="zu-outro">
        <span>祖冲之的遗产永存</span>
        <Title as="h3" className="zu-outro-title">
          Every decimal verified.
          <br />
          Every legacy honored.
        </Title>
        <div>
          <span>CHEF-007-ZCZ</span>
          <strong>355 / 113</strong>
          <span>Q.E.D. ∎</span>
        </div>
      </footer>
    </article>
  );
}
