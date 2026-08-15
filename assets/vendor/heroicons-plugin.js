// Embeds Heroicons (https://heroicons.com) into the app.css bundle as `hero-*` classes.
// See `CoreComponents.icon/1`.
const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = plugin(function ({matchComponents}) {
  let iconsDir = path.join(__dirname, "./heroicons/optimized")
  let values = {}
  let icons = [
    ["", "/24/outline"],
    ["-solid", "/24/solid"],
    ["-mini", "/20/solid"]
  ]

  icons.forEach(([suffix, dir]) => {
    fs.readdirSync(path.join(iconsDir, dir)).map(file => {
      let name = path.basename(file, ".svg") + suffix
      values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
    })
  })

  matchComponents({
    "hero": ({name, fullPath}) => {
      let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
      return {
        [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        "-webkit-mask": `var(--hero-${name})`,
        "mask": `var(--hero-${name})`,
        "mask-repeat": "no-repeat",
        "background-color": "currentColor",
        "vertical-align": "middle",
        "display": "inline-block",
        "width": "1.25rem",
        "height": "1.25rem"
      }
    }
  }, {values})
})
