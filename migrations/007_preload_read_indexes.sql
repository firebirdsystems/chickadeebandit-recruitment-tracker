-- Index the manifest `preload` read, which the hub runs server-side while
-- rendering this app's document — on every launch, for every household.
--
-- preload.prospect_activity asks for the 50 most recent events and was sorting
-- the entire activity log to find them — the worst ratio of the set.
CREATE INDEX IF NOT EXISTS app_recruitment_tracker__prospect_activity_created_idx
  ON app_recruitment_tracker__prospect_activity (created_at DESC);
