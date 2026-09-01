package handlers

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"event-planner/backend/internal/auth"
	"event-planner/backend/internal/db"
)

type TablesHandler struct {
	DB *sql.DB
}

func NewTablesHandler(sqlDB *sql.DB) *TablesHandler {
	return &TablesHandler{DB: sqlDB}
}

var validTableShapes = map[string]bool{
	"round":     true,
	"rectangle": true,
}

const defaultTableCapacity = 8

type tableRequest struct {
	Label    string   `json:"label"`
	Capacity *int     `json:"capacity"`
	Shape    *string  `json:"shape"`
	PosX     *float64 `json:"posX"`
	PosY     *float64 `json:"posY"`
	Rotation *float64 `json:"rotation"`
}

func (h *TablesHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	eventID, err := h.eventForRequest(r, userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	tables, err := db.ListTablesByEvent(h.DB, eventID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, tables)
}

func (h *TablesHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	eventID, err := h.eventForRequest(r, userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req tableRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Label = strings.TrimSpace(req.Label)
	if req.Label == "" {
		writeError(w, http.StatusBadRequest, "invalid_label")
		return
	}

	capacity := defaultTableCapacity
	if req.Capacity != nil {
		capacity = *req.Capacity
	}

	shape := "round"
	if req.Shape != nil {
		shape = strings.TrimSpace(*req.Shape)
	}
	if !validTableShapes[shape] {
		writeError(w, http.StatusBadRequest, "invalid_shape")
		return
	}

	table, err := db.CreateTable(h.DB, eventID, db.TableInput{
		Label:    req.Label,
		Capacity: capacity,
		Shape:    shape,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusCreated, table)
}

func (h *TablesHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	eventID, err := h.eventForRequest(r, userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	tableID, err := tableIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req tableRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Label = strings.TrimSpace(req.Label)
	if req.Label == "" {
		writeError(w, http.StatusBadRequest, "invalid_label")
		return
	}

	capacity := defaultTableCapacity
	if req.Capacity != nil {
		capacity = *req.Capacity
	}

	shape := "round"
	if req.Shape != nil {
		shape = strings.TrimSpace(*req.Shape)
	}
	if !validTableShapes[shape] {
		writeError(w, http.StatusBadRequest, "invalid_shape")
		return
	}

	var posX, posY, rotation float64
	if req.PosX != nil {
		posX = *req.PosX
	}
	if req.PosY != nil {
		posY = *req.PosY
	}
	if req.Rotation != nil {
		rotation = *req.Rotation
	}

	table, err := db.UpdateTableForEvent(h.DB, tableID, eventID, db.TableInput{
		Label:    req.Label,
		Capacity: capacity,
		Shape:    shape,
		PosX:     posX,
		PosY:     posY,
		Rotation: rotation,
	})
	if err != nil {
		if errors.Is(err, db.ErrTableNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, table)
}

func (h *TablesHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	eventID, err := h.eventForRequest(r, userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	tableID, err := tableIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	if err := db.DeleteTableForEvent(h.DB, tableID, eventID); err != nil {
		if errors.Is(err, db.ErrTableNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// eventForRequest reads {eventId} from the URL and confirms it belongs to
// userID, returning the parsed id. Callers should map any error to 404.
func (h *TablesHandler) eventForRequest(r *http.Request, userID int64) (int64, error) {
	eventID, err := eventIDFromURL(r)
	if err != nil {
		return 0, err
	}
	if _, err := db.GetEventForUser(h.DB, eventID, userID); err != nil {
		return 0, err
	}
	return eventID, nil
}

func tableIDFromURL(r *http.Request) (int64, error) {
	return strconv.ParseInt(chi.URLParam(r, "tableId"), 10, 64)
}
