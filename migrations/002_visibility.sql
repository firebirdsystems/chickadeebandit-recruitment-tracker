ALTER TABLE app_recruitment_tracker__prospects ADD COLUMN visibility TEXT NOT NULL DEFAULT 'everyone';
ALTER TABLE app_recruitment_tracker__votes ADD COLUMN visibility TEXT NOT NULL DEFAULT 'everyone';
ALTER TABLE app_recruitment_tracker__prospect_activity ADD COLUMN visibility TEXT NOT NULL DEFAULT 'everyone';
CREATE INDEX IF NOT EXISTS prospects_stage_idx ON app_recruitment_tracker__prospects (stage);
