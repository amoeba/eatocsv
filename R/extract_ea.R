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
extract_ea <- function(paths, datetime = Sys.time()) {
  result <- lapply(paths, function(path) {
    doc <- xml2::read_xml(path)

    identifier <- rawToChar(
      openssl::base64_decode(
        strsplit(basename(path), ".xml")[[1]][1]))

    message(paste0("Extracting attributes from ", identifier))

    entities <- lapply(xml2::xml_find_all(doc, "//otherEntity | //dataTable | //spatialVector | // spatialRaster | //storedProcedure | //view"), function(entity) {
      entity_name <- xml2::xml_find_first(entity, ".//entityName") %>%
        xml2::xml_text()

      attributes <- lapply(xml2::xml_find_all(entity, ".//attribute"), function(attribute) {

        attribute_name <- xml2::xml_find_first(attribute, "./attributeName") %>%
          xml2::xml_text()
        attribute_labels <- xml2::xml_find_all(attribute, "./attributeLabel") %>%
          xml2::xml_text() %>%
          paste(collapse = " ")
        attribute_def <- xml2::xml_find_first(attribute, "./attributeDefinition") %>%
          xml2::xml_text()
        attribute_unit <- xml2::xml_find_first(attribute, ".//unit/standardUnit | .//unit/customUnit") %>%
          xml2::xml_text()
        attribute_propertyURI <- xml2::xml_find_first(attribute, "./annotation/propertyURI") %>% # added by SC
          xml2::xml_text()
        attribute_valueURI <- xml2::xml_find_first(attribute, "./annotation/valueURI") %>% # added by SC
          xml2::xml_text()

        # Clean up xml_find results
        attribute_labels <- ifelse(nchar(attribute_labels) == 0, NA_character_, attribute_labels)
        attribute_unit <- ifelse(nchar(attribute_unit) == 0, NA, attribute_unit)

        # Return the result as a data.frame with all the info
        data.frame(identifier = identifier,
                   entityName = entity_name,
                   attributeName = attribute_name,
                   attributeLabel = attribute_labels,
                   attributeDefinition = attribute_def,
                   attributeUnit = attribute_unit,
                   propertyURI = attribute_propertyURI,
                   valueURI = attribute_valueURI,
                   viewURL = paste0("https://search.dataone.org/view/", identifier))
      })

      do.call(rbind, attributes)
    })

    # Clean up NULL/NA results
    entities <- entities[which(!vapply(entities, is.null, FALSE))]

    if (length(entities) == 0) {
      warning(paste0("No entities with attributes found for ", identifier, "."))
      return(data.frame())
    }

    do.call(rbind, entities)
  })

  attributes <- do.call(rbind, result)

  if (nrow(attributes) == 0) {
    stop(call. = FALSE, paste0("No entities with attributes were found in any of the ", length(paths), " document(s) parsed. This could be a bug in the function or it could be that none of the documents have entity-attribute metadata."))
  }
  attributes$query_datetime_utc <- datetime # Append query time in utc

  attributes
}


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
ea_to_csv <- function(paths,
                      datetime = Sys.time()) {
  .Deprecated("extract_ea")
}