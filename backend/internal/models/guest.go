package models

import "time"

type Guest struct {
	ID         int64     `json:"id"`
	EventID    int64     `json:"eventId"`
	Name       string    `json:"name"`
	Phone      *string   `json:"phone"`
	Email      *string   `json:"email"`
	RSVPStatus string    `json:"rsvpStatus"`
	PlusOne    bool      `json:"plusOne"`
	Notes      *string   `json:"notes"`
	TableID    *int64    `json:"tableId"`
	SeatNumber *int64    `json:"seatNumber"`
	CreatedAt  time.Time `json:"createdAt"`
}
