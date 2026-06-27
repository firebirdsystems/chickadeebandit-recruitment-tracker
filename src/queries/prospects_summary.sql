SELECT
  p.id,
  p.name,
  p.year,
  -- Effective stage: a committee decision (bid/pledged) overrides the owner's
  -- pipeline stage. Owners cannot self-advance, so trust the decisions table.
  COALESCE(d.decision, p.stage) AS stage,
  p.source,
  p.notes,
  p.created_at,
  COUNT(CASE WHEN b.vote = 'yes'     THEN 1 END) AS votes_yes,
  COUNT(CASE WHEN b.vote = 'no'      THEN 1 END) AS votes_no,
  COUNT(CASE WHEN b.vote = 'abstain' THEN 1 END) AS votes_abstain
FROM app_recruitment_tracker__prospects p
LEFT JOIN app_recruitment_tracker__ballots b
  ON b.prospect_id   = p.id
LEFT JOIN app_recruitment_tracker__decisions d
  ON d.prospect_id   = p.id
GROUP BY p.id, p.name, p.year, COALESCE(d.decision, p.stage), p.source, p.notes, p.created_at
ORDER BY
  CASE COALESCE(d.decision, p.stage)
    WHEN 'invited'  THEN 1
    WHEN 'rushed'   THEN 2
    WHEN 'bid'      THEN 3
    WHEN 'pledged'  THEN 4
    WHEN 'dropped'  THEN 5
    ELSE 6
  END,
  p.name
LIMIT 500
