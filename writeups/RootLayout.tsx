import { NavLink, Outlet, ScrollRestoration } from "react-router";

const links = [
  ["/", "Discover"],
  ["/journal", "Journal"],
  ["/artists", "Artists"],
  ["/albums", "Albums"],
  ["/tracks", "Tracks"],
  ["/genres", "Genres"],
  ["/playlists", "Playlists"],
  ["/numbers", "Numbers"],
  ["/audience", "Audience"],
  ["/studio", "Studio"],
];

export default function RootLayout() {
  return (
    <div className="route-shell">
      <header className="route-header">
        <NavLink className="route-logo" to="/">
          <span>V</span>
          VOLUME
        </NavLink>
        <nav aria-label="Primary navigation">
          {links.map(([to, label]) => (
            <NavLink
              className={({ isActive }) => (isActive ? "active" : undefined)}
              end={to === "/"}
              key={to}
              to={to}
            >
              {label}
            </NavLink>
          ))}
        </nav>
        <span className="route-edition">CHEF VIZ PRO · 2026</span>
      </header>
      <Outlet />
      <footer className="route-footer">
        <div>
          <span className="route-footer-mark">V</span>
          <strong>VOLUME</strong>
        </div>
        <p>
          A conceptual editorial archive. Collaborations and quotations are
          presented as creative treatments unless independently documented.
        </p>
        <span>© 2026 Volume Media</span>
      </footer>
      <ScrollRestoration />
    </div>
  );
}
