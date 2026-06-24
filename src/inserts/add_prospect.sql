INSERT INTO app_recruitment_tracker__prospects (
  id,
  name,
  year,
  source,
  contact,
  stage,
  notes,
  created_by,
  visibility,
  created_at,
  updated_at
) VALUES (
  lower(hex(randomblob(16))),
  ?,
  COALESCE(?, ''),
  COALESCE(?, ''),
  '',
  'invited',
  '',
  'ai',
  'everyone',
  datetime('now'),
  datetime('now')
)
ON CONFLICT (id) DO NOTHING
