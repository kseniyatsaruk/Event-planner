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

type ChecklistHandler struct {
	DB *sql.DB
}

func NewChecklistHandler(sqlDB *sql.DB) *ChecklistHandler {
	return &ChecklistHandler{DB: sqlDB}
}

var validChecklistStatuses = map[string]bool{
	"todo":        true,
	"in_progress": true,
	"done":        true,
}

type checklistItemRequest struct {
	Title       string  `json:"title"`
	Description *string `json:"description"`
	Category    *string `json:"category"`
	DueDate     *string `json:"dueDate"`
	Status      *string `json:"status"`
	VendorID    *int64  `json:"vendorId"`
}

func (h *ChecklistHandler) List(w http.ResponseWriter, r *http.Request) {
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

	items, err := db.ListChecklistItems(h.DB, eventID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, items)
}

func (h *ChecklistHandler) Create(w http.ResponseWriter, r *http.Request) {
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

	var req checklistItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Title = strings.TrimSpace(req.Title)
	if req.Title == "" {
		writeError(w, http.StatusBadRequest, "invalid_title")
		return
	}

	dueDate, err := parseOptionalDate(req.DueDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_date")
		return
	}

	item, err := db.CreateChecklistItem(h.DB, eventID, db.ChecklistItemInput{
		Title:       req.Title,
		Description: req.Description,
		Category:    req.Category,
		DueDate:     dueDate,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusCreated, item)
}

func (h *ChecklistHandler) Update(w http.ResponseWriter, r *http.Request) {
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

	itemID, err := checklistItemIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req checklistItemRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Title = strings.TrimSpace(req.Title)
	if req.Title == "" {
		writeError(w, http.StatusBadRequest, "invalid_title")
		return
	}

	status := "todo"
	if req.Status != nil {
		status = strings.TrimSpace(*req.Status)
	}
	if !validChecklistStatuses[status] {
		writeError(w, http.StatusBadRequest, "invalid_status")
		return
	}

	dueDate, err := parseOptionalDate(req.DueDate)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_date")
		return
	}

	item, err := db.UpdateChecklistItemForEvent(h.DB, itemID, eventID, db.ChecklistItemInput{
		Title:       req.Title,
		Description: req.Description,
		Category:    req.Category,
		DueDate:     dueDate,
		Status:      status,
		VendorID:    req.VendorID,
	})
	if err != nil {
		if errors.Is(err, db.ErrChecklistItemNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, item)
}

func (h *ChecklistHandler) Delete(w http.ResponseWriter, r *http.Request) {
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

	itemID, err := checklistItemIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	if err := db.DeleteChecklistItemForEvent(h.DB, itemID, eventID); err != nil {
		if errors.Is(err, db.ErrChecklistItemNotFound) {
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
func (h *ChecklistHandler) eventForRequest(r *http.Request, userID int64) (int64, error) {
	eventID, err := eventIDFromURL(r)
	if err != nil {
		return 0, err
	}
	if _, err := db.GetEventForUser(h.DB, eventID, userID); err != nil {
		return 0, err
	}
	return eventID, nil
}

func checklistItemIDFromURL(r *http.Request) (int64, error) {
	return strconv.ParseInt(chi.URLParam(r, "itemId"), 10, 64)
}
