package db

import (
	"database/sql"
	"errors"

	"event-planner/backend/internal/models"
)

// ErrTableNotFound is returned both when a table doesn't exist and when it
// belongs to a different event, mirroring ErrEventNotFound so callers
// always map it to a 404.
var ErrTableNotFound = errors.New("table not found")

// ErrSeatTaken is returned when assigning a guest to a table_id+seat_number
// pair already held by another guest. It is detected from the UNIQUE index
// (see migrations/0003_unique_guest_seat.sql) rather than a separate
// check-then-write, so it holds even under concurrent requests targeting the
// same seat — a pre-check query would still leave a race window between the
// check and the write.
var ErrSeatTaken = errors.New("seat already taken")

type TableInput struct {
	Label    string
	Capacity int
	Shape    string
	PosX     float64
	PosY     float64
	Rotation float64
}

func CreateTable(sqlDB *sql.DB, eventID int64, input TableInput) (models.Table, error) {
	res, err := sqlDB.Exec(
		`INSERT INTO tables (event_id, label, capacity, shape, pos_x, pos_y, rotation)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		eventID, input.Label, input.Capacity, input.Shape, input.PosX, input.PosY, input.Rotation,
	)
	if err != nil {
		return models.Table{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.Table{}, err
	}

	return GetTableForEvent(sqlDB, id, eventID)
}

func ListTablesByEvent(sqlDB *sql.DB, eventID int64) ([]models.Table, error) {
	rows, err := sqlDB.Query(
		`SELECT id, event_id, label, capacity, shape, pos_x, pos_y, rotation, created_at
		 FROM tables WHERE event_id = ? ORDER BY created_at, id`,
		eventID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	tables := []models.Table{}
	for rows.Next() {
		t, err := scanTable(rows)
		if err != nil {
			return nil, err
		}
		tables = append(tables, t)
	}
	return tables, rows.Err()
}

// GetTableForEvent returns the table only if it exists and belongs to eventID.
func GetTableForEvent(sqlDB *sql.DB, id, eventID int64) (models.Table, error) {
	row := sqlDB.QueryRow(
		`SELECT id, event_id, label, capacity, shape, pos_x, pos_y, rotation, created_at
		 FROM tables WHERE id = ? AND event_id = ?`,
		id, eventID,
	)
	t, err := scanTable(row)
	if errors.Is(err, sql.ErrNoRows) {
		return models.Table{}, ErrTableNotFound
	}
	if err != nil {
		return models.Table{}, err
	}
	return t, nil
}

func UpdateTableForEvent(sqlDB *sql.DB, id, eventID int64, input TableInput) (models.Table, error) {
	res, err := sqlDB.Exec(
		`UPDATE tables SET label = ?, capacity = ?, shape = ?, pos_x = ?, pos_y = ?, rotation = ?
		 WHERE id = ? AND event_id = ?`,
		input.Label, input.Capacity, input.Shape, input.PosX, input.PosY, input.Rotation,
		id, eventID,
	)
	if err != nil {
		return models.Table{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.Table{}, err
	}
	if affected == 0 {
		return models.Table{}, ErrTableNotFound
	}

	return GetTableForEvent(sqlDB, id, eventID)
}

func DeleteTableForEvent(sqlDB *sql.DB, id, eventID int64) error {
	res, err := sqlDB.Exec("DELETE FROM tables WHERE id = ? AND event_id = ?", id, eventID)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return ErrTableNotFound
	}
	return nil
}

func scanTable(s rowScanner) (models.Table, error) {
	var t models.Table
	err := s.Scan(
		&t.ID, &t.EventID, &t.Label, &t.Capacity, &t.Shape,
		&t.PosX, &t.PosY, &t.Rotation, &t.CreatedAt,
	)
	if err != nil {
		return models.Table{}, err
	}
	return t, nil
}

// NextSeatNumber returns the seat number physically adjacent to seatNumber —
// the seat a plus-one would take — or 0 if there is none. A round table is a
// genuine circle, so its last seat wraps back to seat 1. A rectangle's seats
// are split into a top row (1..topCount) and a bottom row
// (topCount+1..capacity); adjacency only holds within a row, so the last
// seat of either row has no neighbor (it does not wrap to the other row or
// back to seat 1).
//
// This rule is mirrored in frontend/src/components/seating/seatAdjacency.js
// (function nextSeatNumber, which returns null in place of 0) — there is no
// code sharing across the Go/JS boundary, so if this logic ever changes,
// that file must change identically or the frontend's seat rendering will
// disagree with what this function actually validates and persists.
func NextSeatNumber(shape string, capacity int, seatNumber int) int {
	if capacity < 2 {
		return 0
	}

	if shape == "round" {
		if seatNumber >= capacity {
			return 1
		}
		return seatNumber + 1
	}

	topCount := (capacity + 1) / 2 // ceil(capacity/2), matches the frontend's row split
	if seatNumber == topCount || seatNumber == capacity {
		return 0
	}
	return seatNumber + 1
}

// PlusOneFits reports whether the seat next to seatNumber at tableID is free
// for guestID's plus-one: it must exist (see NextSeatNumber) and not already
// be another guest's own seat.
func PlusOneFits(sqlDB *sql.DB, eventID, tableID, seatNumber, guestID int64) (bool, error) {
	table, err := GetTableForEvent(sqlDB, tableID, eventID)
	if err != nil {
		return false, err
	}

	companion := NextSeatNumber(table.Shape, table.Capacity, int(seatNumber))
	if companion == 0 {
		return false, nil
	}

	var found int
	err = sqlDB.QueryRow(
		"SELECT 1 FROM guests WHERE table_id = ? AND seat_number = ? AND id != ? LIMIT 1",
		tableID, companion, guestID,
	).Scan(&found)
	if errors.Is(err, sql.ErrNoRows) {
		return true, nil
	}
	if err != nil {
		return false, err
	}
	return false, nil
}

// SetGuestTable assigns (or clears, when tableID is nil) a guest's table_id
// and seat_number. seatNumber is always cleared alongside tableID, even if
// the caller passed one, so a guest can never be left with a seat number on
// a table it is no longer assigned to.
func SetGuestTable(sqlDB *sql.DB, guestID, eventID int64, tableID *int64, seatNumber *int64) (models.Guest, error) {
	if tableID == nil {
		seatNumber = nil
	}

	res, err := sqlDB.Exec(
		"UPDATE guests SET table_id = ?, seat_number = ? WHERE id = ? AND event_id = ?",
		tableID, seatNumber, guestID, eventID,
	)
	if err != nil {
		if isUniqueConstraintError(err) {
			return models.Guest{}, ErrSeatTaken
		}
		return models.Guest{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.Guest{}, err
	}
	if affected == 0 {
		return models.Guest{}, ErrGuestNotFound
	}

	return GetGuestForEvent(sqlDB, guestID, eventID)
}
