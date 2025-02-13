// const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        // sans: ["Inter var", "ui-sans-serif", "system-ui", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"],
      },
    },
  },
  // plugins: [
  //   // require('@tailwindcss/forms'),
  //   require("@tailwindcss/typography"),
  //   // require('@tailwindcss/container-queries'),
  //   require("daisyui"),
  // ],
  // daisyui: {
  //   themes: ["light", "dark", "coporate", "pastel"],
  //   darkTheme: "coporate", // name of one of the included themes for dark mode
  // },
};
