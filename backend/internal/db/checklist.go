package db

import (
	"database/sql"
	"errors"
	"time"

	"event-planner/backend/internal/models"
)

// ErrChecklistItemNotFound is returned both when an item doesn't exist and
// when it belongs to a different event, mirroring ErrEventNotFound so
// callers always map it to a 404.
var ErrChecklistItemNotFound = errors.New("checklist item not found")

type ChecklistItemInput struct {
	Title       string
	Description *string
	Category    *string
	DueDate     *time.Time
	Status      string
	VendorID    *int64
}

func CreateChecklistItem(sqlDB *sql.DB, eventID int64, input ChecklistItemInput) (models.ChecklistItem, error) {
	res, err := sqlDB.Exec(
		`INSERT INTO checklist_items (event_id, title, description, category, due_date, vendor_id)
		 VALUES (?, ?, ?, ?, ?, ?)`,
		eventID, input.Title, input.Description, input.Category, formatDateTime(input.DueDate), input.VendorID,
	)
	if err != nil {
		return models.ChecklistItem{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.ChecklistItem{}, err
	}

	return GetChecklistItemForEvent(sqlDB, id, eventID)
}

func ListChecklistItems(sqlDB *sql.DB, eventID int64) ([]models.ChecklistItem, error) {
	rows, err := sqlDB.Query(
		`SELECT id, event_id, title, description, category, due_date, status, vendor_id, sort_order, created_at
		 FROM checklist_items WHERE event_id = ? ORDER BY sort_order, created_at`,
		eventID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := []models.ChecklistItem{}
	for rows.Next() {
		item, err := scanChecklistItem(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

// GetChecklistItemForEvent returns the item only if it exists and belongs to eventID.
func GetChecklistItemForEvent(sqlDB *sql.DB, id, eventID int64) (models.ChecklistItem, error) {
	row := sqlDB.QueryRow(
		`SELECT id, event_id, title, description, category, due_date, status, vendor_id, sort_order, created_at
		 FROM checklist_items WHERE id = ? AND event_id = ?`,
		id, eventID,
	)
	item, err := scanChecklistItem(row)
	if errors.Is(err, sql.ErrNoRows) {
		return models.ChecklistItem{}, ErrChecklistItemNotFound
	}
	if err != nil {
		return models.ChecklistItem{}, err
	}
	return item, nil
}

func UpdateChecklistItemForEvent(sqlDB *sql.DB, id, eventID int64, input ChecklistItemInput) (models.ChecklistItem, error) {
	res, err := sqlDB.Exec(
		`UPDATE checklist_items SET title = ?, description = ?, category = ?, due_date = ?, status = ?, vendor_id = ?
		 WHERE id = ? AND event_id = ?`,
		input.Title, input.Description, input.Category, formatDateTime(input.DueDate), input.Status, input.VendorID,
		id, eventID,
	)
	if err != nil {
		return models.ChecklistItem{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.ChecklistItem{}, err
	}
	if affected == 0 {
		return models.ChecklistItem{}, ErrChecklistItemNotFound
	}

	return GetChecklistItemForEvent(sqlDB, id, eventID)
}

func DeleteChecklistItemForEvent(sqlDB *sql.DB, id, eventID int64) error {
	res, err := sqlDB.Exec("DELETE FROM checklist_items WHERE id = ? AND event_id = ?", id, eventID)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return ErrChecklistItemNotFound
	}
	return nil
}

func scanChecklistItem(s rowScanner) (models.ChecklistItem, error) {
	var item models.ChecklistItem
	var description sql.NullString
	var category sql.NullString
	var dueDate sql.NullTime
	var vendorID sql.NullInt64

	err := s.Scan(
		&item.ID, &item.EventID, &item.Title, &description, &category,
		&dueDate, &item.Status, &vendorID, &item.SortOrder, &item.CreatedAt,
	)
	if err != nil {
		return models.ChecklistItem{}, err
	}

	if description.Valid {
		item.Description = &description.String
	}
	if category.Valid {
		item.Category = &category.String
	}
	if dueDate.Valid {
		item.DueDate = &dueDate.Time
	}
	if vendorID.Valid {
		item.VendorID = &vendorID.Int64
	}

	return item, nil
}
