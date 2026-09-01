import client from './client'

export async function listChecklist(eventId) {
  const { data } = await client.get(`/events/${eventId}/checklist`)
  return data
}

export async function createChecklistItem(eventId, data) {
  const { data: item } = await client.post(`/events/${eventId}/checklist`, data)
  return item
}

export async function updateChecklistItem(eventId, itemId, data) {
  const { data: item } = await client.put(`/events/${eventId}/checklist/${itemId}`, data)
  return item
}

export async function deleteChecklistItem(eventId, itemId) {
  await client.delete(`/events/${eventId}/checklist/${itemId}`)
}
