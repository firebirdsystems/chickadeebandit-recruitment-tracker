import { describe, it, expect } from "vitest";
import {
  STAGES, ACTIVE_STAGES, STAGE_LABELS, STAGE_COLORS,
  PIPELINE_STAGES, DECISION_STAGES, effectiveStage,
  YEAR_OPTIONS, VOTE_LABELS, VOTE_COLORS,
  tallyVotes, prospectsByStage, sortProspects,
} from "../src/logic.js";

// ── effectiveStage (formal-decision derivation) ───────────────────────────────

describe("effectiveStage", () => {
  it("uses the owner pipeline stage when there is no committee decision", () => {
    expect(effectiveStage("invited", undefined)).toBe("invited");
    expect(effectiveStage("rushed", null)).toBe("rushed");
    expect(effectiveStage("dropped", undefined)).toBe("dropped");
  });

  it("lets a committee decision override the owner stage", () => {
    expect(effectiveStage("rushed", "bid")).toBe("bid");
    expect(effectiveStage("invited", "pledged")).toBe("pledged");
  });

  it("clamps a forged bid/pledged owner stage down to rushed (no self-advancement)", () => {
    // An owner can write their own prospects.stage via direct SQL, but without a
    // committee decision it must never read back as advanced.
    expect(effectiveStage("bid", undefined)).toBe("rushed");
    expect(effectiveStage("pledged", null)).toBe("rushed");
  });

  it("keeps pipeline and decision stages disjoint", () => {
    expect(PIPELINE_STAGES).toEqual(["invited", "rushed", "dropped"]);
    expect(DECISION_STAGES).toEqual(["bid", "pledged"]);
    expect(PIPELINE_STAGES.some(s => DECISION_STAGES.includes(s))).toBe(false);
  });
});

// ── tallyVotes ────────────────────────────────────────────────────────────────

describe("tallyVotes", () => {
  it("returns zeros for empty array", () => {
    expect(tallyVotes([])).toEqual({ yes: 0, no: 0, abstain: 0, total: 0 });
  });

  it("counts yes/no/abstain correctly", () => {
    const votes = [
      { vote: "yes" },
      { vote: "yes" },
      { vote: "no" },
      { vote: "abstain" },
    ];
    expect(tallyVotes(votes)).toEqual({ yes: 2, no: 1, abstain: 1, total: 4 });
  });

  it("total equals sum of all votes", () => {
    const votes = [{ vote: "yes" }, { vote: "no" }, { vote: "abstain" }];
    const t = tallyVotes(votes);
    expect(t.total).toBe(t.yes + t.no + t.abstain);
  });
});

// ── prospectsByStage ──────────────────────────────────────────────────────────

describe("prospectsByStage", () => {
  const ps = [
    { id: "a", name: "Charlie", stage: "invited" },
    { id: "b", name: "Alice",   stage: "rushed"  },
    { id: "c", name: "Bob",     stage: "invited" },
    { id: "d", name: "Dana",    stage: "pledged" },
  ];

  it("filters to the requested stage", () => {
    const invited = prospectsByStage(ps, "invited");
    expect(invited.map(p => p.id).sort()).toEqual(["a", "c"]);
  });

  it("returns empty array for an empty stage", () => {
    expect(prospectsByStage(ps, "bid")).toEqual([]);
  });

  it("sorts alphabetically within the stage", () => {
    const invited = prospectsByStage(ps, "invited");
    expect(invited.map(p => p.name)).toEqual(["Bob", "Charlie"]);
  });
});

// ── sortProspects ─────────────────────────────────────────────────────────────

describe("sortProspects", () => {
  it("sorts by stage order then name", () => {
    const ps = [
      { id: "1", name: "Zara",  stage: "pledged" },
      { id: "2", name: "Alice", stage: "rushed"  },
      { id: "3", name: "Bob",   stage: "invited" },
      { id: "4", name: "Andy",  stage: "rushed"  },
    ];
    const sorted = sortProspects(ps).map(p => p.id);
    expect(sorted).toEqual(["3", "2", "4", "1"]); // invited < rushed < pledged; Alice < Andy alphabetically
  });

  it("does not mutate the original array", () => {
    const ps = [{ id: "x", name: "X", stage: "bid" }];
    const sorted = sortProspects(ps);
    expect(sorted).not.toBe(ps);
  });
});

// ── Constants sanity ──────────────────────────────────────────────────────────

describe("constants", () => {
  it("STAGES includes dropped", () => {
    expect(STAGES).toContain("dropped");
  });

  it("ACTIVE_STAGES does not include dropped", () => {
    expect(ACTIVE_STAGES).not.toContain("dropped");
  });

  it("every STAGE has a label and color", () => {
    for (const s of STAGES) {
      expect(STAGE_LABELS[s], `missing label for ${s}`).toBeTruthy();
      expect(STAGE_COLORS[s], `missing color for ${s}`).toMatch(/^#/);
    }
  });

  it("YEAR_OPTIONS is non-empty", () => {
    expect(YEAR_OPTIONS.length).toBeGreaterThan(0);
  });

  it("VOTE_LABELS covers yes/no/abstain", () => {
    for (const v of ["yes", "no", "abstain"]) {
      expect(VOTE_LABELS[v]).toBeTruthy();
      expect(VOTE_COLORS[v]).toMatch(/^#/);
    }
  });
});
