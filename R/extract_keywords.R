#' Extract keywords from EML records
#'
#' @param paths (character) Paths to one or more EML records to read from
#' @param datetime (optional) Optional. Specify a query time to save with the
#'     resulting CSV
#'
#' @return (data.frame) A data.frame of keywords, one row per keyword
#'
#' @importFrom magrittr "%>%"
#' @export
extract_keywords <- function(paths, datetime = Sys.time()) {
  result <- lapply(paths, function(path) {
    doc <- xml2::read_xml(path)

    identifier <- rawToChar(
      openssl::base64_decode(
        strsplit(basename(path), ".xml")[[1]][1]))

    message(paste0("Extracting keywords from ", identifier))

    keywords <- lapply(xml2::xml_find_all(doc, "//keywordSet//keyword") %>% xml2::xml_text(), function(keyword) {
      data.frame(identifier = identifier,
                 keyword = keyword,
                 viewURL = paste0("https://search.dataone.org/view/", identifier))
    })

    do.call(rbind, keywords)
  })

  all <- do.call(rbind, result)

  all$query_datetime_utc <- datetime # Append query time in utc

  all
}

