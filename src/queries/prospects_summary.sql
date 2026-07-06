SELECT
  p.id,
  p.name,
  p.year,
  -- Effective stage: a committee decision (bid/pledged) overrides the owner's
  -- pipeline stage. Owners CAN write their own prospects.stage directly via
  -- /api/db (write_owner_only) and the CHECK permits 'bid'/'pledged', so a forged
  -- advancement must be clamped to 'rushed' unless a real decision row exists —
  -- mirroring effectiveStage() in logic.js. Only the committee-only decisions
  -- table may grant bid/pledged.
  CASE
    WHEN d.decision IS NOT NULL       THEN d.decision
    WHEN p.stage IN ('bid','pledged') THEN 'rushed'
    ELSE p.stage
  END AS stage,
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
GROUP BY
  p.id, p.name, p.year,
  CASE
    WHEN d.decision IS NOT NULL       THEN d.decision
    WHEN p.stage IN ('bid','pledged') THEN 'rushed'
    ELSE p.stage
  END,
  p.source, p.notes, p.created_at
ORDER BY
  CASE
    WHEN d.decision IS NOT NULL AND d.decision = 'invited' THEN 1
    WHEN d.decision IS NOT NULL AND d.decision = 'rushed'  THEN 2
    WHEN d.decision IS NOT NULL AND d.decision = 'bid'     THEN 3
    WHEN d.decision IS NOT NULL AND d.decision = 'pledged' THEN 4
    WHEN d.decision IS NOT NULL AND d.decision = 'dropped' THEN 5
    WHEN d.decision IS NULL AND p.stage = 'invited'        THEN 1
    WHEN d.decision IS NULL AND p.stage = 'rushed'         THEN 2
    WHEN d.decision IS NULL AND p.stage = 'dropped'        THEN 5
    ELSE 2
  END,
  p.name
LIMIT 500
