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
}