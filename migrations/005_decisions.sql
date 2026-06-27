-- Formal advancement (bid / pledged) is a COMMITTEE decision, not something a
-- prospect's owner may grant themselves. Because an owner can always write their
-- own prospect row (write_owner_only), a gated stage stored on `prospects.stage`
-- is self-grantable. So advancement moves into a committee-only child table:
--   decisions: inherit_visibility (everyone reads, since prospects are everyone-
--   visible) + insert_privileged_only (only the configured committee may INSERT,
--   and only the committee/decider may UPDATE/DELETE — see manifest).
-- The app DERIVES a prospect's effective stage from this table: a decision wins;
-- otherwise the owner-controlled stage (invited / rushed / dropped) applies, with
-- any forged bid/pledged value clamped down on read. `prospects.stage` stays the
-- owner's early-pipeline position.
CREATE TABLE IF NOT EXISTS app_recruitment_tracker__decisions (
  prospect_id  TEXT NOT NULL PRIMARY KEY,
  decision     TEXT NOT NULL,
  decided_by   TEXT NOT NULL,
  decided_at   TEXT NOT NULL
);

-- Preserve prospects already advanced under the old open model so they don't
-- visually regress to 'rushed'. decided_by is left blank: under the inherit_visibility
-- writer rules a blank value matches no member, so only the committee (privileged)
-- can later revise or clear these seeded decisions — never the prospect's owner.
INSERT OR IGNORE INTO app_recruitment_tracker__decisions (prospect_id, decision, decided_by, decided_at)
  SELECT id, stage, '', updated_at
  FROM app_recruitment_tracker__prospects
  WHERE stage IN ('bid', 'pledged');

CREATE INDEX IF NOT EXISTS decisions_prospect_idx ON app_recruitment_tracker__decisions (prospect_id);
