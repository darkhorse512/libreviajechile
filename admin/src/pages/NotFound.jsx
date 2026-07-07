import { Link } from 'react-router-dom'
import { Compass } from 'lucide-react'

export default function NotFound() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center text-center">
      <div className="grid h-16 w-16 place-items-center rounded-2xl bg-navy/5 text-navy">
        <Compass size={30} />
      </div>
      <h1 className="mt-5 text-3xl font-extrabold text-navy">404</h1>
      <p className="mt-1 text-slate-500">Esta página no existe o fue movida.</p>
      <Link to="/" className="btn-primary mt-6">
        Volver al dashboard
      </Link>
    </div>
  )
}
