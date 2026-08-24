package database

import _ "embed"

//go:embed migrations/000001_init_schema.up.sql
var SchemaSQL string
