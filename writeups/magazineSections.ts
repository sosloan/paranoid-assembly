export type Metric = {
  label: string;
  value: string;
  change?: string;
};

export type MagazineCard = {
  eyebrow: string;
  title: string;
  description: string;
  meta: string;
  accent: "orange" | "blue" | "green" | "gold";
  tags: readonly string[];
};

export type MagazineSection = {
  slug: string;
  label: string;
  title: string;
  intro: string;
  metrics: readonly Metric[];
  cards: readonly MagazineCard[];
};

export const magazineSections: Record<string, MagazineSection> = {
  journal: {
    slug: "journal",
    label: "The Journal",
    title: "Original thinking, catalog evidence.",
    intro:
      "Editorial concepts, close listening and observations generated from the canonical catalog.",
    metrics: [
      { label: "Published features", value: "24", change: "+6 this issue" },
      { label: "Long reads", value: "08" },
      { label: "Catalog notes", value: "56" },
      { label: "Reading time", value: "3h 42m" },
    ],
    cards: [
      { eyebrow: "Formal Music", title: "The Drop Is the Proof", description: "SSAS maps bass, gravity and bravado onto a parabolic arc.", meta: "12 min read", accent: "orange", tags: ["Mathematics", "Tracks"] },
      { eyebrow: "History of Sound", title: "The Fraction That Outlived Empires", description: "Zu Chongzhi’s precision returns as a three-voice composition.", meta: "14 min read", accent: "gold", tags: ["History", "Artists"] },
      { eyebrow: "Catalog Study", title: "What Does an Ordinal Sound Like?", description: "Five frequency studies move from 55Hz toward ε₀.", meta: "8 min read", accent: "blue", tags: ["Albums", "Theory"] },
      { eyebrow: "Manufacturing", title: "Why the Object Still Matters", description: "Foil, fluorescent ink and cherry wood make a digital catalog physical.", meta: "7 min read", accent: "green", tags: ["Artworks", "Design"] },
      { eyebrow: "Data Notes", title: "The Playlist as Proof Graph", description: "Shared tracks expose hidden relationships between listening contexts.", meta: "6 min read", accent: "blue", tags: ["Playlists", "Data"] },
      { eyebrow: "Essay", title: "Precision Is a Creative Constraint", description: "Rules do not eliminate invention. They give it a surface to push against.", meta: "10 min read", accent: "orange", tags: ["Theory", "Culture"] },
    ],
  },
  artists: {
    slug: "artists",
    label: "Artists",
    title: "Every voice leaves a graph.",
    intro:
      "Discographies, track relationships, genre movement and playlist connections in one editorial profile.",
    metrics: [
      { label: "Artists indexed", value: "275" },
      { label: "Collaborations", value: "84" },
      { label: "Average track", value: "3:54" },
      { label: "Modeled revenue", value: "$42.8k" },
    ],
    cards: [
      { eyebrow: "Featured Profile", title: "HOTBOII", description: "Three albums, formal proofs and a catalog built as one connected architecture.", meta: "30 tracks · 5 genres", accent: "orange", tags: ["Verified Trap", "Hip-Hop"] },
      { eyebrow: "Collaboration", title: "Kevin Gates", description: "Chaos theory, philosophical precision and recurring bridge tracks.", meta: "4 connections", accent: "gold", tags: ["Louisiana", "Features"] },
      { eyebrow: "International", title: "Black Russian", description: "Type theory and bilingual semantics across seven collaboration tracks.", meta: "26:47 runtime", accent: "blue", tags: ["Type Theory", "Global"] },
      { eyebrow: "Network Node", title: "WondaGurl", description: "Recursive production and fixed-point structure on Loop Convergence.", meta: "1 catalog appearance", accent: "green", tags: ["Production", "Graph"] },
    ],
  },
  albums: {
    slug: "albums",
    label: "Albums",
    title: "Records as complete systems.",
    intro:
      "Track sequences, composer credits, runtimes, genre mixtures and purchase signals.",
    metrics: [
      { label: "Canonical releases", value: "06" },
      { label: "Main sequence", value: "30" },
      { label: "Bonus works", value: "05" },
      { label: "Physical formats", value: "15+" },
    ],
    cards: [
      { eyebrow: "Studio Album", title: "Verified Trap Aesthetics", description: "Eleven proofs move from infinite series to a final QED stamp.", meta: "44:31 · CHEF-VTA-001", accent: "orange", tags: ["11 tracks", "2026"] },
      { eyebrow: "Collaboration Album", title: "Global Synthesis", description: "Industrial systems and mathematical frameworks become production material.", meta: "58:31 · CHEF-GS-002", accent: "blue", tags: ["14 tracks", "Global"] },
      { eyebrow: "Artist Collaboration", title: "Lean Semantics & Chaos Theory", description: "Seven tracks test meaning across code, culture and language.", meta: "29:29 · CHEF-LSC-003", accent: "green", tags: ["7 tracks", "Lean4"] },
      { eyebrow: "Deluxe Edition", title: "The Architecture of Harmony", description: "The complete catalog plus five ordinal instrumental studies.", meta: "4×LP · 3×CD", accent: "gold", tags: ["Box set", "Complete"] },
    ],
  },
  tracks: {
    slug: "tracks",
    label: "Tracks",
    title: "One recording. Every connection.",
    intro:
      "Credits, release relationships, media formats, pricing, purchases and playlist appearances.",
    metrics: [
      { label: "Tracks indexed", value: "35" },
      { label: "Average duration", value: "4:02" },
      { label: "Hi-res masters", value: "30" },
      { label: "Playlist links", value: "142" },
    ],
    cards: [
      { eyebrow: "CHEF-022-BTLD", title: "BottleDroppas", description: "Ballistic trajectory theory at 148 BPM in E♭ minor.", meta: "3:39 · Hi-Res FLAC", accent: "orange", tags: ["SSAS", "Mechanics"] },
      { eyebrow: "CHEF-007-ZCZ", title: "祖冲之 — 355/113", description: "A precision approximation translated into three vocal registers.", meta: "4:06 · 138 BPM", accent: "gold", tags: ["History", "π"] },
      { eyebrow: "Track 09", title: "Lean Semantics", description: "A type-correct thesis statement where beat switches mirror dependencies.", meta: "4:44 · Spatial audio", accent: "blue", tags: ["Lean4", "Semantics"] },
      { eyebrow: "Track 25", title: "Black QAG", description: "Ordinal arithmetic structures a quality-assurance collaboration.", meta: "4:12 · 24/96", accent: "green", tags: ["Ordinal", "Remix"] },
    ],
  },
  genres: {
    slug: "genres",
    label: "Genres",
    title: "Scenes, systems and evolution.",
    intro:
      "Artist and album exploration organized around sound rather than database tables.",
    metrics: [
      { label: "Verified Trap share", value: "42%" },
      { label: "Hip-Hop share", value: "31%" },
      { label: "Experimental", value: "18%" },
      { label: "Other", value: "9%" },
    ],
    cards: [
      { eyebrow: "Genre 01", title: "Verified Trap", description: "Precision, formal verification and 808 architecture.", meta: "18 artists · 46 tracks", accent: "orange", tags: ["Core", "Growing"] },
      { eyebrow: "Genre 02", title: "Mathematical Hip-Hop", description: "Proof language and historical mathematics enter lyrical form.", meta: "12 artists · 31 tracks", accent: "blue", tags: ["Editorial", "Theory"] },
      { eyebrow: "Genre 03", title: "Tech-Fusion", description: "Industrial data, signal processing and production systems.", meta: "9 artists · 22 tracks", accent: "green", tags: ["Global", "Electronic"] },
      { eyebrow: "Genre 04", title: "Ordinal Ambient", description: "Harmonic structures expand toward transfinite abstraction.", meta: "5 artists · 11 tracks", accent: "gold", tags: ["Instrumental", "Experimental"] },
    ],
  },
  playlists: {
    slug: "playlists",
    label: "Playlists",
    title: "Curation reveals relationships.",
    intro:
      "Runtime, diversity, represented artists and shared-track similarity explain why a sequence holds together.",
    metrics: [
      { label: "Editorial lists", value: "18" },
      { label: "Average diversity", value: "0.74" },
      { label: "Shared tracks", value: "63" },
      { label: "Mean runtime", value: "54m" },
    ],
    cards: [
      { eyebrow: "High Diversity · 0.91", title: "Eight Traditions", description: "A global sequence crossing languages, artists and mathematical schools.", meta: "22 tracks · 1h 34m", accent: "blue", tags: ["12 artists", "8 genres"] },
      { eyebrow: "Jaccard · 0.68", title: "Proof Before Playback", description: "Lean semantics, test-driven production and formally structured tracks.", meta: "16 tracks · 1h 08m", accent: "green", tags: ["Theory", "Code"] },
      { eyebrow: "Editorial Pick", title: "55Hz After Dark", description: "Sub-bass studies and slow harmonic movement for close listening.", meta: "14 tracks · 58m", accent: "orange", tags: ["Instrumental", "Bass"] },
      { eyebrow: "Shared Tracks · 9", title: "The Collaboration Graph", description: "Bridge tracks connecting corporate and artist-led releases.", meta: "19 tracks · 1h 21m", accent: "gold", tags: ["Features", "Network"] },
    ],
  },
  numbers: {
    slug: "numbers",
    label: "The Numbers",
    title: "The business behind the listening.",
    intro:
      "Monthly revenue, genre share, leading catalog items, territories and media formats.",
    metrics: [
      { label: "Modeled year-one", value: "$278k", change: "+18% plan" },
      { label: "Physical share", value: "44%" },
      { label: "Direct margin", value: "89%" },
      { label: "Markets", value: "07" },
    ],
    cards: [
      { eyebrow: "Revenue Leader", title: "Collector Editions", description: "Scarce physical objects produce the strongest direct-sales contribution.", meta: "$125k modeled", accent: "gold", tags: ["DTC", "Physical"] },
      { eyebrow: "Format Share", title: "Vinyl Holds the Center", description: "Audiophile editions balance premium pricing and repeat demand.", meta: "3,000 units modeled", accent: "orange", tags: ["Vinyl", "Retail"] },
      { eyebrow: "Territory", title: "The Seven-Market Plan", description: "USA leads, with Japan, Germany and the UK driving premium physical sales.", meta: "7 regions", accent: "blue", tags: ["Global", "Distribution"] },
      { eyebrow: "Channel", title: "Direct Is the Margin", description: "Artist-direct channels retain the largest share after fulfillment.", meta: "85–95% gross", accent: "green", tags: ["Bandcamp", "Store"] },
    ],
  },
  audience: {
    slug: "audience",
    label: "Audience / Editorial Desk",
    title: "Affinity without surveillance.",
    intro:
      "Opt-in purchase patterns, timelines and support relationships designed around consent.",
    metrics: [
      { label: "Opt-in profiles", value: "1,284" },
      { label: "Average order", value: "$68.40" },
      { label: "Lifetime value", value: "$214" },
      { label: "Support coverage", value: "96%" },
    ],
    cards: [
      { eyebrow: "Affinity Cluster", title: "The Physical Archivists", description: "Collectors favor numbered editions, books and proof-source bundles.", meta: "18% of opt-in audience", accent: "gold", tags: ["High LTV", "Physical"] },
      { eyebrow: "Affinity Cluster", title: "The Formal Listeners", description: "Lean4 notes and instrumental demonstrations drive repeat sessions.", meta: "27% of opt-in audience", accent: "blue", tags: ["Digital", "Education"] },
      { eyebrow: "Support Desk", title: "Managed Relationships", description: "Regional coverage links customer questions to accountable staff.", meta: "4 regions · 8 owners", accent: "green", tags: ["Support", "Hierarchy"] },
      { eyebrow: "Privacy Standard", title: "Consent Is a Feature", description: "Purchase affinity appears only for customers who explicitly opt in.", meta: "No inferred sensitive traits", accent: "orange", tags: ["Privacy", "Trust"] },
    ],
  },
};
