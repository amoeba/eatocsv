#' Get Entity-Attribute Metadata for one or more Objects
#'
#' @param node (MNode|CNode) The Node where the Object(s) can be found
#' @param identifiers The Object's identifier (PID)
#'
#' @return (data.frame) A table of entity attribute metadata
#' @export
#'
#' @examples
get_object_ea <- function(node, identifiers) {
  # For each Object
  #   Get a copy of the Object(s)
  #   Read it in and extract EA
  #   Return the attributes
  # Collate them all and return that
}