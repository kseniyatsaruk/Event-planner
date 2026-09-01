package models

import "time"

type ChecklistItem struct {
	ID          int64      `json:"id"`
	EventID     int64      `json:"eventId"`
	Title       string     `json:"title"`
	Description *string    `json:"description"`
	Category    *string    `json:"category"`
	DueDate     *time.Time `json:"dueDate"`
	Status      string     `json:"status"`
	VendorID    *int64     `json:"vendorId"`
	SortOrder   int        `json:"sortOrder"`
	CreatedAt   time.Time  `json:"createdAt"`
}
