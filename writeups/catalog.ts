import { catalogLiners, type AlbumLiner } from "../catalogLiners";

export type ReleaseKind =
  | "studio-album"
  | "collaboration-album"
  | "deluxe-edition"
  | "ep"
  | "archive";

export type CatalogTrack = {
  id: string;
  sequence: string;
  title: string;
  duration: string | null;
  annotation: string;
};

export type CatalogRelease = {
  id: string;
  slug: string;
  title: string;
  artist: "HOTBOII";
  kind: ReleaseKind;
  releaseDate: string;
  runtime: string;
  genre: readonly string[];
  theme: string;
  palette: string;
  price: number;
  currency: "USD";
  formats: readonly string[];
  tracks: CatalogTrack[];
  liner: AlbumLiner;
  relatedArticleSlugs: readonly string[];
};

type ReleaseMetadata = Omit<CatalogRelease, "tracks" | "liner" | "artist" | "currency">;

const metadata: ReleaseMetadata[] = [
  {
    id: "CHEF-VTA-001",
    slug: "verified-trap-aesthetics",
    title: "Verified Trap Aesthetics",
    kind: "studio-album",
    releaseDate: "2026-03-29",
    runtime: "44:31",
    genre: ["Verified Trap", "Mathematical Hip-Hop"],
    theme: "Formal proof theory translated into melodic trap.",
    palette: "orange",
    price: 34.99,
    formats: ["180g Vinyl", "CD", "Cassette", "Hi-Res FLAC", "Dolby Atmos"],
    relatedArticleSlugs: ["zu-chongzhi-355-113"],
  },
  {
    id: "CHEF-GS-002",
    slug: "global-synthesis",
    title: "Global Synthesis",
    kind: "collaboration-album",
    releaseDate: "2026-06-20",
    runtime: "58:31",
    genre: ["Verified Trap", "Tech-Fusion"],
    theme: "Mathematical excellence across industries and borders.",
    palette: "synthesis",
    price: 39.99,
    formats: ["Splatter Vinyl", "Deluxe CD", "Digital Deluxe", "Dolby Atmos"],
    relatedArticleSlugs: ["ssas-bottledroppas"],
  },
  {
    id: "CHEF-LSC-003",
    slug: "lean-semantics-chaos-theory",
    title: "Lean Semantics & Chaos Theory",
    kind: "collaboration-album",
    releaseDate: "2026-09-10",
    runtime: "29:29",
    genre: ["International Hip-Hop", "Type Theory"],
    theme: "Cultural fusion, formal semantics and chaos.",
    palette: "chaos",
    price: 36.99,
    formats: ["Purple Marble Vinyl", "CD", "Limited Box", "Hi-Res FLAC"],
    relatedArticleSlugs: ["ssas-bottledroppas"],
  },
  {
    id: "CHEF-AOH-DLX",
    slug: "architecture-of-harmony-complete",
    title: "The Architecture of Harmony — Complete",
    kind: "deluxe-edition",
    releaseDate: "2026-12-01",
    runtime: "Complete catalog + 20:58 bonus program",
    genre: ["Comprehensive Verified Trap"],
    theme: "The complete architecture: thirty tracks and five ordinal studies.",
    palette: "complete",
    price: 149.99,
    formats: ["4×LP Box", "3×CD", "Hardcover Book", "24-bit / 96kHz"],
    relatedArticleSlugs: ["ssas-bottledroppas", "zu-chongzhi-355-113"],
  },
  {
    id: "CHEF-OF-EP1",
    slug: "ordinal-frequencies",
    title: "Ordinal Frequencies",
    kind: "ep",
    releaseDate: "2026-10-01",
    runtime: "19:58",
    genre: ["Experimental Verified Trap", "Instrumental Mathematics"],
    theme: "Five ordinal levels expressed through a shared 55Hz foundation.",
    palette: "ordinal",
    price: 24.99,
    formats: ["10-inch 45rpm", "Hi-Res FLAC", "Limited to 1,000"],
    relatedArticleSlugs: [],
  },
  {
    id: "CHEF-ARCHIVE-250",
    slug: "complete-chef-archive",
    title: "The Complete CHEF Archive",
    kind: "archive",
    releaseDate: "2026-12-15",
    runtime: "Complete archive",
    genre: ["Ultimate Collection"],
    theme: "The complete first chapter in 250 numbered objects.",
    palette: "archive",
    price: 499.99,
    formats: ["Cherry-Wood Box", "Vinyl + CD", "100GB USB", "200-page Art Book"],
    relatedArticleSlugs: ["ssas-bottledroppas", "zu-chongzhi-355-113"],
  },
];

const trackOverrides: Record<string, CatalogTrack[]> = {
  "CHEF-OF-EP1": [
    ["01", "ω⁰ (55Hz) — Foundation Bass", "3:31", "Fundamental only: one frequency."],
    ["02", "ω¹ (110Hz) — First Harmonic", "3:45", "Fundamental plus first harmonic: two frequencies."],
    ["03", "ω² (220Hz) — Second Ordinal", "3:52", "Fundamental plus harmonics one through four."],
    ["04", "ω^ω — Omega to Omega", "4:03", "An exponential harmonic series represented as infinite recursion."],
    ["05", "ε₀ — Epsilon Zero", "4:47", "An impredicative harmonic structure at the edge of construction."],
  ].map(([sequence, title, duration, annotation], index) => ({
    id: `CHEF-OF-EP1-T${String(index + 1).padStart(2, "0")}`,
    sequence,
    title,
    duration,
    annotation,
  })),
};

function parseTrack(id: string, source: AlbumLiner["notes"][number], index: number): CatalogTrack {
  const match = source.title.match(/^((?:\d+|B\d+)) · (.*?)(?: \((\d+:\d+)\))?$/);
  return {
    id: `${id}-T${String(index + 1).padStart(2, "0")}`,
    sequence: match?.[1] ?? String(index + 1).padStart(2, "0"),
    title: match?.[2] ?? source.title,
    duration: match?.[3] ?? null,
    annotation: source.text,
  };
}

export const catalog: CatalogRelease[] = metadata.map((release, index) => {
  const liner = catalogLiners[index];
  return {
    ...release,
    artist: "HOTBOII",
    currency: "USD",
    liner,
    tracks:
      trackOverrides[release.id] ??
      liner.notes.map((note, trackIndex) =>
        parseTrack(release.id, note, trackIndex),
      ),
  };
});

export function getReleaseBySlug(slug: string | undefined) {
  return catalog.find((release) => release.slug === slug);
}

export function formatReleaseDate(date: string) {
  return new Intl.DateTimeFormat("en-US", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(`${date}T00:00:00Z`));
}
