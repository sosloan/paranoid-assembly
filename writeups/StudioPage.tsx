import {
  createElement,
  useEffect,
  useMemo,
  useState,
  type ChangeEvent,
  type DragEvent,
  type ReactNode,
} from "react";
import { catalog } from "../data/catalog";

type BlockLayout = "full-width" | "two-column" | "text-only";

type IssueBlock = {
  id: string;
  kicker: string;
  title: string;
  copy: string;
  layout: BlockLayout;
  sourceId?: string;
};

type IssueDraft = {
  masthead: string;
  headline: string;
  direction: string;
  editor: string;
  issueDate: string;
  status: "Draft" | "In review" | "Ready";
  blocks: IssueBlock[];
};

const directions = [
  "Verified Orange",
  "Midnight Journal",
  "Blueprint Edition",
  "Terminal Proof",
  "Museum Paper",
  "Global Network",
  "Ordinal Spectrum",
];

const initialDraft: IssueDraft = {
  masthead: "VOLUME",
  headline: "The Architecture of Harmony",
  direction: directions[0],
  editor: "Volume Editorial",
  issueDate: "2026-12-01",
  status: "Draft",
  blocks: [
    {
      id: "lead-story",
      kicker: "Cover Story",
      title: "The proof is in the playback",
      copy: "A complete issue about artists who treat mathematics as musical material.",
      layout: "full-width",
    },
    {
      id: "catalog-vta",
      kicker: "Album of the Week",
      title: "Verified Trap Aesthetics",
      copy: "Eleven tracks move from infinite series to a final QED stamp.",
      layout: "two-column",
      sourceId: "CHEF-VTA-001",
    },
    {
      id: "editor-note",
      kicker: "From the Editor",
      title: "Precision is not the opposite of feeling",
      copy: "Rules become meaningful when artists find where they bend.",
      layout: "text-only",
    },
  ],
};

function Button({
  children,
  className = "",
  onClick,
}: {
  children: ReactNode;
  className?: string;
  onClick: () => void;
}) {
  return createElement("button", { className, onClick, type: "button" }, children);
}

function Title({
  as,
  children,
  className,
}: {
  as: "h1" | "h2" | "h3";
  children: ReactNode;
  className?: string;
}) {
  return createElement(as, { className }, children);
}

function Input({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return createElement("label", { className: "studio-field" }, [
    createElement("span", { key: "label" }, label),
    createElement("input", {
      key: "input",
      value,
      onChange: (event: ChangeEvent<HTMLInputElement>) =>
        onChange(event.target.value),
    }),
  ]);
}

function TextArea({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return createElement("label", { className: "studio-field" }, [
    createElement("span", { key: "label" }, label),
    createElement("textarea", {
      key: "textarea",
      rows: 3,
      value,
      onChange: (event: ChangeEvent<HTMLTextAreaElement>) =>
        onChange(event.target.value),
    }),
  ]);
}

function Select({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string;
  options: readonly string[];
  onChange: (value: string) => void;
}) {
  return createElement("label", { className: "studio-field" }, [
    createElement("span", { key: "label" }, label),
    createElement(
      "select",
      {
        key: "select",
        value,
        onChange: (event: ChangeEvent<HTMLSelectElement>) =>
          onChange(event.target.value),
      },
      options.map((option) =>
        createElement("option", { key: option, value: option }, option),
      ),
    ),
  ]);
}

function FileImport({
  onImport,
}: {
  onImport: (event: ChangeEvent<HTMLInputElement>) => void;
}) {
  return createElement("label", { className: "studio-import" }, [
    "Import JSON",
    createElement("input", {
      accept: "application/json,.json",
      key: "file",
      onChange: onImport,
      type: "file",
    }),
  ]);
}

function loadDraft(): IssueDraft {
  try {
    const saved = localStorage.getItem("volume-issue-draft");
    return saved
      ? { ...initialDraft, ...(JSON.parse(saved) as Partial<IssueDraft>) }
      : initialDraft;
  } catch {
    return initialDraft;
  }
}

export default function StudioPage() {
  const loadedDraft = useMemo(loadDraft, []);
  const [history, setHistory] = useState<IssueDraft[]>([loadedDraft]);
  const [historyIndex, setHistoryIndex] = useState(0);
  const [selectedId, setSelectedId] = useState(loadedDraft.blocks[0]?.id ?? "");
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [zoom, setZoom] = useState<75 | 100 | 125>(100);
  const [savedAt, setSavedAt] = useState("Not saved");
  const [notice, setNotice] = useState("");
  const draft = history[historyIndex];
  const selected = draft.blocks.find((block) => block.id === selectedId);

  useEffect(() => {
    localStorage.setItem("volume-issue-draft", JSON.stringify(draft));
    setSavedAt(
      new Intl.DateTimeFormat("en-US", {
        hour: "numeric",
        minute: "2-digit",
        second: "2-digit",
      }).format(new Date()),
    );
  }, [draft]);

  const setDraft = (
    update: IssueDraft | ((current: IssueDraft) => IssueDraft),
  ) => {
    const next = typeof update === "function" ? update(draft) : update;
    setHistory((current) => [...current.slice(0, historyIndex + 1), next].slice(-50));
    setHistoryIndex((current) => Math.min(current + 1, 49));
  };

  const issueNumber = useMemo(
    () => `ISSUE-${new Date().getUTCFullYear()}-${String(draft.blocks.length).padStart(2, "0")}`,
    [draft.blocks.length],
  );

  const issueStats = useMemo(() => {
    const words = draft.blocks.reduce(
      (total, block) =>
        total + `${block.title} ${block.copy}`.trim().split(/\s+/).filter(Boolean).length,
      0,
    );
    const incomplete = draft.blocks.filter(
      (block) => !block.title.trim() || !block.copy.trim(),
    ).length;
    return {
      words,
      readingTime: Math.max(1, Math.ceil(words / 220)),
      incomplete,
    };
  }, [draft.blocks]);

  const undo = () => setHistoryIndex((current) => Math.max(0, current - 1));
  const redo = () =>
    setHistoryIndex((current) => Math.min(history.length - 1, current + 1));

  const patchBlock = (id: string, patch: Partial<IssueBlock>) => {
    setDraft((current) => ({
      ...current,
      blocks: current.blocks.map((block) =>
        block.id === id ? { ...block, ...patch } : block,
      ),
    }));
  };

  const moveBlock = (id: string, delta: number) => {
    setDraft((current) => {
      const index = current.blocks.findIndex((block) => block.id === id);
      const destination = Math.max(0, Math.min(current.blocks.length - 1, index + delta));
      if (destination === index) return current;
      const blocks = [...current.blocks];
      const [block] = blocks.splice(index, 1);
      blocks.splice(destination, 0, block);
      return { ...current, blocks };
    });
  };

  const moveBlockTo = (sourceId: string, destinationId: string) => {
    if (sourceId === destinationId) return;
    setDraft((current) => {
      const source = current.blocks.findIndex((block) => block.id === sourceId);
      const destination = current.blocks.findIndex(
        (block) => block.id === destinationId,
      );
      if (source < 0 || destination < 0) return current;
      const blocks = [...current.blocks];
      const [block] = blocks.splice(source, 1);
      blocks.splice(destination, 0, block);
      return { ...current, blocks };
    });
  };

  const duplicateBlock = (id: string) => {
    const source = draft.blocks.find((block) => block.id === id);
    if (!source) return;
    const duplicate = {
      ...source,
      id: `${source.id}-copy-${Date.now()}`,
      title: `${source.title} — Copy`,
    };
    setDraft((current) => {
      const index = current.blocks.findIndex((block) => block.id === id);
      const blocks = [...current.blocks];
      blocks.splice(index + 1, 0, duplicate);
      return { ...current, blocks };
    });
    setSelectedId(duplicate.id);
  };

  const removeBlock = (id: string) => {
    setDraft((current) => ({
      ...current,
      blocks: current.blocks.filter((block) => block.id !== id),
    }));
    setSelectedId("");
  };

  const addCatalogBlock = (releaseId: string) => {
    const release = catalog.find((item) => item.id === releaseId);
    if (!release) return;
    const block: IssueBlock = {
      id: `${release.id}-${Date.now()}`,
      kicker: "From the Catalog",
      title: release.title,
      copy: release.theme,
      layout: "two-column",
      sourceId: release.id,
    };
    setDraft((current) => ({ ...current, blocks: [...current.blocks, block] }));
    setSelectedId(block.id);
  };

  const addTextBlock = () => {
    const block: IssueBlock = {
      id: `story-${Date.now()}`,
      kicker: "New Story",
      title: "Untitled feature",
      copy: "Begin writing here.",
      layout: "text-only",
    };
    setDraft((current) => ({ ...current, blocks: [...current.blocks, block] }));
    setSelectedId(block.id);
  };

  const exportJson = () => {
    const blob = new Blob([JSON.stringify({ ...draft, issueNumber }, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `${issueNumber.toLowerCase()}.json`;
    anchor.click();
    URL.revokeObjectURL(url);
    setNotice("Issue JSON exported");
  };

  const importJson = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const imported = JSON.parse(String(reader.result)) as Partial<IssueDraft>;
        if (
          typeof imported.masthead !== "string" ||
          typeof imported.headline !== "string" ||
          !Array.isArray(imported.blocks)
        ) {
          throw new Error("Invalid issue");
        }
        const next: IssueDraft = { ...initialDraft, ...imported };
        setDraft(next);
        setSelectedId(next.blocks[0]?.id ?? "");
        setNotice("Issue imported successfully");
      } catch {
        setNotice("Import failed: invalid Volume issue JSON");
      }
      event.target.value = "";
    };
    reader.readAsText(file);
  };

  const resetDraft = () => {
    if (!window.confirm("Reset this issue to the starter draft?")) return;
    setDraft(initialDraft);
    setSelectedId(initialDraft.blocks[0].id);
    setNotice("Starter draft restored");
  };

  return (
    <main className="studio-page">
      <header className="studio-header">
        <div>
          <p className="eyebrow">Magazine Studio · {issueNumber}</p>
          <Title as="h1">Build the next issue.</Title>
        </div>
        <div className="studio-actions">
          <Button className="history" onClick={undo}>Undo</Button>
          <Button className="history" onClick={redo}>Redo</Button>
          <FileImport onImport={importJson} />
          <Button onClick={exportJson}>Export issue JSON</Button>
          <Button className="primary" onClick={() => window.print()}>
            Print / Save PDF
          </Button>
        </div>
      </header>

      <div className="studio-workspace">
        <aside className="studio-sidebar">
          <section>
            <span className="studio-label">Issue identity</span>
            <Input
              label="Masthead"
              value={draft.masthead}
              onChange={(masthead) => setDraft({ ...draft, masthead })}
            />
            <Input
              label="Cover headline"
              value={draft.headline}
              onChange={(headline) => setDraft({ ...draft, headline })}
            />
            <Input
              label="Editor"
              value={draft.editor}
              onChange={(editor) => setDraft({ ...draft, editor })}
            />
            <Input
              label="Issue date"
              value={draft.issueDate}
              onChange={(issueDate) => setDraft({ ...draft, issueDate })}
            />
            <Select
              label="Workflow status"
              value={draft.status}
              options={["Draft", "In review", "Ready"]}
              onChange={(status) =>
                setDraft({
                  ...draft,
                  status: status as IssueDraft["status"],
                })
              }
            />
          </section>
          <section>
            <span className="studio-label">Design direction · 1 of 7</span>
            <div className="direction-list">
              {directions.map((direction, index) => (
                <Button
                  className={draft.direction === direction ? "active" : ""}
                  key={direction}
                  onClick={() => setDraft({ ...draft, direction })}
                >
                  <i>0{index + 1}</i>{direction}
                </Button>
              ))}
            </div>
          </section>
          <section>
            <span className="studio-label">Add content</span>
            <Button className="studio-add" onClick={addTextBlock}>+ Original story block</Button>
            {catalog.slice(0, 4).map((release) => (
              <Button
                className="studio-add"
                key={release.id}
                onClick={() => addCatalogBlock(release.id)}
              >
                + {release.title}
              </Button>
            ))}
          </section>
          <section className="studio-audit">
            <span className="studio-label">Issue audit</span>
            <div><span>Blocks</span><strong>{draft.blocks.length}</strong></div>
            <div><span>Words</span><strong>{issueStats.words}</strong></div>
            <div><span>Read time</span><strong>{issueStats.readingTime} min</strong></div>
            <div className={issueStats.incomplete ? "warning" : ""}>
              <span>Incomplete</span><strong>{issueStats.incomplete}</strong>
            </div>
          </section>
        </aside>

        <section className="studio-canvas-wrap">
          <div className="studio-preview-toolbar">
            <div>
              <span>Preview</span>
              <strong>{draft.status}</strong>
            </div>
            <div className="zoom-controls">
              {([75, 100, 125] as const).map((level) => (
                <Button
                  className={zoom === level ? "active" : ""}
                  key={level}
                  onClick={() => setZoom(level)}
                >
                  {level}%
                </Button>
              ))}
            </div>
          </div>
          <div className={`studio-canvas-frame zoom-${zoom}`}>
          <div className={`studio-canvas direction-${directions.indexOf(draft.direction) + 1}`}>
            <div className="studio-masthead">
              <strong>{draft.masthead}</strong>
              <span>{issueNumber} · {draft.issueDate} · {draft.direction}</span>
            </div>
            <Title as="h2">{draft.headline}</Title>
            <div className="studio-blocks">
              {draft.blocks.map((block, index) => (
                <article
                  className={`studio-issue-block ${block.layout} ${selectedId === block.id ? "selected" : ""}`}
                  key={block.id}
                  draggable
                  onDragEnd={() => setDraggedId(null)}
                  onDragOver={(event: DragEvent<HTMLElement>) =>
                    event.preventDefault()
                  }
                  onDragStart={() => setDraggedId(block.id)}
                  onDrop={() => {
                    if (draggedId) moveBlockTo(draggedId, block.id);
                    setDraggedId(null);
                  }}
                  onClick={() => setSelectedId(block.id)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter" || event.key === " ") {
                      setSelectedId(block.id);
                    }
                  }}
                  role="button"
                  tabIndex={0}
                >
                  <b className="studio-drag-handle" aria-hidden="true">⋮⋮</b>
                  <span>{block.kicker}</span>
                  <Title as="h3">{block.title}</Title>
                  <p>{block.copy}</p>
                  <small>{block.sourceId ?? `ORIGINAL-${String(index + 1).padStart(2, "0")}`}</small>
                </article>
              ))}
            </div>
          </div>
          </div>
        </section>

        <aside className="studio-inspector">
          <span className="studio-label">Block inspector</span>
          {selected ? (
            <>
              <Input label="Kicker" value={selected.kicker} onChange={(kicker) => patchBlock(selected.id, { kicker })} />
              <Input label="Headline" value={selected.title} onChange={(title) => patchBlock(selected.id, { title })} />
              <TextArea label="Feature copy" value={selected.copy} onChange={(copy) => patchBlock(selected.id, { copy })} />
              <div className="layout-picker">
                <span>Layout</span>
                {(["full-width", "two-column", "text-only"] as BlockLayout[]).map((layout) => (
                  <Button
                    className={selected.layout === layout ? "active" : ""}
                    key={layout}
                    onClick={() => patchBlock(selected.id, { layout })}
                  >
                    {layout.replace(/-/g, " ")}
                  </Button>
                ))}
              </div>
              <div className="block-order-actions">
                <Button onClick={() => moveBlock(selected.id, -1)}>Move up</Button>
                <Button onClick={() => moveBlock(selected.id, 1)}>Move down</Button>
                <Button onClick={() => duplicateBlock(selected.id)}>Duplicate</Button>
                <Button className="danger" onClick={() => removeBlock(selected.id)}>Remove</Button>
              </div>
            </>
          ) : (
            <p className="studio-empty">Select a block on the issue canvas to edit it.</p>
          )}
          <div className="draft-status">
            <i />
            <span>Saved locally at {savedAt}</span>
          </div>
          <Button className="studio-reset" onClick={resetDraft}>Reset starter draft</Button>
          {notice && <p className="studio-notice">{notice}</p>}
        </aside>
      </div>
    </main>
  );
}
