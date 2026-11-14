import { createElement, useMemo, useState, type ReactNode } from "react";
import { useLocation } from "react-router";
import { magazineSections } from "../data/magazineSections";

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

export default function MagazineSectionPage() {
  const slug = useLocation().pathname.split("/").filter(Boolean)[0] ?? "journal";
  const section = magazineSections[slug] ?? magazineSections.journal;
  const tags = useMemo(
    () => ["All", ...new Set(section.cards.flatMap((card) => card.tags))],
    [section],
  );
  const [activeTag, setActiveTag] = useState("All");
  const cards =
    activeTag === "All"
      ? section.cards
      : section.cards.filter((card) => card.tags.includes(activeTag));

  return (
    <main className={`mag-section-page mag-${section.slug}`}>
      <header className="mag-section-hero">
        <p className="eyebrow">Volume / {section.label}</p>
        <Title as="h1" className="mag-section-title">{section.title}</Title>
        <p>{section.intro}</p>
      </header>
      <section className="mag-metric-strip">
        {section.metrics.map((metric, index) => (
          <div key={metric.label}>
            <span>0{index + 1} · {metric.label}</span>
            <strong>{metric.value}</strong>
            <small>{metric.change ?? "Current issue"}</small>
          </div>
        ))}
      </section>
      <section className="mag-card-section">
        <div className="mag-filter-row">
          <span>Explore {section.label}</span>
          <div>
            {tags.map((tag) => (
              <Button
                className={activeTag === tag ? "active" : ""}
                key={tag}
                onClick={() => setActiveTag(tag)}
              >
                {tag}
              </Button>
            ))}
          </div>
        </div>
        <div className="mag-card-grid">
          {cards.map((card, index) => (
            <article className={`mag-data-card ${card.accent}`} key={card.title}>
              <div className="mag-card-top">
                <span>{card.eyebrow}</span>
                <small>0{index + 1}</small>
              </div>
              <Title as="h2" className="mag-card-title">{card.title}</Title>
              <p>{card.description}</p>
              <div className="mag-card-bottom">
                <span>{card.meta}</span>
                <div>{card.tags.map((tag) => <small key={tag}>{tag}</small>)}</div>
              </div>
            </article>
          ))}
        </div>
      </section>
      <section className="mag-data-disclosure">
        <span>Data note</span>
        <p>
          Catalog counts are derived from the canonical Volume model. Commerce
          and audience figures are clearly labeled modeled or opt-in and should
          be replaced by connected Chinook aggregates in production.
        </p>
      </section>
    </main>
  );
}
