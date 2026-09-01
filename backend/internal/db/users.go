package db

import (
	"database/sql"
	"errors"
	"strings"

	"event-planner/backend/internal/models"
)

// ErrEmailTaken is returned by CreateUser when the email is already registered.
var ErrEmailTaken = errors.New("email already taken")

// ErrUserNotFound is returned when no user matches the lookup.
var ErrUserNotFound = errors.New("user not found")

func CreateUser(sqlDB *sql.DB, email, passwordHash, name string) (models.User, error) {
	res, err := sqlDB.Exec(
		"INSERT INTO users (email, password_hash, name) VALUES (?, ?, ?)",
		email, passwordHash, name,
	)
	if err != nil {
		if isUniqueConstraintError(err) {
			return models.User{}, ErrEmailTaken
		}
		return models.User{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.User{}, err
	}

	return GetUserByID(sqlDB, id)
}

func GetUserByEmail(sqlDB *sql.DB, email string) (models.User, error) {
	row := sqlDB.QueryRow(
		"SELECT id, email, password_hash, name, created_at FROM users WHERE email = ?",
		email,
	)
	return scanUser(row)
}

func GetUserByID(sqlDB *sql.DB, id int64) (models.User, error) {
	row := sqlDB.QueryRow(
		"SELECT id, email, password_hash, name, created_at FROM users WHERE id = ?",
		id,
	)
	return scanUser(row)
}

func scanUser(row *sql.Row) (models.User, error) {
	var u models.User
	err := row.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.Name, &u.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return models.User{}, ErrUserNotFound
	}
	if err != nil {
		return models.User{}, err
	}
	return u, nil
}

func isUniqueConstraintError(err error) bool {
	return strings.Contains(err.Error(), "UNIQUE constraint failed")
}
