# Toronto Traffic Signals Heat Map
# Myles Harrison
# http://www.everydayanalytics.ca
# Data from Toronto Open Data Portal:
# http://www.toronto.ca/open

library(MASS)
library(RgoogleMaps)
library(RColorBrewer)
source('colorRampPaletteAlpha.R')

# Read in the data
data <- read.csv(file="traffic_signals.csv", skip=1, header=T, stringsAsFactors=F)
# Keep the lon and lat data
rawdata <- data.frame(as.numeric(data$Longitude), as.numeric(data$Latitude))
names(rawdata) <- c("lon", "lat")
data <- as.matrix(rawdata)

# Rotate the lat-lon coordinates using a rotation matrix
# Trial and error lead to pi/15.0 = 12 degrees
theta = pi/15.0
m = matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), nrow=2)
data <- as.matrix(data) %*% m

# Reproduce William's original map
par(bg='black')
plot(data, cex=0.1, col="white", pch=16)

# Create heatmap with kde2d and overplot
k <- kde2d(data[,1], data[,2], n=500)
# Intensity from green to red
cols <- rev(colorRampPalette(brewer.pal(8, 'RdYlGn'))(100))
par(bg='white')
image(k, col=cols, xaxt='n', yaxt='n')
points(data, cex=0.1, pch=16)

# Mapping via RgoogleMaps
# Find map center and get map
center <- rev(sapply(rawdata, mean))
map <- GetMap(center=center, zoom=11)
# Translate original data
coords <- LatLon2XY.centered(map, rawdata$lat, rawdata$lon, 11)
coords <- data.frame(coords)

# Rerun heatmap
k2 <- kde2d(coords$newX, coords$newY, n=500)

# Create exponential transparency vector and add
alpha <- seq.int(0.5, 0.95, length.out=100)
alpha <- exp(alpha^6-1)
cols2 <- addalpha(cols, alpha)

# Plot
PlotOnStaticMap(map)
image(k2, col=cols2, add=T)
points(coords$newX, coords$newY, pch=16, cex=0.3)
