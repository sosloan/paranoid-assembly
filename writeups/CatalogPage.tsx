import { createElement, type ReactNode } from "react";
import { Link, useParams } from "react-router";
import {
  catalog,
  formatReleaseDate,
  getReleaseBySlug,
  type CatalogRelease,
} from "../data/catalog";
import { articles } from "../data/articles";

function Title({
  as,
  children,
  className,
}: {
  as: "h1" | "h2" | "h3";
  children: ReactNode;
  className: string;
}) {
  return createElement(as, { className }, children);
}

function ReleaseCover({ release }: { release: CatalogRelease }) {
  const formula =
    release.palette === "orange"
      ? "∫ TRAP dt"
      : release.palette === "synthesis"
        ? "Σ GLOBAL"
        : release.palette === "chaos"
          ? "dx/dt = σ(y−x)"
          : release.palette === "ordinal"
            ? "ω^ω"
            : "Q.E.D.";

  return (
    <div className={`release-cover ${release.palette}`}>
      <span className="cover-catalog">{release.id}</span>
      <span className="cover-formula">{formula}</span>
      <div>
        <small>{release.artist}</small>
        <Title as="h3" className="cover-title">{release.title}</Title>
      </div>
      <span className="cover-label">CHEF VIZ PRO · 2026</span>
    </div>
  );
}

function CatalogIndex() {
  return (
    <>
      <header className="catalog-route-hero">
        <p className="eyebrow">Canonical Catalog · 2026</p>
        <Title as="h1" className="catalog-route-title">
          Every release.
          <br />
          <i>One source of truth.</i>
        </Title>
        <p>
          Six editions normalized from the physical liner archive. Stable IDs,
          dates, tracks, formats and relationships now power every catalog view.
        </p>
      </header>
      <section className="catalog-route-grid">
        {catalog.map((release, index) => (
          <Link className="catalog-route-card" key={release.id} to={`/catalog/${release.slug}`}>
            <div className="catalog-card-number">0{index + 1}</div>
            <ReleaseCover release={release} />
            <div className="catalog-card-copy">
              <span>{release.id}</span>
              <Title as="h2" className="catalog-card-title">{release.title}</Title>
              <p>{release.kind.replace(/-/g, " ")} · {formatReleaseDate(release.releaseDate)}</p>
            </div>
          </Link>
        ))}
      </section>
      <section className="catalog-data-note">
        <span>Catalog policy</span>
        <p>
          The latest physical liner sequence is canonical. Earlier conflicting
          draft titles and catalog numbers are treated as superseded working
          metadata.
        </p>
      </section>
    </>
  );
}

function ReleaseDetail({ release }: { release: CatalogRelease }) {
  const relatedArticles = articles.filter((article) =>
    release.relatedArticleSlugs.includes(article.slug),
  );

  return (
    <main className="release-route">
      <div className="release-route-breadcrumb">
        <Link to="/catalog">Catalog</Link>
        <span>/</span>
        <span>{release.id}</span>
      </div>
      <section className="release-route-hero">
        <ReleaseCover release={release} />
        <div className="release-route-intro">
          <p className="eyebrow">{release.id} · {release.kind.replace(/-/g, " ")}</p>
          <Title as="h1" className="release-route-title">{release.title}</Title>
          <p className="release-route-theme">{release.theme}</p>
          <dl>
            <div><dt>Release</dt><dd>{formatReleaseDate(release.releaseDate)}</dd></div>
            <div><dt>Runtime</dt><dd>{release.runtime}</dd></div>
            <div><dt>Genre</dt><dd>{release.genre.join(" / ")}</dd></div>
            <div><dt>Edition from</dt><dd>${release.price.toFixed(2)} {release.currency}</dd></div>
          </dl>
          <div className="release-route-formats">
            {release.formats.map((format) => <span key={format}>{format}</span>)}
          </div>
        </div>
      </section>

      <section className="canonical-tracklist">
        <div className="canonical-section-head">
          <div>
            <p className="eyebrow">Canonical Sequence</p>
            <Title as="h2" className="canonical-title">Track register</Title>
          </div>
          <span>{release.tracks.length} entries</span>
        </div>
        {release.tracks.length ? (
          release.tracks.map((track) => (
            <article className="canonical-track" key={track.id}>
              <span>{track.sequence}</span>
              <div>
                <Title as="h3" className="canonical-track-title">{track.title}</Title>
                <p>{track.annotation}</p>
              </div>
              <span>{track.duration ?? "Archive"}</span>
              <small>{track.id}</small>
            </article>
          ))
        ) : (
          <p className="canonical-empty">
            This edition references the complete catalog rather than defining a
            separate audio sequence.
          </p>
        )}
      </section>

      <section className="canonical-liner">
        <div>
          <p className="eyebrow">Physical Liner Archive</p>
          <Title as="h2" className="canonical-title">{release.liner.label}</Title>
        </div>
        <blockquote>
          {release.liner.statement.split("\n\n").map((paragraph) => (
            <p key={paragraph}>{paragraph}</p>
          ))}
          <cite>— {release.liner.attribution}</cite>
        </blockquote>
        <div className="canonical-credits">
          {release.liner.credits.map((credit) => <p key={credit}>{credit}</p>)}
        </div>
      </section>

      {relatedArticles.length > 0 && (
        <section className="related-route-articles">
          <p className="eyebrow">Related Reading</p>
          {relatedArticles.map((article) => (
            <Link key={article.slug} to={`/articles/${article.slug}`}>
              <span>{article.subject}</span>
              <Title as="h3" className="related-route-title">{article.title}</Title>
              <p>{article.description}</p>
            </Link>
          ))}
        </section>
      )}
    </main>
  );
}

export default function CatalogPage() {
  const { releaseSlug } = useParams();
  if (!releaseSlug) return <CatalogIndex />;

  const release = getReleaseBySlug(releaseSlug);
  if (!release) {
    return (
      <main className="not-found-page">
        <span>CATALOG / UNKNOWN EDITION</span>
        <Title as="h1" className="not-found-title">Release not found.</Title>
        <Link to="/catalog">Return to the catalog</Link>
      </main>
    );
  }
  return <ReleaseDetail release={release} />;
}
