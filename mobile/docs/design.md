# Design

Editorial content, glass controls. The content layer is flat and hairline-ruled - no cards, no
raised surfaces, no corner radius. Every control floats above it as a pane of glass: blurred,
tinted, lit along its top edge. The two layers never borrow each other's treatment.

Both appearances are first class and follow the system.

## Where it lives

`lib/design/` holds the system; a screen should reach for it before inventing anything.

| File | What it is |
| --- | --- |
| `tokens.dart` | Colours per appearance, and the spacing, radius, blur and chrome metrics |
| `typography.dart` | The type ramp. Money always sets in tabular figures |
| `theme.dart` | `ThemeData` for the Material widgets that remain - fields, switches, pickers |
| `glass.dart` | `GlassPanel`: blur, tint, lit edge, ring, shadow. Every control is one |
| `ledger_screen.dart` | The shape of a screen: band, bouncing list, floating bottom bar |
| `nav_band.dart` | Large title that collapses into a glass band with a compact title |
| `ledger_row.dart` | A row and the rule it closes with, which thickens into its progress bar |
| `glass_tab_bar.dart`, `glass_sheet.dart`, `glass_menu.dart` | The three pieces of chrome |
| `glyph_icon.dart` | Phosphor glyphs, vendored under `assets/icons` from the set the web app ships |

## Rules worth stating

- **Colour comes from `SpendableColors.of(context)`, never from a literal.** It resolves off
  brightness alone, so a screen mounted without the app's theme still reads right.
- **Money goes through `MoneyText`.** It sets tabular figures and colours by sign; `creditIsPositive`
  is for the places where being in the black is the point.
- **A row is a `LedgerRow`.** Progress is `progress` on that row, not a separate bar.
- **A caption is a `Caption`.** It uppercases; do not pass text that is already uppercase.
- **A choice opens a sheet, not a dropdown.** `PickerField` reads like a field and opens one.
- **Selection is entered by long press**, and the leading circles only exist while it is on.
- **Anything drawn in a route of its own needs a `Material` above it.** Text without one falls back
  to the framework's yellow-underlined error style - which is what the tab bar and the month menu
  each did until they were given one.

## Metrics

The blur is `ImageFilterConfig.blur(bounded: true)` rather than a plain `ImageFilter.blur`. A
bounded blur samples only what is behind the pane; an unbounded one pulls in transparent black from
outside its edges, which is what makes an ordinary `BackdropFilter` read as a washed-out rectangle
instead of glass. `Shell` wraps the app in a `BackdropGroup` so the panes on a screen sample the
backdrop once between them.

Spacing 4 / 7 / 13 / 17 / 24 in content. Chrome insets 14 at the sides and 24 at the bottom. Radii
are 0 on every row and rail, 31 on the tab bar, 25 on a capsule, 16 on a menu or sheet. Blur is 26
on the band, 28 on the tab bar, 30 on menus and sheets, all at saturate(180%).

The tab bar is 62 tall and floats 24 above the bottom of the screen - over the home indicator's
margin rather than stacked on top of it, which is where iOS puts a floating bar. `Shell` hands the
clearance down as bottom padding so lists scroll under it rather than stopping above it.

There is no native glass to call on: nothing in the Flutter SDK provides it, and its own
`CupertinoTabBar` is a full-width bar with a solid 1px grey top border. The lit edge here fades out
towards the ends for the same reason - an even line across the top reads as a drawn border, which is
the tell that a pane is not really glass.

## Seeing it

The simulator runtime is not installed yet, so the way to look at a screen is to render it from the
test tree: pump `Shell` at 390x844 with `/System/Library/Fonts/SFNS.ttf` loaded through a
`FontLoader` (the test renderer draws every glyph as a box without it), then
`expectLater(find.byType(Shell), matchesGoldenFile(...))` with `--update-goldens`. It is close
enough to read the layout and the colour, and it costs nothing to throw away afterwards.
