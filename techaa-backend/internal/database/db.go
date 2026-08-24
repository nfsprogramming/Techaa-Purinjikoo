package database

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
	"techaa-backend/internal/logger"
)

type DB struct {
	*sql.DB
}

func Connect(databaseURL string) (*DB, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Render Free tier connection limits
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)
	db.SetConnMaxIdleTime(2 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		logger.Log.Warn("PostgreSQL ping failed (running in offline/mock mode if applicable)", "error", err)
	} else {
		logger.Log.Info("Connected to PostgreSQL successfully")
	}

	return &DB{db}, nil
}

func (db *DB) RunMigrations(schemaSQL string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	_, err := db.ExecContext(ctx, schemaSQL)
	if err != nil {
		return fmt.Errorf("migration failed: %w", err)
	}
	logger.Log.Info("Database migrations applied successfully")
	return nil
}
