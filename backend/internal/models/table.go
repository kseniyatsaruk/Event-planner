package models

import "time"

type Table struct {
	ID        int64     `json:"id"`
	EventID   int64     `json:"eventId"`
	Label     string    `json:"label"`
	Capacity  int       `json:"capacity"`
	Shape     string    `json:"shape"`
	PosX      float64   `json:"posX"`
	PosY      float64   `json:"posY"`
	Rotation  float64   `json:"rotation"`
	CreatedAt time.Time `json:"createdAt"`
}
