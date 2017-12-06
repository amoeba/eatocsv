# eatocsv

Download and extract Entity-Attribute metadata into a CSV

This package is a micro-package that can be used to download (optionally in parallel) Objects from a DataONE CN or MN, extract Entity-Attribute metadata and export it into a CSV with the structure:

| pid | entity | attributeName | attributeLabel | attributeDefinition | unit | query_time |
| -- | -- | -- | -- | -- | -- | -- |
| X | MyEntity | SomeAttribute | SomeLabel | SomeDef | SomeUnit | 20171028T00:00:00Z |

It's designed to be used for work on [arctic-semantics](https://github.com/DataONEorg/arctic-semantics) and requires some knowledge of what's going on there and how the [dataone](https://github.com/DataONEorg/rdataone) package works.

## Installation

```{r}
remotes::install_github("amoeba/eatocsv")
```

Note: You will need to install the `remotes` package first in order to run the above line of code.

## Usage

Here's an example of how to use the package to extract Entity-Attribute metadata into a CSV from EML records on the  [Arctic Data Center](https://arcticdata.io).

```r
library(eatocsv)
library(dataone)
library(readr)
library(future)
library(xml2)

#' Step 1:
#' Query for records to download
CN <- CNode("PROD")
arcticdata.io <- dataone::MNode("https://arcticdata.io/metacat/d1/mn/v2")

query_url <- paste0(arcticdata.io@baseURL,
                    "/v2/query/solr/",
                    "?fl=identifier",
                    '&q=formatType:METADATA+AND+datasource:"urn:node:ARCTIC"+AND+-obsoletedBy:*+AND+attribute:*',
                    "&rows=1000",
                    "&start=0",
                    "&wt=csv")

query_datetime <- Sys.time() # Save querytime for later
documents <- readr::read_csv(query_url)

#' Step 2:
#' Download in parallel using the future package
future::plan("multiprocess")
download_objects(CN, documents$identifier)

#' Step 3:
#' Parse and extract entities and their attributes
document_paths <- list.files(getwd(), full.names = TRUE, pattern = "*.xml")
attributes <- extract_ea(document_paths)
write_csv(attributes, 
file.path(getwd(), 
          paste0(format(query_datetime, "%Y%m%d%H%M%S"), "_attributes.csv")))
```
