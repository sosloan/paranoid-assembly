import { createBrowserRouter } from "react-router";
import RootLayout from "./RootLayout";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: RootLayout,
    children: [
      {
        index: true,
        lazy: async () => ({ Component: (await import("../App")).default }),
      },
      {
        path: "catalog",
        lazy: async () => ({ Component: (await import("../pages/CatalogPage")).default }),
      },
      {
        path: "catalog/:releaseSlug",
        lazy: async () => ({ Component: (await import("../pages/CatalogPage")).default }),
      },
      {
        path: "artworks",
        lazy: async () => ({ Component: (await import("../ArtworkMagazine")).default }),
      },
      {
        path: "tour",
        lazy: async () => ({ Component: (await import("../pages/TourPage")).default }),
      },
      ...["journal", "artists", "albums", "tracks", "genres", "playlists", "numbers", "audience"].map(
        (path) => ({
          path,
          lazy: async () => ({
            Component: (await import("../pages/MagazineSectionPage")).default,
          }),
        }),
      ),
      {
        path: "studio",
        lazy: async () => ({ Component: (await import("../pages/StudioPage")).default }),
      },
      {
        path: "articles/ssas-bottledroppas",
        lazy: async () => ({ Component: (await import("../BottleDroppasArticle")).default }),
      },
      {
        path: "articles/zu-chongzhi-355-113",
        lazy: async () => ({ Component: (await import("../ZuChongzhiArticle")).default }),
      },
      {
        path: "*",
        lazy: async () => ({ Component: (await import("../pages/NotFoundPage")).default }),
      },
    ],
  },
]);
