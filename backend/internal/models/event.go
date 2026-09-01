package models

import "time"

type Event struct {
	ID              int64      `json:"id"`
	UserID          int64      `json:"userId"`
	Name            string     `json:"name"`
	EventDate       *time.Time `json:"eventDate"`
	Description     *string    `json:"description"`
	LocationAddress *string    `json:"locationAddress"`
	LocationLat     *float64   `json:"locationLat"`
	LocationLng     *float64   `json:"locationLng"`
	CreatedAt       time.Time  `json:"createdAt"`
	UpdatedAt       time.Time  `json:"updatedAt"`
}
