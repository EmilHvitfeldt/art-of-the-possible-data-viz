# Art of the Possible: Data Viz

A small [Quarto](https://quarto.org/) website showcasing what is possible with data visualization in R: tables, plots, maps, and interactive Shiny apps, one per page.

Most pages are **recreations of work by other authors**. Every page credits its original author at the top with links to the original article and its source code. All credit for those designs and analyses belongs to them; see [Credits](#credits) below.

## The examples

| Page | What it shows | Tools |
| --- | --- | --- |
| [Subway table](viz/subway-table.qmd) | Buenos Aires subway lines with inline clock plots, maps, and sparklines | `gt`, `gtExtras`, `sf` |
| [Sequence alignment](viz/msa-table.qmd) | Conserved regions across coronavirus spike proteins | `gt` |
| [Ridgeline plot](viz/ridgeline-plot.qmd) | Bay Area Craigslist rents by listing adjective, with an annotated legend plot inside the panel | `ggplot2`, `ggdist`, `patchwork` |
| [Waffle chart](viz/waffle-storms.qmd) | Yearly Atlantic tropical cyclone counts by category | `ggplot2`, `waffle` |
| [Choropleth map](viz/brussels-choropleth.qmd) | Building-level health-precarity index across Brussels | `sf`, `ggplot2` |
| [Commute Explorer](shiny/commute-explorer.qmd) | Interactive exploration of New Zealand commuting patterns | Shiny |

## Building the site

```sh
quarto preview   # local preview with live reload
quarto render    # build into _site/
```

R packages used across the pages:

`dplyr`, `ggdist`, `ggiraph`, `ggplot2`, `ggtext`, `glue`, `gt`, `gtExtras`, `here`, `htmltools`, `MetBrewer`, `patchwork`, `purrr`, `readr`, `scales`, `sf`, `showtext`, `stringr`, `tidyr`, `waffle`

The [`quarto-ext/shinylive`](https://github.com/quarto-ext/shinylive) extension is vendored under `_extensions/`.

## How it is put together

- `index.qmd` is the landing page; each example lives in `viz/` or `shiny/` and is listed in the navbar in `_quarto.yml`.
- Data and assets are **vendored into the repo** (e.g. `viz/ridgeline-data/`, `viz/choropleth-data/`) so every page renders without network access. A few figures, such as subway passenger counts, are simulated placeholders; the pages say so where that is the case.
- Non-Shiny pages show the finished result first, then the code in a collapsed "Show code" block.
- `_postrender-downlit.R` runs after rendering and uses [downlit](https://downlit.r-lib.org/) to turn function calls in the code blocks into links to their documentation.

## Credits

- **Karina Bartolomé**, [*The grammar of tables*](https://karbartolome.quarto.pub/the-grammar-of-tables/) ([source](https://github.com/karbartolome/quartopub/tree/main/01_tables_r_python)) for the subway table.
- **Victor Yuan**, *Visualizing Conserved Regions Across Coronavirus Spike Proteins*, 2025 Posit Table Contest ([entry](https://github.com/rich-iannone/table-contest/discussions/10) · [source](https://github.com/wvictor14/2025-posit-table-contest-gt-msa/)) for the sequence alignment table.
- **Ansgar Wolsing** for the [ridgeline plot](https://r-graph-gallery.com/web-ridgeline-plot-with-inside-plot-and-annotations.html), via the R Graph Gallery. Data: Kate Pennington (2018), *Bay Area Craigslist Rental Housing Posts, 2000-2018*.
- **Muhammad Azhar** for the [waffle chart](https://r-graph-gallery.com/web-waffle-for-time-evolution.html), via the R Graph Gallery. Data: NOAA `storms`.
- **[Médor](https://bxl-malade.medor.coop/)** for *Bruxelles malade*, the Brussels health-precarity map, rebuilt in R from the article's own data.
- **Stefan Schliebs** for [Commute Explorer](https://nz-stefan.shinyapps.io/commute-explorer-2/) ([source](https://github.com/nz-stefan/commute-explorer-2)), a winner of the 3rd Annual Posit Shiny Contest.
