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

type VendorsHandler struct {
	DB *sql.DB
}

func NewVendorsHandler(sqlDB *sql.DB) *VendorsHandler {
	return &VendorsHandler{DB: sqlDB}
}

var validVendorStatuses = map[string]bool{
	"contacted":   true,
	"negotiating": true,
	"confirmed":   true,
	"paid":        true,
	"cancelled":   true,
}

type vendorRequest struct {
	Name        string   `json:"name"`
	Category    *string  `json:"category"`
	ContactName *string  `json:"contactName"`
	Phone       *string  `json:"phone"`
	Email       *string  `json:"email"`
	Price       *float64 `json:"price"`
	Status      *string  `json:"status"`
	Notes       *string  `json:"notes"`
}

func (h *VendorsHandler) List(w http.ResponseWriter, r *http.Request) {
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

	vendors, err := db.ListVendorsByEvent(h.DB, eventID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, vendors)
}

func (h *VendorsHandler) Create(w http.ResponseWriter, r *http.Request) {
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

	var req vendorRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	vendor, err := db.CreateVendor(h.DB, eventID, db.VendorInput{
		Name:        req.Name,
		Category:    req.Category,
		ContactName: req.ContactName,
		Phone:       req.Phone,
		Email:       req.Email,
		Price:       req.Price,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusCreated, vendor)
}

func (h *VendorsHandler) Update(w http.ResponseWriter, r *http.Request) {
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

	vendorID, err := vendorIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req vendorRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	status := "contacted"
	if req.Status != nil {
		status = strings.TrimSpace(*req.Status)
	}
	if !validVendorStatuses[status] {
		writeError(w, http.StatusBadRequest, "invalid_status")
		return
	}

	vendor, err := db.UpdateVendorForEvent(h.DB, vendorID, eventID, db.VendorInput{
		Name:        req.Name,
		Category:    req.Category,
		ContactName: req.ContactName,
		Phone:       req.Phone,
		Email:       req.Email,
		Price:       req.Price,
		Status:      status,
		Notes:       req.Notes,
	})
	if err != nil {
		if errors.Is(err, db.ErrVendorNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, vendor)
}

func (h *VendorsHandler) Delete(w http.ResponseWriter, r *http.Request) {
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

	vendorID, err := vendorIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	if err := db.DeleteVendorForEvent(h.DB, vendorID, eventID); err != nil {
		if errors.Is(err, db.ErrVendorNotFound) {
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
func (h *VendorsHandler) eventForRequest(r *http.Request, userID int64) (int64, error) {
	eventID, err := eventIDFromURL(r)
	if err != nil {
		return 0, err
	}
	if _, err := db.GetEventForUser(h.DB, eventID, userID); err != nil {
		return 0, err
	}
	return eventID, nil
}

func vendorIDFromURL(r *http.Request) (int64, error) {
	return strconv.ParseInt(chi.URLParam(r, "vendorId"), 10, 64)
}
