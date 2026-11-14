import { createElement, useState, type ReactNode } from "react";
import { tourLegs, type TourStop } from "../data/tours";

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

function StopDetail({ stop }: { stop: TourStop }) {
  return (
    <section className="tour-day-detail">
      <div className="tour-day-heading">
        <div>
          <p className="eyebrow">Selected itinerary</p>
          <Title as="h2" className="tour-day-title">{stop.city}</Title>
          <p>{stop.region}, {stop.country} · {stop.venue}</p>
        </div>
        <div className="tour-date-block">
          <span>{new Date(`${stop.date}T00:00:00Z`).toLocaleDateString("en-US", { month: "short", timeZone: "UTC" })}</span>
          <strong>{stop.date.slice(-2)}</strong>
          <small>{stop.date.slice(0, 4)}</small>
        </div>
      </div>
      {stop.travelFrom && (
        <div className="travel-leg">
          <span>Inbound routing</span>
          <strong>{stop.travelFrom.city} → {stop.city}</strong>
          <div>
            <span>{stop.travelFrom.mode}</span>
            <span>{stop.travelFrom.distance}</span>
            <span>{stop.travelFrom.duration}</span>
          </div>
        </div>
      )}
      <div className="day-schedule">
        {stop.itinerary.map((item, index) => (
          <article key={`${item.time}-${item.label}`}>
            <span>{item.time}</span>
            <i />
            <div>
              <strong>{item.label}</strong>
              <p>{item.detail}</p>
            </div>
            <small>0{index + 1}</small>
          </article>
        ))}
      </div>
    </section>
  );
}

export default function TourPage() {
  const [activeStopId, setActiveStopId] = useState(tourLegs[0].stops[0].id);
  const allStops = tourLegs.flatMap((leg) => leg.stops);
  const activeStop = allStops.find((stop) => stop.id === activeStopId) ?? allStops[0];

  return (
    <main className="tour-page">
      <header className="tour-hero">
        <img
          src="https://images.unsplash.com/photo-1769368959365-7c28d4c1cc90?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=88&w=1800"
          alt="Tour bus moving through a city at night"
        />
        <div className="tour-hero-shade" />
        <div className="tour-hero-copy">
          <p className="eyebrow">Concept Routing · Fall 2026</p>
          <Title as="h1" className="tour-title">
            The Architecture
            <br />
            <i>on the road.</i>
          </Title>
          <p>
            Nine proposed stops. Two legs. One production moving from Atlanta
            to Tokyo with every transfer, reset and soundcheck mapped.
          </p>
        </div>
        <div className="tour-hero-meta">
          <span>Photo: Brad Rucker / Unsplash</span>
          <strong>9 cities · 45 days · 9,000+ miles</strong>
        </div>
      </header>

      <section className="tour-notice">
        <strong>Planning document</strong>
        <p>
          This is a conceptual itinerary, not an announced tour. Dates, venues,
          travel times and artist appearances are provisional. Do not book travel.
        </p>
      </section>

      <section className="tour-routing">
        <div className="tour-routing-head">
          <div>
            <p className="eyebrow">Master Route</p>
            <Title as="h2" className="tour-routing-title">City by city.</Title>
          </div>
          <div className="tour-legend">
            <span><i className="hold" /> Hold</span>
            <span><i className="proposed" /> Proposed</span>
            <span><i className="routing" /> Routing</span>
          </div>
        </div>
        {tourLegs.map((leg, legIndex) => (
          <section className="tour-leg" key={leg.id}>
            <div className="tour-leg-intro">
              <span>Leg 0{legIndex + 1} · {leg.id}</span>
              <Title as="h3" className="tour-leg-title">{leg.name}</Title>
              <p>{leg.dates} · {leg.theme}</p>
            </div>
            <div className="tour-stops">
              {leg.stops.map((stop, index) => (
                <Button
                  className={activeStop.id === stop.id ? "tour-stop active" : "tour-stop"}
                  key={stop.id}
                  onClick={() => setActiveStopId(stop.id)}
                >
                  <span className={`tour-status ${stop.status}`} />
                  <small>{String(index + 1).padStart(2, "0")}</small>
                  <strong>{stop.city}</strong>
                  <span>{stop.region} · {stop.date.slice(5).replace("-", ".")}</span>
                </Button>
              ))}
            </div>
          </section>
        ))}
      </section>

      <StopDetail stop={activeStop} />

      <section className="tour-logistics">
        <div>
          <p className="eyebrow">Tour Standards</p>
          <Title as="h2" className="tour-logistics-title">Move precisely.</Title>
        </div>
        <div className="logistics-grid">
          <article><span>01</span><strong>Travel buffers</strong><p>Minimum twelve-hour crew rest after overnight bus legs and one dark day after intercontinental flights.</p></article>
          <article><span>02</span><strong>Freight</strong><p>Primary production travels by truck in North America and bonded freight internationally. Fly dates use duplicate playback.</p></article>
          <article><span>03</span><strong>Documents</strong><p>Passports, work permits, carnets, manifests and insurance certificates cleared before final ticketing.</p></article>
          <article><span>04</span><strong>Accessibility</strong><p>Step-free routing, accessible viewing positions, captioned visuals and quiet-space requirements advance with every venue.</p></article>
        </div>
      </section>
    </main>
  );
}
