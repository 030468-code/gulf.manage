library(gulf.utils)

# Load raw data:
x <- readLines(locate(file = "species.list.update.2020"), encoding = "latin1")
x <- strsplit(x, ",")

v <- data.frame(code = unlist(lapply(x, function(x) x[2])),
                english = unlist(lapply(x, function(x) x[1])),
                latin = unlist(lapply(x, function(x) x[3])),
                french = unlist(lapply(x, function(x) x[4])),
                stringsAsFactors = FALSE)
v <- v[-1, ]
v$code <- as.numeric(v$code)

v$french = gsub("Š", "è", v$french)
v$french = gsub("‚", "é", v$french) 
v$french = gsub("ˆ", "ê", v$french) 
v$french = gsub("…", "à", v$french) 
v$french = gsub("<90>", "É", v$french)  
v$french = gsub("Œ", "î", v$french)   

v$english <- tolower(v$english)

index <- grep("(atlantic)", v$english)
v$english[index] <- gsub("[(]atlantic[)]", "", v$english[index])
v$english[index] <- paste("Atlantic", v$english[index])
v$english <- gsub("Atlantic atlantic", "Atlantic", v$english)  
v$english <- gsub("greenland", "Greenland", v$english) 
v$english <- gsub(";", ", ", v$english) 
v$english <- gsub("turbot, Greenland halibut", "Greenland halibut(turbot)", v$english)
v$english <- gsub("[(]ns[)]", "unsp.", v$english)
v$english <- gsub("unident[.]", "unsp.", v$english)
v$english <- gsub("unid[.]", "unsp.", v$english)
v$english <- gsub("s[.]f[.]", "f.", v$english)
v$english <- gsub("s[.]o[.]", "o.", v$english)
v$english <- gsub("unidentified", "unsp.", v$english)
v$english <- gsub("Atlantic striped atlantic wolffish", "Atlantic striped wolffish", v$english)
v$english <- gsub("unseparated", "unsp.", v$english)
v$english <- gsub("brill[/]windowpane", "windowpane", v$english)
v$english <- gsub("hyas coarctatus", "Lesser toad crab", v$english)
v$english <- gsub("snow crab [(]queen[)]", "snow crab", v$english)
v$english <- gsub("4-line snake blenny", "fourline snakeblenny", v$english)
v$english <- gsub("Paguroidea f.", "Hermit crabs", v$english)  
v$english <- gsub("Sea cucumber (unsp.)", "Sea cucumbers", v$english)  
v$english <- gsub("Bivalvia c.", "Bivalves", v$english)  
v$english <- gsub("Ocean pout(common)", "Ocean pout", v$english)  
v$english <- gsub("Asteroidea s.c.", "Starfish", v$english) 
v$english <- gsub("Mollusca p.", "Molluscs", v$english) 

v$english[v$code == 62] <- "Gaspereau"
v$english[v$code == 2527] <- "Greater toad crab"

# Clean-up spacing:
v$english <- gsub(" +", " ", v$english)
v$french <- gsub(" +", " ", v$french)
v$latin <- gsub(" +", " ", v$latin)

# Capitalization:
v$english <- paste0(toupper(substr(v$english,1,1)), substr(v$english,2,nchar(v$english)))
v$latin   <- paste0(toupper(substr(v$latin,1,1)), tolower(substr(v$latin,2,nchar(v$latin))))

# Correct blanks:
v$english <- deblank(v$english)
v$french <- deblank(v$french)
v$latin <- deblank(v$latin)

# Load WoRMS AphiaID codes:
load(locate(file = "species.names"))
x <- species.names
v$aphia.id <- x$aphia.code[match(v$code, x$code)]

# Compile classification information from WoRMS database (takes a long time):
library(worrms)
u <- sort(unique(v$aphia.id))
classification <- function(x) return(as.data.frame(as.list(wm_classification(id = x))))
tmp <- lapply(u, classification) # Takes a while
names(tmp) <- u
u <- tmp
tab <- data.frame(aphia.id = as.numeric(names(u)))
tab[unique(unlist(lapply(u, function(x) return(x$rank))))] <- ""
for (i in 1:length(u)){
   u[[i]] <- u[[i]][!duplicated(u[[i]]$rank), ]
   tab[i, u[[i]]$rank] <- u[[i]]$scientificname
} 
names(tab) <- tolower(names(tab))

# Add taxonomic information:
ix <- match(v$aphia.id, tab$aphia.id)
vars <- setdiff(names(tab), "aphia.id")
v[vars] <- tab[ix, vars]
z <- v[vars]
z[is.na(z)] <- ""
v[vars] <- z

# Fix name fields:
names(v) <- gsub("[.]+", ".", names(v))
names(v) <- gsub("[.]$", "", names(v))

# Combine redundant field names:
ix <- which(v$"phylum (division)" != "")
v$phylum[ix] <- v$"phylum (division)"[ix]
ix <- which(v$"subphylum (subdivision)" != "")
v$subphylum[ix] <- v$"subphylum (subdivision)"[ix]
v <- v[, -grep("division", names(v))]

# Re-order table fields:
vars <- c("code", "english", "latin", "french", "aphia.id", 
          "kingdom", "subkingdom", "infrakingdom", "phylum", "subphylum", "infraphylum", 
          "superclass", "class", "subclass", "infraclass", "subterclass", "superorder", "order", "suborder", "infraorder", "parvorder", 
          "superfamily", "family", "subfamily", "tribe", "subtribe",  
          "section", "subsection",  "genus", "subgenus", "species", "subspecies")

ix <- match(names(v), vars)
v <- v[,c(vars[ix], setdiff(names(v), vars[ix]))]

# Write:
path <- gsub("gulf.manage", "gulf.data", getwd())
path <- paste0(path, "/inst/extdata")
if (file.exists(path)){
   file <- paste0(path, "/", "species", ".tab") 
   write.table(v, file = file, row.names = FALSE, sep = "\t", fileEncoding = "utf-8")
}
