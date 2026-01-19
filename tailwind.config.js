module.exports = {
  darkMode: 'class',
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html.slim',
    './db/seeds.rb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/javascript/**/*.jsx'
  ],
  safelist: [
    // Simplified 3-color palette for question_cta cards
    {
      pattern: /^(bg|border|text)-(slate|indigo|emerald)-(50|100|200|300|400|500|600|700|800|900)/,
      variants: ['hover', 'dark', 'dark:hover']
    }
  ]
}