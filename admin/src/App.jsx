import { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute'
import Layout from './components/Layout'
import { Spinner } from './components/ui'
import Login from './pages/Login'

// Carga diferida de las páginas internas: reduce el bundle inicial y solo
// descarga recharts/leaflet cuando el admin entra al dashboard o al detalle.
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Users = lazy(() => import('./pages/Users'))
const Drivers = lazy(() => import('./pages/Drivers'))
const Trips = lazy(() => import('./pages/Trips'))
const TripDetail = lazy(() => import('./pages/TripDetail'))
const Ratings = lazy(() => import('./pages/Ratings'))
const NotFound = lazy(() => import('./pages/NotFound'))

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >
        <Route
          path="/"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <Dashboard />
            </Suspense>
          }
        />
        <Route
          path="/usuarios"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <Users />
            </Suspense>
          }
        />
        <Route
          path="/conductores"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <Drivers />
            </Suspense>
          }
        />
        <Route
          path="/viajes"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <Trips />
            </Suspense>
          }
        />
        <Route
          path="/viajes/:id"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <TripDetail />
            </Suspense>
          }
        />
        <Route
          path="/calificaciones"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <Ratings />
            </Suspense>
          }
        />
        <Route
          path="*"
          element={
            <Suspense fallback={<Spinner label="Cargando…" />}>
              <NotFound />
            </Suspense>
          }
        />
      </Route>
    </Routes>
  )
}
