# Cocktail Menus (LaTeX)

Bilingual (English / 中文) cocktail and spirits menus, laid out for **US Letter folded in half** (5.5 × 8.5 in panels).

## Layout

```
shared/                     shared assets, used by every event
  cocktailmenu.cls            document class (layout, commands, settings)
  cocktailglasses.sty         TikZ glass icons (\glassicon, \DeclareGlass)
  template.tex                starting point for new events (full example)
  glass-catalog.tex           reference sheet of every glass style
events/
  20261121_Friendsgiving/
    menu.tex                  this event's drinks
    build/                    generated PDFs (not tracked by git)
tools/                      build.sh, impose.sh, new-event.sh
```

Event folders are named `YYYYMMDD_Name`, using letters, digits, `-`, `_` or `.`. Spaces aren't allowed because they break the build tools.

## Quick start

```sh
make new E=20261225_Christmas                             # new event from the template
make new E=20261225_Christmas FROM=20261121_Friendsgiving # …or copy an earlier event
make E=20261225_Christmas                                 # build one event
make                                                      # build every event
make catalog                                              # glass reference sheet
```

Each event's `build/` folder gets two PDFs:

| File | Use it for |
|---|---|
| `build/menu.pdf` | Screen viewing: one panel per page, in reading order |
| `build/menu-print.pdf` | Printing: panels arranged two per Letter sheet in booklet order |

**In VS Code** (LaTeX Workshop), open the repo folder, open an event's `menu.tex` and save. It rebuilds both PDFs and shows a preview in a tab.

If you change `shared/cocktailmenu.cls` or `shared/cocktailglasses.sty`, every event picks up the change on its next build. To freeze an event's look (for example a printed past menu), copy the class into that event's folder; a local copy takes precedence.

## Printing

1. Open `build/menu-print.pdf` and print at **100% / Actual size** (not "Fit to page").
2. Choose **double-sided, flip on short edge**.
3. Fold the sheet in half with the cover facing out.

Pages run in this order: **1** front cover · **2** inside left · **3** inside right · **4** back.
If you add more pages with `\nextpanel`, the print build pads them to a multiple of 4 and nests the sheets into a booklet.

## Writing a menu

```latex
\documentclass[script=sc, layout=stacked, lang=both, frame=all]{cocktailmenu}
\begin{document}

\menucover{title=The Late Hour, title-zh=夜阑, subtitle=Cocktails \& Spirits,
           subtitle-zh=鸡尾酒 · 烈酒, edition=Winter 2026, glass=coupe}

\menusection{Classics}{经典鸡尾酒}
\cocktail{
  name           = Paper Plane,
  name-zh        = 纸飞机,
  glass          = coupe,
  ingredients    = {Bourbon, Aperol, Amaro Nonino, lemon},
  ingredients-zh = {波本威士忌, 阿佩罗, 诺妮诺, 柠檬},
  taste          = {Bittersweet, bright, citrus-forward},
  taste-zh       = 苦甜交织，明亮清爽,
  abv            = 18,
}

\nextpanel
\menusection{Whisky}{威士忌}
\spiritgroup{Scotland}{苏格兰}
\spirit{name=Lagavulin 16, name-zh=乐加维林 16 年, origin=Islay, origin-zh=艾雷岛,
        taste={peat smoke, sea salt}, taste-zh=泥煤烟熏、海盐, abv=43}

\menufooter{Please enjoy responsibly.}{请理性饮酒}
\end{document}
```

> **Watch the commas.** Values are separated by commas, so any value that *contains* an ASCII comma needs braces: `taste = {Rich, smoky}`. Chinese full-width `，` and `、` don't need braces.
> In `ingredients` and `ingredients-zh`, the comma-separated items are joined automatically with a `·` separator.

### Commands

| Command | Purpose |
|---|---|
| `\menucover{…}` | Full cover page. Keys: `title`, `title-zh`, `subtitle`, `subtitle-zh`, `edition`, `glass`, `glass-height` |
| `\menusection{EN}{中文}` | Centred section title with an ornament |
| `\cocktail{…}` | A drink with its glass icon |
| `\spiritgroup{EN}{中文}` | Small ruled sub-heading for spirits (Scotland, Japan, …) |
| `\spirit{…}` | A compact à la carte spirit row |
| `\menutext{EN}{中文}` | Short centred paragraph (intro, house notes) |
| `\menufooter{EN}{中文}` | Footer pinned to the bottom of the current panel |
| `\nextpanel` | Start the next panel (page) |
| `\glassicon[height]{style}` | Draw a glass icon anywhere |
| `\menudot` | The accent-coloured `·` separator. Typing `·` gives the same dot. |

### `\cocktail` / `\spirit` keys

| Key | Example | Notes |
|---|---|---|
| `name`, `name-zh` | `Old Fashioned`, `古典` | Uppercased automatically (`uppercase-names=false` turns this off) |
| `glass` | `rocks` | See `make catalog` → `shared/build/glass-catalog.pdf` |
| `ingredients`, `ingredients-zh` | `{Gin, lime, sugar}` | Comma list, joined with `·` |
| `taste`, `taste-zh` | `{Tart, clean}` | Italic (EN) and Kaiti 楷体 (ZH) |
| `abv` | `18`, `12--15`, `0` | `0` prints **Zero Proof 无酒精** |
| `price` | `14` | Optional; set `currency` to add a symbol in front |
| `note`, `note-zh` | `Contains egg white` | Small accent-coloured line for allergens and similar |
| `origin`, `origin-zh` | `Islay single malt` | Spirits only |

### Glass styles

`coupe` `nicknora` `martini` `margarita` `flute` `wine` `snifter` `hurricane` `irishcoffee` `rocks` `highball` `collins` `shot` `glencairn` `mule` `julep` `tiki`

Aliases: `oldfashioned` `lowball` → rocks, `cocktail` → martini, `champagne` → flute, `brandy` → snifter, `whisky`/`whiskey` → glencairn, `coppermug` → mule, `toddy` → irishcoffee, `nickandnora` → nicknora.

Add your own glass in the preamble with `\DeclareGlass`; see the header of `shared/cocktailglasses.sty`.

## Global settings

Set these as class options (`\documentclass[...]{cocktailmenu}`) or anywhere with `\menusetup{…}`:

| Key | Default | Choices / meaning |
|---|---|---|
| `script` | `sc` | `sc` 简体 · `tc` 繁體 (switches the Songti / Kaiti fonts) |
| `layout` | `stacked` | `stacked` (Chinese under English) · `parallel` (side-by-side columns) |
| `lang` | `both` | `both` · `en` · `zh`. Can be changed mid-document. |
| `frame` | `all` | `all` · `cover` · `none` (double-rule border) |
| `accent` | `8A6A3B` | Hex colour for rules, ABV, dots, icon fill |
| `ink` | `1E1B18` | Hex colour for body text |
| `glass-liquid` | `true` | `false` gives outline-only icons |
| `currency` | *(empty)* | e.g. `\$`, `¥` |
| `spread` | `true` | Share spare space on each panel between the items and the bottom edge |
| `uppercase-names` | `true` | |
| `icon-height`, `icon-column` | `0.6in`, `0.66in` | |
| `entry-sep`, `spirit-sep` | `11pt`, `6pt` | Minimum gap between items |
| `ingredient-sep`, `ingredient-sep-zh` | dot | Custom separator, e.g. `{,\ }` or `{、}` |
| `abv-label`, `zero-proof-label`, `zero-proof-label-zh` | `ABV`, `Zero Proof`, `无酒精` | |

### Fonts

The defaults are all bundled with macOS: **Didot** for titles, **Baskerville** for body text, and **Songti SC/TC** with **Kaiti** for italics. To change them, add lines like these to your preamble:

```latex
\setmainfont{Hoefler Text}                   % English body
\renewfontfamily\menudisplayfont{Bodoni 72}  % cover & section titles
\renewfontfamily\menunamefont{Hoefler Text}  % drink names
\setCJKmainfont{STSong}                      % Chinese body
\setCJKfamilyfont{menuzhdisplay}{Kaiti SC}   % Chinese titles
```

## Build tools

```
tools/build.sh        puts shared/ on TeX's path, runs latexmk (XeLaTeX), then impose.sh
tools/impose.sh       turns build/X.pdf into the print booklet build/X-print.pdf
tools/new-event.sh    creates events/<name>/menu.tex (used by `make new`)
Makefile              shortcuts for the above
.vscode/settings.json LaTeX Workshop recipes (call tools/build.sh)
```

Running plain `latexmk` or `xelatex` inside an event folder won't find the shared class. Use `make`, VS Code, or `tools/build.sh`.

Requirements: TeX Live 2023+ (XeLaTeX, latexmk, xeCJK, fontspec, TikZ, pdfpages) and macOS for the default fonts. On another OS, change the fonts as shown above.
