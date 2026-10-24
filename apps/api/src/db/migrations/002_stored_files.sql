-- Uploaded file contents, keyed like the files under STORAGE_DIR. Hosts with an ephemeral disk
-- (e.g. free cloud instances) lose STORAGE_DIR on restart; the database copy keeps documents readable.
CREATE TABLE stored_files (
  file_key    TEXT PRIMARY KEY,
  content     BYTEA NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
