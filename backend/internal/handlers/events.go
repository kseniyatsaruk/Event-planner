package handlers

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"

	"event-planner/backend/internal/auth"
	"event-planner/backend/internal/db"
)

type EventsHandler struct {
	DB *sql.DB
}

func NewEventsHandler(sqlDB *sql.DB) *EventsHandler {
	return &EventsHandler{DB: sqlDB}
}

type eventRequest struct {
	Name            string   `json:"name"`
	EventDate       *string  `json:"eventDate"`
	Description     *string  `json:"description"`
	LocationAddress *string  `json:"locationAddress"`
	LocationLat     *float64 `json:"locationLat"`
	LocationLng     *float64 `json:"locationLng"`
}

func (h *EventsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	events, err := db.ListEventsByUser(h.DB, userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, events)
}

func (h *EventsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req eventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	eventDate, err := parseOptionalDate(req.EventDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_date")
		return
	}

	event, err := db.CreateEvent(h.DB, userID, db.EventInput{
		Name:        req.Name,
		EventDate:   eventDate,
		Description: req.Description,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusCreated, event)
}

func (h *EventsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	id, err := eventIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	event, err := db.GetEventForUser(h.DB, id, userID)
	if err != nil {
		if errors.Is(err, db.ErrEventNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, event)
}

func (h *EventsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	id, err := eventIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req eventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	eventDate, err := parseOptionalDate(req.EventDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_date")
		return
	}

	event, err := db.UpdateEventForUser(h.DB, id, userID, db.EventInput{
		Name:            req.Name,
		EventDate:       eventDate,
		Description:     req.Description,
		LocationAddress: req.LocationAddress,
		LocationLat:     req.LocationLat,
		LocationLng:     req.LocationLng,
	})
	if err != nil {
		if errors.Is(err, db.ErrEventNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, event)
}

func (h *EventsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	id, err := eventIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	if err := db.DeleteEventForUser(h.DB, id, userID); err != nil {
		if errors.Is(err, db.ErrEventNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func eventIDFromURL(r *http.Request) (int64, error) {
	return strconv.ParseInt(chi.URLParam(r, "eventId"), 10, 64)
}

func parseOptionalDate(raw *string) (*time.Time, error) {
	if raw == nil || strings.TrimSpace(*raw) == "" {
		return nil, nil
	}
	if t, err := time.Parse(time.RFC3339, *raw); err == nil {
		return &t, nil
	}
	if t, err := time.Parse("2006-01-02", *raw); err == nil {
		return &t, nil
	}
	return nil, fmt.Errorf("invalid date format: %q", *raw)
}
