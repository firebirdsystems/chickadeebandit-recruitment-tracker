INSERT INTO prospects (
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
  gen_random_uuid()::text,
  $1,
  COALESCE($2, ''),
  COALESCE($3, ''),
  '',
  'invited',
  '',
  'ai',
  NOW()::text,
  NOW()::text
)
ON CONFLICT (household_id, id) DO NOTHING
