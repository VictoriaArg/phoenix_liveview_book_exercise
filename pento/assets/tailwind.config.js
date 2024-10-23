// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/pento_web.ex",
    "../lib/pento_web/**/*.*ex"
  ],
  theme: {
    extend: {
      fontSize: {
        'xs': '0.75rem',
        'sm': '0.875rem',
        'base': '1rem',
        'lg': '1.125rem',
        'xl': '1.25rem',
        '2xl': '1.5rem',
        '3xl': '1.875rem',
        '4xl': '2.25rem',
        '5xl': '3rem',
        '6xl': '3.75rem',
        '7xl': '4.5rem',
        '8xl': '6rem',
        '9xl': '8rem',
      },
      fontFamily: {
        'cooper': ['"Cooper Hewitt"', 'sans-serif'],
        'cooper-black': ['"Cooper Black"', 'sans-serif']
      },
      colors: {
        'primary-100': "#AAABEE",
        'primary-300': "#7779E4",
        'primary-500': "#2D2FD5",
        'primary-700': "#141666",
        'secondary-100': "#FFEBF8",
        'secondary-300': "#FF97DC",
        'secondary-500': "#FF1FB0",
        'secondary-700': "#AA177D",
        'info-100': "#C2FFF4",
        'info-300': "#5DFEE1",
        'info-500': "#06BF9C",
        'info-700': "#007A64",
        'warning-100': "#FDD5C3",
        'warning-300': "#FB9160",
        'warning-500': "#FA6826",
        'warning-700': "#9E3505",
        'highlight-100': "#FDEDC3",
        'highlight-300': "#FDD672",
        'highlight-500': "#FCC638",
        'highlight-700': "#B28106",
        'bnw-300': "#BABABA",
        'bnw-500': "#494949",
      },
      boxShadow: {
        'solid-black': '8px 8px 0 0 rgba(0, 0, 0, 1)',
        'solid-primary': '8px 8px 0 0 rgba(170, 171, 238, 1)',
        'solid-secondary': '8px 8px 0 0 rgba(255, 235, 248, 1)',
        'solid-disabled': '8px 8px 0 0 rgba(186, 186, 186, 1)',
        'solid-warning': '8px 8px 0 0 rgba(251, 145, 96, 1)'
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
