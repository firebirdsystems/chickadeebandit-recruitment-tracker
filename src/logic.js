export { memberColor, initial, esc, isAdult, formatRelativeDate } from "./shared.js";

/**
 * Whether `me` is on the configured Recruitment Committee — mirrors the
 * server-side privileged resolution for the `decisions` (insert_privileged_only)
 * and `prospects` (write_owner_only + bypass) policies, gated by committee_group_id.
 *
 * MUST match the hub exactly: privileged IFF the committee group is configured,
 * still exists, and the member is in it. There is NO "all adults" fallback when
 * the group is unset or dangling — the hub rejects privileged writes in that
 * state, so committee controls stay hidden here too (otherwise they would 403).
 * See __tests__/helpers/privileged-gate.mjs.
 *
 * @param {object|null} me
 * @param {Array}  groups
 * @param {string|null} committeeGroupId
 */
export function isCommittee(me, groups, committeeGroupId) {
  if (!me || !committeeGroupId) return false;
  const g = groups.find(g => g.id === committeeGroupId);
  return !!g && g.memberIds.includes(me.id);
}

export const STAGES        = ["invited", "rushed", "bid", "pledged", "dropped"];
export const ACTIVE_STAGES = ["invited", "rushed", "bid", "pledged"];

// Stage governance split: owners manage the early pipeline; only the committee
// may issue the formal advancement decisions. Used to keep the UI honest with the
// server policies (prospects.write_owner_only vs decisions.insert_privileged_only).
export const PIPELINE_STAGES = ["invited", "rushed", "dropped"]; // owner-settable
export const DECISION_STAGES = ["bid", "pledged"];               // committee-only

/**
 * Effective stage for a prospect. A committee decision (bid/pledged) is
 * authoritative; otherwise the owner-controlled stage applies, with any forged
 * bid/pledged value (an owner can write their own row) clamped down to "rushed".
 */
export function effectiveStage(rawStage, decision) {
  if (decision) return decision;
  return DECISION_STAGES.includes(rawStage) ? "rushed" : rawStage;
}

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
