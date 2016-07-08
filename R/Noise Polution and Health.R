# Load Libraries
library(downloader)
library(data.table)
library(stringr)
library(ggmap)

# Baltimore City, MD
url <- "https://data.baltimorecity.gov/api/views/xviu-ezkt/rows.csv?accessType=DOWNLOAD"
dfn <- "bcmd.csv"
csv <- download(url, dfn)
bcd <- fread(dfn)

# New York, NY
url <- "https://data.cityofnewyork.us/api/views/erm2-nwe9/rows.csv?accessType=DOWNLOAD"
dfn <- "nyny.csv"
csv <- download(url, dfn)
nyd <- fread(dfn)

# San Fransisco, CA
url <- "https://data.sfgov.org/api/views/vw6y-z8j6/rows.csv?accessType=DOWNLOAD"
dfn <- "sfca.csv"
csv <- download(url, dfn)
sfd <- fread(dfn)

# Clear Memory
rm(url, dfn, csv)

# Clean Baltimore Data
bcnp <- subset(bcd, grepl("2015", callDateTime) & grepl("noise", description, ignore.case = TRUE) & location!="(,)" & location!="(0,0)", select = c("callDateTime", "location"))
bcnp$callDateTime <- lapply(bcnp$callDateTime, function(x) str_split_fixed(x, " ", 2)[1])
bcnp$location <- str_replace_all(bcnp$location, "[()º ]", "")
bcnp$latitude <- lapply(bcnp$location, function(x) str_split_fixed(x, ",", 2)[1])
bcnp$longitude <- lapply(bcnp$location, function(x) str_split_fixed(x, ",", 2)[2])
bcnp$zip <- mapply(function(x, y) revgeocode(as.numeric(c(x, y)), output = "more")$postal_code, bcnp$longitude, bcnp$latitude)
colnames(bcnp) <- c("date", "location", "latitude", "longitude", "zip")
save(bcnp, file = "bcnp.rda")

# Clean New York Data
nynp <- subset(nyd, grepl("2015", `Created Date`) & grepl("noise", `Complaint Type`, ignore.case = TRUE) & Location!="" & `Incident Zip`!="", select = c("Created Date", "Location", "Latitude", "Longitude", "Incident Zip"))
nynp$`Created Date` <- lapply(nynp$`Created Date`, function(x) str_split_fixed(x, " ", 2)[1])
nynp$Location <- str_replace_all(nynp$Location, "[()º ]", "")
colnames(nynp) <- c("date", "location", "latitude", "longitude", "zip")
save(nynp, file = "nynp.rda")

# Clean San Fransisco Data
sfnp <- subset(sfd, grepl("2015", Opened) & Category=="Noise Report" & Address!="Not associated with a specific address", select = c("Opened", "Point"))
sfnp$Opened <- lapply(sfnp$Opened, function(x) str_split_fixed(x, " ", 2)[1])
sfnp$Point <- str_replace_all(sfnp$Point, "[()º ]", "")
sfnp$latitude <- lapply(sfnp$Point, function(x) str_split_fixed(x, ",", 2)[1])
sfnp$longitude <- lapply(sfnp$Point, function(x) str_split_fixed(x, ",", 2)[2])
sfnp$zip <- mapply(function(x, y) revgeocode(as.numeric(c(x, y)), output = "more")$postal_code, sfnp$longitude, sfnp$latitude)
colnames(sfnp) <- c("date", "location", "latitude", "longitude", "zip")
save(sfnp, file = "sfnp.rda")
