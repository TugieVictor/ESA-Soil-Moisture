#Set the working directory
setwd("/home/victor/Documents/Victor/Tugie/R/ICRAF/SoilMoisture/")

#Load required libraries
library(ncdf4)
library(raster)
library(sp)
library(RNetCDF)
library(ggplot2)

# load all 1979 files into the global environment
filenames= list.files('data/1979/',pattern = '*.nc',full.names = TRUE)

# Load January 1979 file (to merge the daily files into monthly files we used the cdo mergetime input.nc output.nc code)
Jan79 <- nc_open("data/1979/Jan79.nc")

# Print Jan79 to view the data
print(Jan79)

# Get the variables in the data
attributes(Jan79$var)

# Get the dimensions of Jan79 data
long <- ncvar_get(Jan79, "lon")
lat <- ncvar_get(Jan79, "lat", verbose = F)
t <- ncvar_get(Jan79, "time")

# look at the first few entries in the longitude vector
head(long)

# look at the first few entries in the latitude vector
head(lat)

# look at the first few entries in the time vector
head(t)

# store the data in a 3-dimensional array
jan.array <- ncvar_get(Jan79, "sm")
#view the dimension of the array
dim(jan.array)

# see what fill value was used for missing data
fillvalue <- ncatt_get(Jan79, "sm", "_FillValue")
fillvalue

# close the netCDF file
nc_close(Jan79)


#Replace all those fill values with the R-standard ‘NA’.
jan.array[jan.array == fillvalue$value] <- NA

# Slice the first day of January
jan01 <- jan.array[, , 1]
#View the dimensions
dim(jan01)

#Now we can create a RasterLayer for January 01
jan01Ras <- raster(t(jan01), xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                   crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
#View the dimensions of the raster
dim(jan01Ras)

#To orient the data properly we need to flip it
jan01Ras <- flip(jan01Ras, direction='y')

# Now we can plot the raster for January 01
plot(jan01Ras)

# save the raster as a GeoTIFF
writeRaster(jan01Ras, 'January_o1.tif', 'GTiff', overwrite=TRUE)



# We can try to extract data for a specific location say Kenya for example (0.0236, 37.9062)
#To do this we will need to convert the entire 3d array of data to a raster brick(this may take some time)
jan01_brick <- brick(jan.array, xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                 crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# View the dimension of the brick (since it is well oriented we don't need to flip or transpose)
dim(jan01_brick)

#Extract timeseries of data in Kenya (the study location) from the raster brick using the ‘extract()’ function.

Kenya_long <- 0.0236
Kenya_lat <-  37.962
Kenya_series <- extract(jan01_brick, SpatialPoints(cbind(Kenya_long,Kenya_lat)), method='simple')

# Put the data into a dataframe and plot a graph (this did not plot a graph due o missing values)
Kenya_df <- data.frame(day= seq(from=01, to=31, by=1), sm=t(Kenya_series))
ggplot(data=Kenya_df, aes(x=day, y=sm, group=1)) +
  geom_line() + # make this a line plot
  ggtitle("Soil Moisture Data for Kenya") +     # Set title
  theme_bw() # use the black and white theme


# get the difference between the month from 1st January and 31st January
# Slice data for jan 31st
jan31 <- jan.array[, , 31]

# Get the difference
jan_difference <- jan31 - jan01

# Save the difference as a raster
jan_diff_ras <- raster(t(jan_difference), xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                       crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

# Orient the data correctly
jan_diff_ras <- flip(t(jan_diff_ras), direction= 'y')

#plot the diff
plot(jan_diff_ras)

dim(jan_diff_ras)

