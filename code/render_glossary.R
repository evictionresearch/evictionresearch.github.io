#!/usr/bin/env Rscript
# =============================================================================
# render_glossary.R — Eviction Research Network
# -----------------------------------------------------------------------------
# Build glossary.html from the editable source docs/glossary.md and the page
# chrome docs/glossary.template.html. Mirrors the content.md -> render.R pattern
# used by the state-profile repos.
#
# Usage (from the repo root):
#     Rscript code/render_glossary.R
#
# Inputs : docs/glossary.md            (front matter + "## Term" entries)
#          docs/glossary.template.html (chrome with {{TOKENS}} + <!--GLOSSARY_BODY-->)
# Output : glossary.html               (repo root)
#
# No external packages — base R only.
# =============================================================================

suppressWarnings({
  SRC_MD   <- "docs/glossary.md"
  TPL_HTML <- "docs/glossary.template.html"
  OUT_HTML <- "glossary.html"
})

stopifnot_file <- function(p) if (!file.exists(p))
  stop(sprintf("Cannot find '%s'. Run this from the repo root.", p), call. = FALSE)
stopifnot_file(SRC_MD); stopifnot_file(TPL_HTML)

# ---- small helpers ----------------------------------------------------------

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || is.na(a)) b else a

trim    <- function(x) gsub("^\\s+|\\s+$", "", x)
squish  <- function(x) trim(gsub("\\s+", " ", x))
nkey    <- function(x) squish(tolower(x))                     # lookup key
strip_paren <- function(x) squish(sub("\\s*\\([^)]*\\)", "", x))

slugify <- function(x) {
  x <- sub("\\s*\\([^)]*\\)", "", x)        # drop a parenthetical
  x <- tolower(trim(x))
  x <- gsub("&", " and ", x, fixed = TRUE)
  x <- gsub("[^a-z0-9]+", "-", x)
  gsub("^-+|-+$", "", x)
}

html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  x <- gsub(">", "&gt;",  x, fixed = TRUE)
  x
}

# inline markdown -> HTML (escape first, then links, bold, italic, code)
inline_md <- function(s) {
  s <- html_escape(s)
  s <- gsub("\\[([^]]+)\\]\\((https?://[^) ]+)\\)",
            "<a href=\"\\2\" target=\"_blank\" rel=\"noopener noreferrer\">\\1</a>",
            s, perl = TRUE)
  s <- gsub("\\*\\*([^*]+)\\*\\*", "<strong>\\1</strong>", s, perl = TRUE)
  s <- gsub("(?<!\\*)\\*(?!\\*)([^*]+)\\*(?!\\*)", "<em>\\1</em>", s, perl = TRUE)
  s <- gsub("`([^`]+)`", "<code>\\1</code>", s, perl = TRUE)
  s
}

# a multi-paragraph definition block -> <p>..</p><p>..</p>
def_to_html <- function(lines) {
  block <- paste(lines, collapse = "\n")
  block <- trim(block)
  paras <- strsplit(block, "\n[ \t]*\n")[[1]]          # blank line = paragraph
  paras <- paras[nzchar(trim(paras))]
  paste0("<p>", vapply(paras, function(p) inline_md(squish(p)), character(1)),
         "</p>", collapse = "\n            ")
}

# ---- read source ------------------------------------------------------------

md <- readLines(SRC_MD, encoding = "UTF-8", warn = FALSE)

# front matter: between the first two '---' fences
fence <- which(trim(md) == "---")
meta <- list()
body_start <- 1L
if (length(fence) >= 2 && fence[1] == 1L) {
  fm <- md[(fence[1] + 1):(fence[2] - 1)]
  for (ln in fm) {
    m <- regmatches(ln, regexec("^([A-Za-z0-9_]+):\\s*(.*)$", ln))[[1]]
    if (length(m) == 3) {
      val <- trim(m[3])
      val <- sub('^"(.*)"$', "\\1", val)              # strip surrounding quotes
      val <- sub("^'(.*)'$", "\\1", val)
      meta[[m[2]]] <- val
    }
  }
  body_start <- fence[2] + 1L
}

# ---- parse entries ----------------------------------------------------------
# Each entry starts at "## Term". Optional metadata lines (Category / See also /
# Also known as) directly follow; the rest, until the next "## ", is the body.

body <- md[body_start:length(md)]
heads <- grep("^##\\s+", body)
if (!length(heads)) stop("No '## Term' entries found in ", SRC_MD, call. = FALSE)

entries <- list()
for (i in seq_along(heads)) {
  s <- heads[i]
  e <- if (i < length(heads)) heads[i + 1] - 1 else length(body)
  term <- squish(sub("^##\\s+", "", body[s]))

  category <- NULL; see_also <- character(0); aka <- character(0)
  j <- s + 1
  while (j <= e) {
    ln <- body[j]
    mm <- regmatches(ln, regexec("^(Category|See also|Also known as):\\s*(.*)$",
                                 ln, ignore.case = TRUE))[[1]]
    if (length(mm) == 3) {
      key <- tolower(mm[2]); val <- trim(mm[3])
      if (key == "category")           category <- val
      else if (key == "see also")      see_also <- trim(strsplit(val, ",")[[1]])
      else if (key == "also known as") aka      <- trim(strsplit(val, ",")[[1]])
      j <- j + 1
    } else if (!nzchar(trim(ln))) {
      j <- j + 1                                       # skip blank before body
      break
    } else break
  }
  def_lines <- if (j <= e) body[j:e] else character(0)

  entries[[length(entries) + 1]] <- list(
    term = term, category = category %||% "", see_also = see_also,
    aka = aka, def = def_lines
  )
}

# ---- slugs + alias map (for See-also resolution) ----------------------------

slugs <- vapply(entries, function(en) slugify(en$term), character(1))
# de-duplicate slugs defensively
dup <- duplicated(slugs)
if (any(dup)) for (k in which(dup)) slugs[k] <- paste0(slugs[k], "-", k)

alias <- new.env(parent = emptyenv())
reg <- function(key, slug) if (nzchar(key)) assign(key, slug, envir = alias)
for (i in seq_along(entries)) {
  t <- entries[[i]]$term; sl <- slugs[i]
  reg(nkey(t), sl)
  reg(nkey(strip_paren(t)), sl)
  reg(slugs[i], sl)
  ab <- regmatches(t, regexec("\\(([^),]+)\\)", t))[[1]]   # single-abbr paren only
  if (length(ab) == 2) reg(nkey(ab[2]), sl)
}
resolve <- function(ref) {
  for (cand in unique(c(nkey(ref), nkey(strip_paren(ref)), slugify(ref))))
    if (exists(cand, envir = alias, inherits = FALSE)) return(get(cand, envir = alias))
  NA_character_
}

# ---- order + group by first letter ------------------------------------------

ord <- order(tolower(vapply(entries, `[[`, character(1), "term")))
entries <- entries[ord]; slugs <- slugs[ord]
first_letter <- toupper(substr(vapply(entries, `[[`, character(1), "term"), 1, 1))

# ---- build A–Z index --------------------------------------------------------

LETTERS_USED <- sort(unique(first_letter))
az <- vapply(LETTERS, function(L) {
  if (L %in% LETTERS_USED)
    sprintf('<a href="#letter-%s">%s</a>', L, L)
  else
    sprintf('<span aria-hidden="true">%s</span>', L)
}, character(1))
az_html <- paste0(
  '<nav class="glossary-az" aria-label="Jump to letter">\n          ',
  paste(az, collapse = "\n          "), "\n        </nav>")

# ---- build term list --------------------------------------------------------

term_html <- character(0)
for (L in LETTERS_USED) {
  idx <- which(first_letter == L)
  term_html <- c(term_html,
    sprintf('<h2 id="letter-%s" class="glossary-letter">%s</h2>', L, L))
  for (i in idx) {
    en <- entries[[i]]; sl <- slugs[i]

    # data-term: term + aliases for the filter box
    keys <- unique(tolower(c(en$term, strip_paren(en$term), en$aka,
                             regmatches(en$term,
                               regexec("\\(([^)]+)\\)", en$term))[[1]][-1])))
    keys <- keys[nzchar(keys)]
    data_term <- html_escape(paste(keys, collapse = " "))

    cat_html <- if (nzchar(en$category))
      sprintf('<span class="term-cat">%s</span>\n            ',
              html_escape(en$category)) else ""

    see_html <- ""
    if (length(en$see_also)) {
      links <- vapply(en$see_also, function(r) {
        sl2 <- resolve(r)
        if (is.na(sl2)) html_escape(r)
        else sprintf('<a href="#%s">%s</a>', sl2, html_escape(r))
      }, character(1))
      see_html <- sprintf(
        '\n            <p class="term-see"><span class="see-label">See also:</span> %s</p>',
        paste(links, collapse = ", "))
    }

    term_html <- c(term_html, paste0(
      sprintf('<article class="glossary-term" id="%s" data-term="%s">', sl, data_term), "\n            ",
      sprintf('<h3 class="term-name">%s <a class="term-anchor" href="#%s" aria-label="Permalink to %s">#</a></h3>',
              html_escape(en$term), sl, html_escape(en$term)), "\n            ",
      cat_html,
      sprintf('<div class="term-def">%s</div>', def_to_html(en$def)),
      see_html, "\n          </article>"))
  }
}

body_html <- paste0(
  '<div class="glossary-controls">\n          ',
  '<label class="visually-hidden" for="glossary-filter">Filter glossary terms</label>\n          ',
  '<input type="search" id="glossary-filter" class="glossary-filter" placeholder="Filter terms…" autocomplete="off" spellcheck="false">\n        </div>\n        ',
  az_html, "\n        ",
  '<div class="glossary-list">\n          ',
  paste(term_html, collapse = "\n          "),
  "\n        </div>\n        ",
  '<p class="glossary-noresults" hidden>No terms match your filter.</p>')

# ---- assemble page ----------------------------------------------------------

tpl <- paste(readLines(TPL_HTML, encoding = "UTF-8", warn = FALSE), collapse = "\n")

subst <- function(tpl, token, value)
  gsub(paste0("{{", token, "}}"), value %||% "", tpl, fixed = TRUE)

tpl <- subst(tpl, "TITLE",       meta$title)
tpl <- subst(tpl, "DESCRIPTION", meta$description)
tpl <- subst(tpl, "KEYWORDS",    meta$keywords)
tpl <- subst(tpl, "KICKER",      meta$kicker %||% "Reference")
tpl <- subst(tpl, "H1",          meta$h1)
tpl <- subst(tpl, "LEAD",        meta$lead)
tpl <- subst(tpl, "UPDATED",     meta$updated)
tpl <- subst(tpl, "N_TERMS",     as.character(length(entries)))
tpl <- sub("<!--GLOSSARY_BODY-->", body_html, tpl, fixed = TRUE)

con <- file(OUT_HTML, open = "w", encoding = "UTF-8")
writeLines(tpl, con)
close(con)

message(sprintf("Wrote %s — %d terms across %d letters.",
                OUT_HTML, length(entries), length(LETTERS_USED)))
