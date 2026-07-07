/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // Paleta oficial de Libre Viaje Chile (derivada del logotipo).
        brand: {
          DEFAULT: '#4FBE2A',
          dark: '#3C9A1E',
          light: '#60CC30',
          soft: '#EAF8E1',
        },
        navy: {
          DEFAULT: '#002454',
          light: '#123B72',
          900: '#001836',
        },
        accent: {
          DEFAULT: '#0060C4',
          dark: '#004AA0',
          soft: '#E3EEFB',
        },
        price: '#F59E0B',
        danger: '#E5484D',
        success: '#2FA84F',
        star: '#FBBF24',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      boxShadow: {
        card: '0 1px 3px rgba(16, 24, 40, 0.06), 0 1px 2px rgba(16, 24, 40, 0.04)',
        'card-hover': '0 8px 24px rgba(16, 24, 40, 0.10)',
      },
      keyframes: {
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(6px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.35s ease-out both',
      },
    },
  },
  plugins: [],
}
