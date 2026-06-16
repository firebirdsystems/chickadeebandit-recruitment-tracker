INSERT INTO app_recruitment_tracker__prospects (
  id,
  name,
  year,
  source,
  contact,
  stage,
  notes,
  created_by,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  $1,
  COALESCE($2, ''),
  COALESCE($3, ''),
  '',
  'invited',
  '',
  'ai',
  datetime('now'),
  datetime('now')
)
ON CONFLICT (id) DO NOTHING
