save_figure <- function(
    filename,
    dir,
    plot,
    width,
    height) {
  dir <- RUtilpol::add_slash_to_path(dir)

  ggplot2::ggsave(
    filename = paste0(dir, filename, ".pdf"),
    plot = plot,
    width = width,
    height = height,
    device = cairo_pdf,
    units = "mm",
    dpi = 600,
    family = "arial",
    pointsize = 12,
    scale = 1,
    antialias = "subpixel",
    onefile = FALSE,
    bg = "transparent",
    limitsize = FALSE
  )

  ggplot2::ggsave(
    filename = paste0(dir, filename, ".png"),
    plot = plot,
    width = width,
    height = height,
    units = "mm",
    dpi = 600,
    pointsize = 12,
    scale = 1,
    bg = "transparent",
    limitsize = FALSE
  )
}