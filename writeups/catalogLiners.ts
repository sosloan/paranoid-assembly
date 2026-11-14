export type AlbumLiner = {
  catalog: string;
  label: string;
  statement: string;
  attribution: string;
  credits: string[];
  notes: { title: string; text: string }[];
};

export const catalogLiners: AlbumLiner[] = [
  {
    catalog: "CHEF-VTA-001",
    label: "HOTBOII Solo Album · March 2026",
    statement: `Mathematics isn't decoration—it's the architecture beneath every bar, every beat, every breath. This album proves what I've known since day one: trap music and formal proof theory speak the same language. Both demand precision. Both reward elegance. Both transform chaos into structure.

From Ramanujan's infinite series to 808 basslines at 55Hz, from Curry-Howard correspondences to code-switching between registers—this is verification music. Every track passes the proof assistant. Every collaboration extends the theorem. Every feature strengthens the foundation.

To my mentors in mathematics departments worldwide who said this couldn't work: check the QED stamps. To the producers who said formal methods kill creativity: listen to Track 003. To everyone who believed trap and topology could coexist: this one's verified just for you.`,
    attribution: "HOTBOII · January 2026",
    credits: [
      "Executive Producer: HOTBOII",
      "Mathematical Consultant: Dr. Sarah Chen, MIT Mathematics",
      "Lean4 Proof Verification: CHEF VIZ PRO Development Team",
      "Primary Production: HOTBOII, Metro Boomin (Track 003), DJ Khaled (Track 007)",
      "Engineering: Mixed by Alex Tumay; mastered by Dave Kutch",
      "Recorded at CHEF Studios Atlanta and Patchwerk Recording Studios",
      "Cover Art: Proof tree visualization by Studio Permanent",
      "Typography: JetBrains Mono and Montserrat Black",
      "Special thanks to the eight nations and 120 prime-number tradition keepers who contributed to CHEF VIZ PRO.",
    ],
    notes: [
      { title: "01 · RAMANUJAN INFINITE (5:15)", text: "The foundation. Ramanujan's work on infinite series and modular forms provides the melodic structure—each verse unfolds like a continued fraction, never quite resolving but always approaching truth. The 808 pattern mirrors the Hardy-Ramanujan asymptotic formula for partition numbers. First track recorded, last track finished." },
      { title: "02 · ZU CHONGZHI π (4:38)", text: "Named for the 5th-century Chinese mathematician who calculated π to seven decimal places—a record that stood for 800 years. The beat uses a 22/7 pattern while the bass follows the decimal expansion 3.14159265358979, converted to Hz frequencies." },
      { title: "03 · SIGNAL OPERATORS ft. Metro Boomin (3:47)", text: "Metro brought the filter sweeps; I brought the Fourier transforms. Every riser is a convolution, every drop a frequency-domain multiplication. The Lean proof verifies that our audio processing chain is mathematically lossless." },
      { title: "04 · P-ADIC SOIL (4:02)", text: "An alternative number system where closeness is defined by divisibility rather than magnitude. Roots grow down through prime-factorization layers. The deeper you dig, the more structure you find." },
      { title: "05 · CHERN-SAGE BOUNDED (3:33)", text: "Shiing-Shen Chern's differential geometry meets ancient wisdom traditions. The string arrangement follows geodesic curves on a hyperbolic surface; a 1979 Chern lecture is pitch-shifted into the bass range." },
      { title: "06 · BRIDGE CONSTRUCTION (4:51)", text: "Inspired by the Königsberg bridge problem. Each verse is a Eulerian path through the beat—visiting every element exactly once while connecting communities, traditions, streets and seminar rooms." },
      { title: "07 · ALUMINUM LOGIC ft. DJ Khaled (3:58)", text: `"Another one" is mathematical induction in disguise. Precision engineering meets mass production, mirroring how verified trap scales from underground to stadium.` },
      { title: "08 · 大合 (GRAND UNION) (4:47)", text: "A synthesis of eight mathematical traditions. Lectures in Mandarin, English, Russian, Arabic, Italian, German, Japanese and Sanskrit are processed through harmonic-analysis filters." },
      { title: "09 · LEAN SEMANTICS (4:44)", text: "The thesis statement. Lean4 is a new semantic layer for trap music. Every claim can be verified, every boast proven, every metaphor given a formal correspondence. Beat switches mirror theorem dependencies." },
      { title: "10 · ORDINAL FREQUENCIES (3:45)", text: "From 808 (ω⁰) to omega-omega (ω^ω), the bass ascends through countable infinity. Each hit represents a higher ordinal rank; the fadeout asymptotically approaches ε₀." },
      { title: "11 · QED STAMPS (3:03)", text: `QED means "which was to be demonstrated." The victory lap samples rubber stamps, typewriter dings and the satisfying click of a theorem falling into place. Short, sharp, verified.` },
    ],
  },
  {
    catalog: "CHEF-GS-002",
    label: "Corporate Collaborations Album · June 2026",
    statement: `They said: "Don't work with corporations. They'll water down your vision. They'll sanitize your sound. They'll strip the mathematics and sell the aesthetic."

They were wrong.

Boeing brought aerospace precision. Siemens brought industrial-grade differential equations. Lockheed brought graph theory from guidance systems. EA Sports brought collision physics. Deutsche Bank brought stochastic calculus. These aren't sellout features. These are mathematical collaborations between equals.

This album verifies that mathematics has no boundaries—only bridges waiting to be built.`,
    attribution: "HOTBOII · March 2026",
    credits: [
      "Executive Producers: HOTBOII and Corporate Partners",
      "A&R Coordination: CHEF VIZ PRO Legal Team",
      "Mathematical Verification: Multi-institutional peer review",
      "Production: HOTBOII, WondaGurl, Boi-1da and Tay Keith",
      "Engineering: Boeing Audio Research Lab and Siemens Sound Design Division",
      "Mastering: Bob Ludwig at Gateway Mastering",
      "Cleared for commercial use, broadcast and educational applications",
    ],
    notes: [
      { title: "12 · PRIME LOGIC MASTERS (4:29)", text: "The 120 prime numbers—15 per nation—form the melodic content. Primes are presented as the atoms of arithmetic: indivisible and fundamental." },
      { title: "13 · LOOP CONVERGENCE ft. WondaGurl (3:52)", text: "Each loop modifies the next from prior feedback, creating a fixed-point attractor. The Lean proof verifies convergence to the same eight-bar pattern in finite time." },
      { title: "14 · EXTREME TDD (4:15)", text: "Write the tests before the code and the proofs before the track. The lyrics describe the proof guaranteeing that the lyrics are correct: recursive validity." },
      { title: "15 · META-LEARNING HIERARCHIES (4:07)", text: "Each verse operates at a higher meta-level. The third is about writing the second about writing the first, with samples from Gödel, Escher, Bach." },
      { title: "16 · TURBINE LOGIC ft. Siemens (4:33)", text: "Thermodynamic efficiency curves become melody. The 808 follows steam-pressure fluctuations in a 60Hz grid-synchronized generator." },
      { title: "17 · AEROSPACE CURVES ft. Lockheed Martin (4:22)", text: "Harmonic structure follows an aerodynamic profile, cambered for lift-to-drag ratio. Every drop represents Mach 1; the sonic boom is mathematically scaled for listener safety." },
      { title: "18 · GRAPH HARMONICS ft. Meta (3:58)", text: "Anonymized social-network topology becomes harmony: clusters become chords and bridges become transitions. The song takes the shape of human connection." },
      { title: "19 · COLLISION PHYSICS ft. EA Sports (4:11)", text: "Madden collision algorithms transform tackles into drums, scrambles into hi-hats and celebrations into chords. Video-game physics becomes playable music." },
      { title: "20 · STRESS-TEST INFRASTRUCTURE ft. AWS (4:26)", text: "Tracks are randomly muted to verify the song survives. The final mix passed a 10,000-iteration Monte Carlo simulation. This beat cannot fail." },
      { title: "21 · SUPPLY CHAIN TOPOLOGY ft. Maersk (4:03)", text: "Major ports are notes, shipping lanes melodic lines and the 808 follows a real container-ship schedule across the Pacific, with field recordings from 17 ports." },
      { title: "22 · DERIVATIVES FLOW ft. Deutsche Bank (4:38)", text: "Tay Keith meets Black-Scholes. Parameterized stems respond to the VIX index while every option-pricing equation is verified by quantitative strategists." },
      { title: "23 · ASSEMBLY LINE RHYTHM ft. Toyota (3:57)", text: "Every verse arrives just in time: no wasted bars, maximum efficiency. Nagoya robotic-arm movements at 174 BPM synchronize with the hi-hats." },
      { title: "24 · BUTTERFLY PIPES ft. Kevin Gates (3:46)", text: "Small changes propagate through network-flow systems. A Lorenz attractor defines the beat while Ford-Fulkerson optimizes verse-delivery flow." },
      { title: "25 · BLACK QAG ft. Boeing (4:12)", text: "Boeing's 99.99% quality standard is applied to trap. Ordinal arithmetic structures the harmony, verified against graph coherence and 747-8 engine recordings shifted into sub-bass." },
    ],
  },
  {
    catalog: "CHEF-LSC-003",
    label: "Artist Collaborations Album · September 2026",
    statement: `Black Russian heard the vision immediately. No explanation needed. We locked in for a week straight, proving theorems by day and recording by night.

Kevin Gates called after hearing the Boeing track. "That chaos theory stuff—that's Louisiana. That's the flood models. That's hurricane prediction paths." Three days later, BUTTERFLY PIPES was done.

No corporates, no consultants—just artists who understand mathematics and music as two notations for the same underlying structure. When two mathematicians prove the same theorem differently, they strengthen each other's work. Same logic here.`,
    attribution: "HOTBOII · July 2026",
    credits: [
      "Executive Producers: HOTBOII and Black Russian",
      "Co-Production: Kevin Gates",
      "Additional Production: DJ Paul and Southside",
      "Recorded at CHEF Studios Atlanta, Houston and Baton Rouge",
      "Mixed by Alex Tumay and Seth Firkins",
      "Mastered by Joe LaPorta at Sterling Sound",
      "Visual Concept: Chaos attractors and proof-tree diagrams",
      "Album Photography: Gunner Stahl",
    ],
    notes: [
      { title: "26 · CATASTROPHE THEORY ft. Black Russian (4:18)", text: "Smooth input changes trigger sudden output jumps. The beat gradually builds, then snaps without transition through Thom's seven elementary catastrophes." },
      { title: "27 · TYPE THEORY CORRESPONDENCE (3:55)", text: "Proofs are programs and programs are proofs. Every bar type-checks, every metaphor has a formal interpretation and the complete track compiles without errors." },
      { title: "28 · EIGHT OH EIGHT LAMBDA (4:09)", text: "Each bass hit is a function application. The beat beta-reduces to normal form; Church encoding makes everything a function, even the snares." },
      { title: "29 · CODE-SWITCH SEMANTICS (4:41)", text: "Trap slang switches to formal logic, Russian mathematical language returns to Atlanta ad-libs and time signatures move with context. Meaning is verified across every switch." },
      { title: "30 · ROSETTA LOOP INTEGRATION (4:28)", text: "Lectures in eight languages reveal a common structure and loop infinitely. A multilingual verse proves that mathematics transcends language barriers." },
      { title: "24 · BUTTERFLY PIPES", text: "Appears on both albums as a bridge between corporate and artist collaborations." },
      { title: "25 · BLACK QAG", text: "Appears on both albums to demonstrate that corporations can be creative collaborators too." },
    ],
  },
  {
    catalog: "CHEF-AOH-DLX",
    label: "3-CD / 4-LP Deluxe Box Set · December 2026",
    statement: `In 2026, a trap artist from Atlanta accomplished what academic mathematics has struggled with for decades: making formal verification accessible, aesthetically compelling and culturally relevant.

HOTBOII's CHEF VIZ PRO framework isn't a gimmick. The Lean4 proofs are rigorous. The mathematical content is accurate. The cultural synthesis is genuine. But more importantly, this music works on its own terms.

Future musicians will study this the way we study Bach's Well-Tempered Clavier—not just as music, but as proof that structure and creativity are the same force expressed through different media. The architecture of harmony isn't about rules constraining freedom. It's about understanding the foundation well enough to build skyscrapers.`,
    attribution: "Dr. Marcus Chen · Stanford Mathematics Department · December 2026",
    credits: [
      "3 CDs: 30 main tracks plus 5 bonus instrumentals",
      "4 LPs on 180g audiophile vinyl",
      "84-page hardcover book with lyrics, Lean proofs and annotations",
      "18 × 24-inch proof-tree poster",
      "24-bit / 96kHz FLAC download",
      "Collectible QED rubber stamp",
      "Numbered certificate, limited to 5,000 copies",
    ],
    notes: [
      { title: "B1 · ω⁰ FUNDAMENTAL FREQUENCY (3:31)", text: "Pure 808 at 55Hz. The ground state. No melody, no percussion—just the fundamental defining the entire catalog." },
      { title: "B2 · ω¹ FIRST ORDINAL (3:45)", text: "Melody emerges above the same 55Hz bass. The first harmonic proves addition works in music." },
      { title: "B3 · ω² SECOND ORDINAL (3:52)", text: "Multiplication enters. Linear becomes quadratic; the beat squares itself and complexity emerges from simple operations." },
      { title: "B4 · ω^ω OMEGA TO OMEGA (4:03)", text: "Exponentiation becomes recursive: beats contain beats, nested infinitely. The CD fades, but the mathematical structure continues." },
      { title: "B5 · ε₀ EPSILON ZERO (4:47)", text: "The boundary of what can be constructed from below. Beyond it, new axioms are required—the perfect ending acknowledging another level." },
    ],
  },
  {
    catalog: "CHEF-OF-EP1",
    label: "Instrumental Mathematics EP · October 2026",
    statement: `Five tracks. Five ordinal levels. No lyrics—just pure mathematical structure expressed through sound.

This EP is for the mathematicians who asked "Can we hear the difference between ω and ω²?" and for the producers who asked "What does exponentiation sound like?"

The answer: Yes, you can hear it. And it sounds like this.`,
    attribution: "HOTBOII",
    credits: [
      "ω⁰: Fundamental only — 1 frequency",
      "ω¹: Fundamental + first harmonic — 2 frequencies",
      "ω²: Fundamental + harmonics 1–4 — 5 frequencies",
      "ω^ω: Fundamental + exponential harmonic series — infinite frequencies",
      "ε₀: Fundamental + impredicative harmonic structure — undefined",
      "Recommended listening: high-quality headphones or studio monitors",
      "Consultants: Dr. Sarah Chen, Dr. Pavel Petrov and Dr. Yuki Tanaka",
    ],
    notes: [],
  },
  {
    catalog: "CHEF-ARCHIVE-250",
    label: "Limited Collector's Edition · 250 copies · December 2026",
    statement: `To whoever owns copy #____:

You're holding the complete first chapter of verified trap mathematics. Everything I proved between 2024–2026 is in this box. Every theorem, every track, every collaboration.

The proofs in these albums aren't just correct—they're beautiful. The music isn't just beautiful—it's correct. That's the standard. That's the vision. That's what verification means.

Thank you for believing that trap and topology belong together. You were right.

Stay verified,`,
    attribution: "HOTBOII · Atlanta, December 2026",
    credits: [
      "Certificate of authenticity: copy #____ of 250",
      "All three studio albums, 30 tracks, and Ordinal Frequencies EP",
      "Two hours of unreleased studio sessions",
      `87-minute documentary: "Verified: The Making of CHEF VIZ PRO"`,
      "100GB USB: 24-bit audio, Lean4 source, ProRes documentary and stems",
      "Sustainable cherry-wood box, 14 × 12 × 4 inches",
      "QED relief carving and brass numbered nameplate",
      "Mathematics licensed CC BY-SA 4.0; audio all rights reserved",
      "licensing@chefvizpro.com · mathematics@chefvizpro.com · info@chefvizpro.com",
    ],
    notes: [],
  },
];
