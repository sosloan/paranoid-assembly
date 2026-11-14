import { createElement, useMemo, useState, type ReactNode } from "react";

type IconName =
  | "arrow"
  | "bookmark"
  | "headphones"
  | "menu"
  | "moon"
  | "pause"
  | "play"
  | "search"
  | "sun";

const heroImage =
  "https://images.unsplash.com/photo-1600119692901-94e8b7d2eacd?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=88&w=1800";

const stories = [
  {
    kicker: "The Long Read",
    title: "The quiet architecture of a perfect opening track",
    blurb:
      "Before the chorus, before the hook: how artists build a world in under sixty seconds.",
    image:
      "https://images.unsplash.com/photo-1552595458-3df9ba563207?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=1000",
    tag: "Culture",
    size: "feature",
  },
  {
    kicker: "Scene Report",
    title: "Inside the rooms where guitar music came back to life",
    blurb:
      "A new generation is making the club circuit feel necessary again.",
    image:
      "https://images.unsplash.com/photo-1598295893369-1918ffaf89a2?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=900",
    tag: "Rock",
    size: "standard",
  },
  {
    kicker: "Data Notes",
    title: "What 26,000 playlists tell us about the songs we keep",
    blurb: "The strange, emotional logic behind our most replayed tracks.",
    image:
      "https://images.unsplash.com/uploads/1411160110892ab555b6f/80b0d25e?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=900",
    tag: "Intelligence",
    size: "standard",
  },
];

const albums = [
  {
    artist: "Maya Rowe",
    title: "Soft Static",
    genre: "Alternative",
    image:
      "https://images.unsplash.com/photo-1681404141874-633aa2de7c76?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=800",
    score: "9.1",
    color: "coral",
  },
  {
    artist: "Arlo Saint",
    title: "Blue Hour",
    genre: "Neo-Soul",
    image:
      "https://images.unsplash.com/photo-1647314963806-33b4278d3da4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=800",
    score: "8.8",
    color: "blue",
  },
  {
    artist: "The Ends",
    title: "Still Moving",
    genre: "Indie Rock",
    image:
      "https://images.unsplash.com/photo-1647314942572-6bc428e0a01a?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=800",
    score: "8.6",
    color: "gold",
  },
  {
    artist: "Nia Vale",
    title: "Afterimage",
    genre: "Electronic",
    image:
      "https://images.unsplash.com/photo-1664747144775-8c8fcfa4bf92?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=800",
    score: "8.4",
    color: "violet",
  },
];

const genres = [
  { name: "Alternative", value: 86, delta: "+18%" },
  { name: "R&B / Soul", value: 72, delta: "+12%" },
  { name: "Electronic", value: 61, delta: "+9%" },
  { name: "Hip-Hop", value: 48, delta: "+6%" },
];

function Icon({ name, size = 18 }: { name: IconName; size?: number }) {
  const paths: Record<IconName, ReactNode> = {
    arrow: <path d="M5 12h14M14 6l6 6-6 6" />,
    bookmark: <path d="M6 4.75A1.75 1.75 0 0 1 7.75 3h8.5A1.75 1.75 0 0 1 18 4.75V21l-6-3.75L6 21V4.75Z" />,
    headphones: (
      <>
        <path d="M4 14v-2a8 8 0 0 1 16 0v2" />
        <path d="M4 14h3v6H5.5A1.5 1.5 0 0 1 4 18.5V14Zm16 0h-3v6h1.5a1.5 1.5 0 0 0 1.5-1.5V14Z" />
      </>
    ),
    menu: <path d="M4 7h16M4 12h16M4 17h16" />,
    moon: <path d="M20.5 15.4A8.5 8.5 0 0 1 8.6 3.5 8.5 8.5 0 1 0 20.5 15.4Z" />,
    pause: (
      <>
        <path d="M9 7v10" />
        <path d="M15 7v10" />
      </>
    ),
    play: <path d="m9 7 8 5-8 5V7Z" />,
    search: (
      <>
        <circle cx="11" cy="11" r="6.5" />
        <path d="m16 16 4 4" />
      </>
    ),
    sun: (
      <>
        <circle cx="12" cy="12" r="3.5" />
        <path d="M12 2v2M12 20v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42" />
      </>
    ),
  };
  return (
    <svg
      aria-hidden="true"
      fill="none"
      height={size}
      viewBox="0 0 24 24"
      width={size}
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth="1.75"
    >
      {paths[name]}
    </svg>
  );
}

function Button({
  children,
  className = "",
  label,
  onClick,
}: {
  children: ReactNode;
  className?: string;
  label?: string;
  onClick?: () => void;
}) {
  return createElement(
    "button",
    {
      "aria-label": label,
      className,
      onClick,
      type: "button",
    },
    children,
  );
}

function Link({
  children,
  className = "",
  href = "#",
}: {
  children: ReactNode;
  className?: string;
  href?: string;
}) {
  return createElement("a", { className, href }, children);
}

function Heading({
  as,
  children,
  className = "",
}: {
  as: "h1" | "h2" | "h3";
  children: ReactNode;
  className?: string;
}) {
  return createElement(as, { className }, children);
}

function SectionHeader({
  eyebrow,
  title,
  action = "View all",
}: {
  eyebrow: string;
  title: string;
  action?: string;
}) {
  return (
    <div className="section-header">
      <div>
        <p className="eyebrow">{eyebrow}</p>
        <Heading as="h2" className="section-title">
          {title}
        </Heading>
      </div>
      <Link className="text-link" href="#stories">
        {action} <Icon name="arrow" />
      </Link>
    </div>
  );
}

export default function App() {
  const [playing, setPlaying] = useState(false);
  const [saved, setSaved] = useState<number[]>([]);
  const [activeGenre, setActiveGenre] = useState("All");

  const filteredAlbums = useMemo(
    () =>
      activeGenre === "All"
        ? albums
        : albums.filter((album) => album.genre.includes(activeGenre)),
    [activeGenre],
  );

  const toggleSaved = (index: number) => {
    setSaved((current) =>
      current.includes(index)
        ? current.filter((item) => item !== index)
        : [...current, index],
    );
  };

  return (
    <main className="app dark home-page">

      <section className="hero">
        <div className="hero-image-wrap">
          <img
            className="hero-image"
            src={heroImage}
            alt="Singer performing under dramatic stage lights"
          />
          <div className="hero-image-shade" />
          <p className="photo-credit">Photo: Chris Ainsworth / Unsplash</p>
          <div className="issue-chip">Issue No. 148</div>
        </div>
        <div className="hero-copy">
          <p className="eyebrow accent">Cover Story</p>
          <Heading as="h1" className="hero-title">
            The new
            <br />
            sound of <i>now.</i>
          </Heading>
          <p className="hero-deck">
            Meet the restless artists tearing up old rules and rebuilding pop
            music in their own image.
          </p>
          <div className="byline">
            <span className="byline-rule" />
            By Lena Okafor
            <span>12 min read</span>
          </div>
          <Link className="primary-link" href="#stories">
            Read the story <Icon name="arrow" />
          </Link>
        </div>
      </section>

      <section className="pulse-bar" aria-label="Live music statistics">
        <div className="pulse-label">
          <span className="live-dot" />
          The Pulse
        </div>
        <div className="ticker-track">
          <span>
            <b>01</b> Radiohead <em>+4</em>
          </span>
          <span>
            <b>02</b> Amy Winehouse <em>+2</em>
          </span>
          <span>
            <b>03</b> Miles Davis <em>+7</em>
          </span>
          <span>
            <b>04</b> Nina Simone <em>+1</em>
          </span>
        </div>
        <Link href="#charts">Full charts</Link>
      </section>

      <section className="page-section" id="stories">
        <SectionHeader eyebrow="The Edit" title="Stories worth hearing" />
        <div className="story-grid">
          {stories.map((story, index) => (
            <article className={`story-card ${story.size}`} key={story.title}>
              <div className="story-image-wrap">
                <img src={story.image} alt="" className="story-image" />
                <span className="story-tag">{story.tag}</span>
                <Button
                  className={`save-button ${saved.includes(index) ? "saved" : ""}`}
                  label={saved.includes(index) ? "Remove bookmark" : "Bookmark story"}
                  onClick={() => toggleSaved(index)}
                >
                  <Icon name="bookmark" />
                </Button>
              </div>
              <div className="story-copy">
                <p className="eyebrow">{story.kicker}</p>
                <Heading as="h3" className="story-title">
                  {story.title}
                </Heading>
                <p className="story-blurb">{story.blurb}</p>
                <p className="story-meta">8 min read · June 14</p>
              </div>
            </article>
          ))}
        </div>
      </section>


      <section className="intelligence-section" id="charts">
        <div className="intelligence-copy">
          <p className="eyebrow light-eyebrow">Volume Intelligence</p>
          <Heading as="h2" className="intelligence-title">
            What the world
            <br />
            is listening to.
          </Heading>
          <p className="intelligence-deck">
            Millions of plays, purchases and playlists reveal where culture is
            moving next.
          </p>
          <div className="insight-stat">
            <strong>18.4M</strong>
            <span>listening events analyzed this week</span>
          </div>
        </div>
        <div className="chart-card">
          <div className="chart-head">
            <div>
              <span>Genre momentum</span>
              <strong>Last 30 days</strong>
            </div>
            <span className="chart-status">Live data</span>
          </div>
          <div className="genre-chart">
            {genres.map((genre, index) => (
              <div className="genre-row" key={genre.name}>
                <span className="genre-rank">0{index + 1}</span>
                <span className="genre-name">{genre.name}</span>
                <span className="genre-bar-track">
                  <span
                    className="genre-bar"
                    style={{ "--bar-width": `${genre.value}%` } as React.CSSProperties}
                  />
                </span>
                <em>{genre.delta}</em>
              </div>
            ))}
          </div>
          <div className="now-playing">
            <Button
              className="play-button"
              label={playing ? "Pause track" : "Play track"}
              onClick={() => setPlaying(!playing)}
            >
              <Icon name={playing ? "pause" : "play"} />
            </Button>
            <div className="track-info">
              <span>Trending now</span>
              <strong>Midnight on Mercer · Maya Rowe</strong>
            </div>
            <div className={`waveform ${playing ? "is-playing" : ""}`}>
              {Array.from({ length: 24 }, (_, index) => (
                <i key={index} style={{ height: `${20 + ((index * 17) % 70)}%` }} />
              ))}
            </div>
            <span className="track-time">3:42</span>
          </div>
        </div>
      </section>

      <section className="page-section album-section" id="reviews">
        <SectionHeader
          eyebrow="Fresh Pressings"
          title="Albums in rotation"
          action="All reviews"
        />
        <div className="filter-row" aria-label="Filter albums by genre">
          {["All", "Alternative", "Soul", "Electronic"].map((genre) => (
            <Button
              className={activeGenre === genre ? "filter active" : "filter"}
              key={genre}
              onClick={() => setActiveGenre(genre)}
            >
              {genre}
            </Button>
          ))}
        </div>
        <div className="album-grid">
          {filteredAlbums.map((album) => (
            <article className="album-card" key={album.title}>
              <div className="album-cover-wrap">
                <img src={album.image} alt="" className="album-cover" />
                <span className={`score ${album.color}`}>{album.score}</span>
                <Button className="album-play" label={`Play ${album.title}`}>
                  <Icon name="play" size={22} />
                </Button>
              </div>
              <p className="album-genre">{album.genre}</p>
              <Heading as="h3" className="album-title">
                {album.title}
              </Heading>
              <p className="album-artist">{album.artist}</p>
            </article>
          ))}
        </div>
      </section>


      <section className="dispatch">
        <div className="dispatch-monogram">
          <Icon name="headphones" size={38} />
        </div>
        <p className="eyebrow">The Sunday Dispatch</p>
        <Heading as="h2" className="dispatch-title">
          The week in music,
          <br />
          distilled.
        </Heading>
        <p>
          One thoughtful email. Essential records, sharp criticism and the
          stories shaping how we listen.
        </p>
        <Button className="dispatch-button">
          Join 48,000 readers <Icon name="arrow" />
        </Button>
        <small>No noise. Unsubscribe any time.</small>
      </section>

    </main>
  );
}
