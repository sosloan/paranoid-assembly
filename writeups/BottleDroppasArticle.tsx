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

const proofLines = [
  ["01", "def g : ℝ := 9.81"],
  ["02", "def vertical_position (v₀ h₀ t : ℝ) : ℝ :="],
  ["03", "  h₀ + v₀ * t - (1/2) * g * t^2"],
  ["04", ""],
  ["05", "theorem bottle_droppas_verified :"],
  ["06", "  ∀ track : BottleDroppasTrack,"],
  ["07", "  ∃ street aerospace tactical : Velocity,"],
  ["08", "    trajectory street = trajectory aerospace"],
  ["09", "    ∧ impact.verified = true := by"],
  ["10", "  -- conceptual proof continues"],
];

export default function BottleDroppasArticle() {
  return (
    <article className="bottle-article" id="bottledroppas">
      <header className="bottle-hero">
        <div className="bottle-kicker">
          <span>Volume Profile</span>
          <span>Formal Music · Issue 148</span>
        </div>
        <div className="bottle-headline-row">
          <div>
            <p className="eyebrow">SSAS / BottleDroppas</p>
            <Title as="h2" className="bottle-headline">
              The drop is
              <br />
              <i>the proof.</i>
            </Title>
          </div>
          <div className="bottle-deck-wrap">
            <p className="bottle-deck">
              On “BottleDroppas,” SSAS turns a club record into a ballistic
              thought experiment—mapping bass, gravity and bravado onto one
              parabolic arc.
            </p>
            <p className="bottle-byline">
              Words by Amara Vale <span>·</span> Mathematics review by Ellis Park
            </p>
          </div>
        </div>

        <div className="trajectory-stage" aria-label="Visualization of a parabolic bottle trajectory">
          <div className="trajectory-grid" />
          <svg viewBox="0 0 1200 430" preserveAspectRatio="none" aria-hidden="true">
            <path className="trajectory-ghost" d="M40 370 Q430 -20 1160 350" />
            <path className="trajectory-path" d="M40 370 Q430 -20 1160 350" />
            {[0, 1, 2, 3, 4, 5, 6].map((index) => {
              const points = [
                [40, 370], [205, 205], [380, 105], [565, 87],
                [755, 130], [955, 235], [1160, 350],
              ];
              return <circle key={index} cx={points[index][0]} cy={points[index][1]} r={index === 3 ? 8 : 4} />;
            })}
          </svg>
          <div className="trajectory-origin">
            <span>t = 0</span>
            <strong>STREET DROP</strong>
          </div>
          <div className="trajectory-apex">
            <span>vᵧ = 0</span>
            <strong>APOGEE</strong>
          </div>
          <div className="trajectory-impact">
            <span>y = 0</span>
            <strong>Q.E.D. / IMPACT</strong>
          </div>
          <div className="trajectory-equation">
            y = h₀ + v₀t − ½gt²
          </div>
          <div className="track-stamp">
            <span>CHEF-022-BTLD</span>
            <strong>148</strong>
            <small>BPM</small>
          </div>
        </div>
      </header>

      <div className="article-body">
        <aside className="article-rail">
          <div className="track-facts">
            <p className="eyebrow">Track File</p>
            <dl>
              <div><dt>Artist</dt><dd>SSAS</dd></div>
              <div><dt>Work</dt><dd>BottleDroppas</dd></div>
              <div><dt>Key</dt><dd>E♭ minor</dd></div>
              <div><dt>Tempo</dt><dd>148 BPM</dd></div>
              <div><dt>Runtime</dt><dd>3:39</dd></div>
              <div><dt>System</dt><dd>Lean 4</dd></div>
            </dl>
          </div>
          <div className="article-index">
            <span>01</span>
            <p>Street physics</p>
            <span>02</span>
            <p>The formal score</p>
            <span>03</span>
            <p>Descent as harmony</p>
          </div>
        </aside>

        <div className="article-copy">
          <p className="article-lede">
            A bottle leaves the hand. For one suspended second, celebration
            becomes calculation.
          </p>
          <p>
            SSAS builds “BottleDroppas” around that instant—the point where a
            gesture made for spectacle submits to gravity. The supplied track
            file credits a conceptual triple bill of HOTBOII, Lockheed Martin
            and Sheriff James Downey, but its real featured artist is the
            trajectory itself: velocity in, impact out, every boast drawn as a
            curve.
          </p>
          <p>
            At 148 BPM, the record moves too quickly to feel academic. Its drums
            strike with the blunt certainty of a solved variable, while an
            eight-chord E♭ minor sequence keeps falling and returning. The
            production does not illustrate the mathematics from a safe
            distance. It behaves like the mathematics—accumulating force,
            reaching an apex, then resolving under pressure.
          </p>

          <blockquote className="article-pullquote">
            <span>“</span>
            The featured artist is the trajectory itself: velocity in, impact
            out, every boast drawn as a curve.
          </blockquote>

          <Title as="h3" className="article-subhead">
            Street physics, written formally
          </Title>
          <p>
            The project’s Lean 4 file begins with an unromantic constant:
            gravitational acceleration, defined as 9.81 meters per second
            squared. From there it constructs velocity, position and trajectory
            states before asking the question embedded in every bottle toss:
            where will it land?
          </p>
          <p>
            That translation is SSAS’s most effective compositional move.
            “Drop” works simultaneously as a production command, a physical
            event and a social signal. Payload language turns the dance-floor
            image into logistics; the “target zone” makes arrival sound
            inevitable. The metaphors are deliberately excessive, but the
            underlying mechanics are elementary and exact.
          </p>
        </div>
      </div>

      <section className="proof-spread">
        <div className="proof-editor">
          <div className="proof-window-head">
            <span className="proof-dots"><i /><i /><i /></span>
            <span>BottleDroppas.lean</span>
            <span>Lean 4</span>
          </div>
          <div className="proof-code">
            {proofLines.map(([line, code]) => (
              <div key={line}>
                <span>{line}</span>
                <code>{code || " "}</code>
              </div>
            ))}
          </div>
          <div className="proof-status">
            <span>Concept score</span>
            <strong>9 goals · proof terms pending</strong>
          </div>
        </div>
        <div className="proof-commentary">
          <p className="eyebrow">Reading the source</p>
          <Title as="h3" className="proof-title">
            A theorem
            <br />
            with the <i>ad-libs in.</i>
          </Title>
          <p>
            Lean normally rewards restraint: definitions must be precise and
            every theorem must close. SSAS uses that severity as a dramatic
            frame. Structures for tactical command and payload delivery sit
            beside harmonic frequencies and track metadata, making the source
            read like liner notes written for a compiler.
          </p>
          <div className="proof-caveat">
            <strong>Proof note</strong>
            <p>
              Several declarations use <code>sorry</code>, Lean’s placeholder
              for an unfinished proof. So “verified” is currently an artistic
              claim, not a completed machine-checking result. The gap is
              revealing: certainty is the song’s subject, while incompleteness
              remains visible in its source.
            </p>
          </div>
        </div>
      </section>

      <div className="article-body article-body-final">
        <aside className="article-rail">
          <div className="frequency-stack">
            <span>466.16</span>
            <i />
            <span>415.30</span>
            <i />
            <span>370.00</span>
            <i />
            <span>311.13</span>
            <small>Hz / harmonic descent</small>
          </div>
        </aside>
        <div className="article-copy">
          <Title as="h3" className="article-subhead">
            The sound of coming down
          </Title>
          <p>
            The harmonic map assigns each beat in the cycle a frequency, moving
            from E♭ through B♭, G♭, A♭ and back home. It is not a literal model
            of altitude—the frequencies rise as often as they fall—but it is a
            convincing model of tension. “Descent” here is emotional: the
            sensation of a system pulled toward resolution.
          </p>
          <p>
            That distinction matters. “BottleDroppas” is strongest when it
            stops pretending that mathematics removes ambiguity and instead
            shows how mathematical language can intensify it. The code promises
            predictability. The music supplies risk. Between those poles, SSAS
            finds a new kind of flex: not simply saying the mission succeeded,
            but publishing the system that is supposed to make success
            inevitable.
          </p>
          <p>
            When the final E♭ lands, the equation and the record briefly agree.
            The arc closes. The glass shatters. The unresolved proof remains,
            waiting for its last term.
          </p>
          <div className="article-endmark">
            <span>Track 022</span>
            <strong>Q.E.D. ∎</strong>
            <span>March 27, 2026</span>
          </div>
        </div>
      </div>
    </article>
  );
}
