package db

import (
	"database/sql"
	"errors"
	"time"

	"event-planner/backend/internal/models"
)

// ErrEventNotFound is returned both when an event doesn't exist and when it
// belongs to a different user — callers should map it to a 404, never a 403,
// so existence isn't leaked across users.
var ErrEventNotFound = errors.New("event not found")

type EventInput struct {
	Name            string
	EventDate       *time.Time
	Description     *string
	LocationAddress *string
	LocationLat     *float64
	LocationLng     *float64
}

func CreateEvent(sqlDB *sql.DB, userID int64, input EventInput) (models.Event, error) {
	res, err := sqlDB.Exec(
		`INSERT INTO events (user_id, name, event_date, description, location_address, location_lat, location_lng)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		userID, input.Name, formatDateTime(input.EventDate), input.Description,
		input.LocationAddress, input.LocationLat, input.LocationLng,
	)
	if err != nil {
		return models.Event{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.Event{}, err
	}

	return GetEventForUser(sqlDB, id, userID)
}

func ListEventsByUser(sqlDB *sql.DB, userID int64) ([]models.Event, error) {
	rows, err := sqlDB.Query(
		`SELECT id, user_id, name, event_date, description, location_address, location_lat, location_lng, created_at, updated_at
		 FROM events WHERE user_id = ? ORDER BY created_at DESC, id DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	events := []models.Event{}
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, err
		}
		events = append(events, e)
	}
	return events, rows.Err()
}

// GetEventForUser returns the event only if it exists and belongs to userID.
func GetEventForUser(sqlDB *sql.DB, id, userID int64) (models.Event, error) {
	row := sqlDB.QueryRow(
		`SELECT id, user_id, name, event_date, description, location_address, location_lat, location_lng, created_at, updated_at
		 FROM events WHERE id = ? AND user_id = ?`,
		id, userID,
	)
	e, err := scanEvent(row)
	if errors.Is(err, sql.ErrNoRows) {
		return models.Event{}, ErrEventNotFound
	}
	if err != nil {
		return models.Event{}, err
	}
	return e, nil
}

func UpdateEventForUser(sqlDB *sql.DB, id, userID int64, input EventInput) (models.Event, error) {
	res, err := sqlDB.Exec(
		`UPDATE events SET name = ?, event_date = ?, description = ?, location_address = ?, location_lat = ?, location_lng = ?, updated_at = CURRENT_TIMESTAMP
		 WHERE id = ? AND user_id = ?`,
		input.Name, formatDateTime(input.EventDate), input.Description,
		input.LocationAddress, input.LocationLat, input.LocationLng,
		id, userID,
	)
	if err != nil {
		return models.Event{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.Event{}, err
	}
	if affected == 0 {
		return models.Event{}, ErrEventNotFound
	}

	return GetEventForUser(sqlDB, id, userID)
}

func DeleteEventForUser(sqlDB *sql.DB, id, userID int64) error {
	res, err := sqlDB.Exec("DELETE FROM events WHERE id = ? AND user_id = ?", id, userID)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return ErrEventNotFound
	}
	return nil
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanEvent(s rowScanner) (models.Event, error) {
	var e models.Event
	var eventDate sql.NullTime
	var description sql.NullString
	var locationAddress sql.NullString
	var locationLat sql.NullFloat64
	var locationLng sql.NullFloat64

	err := s.Scan(
		&e.ID, &e.UserID, &e.Name, &eventDate, &description,
		&locationAddress, &locationLat, &locationLng, &e.CreatedAt, &e.UpdatedAt,
	)
	if err != nil {
		return models.Event{}, err
	}

	if eventDate.Valid {
		e.EventDate = &eventDate.Time
	}
	if description.Valid {
		e.Description = &description.String
	}
	if locationAddress.Valid {
		e.LocationAddress = &locationAddress.String
	}
	if locationLat.Valid {
		e.LocationLat = &locationLat.Float64
	}
	if locationLng.Valid {
		e.LocationLng = &locationLng.Float64
	}

	return e, nil
}

// formatDateTime renders t in the same "YYYY-MM-DD HH:MM:SS" shape SQLite's
// own CURRENT_TIMESTAMP produces, so it round-trips back into time.Time on
// Scan the same way created_at/updated_at already do.
func formatDateTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.UTC().Format("2006-01-02 15:04:05")
	return &s
}
