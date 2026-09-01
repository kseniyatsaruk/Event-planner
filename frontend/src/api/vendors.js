import client from './client'

export async function listVendors(eventId) {
  const { data } = await client.get(`/events/${eventId}/vendors`)
  return data
}

export async function createVendor(eventId, data) {
  const { data: vendor } = await client.post(`/events/${eventId}/vendors`, data)
  return vendor
}

export async function updateVendor(eventId, vendorId, data) {
  const { data: vendor } = await client.put(`/events/${eventId}/vendors/${vendorId}`, data)
  return vendor
}

export async function deleteVendor(eventId, vendorId) {
  await client.delete(`/events/${eventId}/vendors/${vendorId}`)
}
