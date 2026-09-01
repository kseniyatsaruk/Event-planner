import client from './client'

export async function listTables(eventId) {
  const { data } = await client.get(`/events/${eventId}/tables`)
  return data
}

export async function createTable(eventId, data) {
  const { data: table } = await client.post(`/events/${eventId}/tables`, data)
  return table
}

export async function updateTable(eventId, tableId, data) {
  const { data: table } = await client.put(`/events/${eventId}/tables/${tableId}`, data)
  return table
}

export async function deleteTable(eventId, tableId) {
  await client.delete(`/events/${eventId}/tables/${tableId}`)
}
