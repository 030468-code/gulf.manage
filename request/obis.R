library(gulf.data)
library(gulf.spatial)
library(worrms)

# Control variables:
years <- 2010:2020
variable <- "number.caught"

# Load tow data:
x <- read.scsset(years, valid = 1, survey = "regular")
x$longitude <- longitude(x)
x$latitude  <- latitude(x)

# Load by-catch data from the snow crab survey:
y <- read.scscat(years, survey = "regular")
y$tow.id <- tow.id(y)

# Add snow crab counts:
z <- read.scsbio(years)
z$tow.id <- tow.id(z)
z <- catch(z)  
z$species <- 2526
z$number.caught <- z$total
z[setdiff(names(y), names(z))] <- NA
z <- z[names(y)]
y <- rbind(y, z)

# Add WoRMS codes:
y$aphiaID <- species(y$species, output = "worms")

# Compile classification information from WoRMS database:
u <- sort(unique(y$aphiaID))
classification <- function(x) return(as.data.frame(as.list(wm_classification(id = x))))
tmp <- lapply(u, classification) # Takes a while
names(tmp) <- u
u <- tmp
tab <- data.frame(aphiaID = as.numeric(names(u)))
tab[unique(unlist(lapply(u, function(x) return(x$rank))))] <- ""
for (i in 1:length(u)) tab[i, u[[i]]$rank] <- u[[i]]$scientificname
names(tab) <- tolower(names(tab))

# Re-format for OBIS:
tab$aphiaID <- tab$aphiaid
tab$scientificNameID <- paste0("urn:lsid:marinespecies.org:taxname:", tab$aphiaid)
tab$scientificName   <- tab$species 
for (i in 1:nrow(tab)){
   tab$specificEpithet[i] <- gsub(tab$genus[i], "", tab$species[i])
   tab$specificEpithet[i] <- gsub("[()]", "", tab$specificEpithet[i])
}
tab$specificEpithet <- deblank(tab$specificEpithet)

# Import WoRMS information into catch table:
vars <- c("aphiaID", "scientificNameID", "scientificName", "specificEpithet", "kingdom", "phylum", "class", "order", "family", "genus", "subgenus")                
vars <- vars[vars %in% names(tab)]
ix <- match(y$aphiaID, tab$aphiaID)
y[vars] <- tab[ix, vars]
y <- y[!is.na(y$aphiaID), ]

# Import tow data info into catch table:
ix <- match(y[key(x)], x[key(x)])
y[c("longitude", "latitude", "swept.area", "depth")] <- x[ix, c("longitude", "latitude", "swept.area", "depth")]
y$start.time <- substr(time(x, "start"), 12, 19)[ix]  

# Sort data table:
y <- sort(y, by = c("date", "start.time", "tow.id", "aphiaID"))

# Build OBIS fields:
y$language             <- "En"
# y$license              <- "http://data.gc.ca/eng/open-government-licence-canada & http://www.canadensys.net/norms"
# y$rightsHolder         <- "Her Majesty the Queen in right of Canada, as represented by the Minister of Fisheries and Oceans"
y$institutionID        <- "https://edmo.seadatanet.org/report/5370"
y$datasetID            <- "DFO_Gulf_SnowCrabSurveys" 
y$institutionCode      <- "GFC"
y$collectionCode       <- "SnowCrabSurveys"
y$datasetName          <- "Southern Gulf of St. Lawrence Snow crab research trawl survey data (DFO Gulf region, Canada)"
y$basisOfRecord        <- "HumanObservation"
y$dynamicProperties    <- paste0("Sample size = ", round(y$swept.area), " meters square; Classification = WoRMS")
y$individualCount      <- y$number.caught
y$minimumDepthInMeters <- round(1.8288 * y$depth)
y$maximumDepthInMeters <- y$minimumDepthInMeters
y$decimalLatitude      <- y$latitude
y$decimalLongitude     <- y$longitude
y$occurrenceStatus     <- "Present"
y$catalogNumber        <- paste0(y$date, "_", y$tow.id, "_", y$aphiaID)   
y$occurrenceID         <- paste0(y$institutionCode, "_", y$collectionCode, "_", y$catalogNumber)
y$eventDate            <- as.character(y$date) 
y$eventTime            <- paste0(y$start.time, "AST")

# Remove or identify variables for export:
remove <- c("date", "tow.number", "tow.id", "datasetName", "aphiaID", "longitude", "latitude", "swept.area", "start.time", "language", "depth", "species", "number.caught", "weight.caught", "presence", "comment")
y <- y[, setdiff(names(y), remove)]

# Remove fields with zero or missing 'individualCount'
y <- y[!is.na(y$individualCount), ]

excel(y)
