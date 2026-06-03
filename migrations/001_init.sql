CREATE TABLE IF NOT EXISTS prospects (
  household_id UUID    NOT NULL DEFAULT current_setting('app.household_id', true)::uuid,
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
  PRIMARY KEY (household_id, id),
  CONSTRAINT prospects_stage_check CHECK (stage IN ('invited','rushed','bid','pledged','dropped'))
);

CREATE TABLE IF NOT EXISTS votes (
  household_id UUID NOT NULL DEFAULT current_setting('app.household_id', true)::uuid,
  id           TEXT NOT NULL,
  prospect_id  TEXT NOT NULL,
  voter_id     TEXT NOT NULL,
  vote         TEXT NOT NULL,
  notes        TEXT NOT NULL DEFAULT '',
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  PRIMARY KEY (household_id, id),
  UNIQUE (household_id, prospect_id, voter_id),
  CONSTRAINT votes_vote_check CHECK (vote IN ('yes','no','abstain'))
);

CREATE TABLE IF NOT EXISTS prospect_activity (
  household_id UUID NOT NULL DEFAULT current_setting('app.household_id', true)::uuid,
  id           TEXT NOT NULL,
  prospect_id  TEXT NOT NULL,
  actor_id     TEXT,
  action       TEXT NOT NULL,
  detail       TEXT NOT NULL DEFAULT '',
  created_at   TEXT NOT NULL,
  PRIMARY KEY (household_id, id)
);

CREATE INDEX IF NOT EXISTS votes_prospect_idx    ON votes           (household_id, prospect_id);
CREATE INDEX IF NOT EXISTS activity_prospect_idx ON prospect_activity (household_id, prospect_id);
