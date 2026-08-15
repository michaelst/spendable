// Embeds Phosphor icons (https://phosphoricons.com) into the app.css bundle as `pi-*` classes.
// See `CoreComponents.icon/1`.
//
// The two vendored weights flatten into one namespace, which is safe because Phosphor suffixes
// every non-regular file: `caret-right.svg` and `caret-right-fill.svg` become `pi-caret-right` and
// `pi-caret-right-fill`. Only the icons a template actually names are emitted.
const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = plugin(function ({matchComponents}) {
  let iconsDir = path.join(__dirname, "./phosphor")
  let values = {}

  fs.readdirSync(iconsDir).forEach(weight => {
    fs.readdirSync(path.join(iconsDir, weight)).map(file => {
      let name = path.basename(file, ".svg")
      values[name] = {name, fullPath: path.join(iconsDir, weight, file)}
    })
  })

  matchComponents({
    "pi": ({name, fullPath}) => {
      let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
      return {
        [`--pi-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        "-webkit-mask": `var(--pi-${name})`,
        "mask": `var(--pi-${name})`,
        "mask-repeat": "no-repeat",
        "mask-position": "center",
        "background-color": "currentColor",
        "vertical-align": "middle",
        "display": "inline-block",
        "width": "1.25rem",
        "height": "1.25rem"
      }
    }
  }, {values})
})
