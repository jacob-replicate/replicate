module.exports = {
  darkMode: 'class',
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html.slim',
    './db/seeds.rb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/javascript/**/*.jsx',
    './app/javascript/components/**/*.jsx'
  ],
  theme: {
    extend: {
      animation: {
        'typing-pulse': 'typing-pulse 1.2s ease-in-out infinite',
        'slide-in': 'slide-in 0.3s ease-out',
      },
      keyframes: {
        'typing-pulse': {
          '0%, 100%': { opacity: '0.4' },
          '50%': { opacity: '1' },
        },
        'slide-in': {
          '0%': { transform: 'translateX(100%)', opacity: '0' },
          '100%': { transform: 'translateX(0)', opacity: '1' },
        },
      },
    },
  },
}