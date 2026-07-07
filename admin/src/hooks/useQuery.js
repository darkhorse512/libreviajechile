import { useCallback, useEffect, useRef, useState } from 'react'

/**
 * Ejecuta una función asíncrona (normalmente una consulta a Supabase) y expone
 * estado de carga, error, datos y una función `refetch`.
 *
 * @param {() => Promise<any>} fn
 * @param {Array} deps
 */
export function useQuery(fn, deps = []) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const fnRef = useRef(fn)
  fnRef.current = fn

  const run = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await fnRef.current()
      setData(result)
    } catch (err) {
      setError(err?.message ?? 'Error al cargar los datos')
    } finally {
      setLoading(false)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    run()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)

  return { data, loading, error, refetch: run, setData }
}
