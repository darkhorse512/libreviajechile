import { useEffect } from 'react'
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet'
import L from 'leaflet'

// Marcador coloreado como pin (evita el problema de iconos rotos con bundlers).
function pin(color) {
  return L.divIcon({
    className: '',
    html: `<div style="
      width:22px;height:22px;border-radius:50% 50% 50% 0;
      background:${color};transform:rotate(-45deg);
      border:2.5px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.35)"></div>`,
    iconSize: [22, 22],
    iconAnchor: [11, 22],
  })
}

const ORIGIN_ICON = pin('#4FBE2A')
const DEST_ICON = pin('#E5484D')

function FitBounds({ points }) {
  const map = useMap()
  useEffect(() => {
    if (points.length >= 2) {
      map.fitBounds(points, { padding: [40, 40] })
    } else if (points.length === 1) {
      map.setView(points[0], 14)
    }
  }, [map, points])
  return null
}

/**
 * Mapa OpenStreetMap con origen, destino y trazado.
 * `origin` y `destination` son [lat, lng] o null.
 */
export default function TripMap({ origin, destination, height = 320 }) {
  const points = [origin, destination].filter(Boolean)
  const center = points[0] ?? [-33.4489, -70.6693] // Santiago por defecto

  return (
    <div style={{ height }} className="overflow-hidden rounded-2xl">
      <MapContainer
        center={center}
        zoom={13}
        scrollWheelZoom={false}
        style={{ height: '100%', width: '100%' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {origin && <Marker position={origin} icon={ORIGIN_ICON} />}
        {destination && <Marker position={destination} icon={DEST_ICON} />}
        {points.length === 2 && (
          <Polyline positions={points} pathOptions={{ color: '#0060C4', weight: 4, opacity: 0.75 }} />
        )}
        <FitBounds points={points} />
      </MapContainer>
    </div>
  )
}
