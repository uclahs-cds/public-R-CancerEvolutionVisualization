#!/usr/bin/env Rscript
# update-snapshots.R
#
# Regenerates all reference .Rda snapshot files used by the testthat snapshot
# tests. Run this whenever the rendering output of SRCGrob changes intentionally
# (e.g. after a bug fix or layout change).
#
# Usage (from the package root):
#   Rscript tests/update-snapshots.R
#
# The script re-installs the package from source first so the snapshots are
# always built against the current code.

pkg.root <- normalizePath(file.path(dirname(sys.frame(1)$ofile), '..'), mustWork = FALSE)
if (!nzchar(pkg.root) || pkg.root == '.') {
    pkg.root <- getwd()
    }

message('Package root: ', pkg.root)
message('Installing package from source...')
devtools::load_all(pkg.root, quiet = TRUE)

data.dir <- file.path(pkg.root, 'tests', 'testthat', 'data')

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

update_rda <- function(filename, ...) {
    path <- file.path(data.dir, filename)
    vars <- list(...)
    list2env(vars, envir = environment())
    save(list = names(vars), file = path, envir = environment())
    message('  Saved ', filename)
    }

# ---------------------------------------------------------------------------
# 1. Fixed branching
# ---------------------------------------------------------------------------

message('\n[1/6] Fixed branching...')
local({
    load(file.path(data.dir, 'branching.fixed.data.Rda'))

    branching.fixed.example <- SRCGrob(branching.fixed.test.data$tree)

    branching.fixed.30deg.example <- SRCGrob(
        branching.fixed.test.data$tree,
        plotting.direction = 30
        )

    update_rda(
        'branching.fixed.plots.Rda',
        branching.fixed.example        = branching.fixed.example,
        branching.fixed.30deg.example  = branching.fixed.30deg.example
        )
    })

# ---------------------------------------------------------------------------
# 2. Radial branching
# ---------------------------------------------------------------------------

message('[2/6] Radial branching...')
local({
    load(file.path(data.dir, 'branching.radial.data.Rda'))

    branching.radial.example <- SRCGrob(branching.radial.test.data$tree)

    branching.radial.right.example <- SRCGrob(
        branching.radial.test.data$tree,
        plotting.direction = 'right'
        )

    branching.radial.30deg.example <- SRCGrob(
        branching.radial.test.data$tree,
        plotting.direction = 30
        )

    update_rda(
        'branching.radial.plots.Rda',
        branching.radial.example        = branching.radial.example,
        branching.radial.right.example  = branching.radial.right.example,
        branching.radial.30deg.example  = branching.radial.30deg.example
        )
    })

# ---------------------------------------------------------------------------
# 3. Dendrogram
# ---------------------------------------------------------------------------

message('[3/6] Dendrogram...')
local({
    load(file.path(data.dir, 'branching.dendrogram.data.Rda'))

    branching.dendrogram.example <- SRCGrob(branching.dendrogram.test.data$tree)

    update_rda(
        'branching.dendrogram.plots.Rda',
        branching.dendrogram.example = branching.dendrogram.example
        )
    })

# ---------------------------------------------------------------------------
# 4. Fish plot
# ---------------------------------------------------------------------------

message('[4/6] Fish plot...')
local({
    load(file.path(data.dir, 'fish.data.Rda'))

    fish.example <- SRCGrob(
        fish.test.data$tree,
        polygon.colour.scheme = fish.test.data$colour.scheme
        )

    update_rda(
        'fish.plots.Rda',
        fish.example = fish.example
        )
    })

# ---------------------------------------------------------------------------
# 5. Linear
# ---------------------------------------------------------------------------

message('[5/6] Linear...')
local({
    load(file.path(data.dir, 'linear.data.Rda'))

    linear.example <- SRCGrob(
        linear.test.data$tree,
        linear.test.data$node.text,
        main             = 'WHO003',
        node.text.cex    = 0.85,
        scale1           = 0.9,
        yaxis1.label     = 'PGA',
        yaxis2.label     = 'SNV',
        xaxis.label      = 'CP',
        main.cex         = 1.55,
        main.y           = 0.3,
        size.units       = 'inches',
        horizontal.padding = -1,
        add.normal       = TRUE
        )

    linear.30deg.example <- SRCGrob(
        linear.test.data$tree[, c('parent', 'length.1', 'length.2')],
        yaxis2.label      = '',
        plotting.direction = 30
        )

    update_rda(
        'linear.plots.Rda',
        linear.example       = linear.example,
        linear.30deg.example = linear.30deg.example
        )
    })

# ---------------------------------------------------------------------------
# 6. Complex (spread)
# ---------------------------------------------------------------------------

message('[6/6] Complex spread...')
local({
    load(file.path(data.dir, 'complex.data.Rda'))

    spread.example <- SRCGrob(spread.test.data$tree)

    spread.30deg.example <- SRCGrob(
        spread.test.data$tree,
        plotting.direction = 30
        )

    update_rda(
        'complex.plots.Rda',
        spread.example       = spread.example,
        spread.30deg.example = spread.30deg.example
        )
    })

message('\nAll snapshots updated successfully.')
