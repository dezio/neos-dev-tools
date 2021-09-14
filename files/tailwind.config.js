module.exports = {
  mode: 'jit',
  purge: {
      enabled: true, // process.env.NODE_ENV==="production",
      safelist: ["grid-cols", "col-span", "gap", "inline", "bg-royalblue", "btn", "^w-", "^mt-", "^mx-", "^my-", "^mb-"],
      content: ['./Resources/**/*.html', './Resources/**/*.fusion', './Resources/**/*.js', './Resources/**/*.ts', './.webcache/**/*.html']
  },
  darkMode: false,
  theme: {
      fontFamily: {
          sans: ['titillium web', 'roboto', 'arial', 'sans-serif'],
      },
      extend: {
        
      },
  },
  variants: {
      extend: {}
  },
  plugins: [
      require('@tailwindcss/typography')
  ],
  important: true,
}