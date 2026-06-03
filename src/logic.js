export { memberColor, initial, esc, isAdult, formatRelativeDate } from "./shared.js";

export const STAGES        = ["invited", "rushed", "bid", "pledged", "dropped"];
export const ACTIVE_STAGES = ["invited", "rushed", "bid", "pledged"];

export const STAGE_LABELS = {
  invited: "Invited",
  rushed:  "Rushed",
  bid:     "Bid",
  pledged: "Pledged",
  dropped: "Dropped",
};

export const STAGE_COLORS = {
  invited: "#6366f1",
  rushed:  "#f59e0b",
  bid:     "#3b82f6",
  pledged: "#16a34a",
  dropped: "#9ca3af",
};

export const YEAR_OPTIONS = [
  "Freshman", "Sophomore", "Junior", "Senior", "Transfer", "Grad",
];

export const VOTE_LABELS = { yes: "Yes", no: "No", abstain: "Abstain" };

export const VOTE_COLORS = {
  yes:     "#16a34a",
  no:      "#dc2626",
  abstain: "#9ca3af",
};

/**
 * Count yes/no/abstain votes for a single prospect's vote array.
 */
export function tallyVotes(prospectVotes) {
  const yes     = prospectVotes.filter(v => v.vote === "yes").length;
  const no      = prospectVotes.filter(v => v.vote === "no").length;
  const abstain = prospectVotes.filter(v => v.vote === "abstain").length;
  return { yes, no, abstain, total: yes + no + abstain };
}

/**
 * Filter prospects to a single stage, sorted alphabetically by name.
 */
export function prospectsByStage(prospects, stage) {
  return prospects
    .filter(p => p.stage === stage)
    .sort((a, b) => a.name.localeCompare(b.name));
}

/**
 * Sort all prospects alphabetically, then by stage order.
 */
export function sortProspects(prospects) {
  return [...prospects].sort((a, b) => {
    const si = STAGES.indexOf(a.stage) - STAGES.indexOf(b.stage);
    if (si !== 0) return si;
    return a.name.localeCompare(b.name);
  });
}
