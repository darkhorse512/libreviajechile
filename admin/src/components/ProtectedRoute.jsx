import { Navigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { Spinner } from './ui'

export default function ProtectedRoute({ children }) {
  const { session, isAdmin, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return (
      <div className="grid min-h-screen place-items-center bg-slate-50">
        <Spinner label="Cargando…" />
      </div>
    )
  }

  if (!session || !isAdmin) {
    return <Navigate to="/login" replace state={{ from: location }} />
  }

  return children
}
