const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.{html.erb,erb}',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Suisse Intl', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ],
  safelist: [
    'bg-indigo-50/40', 'border-indigo-200', 'bg-indigo-400', 'text-indigo-500',
    'bg-emerald-50/40', 'border-emerald-200', 'bg-emerald-400',
    'bg-amber-50/40', 'border-amber-200', 'bg-amber-400'
  ]
}