import { Link } from "react-router";

export default function NotFoundPage() {
  return (
    <main className="not-found-page">
      <span>404 / LOST TRACK</span>
      <h1>This groove does not exist.</h1>
      <Link to="/">Return to Volume</Link>
    </main>
  );
}
