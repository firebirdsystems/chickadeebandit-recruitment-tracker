-- Automation support for the `add_prospect` action.
--
-- `source_event_id` records which app event produced the row. The dispatcher's
-- dedupe guard matches on it (SELECT 1 FROM ... WHERE source_event_id = ?
-- LIMIT 1), so a retried or replayed delivery finds the existing file and skips
-- instead of opening a second one on the same person.
--
-- Nullable on purpose: a prospect entered by a member has no source event, and
-- the guard only ever looks for a specific non-null id.
--
-- `created_by` must come from a real member param, never a literal or a NULL:
-- `prospects` is owner_or_visibility with write_owner_only, which narrows every
-- UPDATE and DELETE to `created_by = <caller>` with no adult bypass. An
-- ownerless row would be a permanent, uncorrectable file on a real person.
ALTER TABLE app_recruitment_tracker__prospects ADD COLUMN source_event_id TEXT;

CREATE INDEX IF NOT EXISTS app_recruitment_tracker__idx_prospects_source_event_id
  ON app_recruitment_tracker__prospects (source_event_id);
