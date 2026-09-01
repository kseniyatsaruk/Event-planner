import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'
import { useEffect } from 'react'
import { MapContainer, Marker, TileLayer, useMap, useMapEvents } from 'react-leaflet'

// Vite doesn't serve leaflet's default marker images at the paths the CSS
// expects, so the default icon silently fails to load unless we point it
// at the bundled assets ourselves.
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
})

const DEFAULT_CENTER = [51.505, -0.09]
const DEFAULT_ZOOM = 13

function Recenter({ lat, lng }) {
  const map = useMap()
  useEffect(() => {
    map.setView([lat, lng], map.getZoom())
  }, [lat, lng])
  return null
}

function ClickHandler({ onPick }) {
  useMapEvents({
    click(e) {
      onPick({ lat: e.latlng.lat, lng: e.latlng.lng })
    },
  })
  return null
}

export default function LocationPicker({ lat, lng, onChange }) {
  const hasPosition = typeof lat === 'number' && typeof lng === 'number'
  const center = hasPosition ? [lat, lng] : DEFAULT_CENTER

  return (
    <MapContainer center={center} zoom={DEFAULT_ZOOM} style={{ height: 320, width: '100%' }}>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {hasPosition && <Marker position={[lat, lng]} />}
      {hasPosition && <Recenter lat={lat} lng={lng} />}
      <ClickHandler onPick={onChange} />
    </MapContainer>
  )
}
