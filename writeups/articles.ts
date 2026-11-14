export type ArticleRecord = {
  slug: string;
  title: string;
  subject: string;
  description: string;
  relatedReleaseIds: readonly string[];
};

export const articles: ArticleRecord[] = [
  {
    slug: "ssas-bottledroppas",
    title: "The Drop Is the Proof",
    subject: "SSAS / BottleDroppas",
    description: "Bass, gravity and bravado mapped onto one parabolic arc.",
    relatedReleaseIds: ["CHEF-GS-002", "CHEF-LSC-003"],
  },
  {
    slug: "zu-chongzhi-355-113",
    title: "The Fraction That Outlived Empires",
    subject: "祖冲之 / 355 ÷ 113",
    description: "A fifth-century approximation returns as a three-voice track.",
    relatedReleaseIds: ["CHEF-VTA-001", "CHEF-AOH-DLX"],
  },
];
