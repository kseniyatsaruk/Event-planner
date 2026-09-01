package db

import (
	"database/sql"
	"errors"

	"event-planner/backend/internal/models"
)

// ErrVendorNotFound is returned both when a vendor doesn't exist and when it
// belongs to a different event, mirroring ErrEventNotFound so callers
// always map it to a 404.
var ErrVendorNotFound = errors.New("vendor not found")

type VendorInput struct {
	Name        string
	Category    *string
	ContactName *string
	Phone       *string
	Email       *string
	Price       *float64
	Status      string
	Notes       *string
}

func CreateVendor(sqlDB *sql.DB, eventID int64, input VendorInput) (models.Vendor, error) {
	res, err := sqlDB.Exec(
		`INSERT INTO vendors (event_id, name, category, contact_name, phone, email, price)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		eventID, input.Name, input.Category, input.ContactName, input.Phone, input.Email, input.Price,
	)
	if err != nil {
		return models.Vendor{}, err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return models.Vendor{}, err
	}

	return GetVendorForEvent(sqlDB, id, eventID)
}

func ListVendorsByEvent(sqlDB *sql.DB, eventID int64) ([]models.Vendor, error) {
	rows, err := sqlDB.Query(
		`SELECT id, event_id, name, category, contact_name, phone, email, price, status, notes, created_at
		 FROM vendors WHERE event_id = ? ORDER BY created_at, id`,
		eventID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	vendors := []models.Vendor{}
	for rows.Next() {
		v, err := scanVendor(rows)
		if err != nil {
			return nil, err
		}
		vendors = append(vendors, v)
	}
	return vendors, rows.Err()
}

// GetVendorForEvent returns the vendor only if it exists and belongs to eventID.
func GetVendorForEvent(sqlDB *sql.DB, id, eventID int64) (models.Vendor, error) {
	row := sqlDB.QueryRow(
		`SELECT id, event_id, name, category, contact_name, phone, email, price, status, notes, created_at
		 FROM vendors WHERE id = ? AND event_id = ?`,
		id, eventID,
	)
	v, err := scanVendor(row)
	if errors.Is(err, sql.ErrNoRows) {
		return models.Vendor{}, ErrVendorNotFound
	}
	if err != nil {
		return models.Vendor{}, err
	}
	return v, nil
}

func UpdateVendorForEvent(sqlDB *sql.DB, id, eventID int64, input VendorInput) (models.Vendor, error) {
	res, err := sqlDB.Exec(
		`UPDATE vendors SET name = ?, category = ?, contact_name = ?, phone = ?, email = ?, price = ?, status = ?, notes = ?
		 WHERE id = ? AND event_id = ?`,
		input.Name, input.Category, input.ContactName, input.Phone, input.Email, input.Price, input.Status, input.Notes,
		id, eventID,
	)
	if err != nil {
		return models.Vendor{}, err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return models.Vendor{}, err
	}
	if affected == 0 {
		return models.Vendor{}, ErrVendorNotFound
	}

	return GetVendorForEvent(sqlDB, id, eventID)
}

func DeleteVendorForEvent(sqlDB *sql.DB, id, eventID int64) error {
	res, err := sqlDB.Exec("DELETE FROM vendors WHERE id = ? AND event_id = ?", id, eventID)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return ErrVendorNotFound
	}
	return nil
}

func scanVendor(s rowScanner) (models.Vendor, error) {
	var v models.Vendor
	var category sql.NullString
	var contactName sql.NullString
	var phone sql.NullString
	var email sql.NullString
	var price sql.NullFloat64
	var notes sql.NullString

	err := s.Scan(
		&v.ID, &v.EventID, &v.Name, &category, &contactName,
		&phone, &email, &price, &v.Status, &notes, &v.CreatedAt,
	)
	if err != nil {
		return models.Vendor{}, err
	}

	if category.Valid {
		v.Category = &category.String
	}
	if contactName.Valid {
		v.ContactName = &contactName.String
	}
	if phone.Valid {
		v.Phone = &phone.String
	}
	if email.Valid {
		v.Email = &email.String
	}
	if price.Valid {
		v.Price = &price.Float64
	}
	if notes.Valid {
		v.Notes = &notes.String
	}

	return v, nil
}
