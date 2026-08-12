import { useEffect, useMemo, useRef } from 'react';
import { MapContainer, Marker, Popup, TileLayer, useMap } from 'react-leaflet';
import L from 'leaflet';

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, character => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  })[character]);
}

function FitLocations({ locations }) {
  const map = useMap();
  const fittedMembers = useRef('');
  const memberKey = locations.map(location => location.employee_id).sort().join('|');

  useEffect(() => {
    // Heartbeats update coordinates frequently. Do not refit the viewport for
    // every heartbeat: that fights the user's trackpad zoom/pan gesture.
    if (!locations.length || memberKey === fittedMembers.current) return;
    fittedMembers.current = memberKey;
    const bounds = L.latLngBounds(locations.map(location => [location.latitude, location.longitude]));
    map.fitBounds(bounds, {
      padding: [46, 46],
      maxZoom: locations.length === 1 ? 14 : 12,
      animate: true,
      duration: 0.45,
    });
  }, [locations, map, memberKey]);
  return null;
}

function EmployeeMarker({ location }) {
  const icon = useMemo(() => L.divIcon({
    className: 'employee-marker-wrap',
    html: `<div class="employee-marker"><span class="employee-marker-dot"></span><span class="employee-marker-label">${escapeHtml(location.employee_name)}</span></div>`,
    iconAnchor: [9, 9],
  }), [location.employee_name]);

  return <Marker position={[location.latitude, location.longitude]} icon={icon}>
    <Popup>
      <strong>{location.employee_name}</strong><br />
      {location.employee_id} · {location.role}<br />
      Updated {new Date(location.recorded_at).toLocaleString()}<br />
      Accuracy: {location.accuracy_meters == null ? '—' : `${Math.round(location.accuracy_meters)} m`}
    </Popup>
  </Marker>;
}

export default function LiveLocationMap({ locations }) {
  return <div className="live-location-map" aria-label="Live employee location map">
    <MapContainer
      center={[20, 78]}
      zoom={4}
      className="map-canvas"
      scrollWheelZoom
      touchZoom
      zoomAnimation
      fadeAnimation
      zoomSnap={0.25}
      zoomDelta={0.25}
      wheelDebounceTime={20}
      wheelPxPerZoomLevel={120}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <FitLocations locations={locations} />
      {locations.map(location => <EmployeeMarker key={location.employee_id} location={location} />)}
    </MapContainer>
  </div>;
}
