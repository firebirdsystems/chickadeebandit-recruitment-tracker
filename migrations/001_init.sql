CREATE TABLE IF NOT EXISTS app_recruitment_tracker__prospects (
  id           TEXT    NOT NULL,
  name         TEXT    NOT NULL,
  year         TEXT    NOT NULL DEFAULT '',
  contact      TEXT    NOT NULL DEFAULT '',
  source       TEXT    NOT NULL DEFAULT '',
  stage        TEXT    NOT NULL DEFAULT 'invited',
  notes        TEXT    NOT NULL DEFAULT '',
  created_by   TEXT,
  created_at   TEXT    NOT NULL,
  updated_at   TEXT    NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT prospects_stage_check CHECK (stage IN ('invited','rushed','bid','pledged','dropped'))
);

CREATE TABLE IF NOT EXISTS app_recruitment_tracker__votes (
  id           TEXT NOT NULL,
  prospect_id  TEXT NOT NULL,
  voter_id     TEXT NOT NULL,
  vote         TEXT NOT NULL,
  notes        TEXT NOT NULL DEFAULT '',
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (prospect_id, voter_id),
  CONSTRAINT votes_vote_check CHECK (vote IN ('yes','no','abstain'))
);

CREATE TABLE IF NOT EXISTS app_recruitment_tracker__prospect_activity (
  id           TEXT NOT NULL,
  prospect_id  TEXT NOT NULL,
  actor_id     TEXT,
  action       TEXT NOT NULL,
  detail       TEXT NOT NULL DEFAULT '',
  created_at   TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS votes_prospect_idx    ON app_recruitment_tracker__votes           (prospect_id);
CREATE INDEX IF NOT EXISTS activity_prospect_idx ON app_recruitment_tracker__prospect_activity (prospect_id);
