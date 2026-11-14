import { createElement, useState, type ReactNode } from "react";

type Artwork = {
  issue: string;
  title: string;
  subtitle: string;
  concept: string;
  format: string;
  palette: string[];
  production: string[];
  kind: "proof" | "global" | "chaos" | "blueprint" | "ordinal" | "archive";
};

const artworks: Artwork[] = [
  {
    issue: "Art 001",
    title: "Verified Trap Aesthetics",
    subtitle: "Proof Tree / Gold QED Edition",
    concept:
      "Fifteen theorem nodes rise from an 808 Hz fundamental to a gold-foil QED apex. Formal dependency becomes visual rhythm.",
    format: "3000 × 3000px · RGB / CMYK · 300 DPI",
    palette: ["#FF6B00", "#0066FF", "#00FF66", "#0A0A0A", "#C9A54D"],
    production: [
      "350gsm uncoated gatefold",
      "Matte laminate + spot UV",
      "Gold PMS 871 foil stamp",
      "Equation die-cut inner sleeve",
      "Clear orange / black splatter vinyl",
    ],
    kind: "proof",
  },
  {
    issue: "Art 002",
    title: "Global Synthesis",
    subtitle: "Eight Traditions / One Network",
    concept:
      "A world assembled from mathematical notation. Eight cities glow as connected traditions while metallic landmarks map industrial collaboration.",
    format: "3000 × 3000px · RGB / CMYK · 300 DPI",
    palette: ["#C0C0C0", "#003087", "#00A651", "#54565A", "#FF6B00"],
    production: [
      "400gsm premium coated stock",
      "Holographic route-line foil",
      "Multi-level continent emboss",
      "Metallic silver partner marks",
      "Clear smoke / silver splatter vinyl",
    ],
    kind: "global",
  },
  {
    issue: "Art 003",
    title: "Lean Semantics & Chaos Theory",
    subtitle: "Lorenz Attractor / Terminal Cut",
    concept:
      "A 3D Lorenz attractor traces order through chaos while executable Lean4 syntax scrolls beneath a negative-space butterfly.",
    format: "3000 × 3000px · Animated 4.44s loop",
    palette: ["#00FF41", "#FF0040", "#F8F8F2", "#000000", "#66D9EF"],
    production: [
      "Natural black uncoated stock",
      "Fluorescent green + red inks",
      "Soy-based print process",
      "Transparent code inner sleeve",
      "Neon green vinyl + dead-wax etching",
    ],
    kind: "chaos",
  },
  {
    issue: "Object 001",
    title: "The Architecture of Harmony",
    subtitle: "Deluxe Blueprint Box",
    concept:
      "A four-level structure built from music. Thirty illuminated windows, equation beams and album floors turn the catalog into architecture.",
    format: "12 × 12 × 4in · 4.2lb · 5,000 editions",
    palette: ["#0080FF", "#F0F0F0", "#000000", "#C9A54D"],
    production: [
      "2mm rigid-board magnetic box",
      "Black metal corner protectors",
      "Black flocked interior",
      "84-page Smyth-sewn book",
      "4 × 180g LP + 3 CD + aluminum USB",
    ],
    kind: "blueprint",
  },
  {
    issue: "Art 004",
    title: "Ordinal Frequencies",
    subtitle: "Five Levels / Infinite Harmonics",
    concept:
      "Ordinal progression becomes a vertical spectrum. Bands expand exponentially from a 55Hz ground state into violet, impredicative noise.",
    format: "3000 × 3000px · 12in vinyl sleeve",
    palette: ["#FF0000", "#FF8800", "#FFFF00", "#00FF00", "#0088FF", "#8800FF"],
    production: [
      "300gsm white uncoated stock",
      "Five-color process + 2 spots",
      "Clear unprinted inner sleeve",
      "Concentric ordinal center labels",
      "Clear rainbow-splatter vinyl",
    ],
    kind: "ordinal",
  },
  {
    issue: "Object 002",
    title: "The Complete CHEF Archive",
    subtitle: "No. ___ of 250",
    concept:
      "A museum-grade archive in FSC-certified American cherry, centered by an etched QED seal and eight mathematical traditions.",
    format: "14 × 12 × 4in · 250 numbered objects",
    palette: ["#B56A36", "#FF6B00", "#0A0A0A", "#0066FF", "#C9A54D"],
    production: [
      "Finger-jointed American cherry",
      "Three coats natural Danish oil",
      "Full-length brass piano hinge",
      "Layered orange / black / blue foam",
      "Signed giclée print + 64GB archive USB",
    ],
    kind: "archive",
  },
];

function Button({
  children,
  className,
  onClick,
}: {
  children: ReactNode;
  className: string;
  onClick: () => void;
}) {
  return createElement("button", { className, onClick, type: "button" }, children);
}

function Title({
  as,
  children,
}: {
  as: "h2" | "h3";
  children: ReactNode;
}) {
  return createElement(as, null, children);
}

function ProofCover() {
  const nodes = [
    [50, 83, "808 Hz"],
    [32, 67, "Signal"],
    [68, 67, "Logic"],
    [20, 49, "p-adic"],
    [42, 48, "Chern"],
    [61, 49, "Graph"],
    [80, 48, "Type"],
    [29, 30, "Ordinal"],
    [51, 29, "Lean4"],
    [72, 30, "Chaos"],
    [50, 12, "QED"],
  ];
  const edges = [
    [50, 83, 32, 67], [50, 83, 68, 67], [32, 67, 20, 49],
    [32, 67, 42, 48], [68, 67, 61, 49], [68, 67, 80, 48],
    [20, 49, 29, 30], [42, 48, 51, 29], [61, 49, 51, 29],
    [80, 48, 72, 30], [29, 30, 50, 12], [51, 29, 50, 12], [72, 30, 50, 12],
  ];
  return (
    <div className="art-cover proof-cover">
      <svg viewBox="0 0 100 100" aria-hidden="true">
        <defs>
          <linearGradient id="proof-line">
            <stop stopColor="#ff6b00" />
            <stop offset="1" stopColor="#0066ff" />
          </linearGradient>
        </defs>
        {edges.map((edge, index) => (
          <line key={index} x1={edge[0]} y1={edge[1]} x2={edge[2]} y2={edge[3]} />
        ))}
      </svg>
      {nodes.map(([x, y, label]) => (
        <span className={label === "QED" ? "proof-node apex" : "proof-node"} key={label} style={{ left: `${x}%`, top: `${y}%` }}>
          {label}
        </span>
      ))}
      <strong className="cover-brand">HOTBOII</strong>
      <div className="cover-name">Verified<br />Trap Aesthetics</div>
    </div>
  );
}

function GlobalCover() {
  const cities = [[22, 37], [38, 28], [49, 43], [55, 32], [61, 27], [82, 40], [75, 62], [28, 58]];
  return (
    <div className="art-cover global-cover">
      <div className="world-mass one">∑π∫λ∂ω∞√∆≡</div>
      <div className="world-mass two">∞λ∑∂π∆√ω≡</div>
      <svg viewBox="0 0 100 100" aria-hidden="true">
        {cities.slice(1).map((city, index) => (
          <line key={index} x1="22" y1="37" x2={city[0]} y2={city[1]} />
        ))}
      </svg>
      {cities.map((city, index) => <i key={index} style={{ left: `${city[0]}%`, top: `${city[1]}%` }} />)}
      <strong className="cover-brand">HOTBOII</strong>
      <div className="global-title">GLOBAL<br />SYNTHESIS</div>
      <span className="global-cn">全球综合</span>
    </div>
  );
}

function ChaosCover() {
  return (
    <div className="art-cover chaos-cover">
      <div className="code-rain">
        theorem butterfly (σ ρ β : ℝ)<br />dx := σ * (y - x)<br />dy := x * (ρ - z) - y<br />dz := x * y - β * z<br />by exact chaos_verified
      </div>
      <svg viewBox="0 0 100 100" aria-hidden="true">
        <path d="M50 83C19 65 17 26 38 22c25-4 21 34 12 61C59 56 56 18 72 21c24 4 14 43-22 62Z" />
        <path className="chaos-secondary" d="M50 82C34 65 28 37 41 30c15-8 16 24 9 52 8-28 6-57 20-52 17 7 1 39-20 52Z" />
      </svg>
      <strong className="cover-brand">HOTBOII</strong>
      <div className="chaos-title">LEAN SEMANTICS<br />& CHAOS THEORY</div>
      <span className="chaos-features">BLACK RUSSIAN | KEVIN GATES</span>
    </div>
  );
}

function BlueprintCover() {
  return (
    <div className="art-cover blueprint-cover">
      <span className="dimension horizontal">12.000</span>
      <span className="dimension vertical">4 LEVELS</span>
      <div className="blueprint-building">
        {[0, 1, 2, 3].map((floor) => (
          <div className="building-floor" key={floor}>
            {Array.from({ length: floor === 3 ? 3 : 9 }, (_, index) => <i key={index}>{floor * 9 + index + 1}</i>)}
          </div>
        ))}
      </div>
      <strong className="cover-brand">HOTBOII</strong>
      <div className="blueprint-title">THE ARCHITECTURE<br />OF HARMONY</div>
      <span className="deluxe-mark">DELUXE EDITION</span>
    </div>
  );
}

function OrdinalCover() {
  return (
    <div className="art-cover ordinal-cover">
      <div className="ordinal-title">ORDINAL FREQUENCIES</div>
      <div className="ordinal-bands">
        <span><b>ε₀</b></span>
        <span><b>ω^ω</b></span>
        <span><b>ω²</b></span>
        <span><b>ω¹</b></span>
        <span><b>ω⁰</b></span>
      </div>
      <strong className="ordinal-artist">HOTBOII</strong>
    </div>
  );
}

function ArchiveCover() {
  return (
    <div className="art-cover archive-cover">
      <div className="wood-grain" />
      <div className="archive-seal">
        <span>∑</span><span>∫</span><span>∞</span><span>π</span>
        <strong>Q.E.D.</strong>
        <span>ω</span><span>√</span><span>∆</span><span>≡</span>
      </div>
      <div className="archive-title">THE COMPLETE CHEF ARCHIVE</div>
      <span className="archive-plate">No. ___ of 250</span>
    </div>
  );
}

function Cover({ kind }: { kind: Artwork["kind"] }) {
  if (kind === "proof") return <ProofCover />;
  if (kind === "global") return <GlobalCover />;
  if (kind === "chaos") return <ChaosCover />;
  if (kind === "blueprint") return <BlueprintCover />;
  if (kind === "ordinal") return <OrdinalCover />;
  return <ArchiveCover />;
}

export default function ArtworkMagazine() {
  const [active, setActive] = useState(0);
  const artwork = artworks[active];

  return (
    <section className="art-magazine" id="artworks">
      <div className="magazine-masthead">
        <span>CHEF VIZ PRO</span>
        <strong>ART &amp; OBJECTS</strong>
        <span>Special Edition · 2026</span>
      </div>
      <div className="magazine-lead">
        <div>
          <p className="eyebrow">The visual issue</p>
          <Title as="h2">Every proof<br />needs a <i>form.</i></Title>
        </div>
        <p>
          Six sleeves and objects translate theorem architecture into foil,
          fluorescence, wood, vinyl and light. A complete visual identity where
          every decorative decision carries mathematical meaning.
        </p>
        <span className="magazine-number">01—06</span>
      </div>

      <div className="artwork-feature">
        <div className="feature-cover"><Cover kind={artwork.kind} /></div>
        <div className="feature-notes">
          <span className="artwork-issue">{artwork.issue}</span>
          <Title as="h3">{artwork.title}</Title>
          <p className="artwork-subtitle">{artwork.subtitle}</p>
          <p className="artwork-concept">{artwork.concept}</p>
          <div className="artwork-format">
            <span>Master format</span>
            <strong>{artwork.format}</strong>
          </div>
          <div className="palette-strip">
            {artwork.palette.map((color) => <i key={color} style={{ background: color }}><span>{color}</span></i>)}
          </div>
          <div className="production-list">
            <span>Physical production</span>
            {artwork.production.map((item, index) => (
              <p key={item}><b>0{index + 1}</b>{item}</p>
            ))}
          </div>
        </div>
      </div>

      <div className="artwork-index">
        {artworks.map((item, index) => (
          <Button
            className={index === active ? "artwork-thumb active" : "artwork-thumb"}
            key={item.title}
            onClick={() => setActive(index)}
          >
            <div className="thumb-cover"><Cover kind={item.kind} /></div>
            <span>{item.issue}</span>
            <strong>{item.title}</strong>
          </Button>
        ))}
      </div>

      <div className="identity-strip">
        <div>
          <span>Brand ratio</span>
          <strong>60 / 30 / 8 / 2</strong>
          <small>Orange · Black · Blue · Green</small>
        </div>
        <div className="identity-wordmark">
          <pre aria-label="CHEF logo">{`█▀▀ █ █ █▀▀ █▀▀
█▄▄ █▀█ ██▄ █▀`}</pre>
          <span>Terminal lockup</span>
        </div>
        <div>
          <span>Print standard</span>
          <strong>PDF/X-1a</strong>
          <small>0.125in bleed · CMYK · 300 DPI</small>
        </div>
        <div>
          <span>Digital master</span>
          <strong>3000²</strong>
          <small>sRGB · PNG / JPG · under 5MB</small>
        </div>
      </div>
    </section>
  );
}
