import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
  },
  build: {
    chunkSizeWarningLimit: 800,
    rollupOptions: {
      output: {
        // Separa las librerías pesadas en chunks propios para acelerar la carga
        // inicial y aprovechar la caché del navegador entre despliegues.
        manualChunks: {
          react: ['react', 'react-dom', 'react-router-dom'],
          charts: ['recharts'],
          map: ['leaflet', 'react-leaflet'],
          supabase: ['@supabase/supabase-js'],
        },
      },
    },
  },
})
