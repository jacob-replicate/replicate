const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,html}'
  ],
  theme: {
    screens: {
      md: '768px',
      lg: '1000px',
      xl: '1200px'
    },
    fontSize: {
      sm: '1.1rem',
      md: '1.23rem',
      xl: '1.35rem',
      '2xl': '1.5rem',
      '3xl': '1.8rem',
      '4xl': '2.3rem',
    },
    extend: {
      fontFamily: {
        sans: ['Inter', 'Open Sans', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}