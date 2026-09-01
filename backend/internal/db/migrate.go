package db

import (
	"database/sql"
	"fmt"
	"sort"
	"strings"

	"event-planner/backend/migrations"
)

// Migrate applies any migrations/*.sql files not yet recorded in
// schema_migrations, in filename order, each in its own transaction. This
// makes it safe to add new migration files over time: a database that
// already has earlier migrations applied only runs the new ones.
func Migrate(sqlDB *sql.DB) error {
	if _, err := sqlDB.Exec(`CREATE TABLE IF NOT EXISTS schema_migrations (
		filename TEXT PRIMARY KEY,
		applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
	)`); err != nil {
		return fmt.Errorf("create schema_migrations table: %w", err)
	}

	entries, err := migrations.FS.ReadDir(".")
	if err != nil {
		return fmt.Errorf("read migrations dir: %w", err)
	}

	names := make([]string, 0, len(entries))
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".sql") {
			names = append(names, e.Name())
		}
	}
	sort.Strings(names)

	for _, name := range names {
		applied, err := migrationApplied(sqlDB, name)
		if err != nil {
			return fmt.Errorf("check migration %q: %w", name, err)
		}
		if applied {
			continue
		}

		if err := applyMigration(sqlDB, name); err != nil {
			return err
		}
	}

	return nil
}

func applyMigration(sqlDB *sql.DB, name string) error {
	script, err := migrations.FS.ReadFile(name)
	if err != nil {
		return fmt.Errorf("read migration file %q: %w", name, err)
	}

	tx, err := sqlDB.Begin()
	if err != nil {
		return fmt.Errorf("begin migration transaction: %w", err)
	}
	defer tx.Rollback()

	for _, stmt := range splitStatements(string(script)) {
		if _, err := tx.Exec(stmt); err != nil {
			return fmt.Errorf("apply migration %q statement %q: %w", name, stmt, err)
		}
	}

	if _, err := tx.Exec("INSERT INTO schema_migrations (filename) VALUES (?)", name); err != nil {
		return fmt.Errorf("record migration %q: %w", name, err)
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit migration %q: %w", name, err)
	}
	return nil
}

func migrationApplied(sqlDB *sql.DB, name string) (bool, error) {
	var found string
	err := sqlDB.QueryRow(
		"SELECT filename FROM schema_migrations WHERE filename = ?", name,
	).Scan(&found)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return true, nil
}

func splitStatements(script string) []string {
	raw := strings.Split(script, ";")
	stmts := make([]string, 0, len(raw))
	for _, s := range raw {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		stmts = append(stmts, s)
	}
	return stmts
}
