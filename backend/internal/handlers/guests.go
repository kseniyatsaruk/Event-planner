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

type GuestsHandler struct {
	DB *sql.DB
}

func NewGuestsHandler(sqlDB *sql.DB) *GuestsHandler {
	return &GuestsHandler{DB: sqlDB}
}

var validRSVPStatuses = map[string]bool{
	"pending":   true,
	"invited":   true,
	"confirmed": true,
	"declined":  true,
}

type guestRequest struct {
	Name       string  `json:"name"`
	Phone      *string `json:"phone"`
	Email      *string `json:"email"`
	RSVPStatus *string `json:"rsvpStatus"`
	PlusOne    *bool   `json:"plusOne"`
	Notes      *string `json:"notes"`
}

type guestTableRequest struct {
	TableID    *int64 `json:"tableId"`
	SeatNumber *int64 `json:"seatNumber"`
}

func (h *GuestsHandler) List(w http.ResponseWriter, r *http.Request) {
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

	guests, err := db.ListGuestsByEvent(h.DB, eventID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, guests)
}

func (h *GuestsHandler) Create(w http.ResponseWriter, r *http.Request) {
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

	var req guestRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	plusOne := false
	if req.PlusOne != nil {
		plusOne = *req.PlusOne
	}

	guest, err := db.CreateGuest(h.DB, eventID, db.GuestInput{
		Name:    req.Name,
		Phone:   req.Phone,
		Email:   req.Email,
		PlusOne: plusOne,
		Notes:   req.Notes,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusCreated, guest)
}

func (h *GuestsHandler) Update(w http.ResponseWriter, r *http.Request) {
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

	guestID, err := guestIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req guestRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "invalid_name")
		return
	}

	rsvpStatus := "pending"
	if req.RSVPStatus != nil {
		rsvpStatus = strings.TrimSpace(*req.RSVPStatus)
	}
	if !validRSVPStatuses[rsvpStatus] {
		writeError(w, http.StatusBadRequest, "invalid_rsvp_status")
		return
	}

	plusOne := false
	if req.PlusOne != nil {
		plusOne = *req.PlusOne
	}

	existing, err := db.GetGuestForEvent(h.DB, guestID, eventID)
	if err != nil {
		if errors.Is(err, db.ErrGuestNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	guest, err := db.UpdateGuestForEvent(h.DB, guestID, eventID, db.GuestInput{
		Name:       req.Name,
		Phone:      req.Phone,
		Email:      req.Email,
		RSVPStatus: rsvpStatus,
		PlusOne:    plusOne,
		Notes:      req.Notes,
	})
	if err != nil {
		if errors.Is(err, db.ErrGuestNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	// A plus-one needs the seat next to the guest's own. If enabling (or
	// re-confirming) plusOne on an already-seated guest finds that seat
	// missing or already taken by someone else, it no longer fits: unseat
	// the guest entirely rather than leave plusOne "on" with no room for it.
	// Turning plusOne off needs no extra step here — the companion seat was
	// never its own stored row, only ever derived from plusOne at render
	// time, so it is already implicitly freed.
	if plusOne && existing.TableID != nil && existing.SeatNumber != nil {
		fits, err := db.PlusOneFits(h.DB, eventID, *existing.TableID, *existing.SeatNumber, guestID)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "internal_error")
			return
		}
		if !fits {
			guest, err = db.SetGuestTable(h.DB, guestID, eventID, nil, nil)
			if err != nil {
				writeError(w, http.StatusInternalServerError, "internal_error")
				return
			}
		}
	}

	writeJSON(w, http.StatusOK, guest)
}

func (h *GuestsHandler) Delete(w http.ResponseWriter, r *http.Request) {
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

	guestID, err := guestIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	if err := db.DeleteGuestForEvent(h.DB, guestID, eventID); err != nil {
		if errors.Is(err, db.ErrGuestNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// UpdateTable assigns or clears a guest's table via
// PATCH /api/events/{eventId}/guests/{guestId}/table. If tableId is
// non-null, the target table must belong to the same event.
func (h *GuestsHandler) UpdateTable(w http.ResponseWriter, r *http.Request) {
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

	guestID, err := guestIDFromURL(r)
	if err != nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}

	var req guestTableRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}

	if req.TableID != nil {
		table, err := db.GetTableForEvent(h.DB, *req.TableID, eventID)
		if err != nil {
			writeError(w, http.StatusBadRequest, "invalid_table")
			return
		}
		if req.SeatNumber != nil && (*req.SeatNumber < 1 || *req.SeatNumber > int64(table.Capacity)) {
			writeError(w, http.StatusBadRequest, "invalid_seat")
			return
		}

		// A plus-one guest needs the seat next to whichever one they're being
		// placed in. This mirrors the same check the guest-edit path runs (see
		// Update above) so the rule is enforced on both routes that can seat a
		// guest, not just the one triggered by toggling plusOne.
		if req.SeatNumber != nil {
			existing, err := db.GetGuestForEvent(h.DB, guestID, eventID)
			if err != nil {
				if errors.Is(err, db.ErrGuestNotFound) {
					writeError(w, http.StatusNotFound, "not_found")
					return
				}
				writeError(w, http.StatusInternalServerError, "internal_error")
				return
			}
			if existing.PlusOne {
				fits, err := db.PlusOneFits(h.DB, eventID, *req.TableID, *req.SeatNumber, guestID)
				if err != nil {
					writeError(w, http.StatusInternalServerError, "internal_error")
					return
				}
				if !fits {
					writeError(w, http.StatusBadRequest, "plus_one_no_room")
					return
				}
			}
		}
	} else {
		req.SeatNumber = nil
	}

	guest, err := db.SetGuestTable(h.DB, guestID, eventID, req.TableID, req.SeatNumber)
	if err != nil {
		if errors.Is(err, db.ErrGuestNotFound) {
			writeError(w, http.StatusNotFound, "not_found")
			return
		}
		if errors.Is(err, db.ErrSeatTaken) {
			writeError(w, http.StatusConflict, "seat_taken")
			return
		}
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	writeJSON(w, http.StatusOK, guest)
}

// eventForRequest reads {eventId} from the URL and confirms it belongs to
// userID, returning the parsed id. Callers should map any error to 404.
func (h *GuestsHandler) eventForRequest(r *http.Request, userID int64) (int64, error) {
	eventID, err := eventIDFromURL(r)
	if err != nil {
		return 0, err
	}
	if _, err := db.GetEventForUser(h.DB, eventID, userID); err != nil {
		return 0, err
	}
	return eventID, nil
}

func guestIDFromURL(r *http.Request) (int64, error) {
	return strconv.ParseInt(chi.URLParam(r, "guestId"), 10, 64)
}
