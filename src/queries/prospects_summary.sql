SELECT
  p.id,
  p.name,
  p.year,
  p.stage,
  p.source,
  p.notes,
  p.created_at,
  COUNT(CASE WHEN v.vote = 'yes'     THEN 1 END) AS votes_yes,
  COUNT(CASE WHEN v.vote = 'no'      THEN 1 END) AS votes_no,
  COUNT(CASE WHEN v.vote = 'abstain' THEN 1 END) AS votes_abstain
FROM prospects p
LEFT JOIN votes v
  ON v.prospect_id   = p.id
 AND v.household_id  = p.household_id
WHERE p.household_id = current_setting('app.household_id', true)::uuid
GROUP BY p.id, p.name, p.year, p.stage, p.source, p.notes, p.created_at
ORDER BY
  CASE p.stage
    WHEN 'invited'  THEN 1
    WHEN 'rushed'   THEN 2
    WHEN 'bid'      THEN 3
    WHEN 'pledged'  THEN 4
    WHEN 'dropped'  THEN 5
    ELSE 6
  END,
  p.name
LIMIT 500
