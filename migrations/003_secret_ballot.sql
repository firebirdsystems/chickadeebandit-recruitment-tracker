-- Convert recruitment voting to a SECRET BALLOT.
--
-- The legacy `votes` table stored `voter_id` next to each `vote`, so any member
-- could `SELECT * FROM votes` and read exactly how everyone voted (the UI only
-- ever showed aggregate tallies). Secret-ballot voting requires that a member's
-- identity is never linkable to their selection, which a row policy alone cannot
-- express — so all voting now routes through the hub `anonymous_responses`
-- endpoint (POST /run/recruitment-tracker/api/submit-response):
--   * `ballots`       — one row per cast vote, with NO member id by design.
--   * `vote_receipts` — proves "this member has voted on this prospect" so the
--                       endpoint can block a second/forged ballot. owner_only +
--                       endpoint_writes_only so a member sees only their own
--                       receipt and cannot write it directly.
-- The endpoint inserts the receipt first (fail-safe), then the anonymous ballot.

-- Per-prospect voting gate required by the anonymous_responses mechanism
-- (session_status_column). Defaults to 'open'; kept plaintext via manifest
-- db_plaintext_columns so the endpoint's open-check compares reliably.
ALTER TABLE app_recruitment_tracker__prospects
  ADD COLUMN vote_status TEXT NOT NULL DEFAULT 'open';

-- Anonymous ballot rows — intentionally no voter/member column.
CREATE TABLE IF NOT EXISTS app_recruitment_tracker__ballots (
  id           TEXT NOT NULL,
  prospect_id  TEXT NOT NULL,
  vote         TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  PRIMARY KEY (id)
);

-- One immutable receipt per (prospect, voter); never exposes the vote value.
CREATE TABLE IF NOT EXISTS app_recruitment_tracker__vote_receipts (
  prospect_id  TEXT NOT NULL,
  member_id    TEXT NOT NULL,
  created_at   TEXT NOT NULL,
  PRIMARY KEY (prospect_id, member_id)
);

-- Carry existing tallies forward (anonymized: voter_id is dropped) and seed the
-- receipts so members who already voted cannot vote a second time. `vote` and
-- `voter_id`/`created_at` copy column-for-column. The legacy `votes` table is
-- then emptied of its voter-linked rows (the migration contract disallows
-- removing a table outright) and locked read:"none" via manifest, so the old
-- voter-to-vote linkage is gone for good.
INSERT INTO app_recruitment_tracker__ballots (id, prospect_id, vote, created_at)
  SELECT id, prospect_id, vote, created_at FROM app_recruitment_tracker__votes;
INSERT INTO app_recruitment_tracker__vote_receipts (prospect_id, member_id, created_at)
  SELECT prospect_id, voter_id, created_at FROM app_recruitment_tracker__votes;
DELETE FROM app_recruitment_tracker__votes;

CREATE INDEX IF NOT EXISTS ballots_prospect_idx       ON app_recruitment_tracker__ballots (prospect_id);
CREATE INDEX IF NOT EXISTS vote_receipts_prospect_idx ON app_recruitment_tracker__vote_receipts (prospect_id);
