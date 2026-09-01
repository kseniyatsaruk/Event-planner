package db

import (
	"database/sql"
	"errors"

	"event-planner/backend/internal/models"
)

// ErrGuestNotFound is returned both when a guest doesn't exist and when it
// belongs to a different event, mirroring ErrEventNotFound so callers
// always map it to a 404.
var ErrGuestNotFound = errors.New("guest not found")

type GuestInput struct {
	Name       string
	Phone      *string
	Email      *string
	RSVPStatus string
	PlusOne    bool
	Notes      *string
}

func CreateGuest(sqlDB *sql.DB, eventID int64, input GuestInput) (models.Guest, error) {
	res, err := sqlDB.Exec(
		`INSERT INTO guests (event_id, name, phone, email, plus_one, notes)
		 VALUES (?, ?, ?, ?, ?, ?)`,
		eventID, input.Name, input.Phone, input.Email, input.PlusOne, input.Notes,
	)
	if err != nil {
		return models.Guest{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.Guest{}, err
	}

	return GetGuestForEvent(sqlDB, id, eventID)
}

func ListGuestsByEvent(sqlDB *sql.DB, eventID int64) ([]models.Guest, error) {
	rows, err := sqlDB.Query(
		`SELECT id, event_id, name, phone, email, rsvp_status, plus_one, notes, table_id, seat_number, created_at
		 FROM guests WHERE event_id = ? ORDER BY created_at, id`,
		eventID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	guests := []models.Guest{}
	for rows.Next() {
		g, err := scanGuest(rows)
		if err != nil {
			return nil, err
		}
		guests = append(guests, g)
	}
	return guests, rows.Err()
}

// GetGuestForEvent returns the guest only if it exists and belongs to eventID.
func GetGuestForEvent(sqlDB *sql.DB, id, eventID int64) (models.Guest, error) {
	row := sqlDB.QueryRow(
		`SELECT id, event_id, name, phone, email, rsvp_status, plus_one, notes, table_id, seat_number, created_at
		 FROM guests WHERE id = ? AND event_id = ?`,
		id, eventID,
	)
	g, err := scanGuest(row)
	if errors.Is(err, sql.ErrNoRows) {
		return models.Guest{}, ErrGuestNotFound
	}
	if err != nil {
		return models.Guest{}, err
	}
	return g, nil
}

func UpdateGuestForEvent(sqlDB *sql.DB, id, eventID int64, input GuestInput) (models.Guest, error) {
	res, err := sqlDB.Exec(
		`UPDATE guests SET name = ?, phone = ?, email = ?, rsvp_status = ?, plus_one = ?, notes = ?
		 WHERE id = ? AND event_id = ?`,
		input.Name, input.Phone, input.Email, input.RSVPStatus, input.PlusOne, input.Notes,
		id, eventID,
	)
	if err != nil {
		return models.Guest{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.Guest{}, err
	}
	if affected == 0 {
		return models.Guest{}, ErrGuestNotFound
	}

	return GetGuestForEvent(sqlDB, id, eventID)
}

func DeleteGuestForEvent(sqlDB *sql.DB, id, eventID int64) error {
	res, err := sqlDB.Exec("DELETE FROM guests WHERE id = ? AND event_id = ?", id, eventID)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return ErrGuestNotFound
	}
	return nil
}

func scanGuest(s rowScanner) (models.Guest, error) {
	var g models.Guest
	var phone sql.NullString
	var email sql.NullString
	var notes sql.NullString
	var tableID sql.NullInt64
	var seatNumber sql.NullInt64

	err := s.Scan(
		&g.ID, &g.EventID, &g.Name, &phone, &email,
		&g.RSVPStatus, &g.PlusOne, &notes, &tableID, &seatNumber, &g.CreatedAt,
	)
	if err != nil {
		return models.Guest{}, err
	}

	if phone.Valid {
		g.Phone = &phone.String
	}
	if email.Valid {
		g.Email = &email.String
	}
	if notes.Valid {
		g.Notes = &notes.String
	}
	if tableID.Valid {
		g.TableID = &tableID.Int64
	}
	if seatNumber.Valid {
		g.SeatNumber = &seatNumber.Int64
	}

	return g, nil
}
