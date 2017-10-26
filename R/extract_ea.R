#' Extract Entity-Attribute information from a set of EML records
#'
#' @param paths (character) Paths to one or more EML records to read from
#' @param datetime (optional) Optional. Specify a query time to save with the
#'     resulting CSV
#'
#' @return (data.frame) A data.frame of Entity-Attribute information
#'
#' @importFrom magrittr "%>%"
#' @export
ea_to_csv <- function (paths,
                       datetime = Sys.time()) {
  result <- lapply(paths, function(doc) {
    pkg_id <- xml2::xml_find_first(doc, "/eml:eml/@packageId") %>%
      xml2::xml_text()
    cat(paste0("Extracting attributes from ", pkg_id, ".\n"))

    entities <- lapply(
      xml2::xml_find_all(doc, "//otherEntity | //dataTable"),
      function(entity) {
        entity_names <- xml2::xml_find_first(entity, ".//entityName") %>%
          xml2::xml_text()
        attribute_names <- xml2::xml_find_all(entity, ".//attributeName") %>%
          xml2::xml_text()

        # Skip entities with no attributes
        if (length(attribute_names) == 0) {
          return(NA)
        }

        data.frame(packageId = pkg_id,
                   entityName = entity_names,
                   attributeName = attribute_names)
      })

    entities <- entities[which(!is.na(entities))]
    do.call(rbind, entities)
  })

  attributes <- do.call(rbind, result)
  attributes$query_datetime_utc <- datetime # Append query time in utc

  attributes
}


