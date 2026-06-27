-- Recruitment committee: an optional configured member group that may manage ANY
-- prospect (move stages, edit, delete), on top of each member always being able
-- to manage the prospects they added themselves (write_owner_only on prospects).
--
-- The committee group id lives here under the `app_config` row policy — readable
-- by all, writable by NO app SQL. The only writer is the admin-gated
-- /api/admin-config endpoint, so an ordinary member cannot rewrite the pointer to
-- crown their own group (the bypass_group_setting bootstrap hole). Until a
-- committee is configured the app simply behaves as owner-scoped (members manage
-- only their own prospects).
CREATE TABLE IF NOT EXISTS app_recruitment_tracker__settings (
  key   TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL DEFAULT ''
);
