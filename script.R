library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(RNetCDF)

setwd("/home/victor/Documents/Victor/Tugie/R/ICRAF/SoilMoisture/")

# read the file
moisture_data <- nc_open("./data/1979/ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-19790101000000-fv04.4.nc")


# print and save text file for the metadata
{
  sink('ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-19790101000000-fv04.4.txt')
  print(moisture_data)
  sink()
}


# Get the attributes (how to know the names of the variables in the file)
attributes(moisture_data$var)
#or use this other method
names(moisture_data$var)

# Get the 'sm' variable (read into a specific attribute)
sm <- ncvar_get(moisture_data, attributes(moisture_data$var)$names[2])



# Get the dimensions
lon_1 <- ncvar_get(moisture_data, "lon")
lat_1 <- ncvar_get(moisture_data, "lat", verbose = F)
t_1 <- ncvar_get(moisture_data, "time")

# look at the first few entries in the longitude vector
head(long-1)

# store the data in a 3-dimensional array
sm.array <- ncvar_get(moisture_data, "sm")
dim(sm.array)


# see what fill value was used for missing data
fillvalue <- ncatt_get(moisture_data, "sm", "_FillValue")
fillvalue



# close the netCDF file
nc_close(moisture_data)



# Save data in a raster (provide coordinate reference system 'CRS')
ras <- raster(t(sm.array), xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
              crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84+0,0,0"))


# transpose and flip to orient the data correctly
ras <- flip(ras, direction='y')


# plot the raster to visualize the data
plot(ras)


# save the raster as a GeoTIFF
writeRaster(ras, 'ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-19790101000000-fv04.4.tif', 'GTiff', overwrite=TRUE)



