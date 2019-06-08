#' @importFrom blackmagic xml_to_json
#' @importFrom jsonlite fromJSON
#' @importFrom magrittr %>%
#' @importFrom XML xmlParse
#'
#' @export
read_ora_xml <- function(.path_to_xml, ...) {
  raw_list <- XML::xmlParse(file = .path_to_xml) %>%
    #XML::xmlToList()
    blackmagic::xml_to_json(., spaces = 2, compact = TRUE, ignoreDeclaration = TRUE) %>%
    jsonlite::fromJSON()

  # Get edge list
  edges <- raw_list$DynamicMetaNetwork$MetaNetwork$networks$network$link$`_attributes`

  # Get network metadata
  metadata <- raw_list$DynamicMetaNetwork$MetaNetwork$networks$network$`_attributes$metadata`

  # Get node list
  nodes <- raw_list$DynamicMetaNetwork$MetaNetwork$nodes$nodeclass$node$`_attributes`

  out <- list(metadata = metadata, edges = edges, nodes = nodes)
  out
}
