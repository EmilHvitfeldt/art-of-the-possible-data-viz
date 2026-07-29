# Post-render hook: autolink R code in the rendered site with downlit.
#
# downlit re-highlights every `<pre class="sourceCode r">` block and turns
# function calls into links to the relevant documentation (pkgdown sites for
# tidyverse-style packages, rdrr.io otherwise). Inline `<code>` spans get the
# same treatment via downlit::autolink().
#
# Run automatically by `quarto render` (see post-render in _quarto.yml); it is
# skipped silently when downlit is not installed so the site still builds.

if (!requireNamespace("downlit", quietly = TRUE)) {
  message("downlit not installed; skipping autolinking")
  quit(save = "no")
}

output_dir <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", "_site")

# Packages used across the pages. Only the installed ones are handed to
# downlit; the search order decides which package wins for ambiguous topics.
pkgs <- c(
  "dplyr", "ggdist", "ggiraph", "ggplot2", "ggtext", "glue", "gt", "gtExtras",
  "here", "htmltools", "MetBrewer", "patchwork", "purrr", "readr", "scales",
  "sf", "showtext", "stringr", "tidyr", "waffle",
  "stats", "graphics", "grDevices", "utils", "methods", "base"
)
pkgs <- pkgs[vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
options(downlit.attached = pkgs)

# Package homepages, for inline mentions like `ggplot2`. downlit knows the URL a
# `library()` call should point at; when a package has no website it lands on the
# docs for base::library() instead, and we fall back to the CRAN page.
package_url <- local({
  cache <- list()
  function(pkg) {
    if (is.null(cache[[pkg]])) {
      url <- downlit::autolink_url(paste0("library(", pkg, ")"))
      if (is.na(url) || grepl("rdrr.io/r/base/library", url, fixed = TRUE)) {
        url <- paste0("https://cran.r-project.org/package=", pkg)
      }
      cache[[pkg]] <<- url
    }
    cache[[pkg]]
  }
})

# An inline `<code>` span is treated as a package mention when its text is
# exactly the name of an installed package, so the link is always real. Spans
# inside code blocks, headings, or existing links are left alone (downlit uses
# the same rule for the code it autolinks).
link_package_mentions <- function(html) {
  installed <- rownames(utils::installed.packages())
  spans <- xml2::xml_find_all(
    html,
    paste0(
      "//code[not(ancestor::pre)][not(ancestor::a)][not(descendant::a)]",
      "[not(ancestor::h1|ancestor::h2|ancestor::h3|ancestor::h4)]",
      "[not(*)]"
    )
  )

  n <- 0
  for (span in spans) {
    pkg <- trimws(xml2::xml_text(span))
    if (!pkg %in% installed) next
    xml2::xml_text(span) <- ""
    link <- xml2::xml_add_child(span, "a", pkg)
    xml2::xml_set_attr(link, "href", package_url(pkg))
    n <- n + 1
  }
  n
}

# downlit swaps each R code block for a freshly built <pre class="downlit
# sourceCode r">, which drops the `code-with-copy` class Quarto relies on for
# copy-button spacing. So we stash the class of every block downlit is about to
# touch and reapply it afterwards (document order is preserved, so the rebuilt
# blocks can be matched by position).
r_blocks <- function(html) {
  blocks <- xml2::xml_find_all(html, "//pre[contains(@class, 'sourceCode')]")
  blocks[grepl("(^|\\s)r(\\s|$)", xml2::xml_attr(blocks, "class"))]
}

autolink_file <- function(path) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  classes <- xml2::xml_attr(r_blocks(html), "class")

  # Already processed (e.g. this script run twice over the same output).
  if (any(grepl("downlit", classes, fixed = TRUE))) {
    return(invisible(NA_integer_))
  }

  downlit::downlit_html_node(html)
  mentions <- link_package_mentions(html)

  rebuilt <- xml2::xml_find_all(html, "//pre[contains(@class, 'downlit')]")
  if (length(rebuilt) != length(classes)) {
    message(
      "downlit: unexpected block count in ", path,
      " (", length(rebuilt), " vs ", length(classes), "); leaving classes as is"
    )
  } else {
    for (i in seq_along(rebuilt)) {
      xml2::xml_set_attr(rebuilt[[i]], "class", classes[[i]])
    }
  }

  xml2::write_html(html, path, format = FALSE)
  invisible(mentions)
}

files <- list.files(output_dir, pattern = "[.]html$", recursive = TRUE, full.names = TRUE)
files <- files[!startsWith(files, file.path(output_dir, "site_libs"))]

# One count of inline package mentions per file; NA means the file was skipped.
mentions <- vapply(files, function(file) {
  tryCatch(
    as.integer(autolink_file(file)),
    error = function(cnd) {
      message("downlit failed on ", file, ": ", conditionMessage(cnd))
      NA_integer_
    }
  )
}, integer(1))

message(
  "downlit: autolinked ", sum(!is.na(mentions)), " of ", length(files),
  " file(s) in ", output_dir, "; linked ", sum(mentions, na.rm = TRUE),
  " inline package mention(s)"
)
