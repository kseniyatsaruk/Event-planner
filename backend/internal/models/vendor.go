package models

import "time"

type Vendor struct {
	ID          int64     `json:"id"`
	EventID     int64     `json:"eventId"`
	Name        string    `json:"name"`
	Category    *string   `json:"category"`
	ContactName *string   `json:"contactName"`
	Phone       *string   `json:"phone"`
	Email       *string   `json:"email"`
	Price       *float64  `json:"price"`
	Status      string    `json:"status"`
	Notes       *string   `json:"notes"`
	CreatedAt   time.Time `json:"createdAt"`
}
