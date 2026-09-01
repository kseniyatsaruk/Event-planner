// Mirrors NextSeatNumber in backend/internal/db/tables.go — MUST stay in
// exact sync with it. There is no code sharing across the Go backend / JS
// frontend boundary, so this is a manual mirror, not a shared module: if the
// adjacency rule ever changes on one side, change it identically on the
// other, or the frontend's seat rendering will disagree with what the
// backend actually validates and persists (0 there ↔ null here, for "no
// neighbor").
//
// Returns the seat number physically adjacent to seatNumber — the seat a
// plus-one would take — or null if there is none. A round table is a
// genuine circle, so its last seat wraps back to seat 1. A rectangle's seats
// are split into a top row (1..topCount) and a bottom row
// (topCount+1..capacity); adjacency only holds within a row, so the last
// seat of either row has no neighbor (it does not wrap to the other row or
// back to seat 1).
export function nextSeatNumber(shape, capacity, seatNumber) {
  if (capacity < 2) return null

  if (shape === 'round') {
    return seatNumber >= capacity ? 1 : seatNumber + 1
  }

  const topCount = Math.ceil(capacity / 2)
  if (seatNumber === topCount || seatNumber === capacity) return null
  return seatNumber + 1
}
