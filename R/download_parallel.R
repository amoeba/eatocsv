#' Santize filenames into valid filesystem paths
#'
#' This is a custom routine that's probably overly aggressive
#'
#' @param filenames (character) One or more filenames to sanitized
#'
#' @return (character) The sanitized filenames
#' @export
sanitize_filename <- function(filenames) {
  stringr::str_replace_all(filenames, "[^A-Za-z0-9]", "_")
}

#' Download objects from an MN, optionally in parallel
#'
#' This function uses the \code{future} package and therefore allows
#' downloads to happen in sequential order or parallel.
#'
#' @param node (CNode|MNode) The Node to download from
#' @param pids (character) One ore more PIDs to download from the \code{node}
#' @param path (character) The destination directory for downloadd Objects
#' @param ext (character) Optional. Specify a custom file extension to add to each downloaded file
#' @param overwrite (boolean) Whether to overwrite existing files (TRUE) or not (FALSE)
#'
#' @return (list) A list of file paths for the downloaded files
#' @export
download_objects <- function(node,
                             pids,
                             path = getwd(),
                             ext = ".xml",
                             overwrite = FALSE) {
  # Generate a set of sane filenames for each PID to use
  filenames <- sanitize_filename(pids)

  # A list stores our futures, which are resolved after being defined
  result <- list()

  # Create a future for each download job
  for (i in seq_along(pids)) {
    pid <- pids[i]
    outpath <- paste0(filenames[i], ext)

    result[[pid]] <- future::future({
      # Warn the user and don't overwrite existing files
      if (!overwrite && file.exists(file.path(path, outpath))) {
        warning(paste0("File with the filename ",
                       outpath,
                       " already exists so it was not overwritten."))
      } else {
        tryCatch({
          writeBin(dataone::getObject(node, pid), file.path(path, outpath))
        },
        error = function(e) {
          outpath <- e
        })
      }

      outpath
    })
  }

  # This function iterates over all the futures and tries to resolve them
  watch <- function(result) {
    for (i in seq_along(result)) {
      f <- result[[i]]

      if (!inherits(f, "Future")) next
      if (!future::resolved(f)) next

      result[[i]] <- tryCatch({
        future::value(result[[i]])
      },
      error = function(e) {
        e
      })
    }

    result
  }

  # Try to resolve every future and finish when all are resolved
  repeat {
    result <- watch(result)
    if (!any(vapply(result, FUN = inherits, "Future", TRUE))) break
  }

  result
}
