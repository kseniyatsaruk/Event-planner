import client from './client'

export async function listGuests(eventId) {
  const { data } = await client.get(`/events/${eventId}/guests`)
  return data
}

export async function createGuest(eventId, data) {
  const { data: guest } = await client.post(`/events/${eventId}/guests`, data)
  return guest
}

export async function updateGuest(eventId, guestId, data) {
  const { data: guest } = await client.put(`/events/${eventId}/guests/${guestId}`, data)
  return guest
}

export async function deleteGuest(eventId, guestId) {
  await client.delete(`/events/${eventId}/guests/${guestId}`)
}

export async function assignGuestTable(eventId, guestId, tableId, seatNumber = null) {
  const { data } = await client.patch(`/events/${eventId}/guests/${guestId}/table`, {
    tableId,
    seatNumber,
  })
  return data
}
