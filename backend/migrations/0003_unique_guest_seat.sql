CREATE UNIQUE INDEX IF NOT EXISTS idx_guests_table_seat
  ON guests(table_id, seat_number)
  WHERE table_id IS NOT NULL AND seat_number IS NOT NULL;
