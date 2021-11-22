#Load required libraries
library(ncdf4)
library(raster)
library(sp)
library(RNetCDF)
library(ggplot2)

# Load February 1979 file (to merge the daily files into monthly files we used the cdo mergetime input.nc output.nc code)
Feb79 <- nc_open("../data/Monthly-Files/Feb79.nc")

# Get the dimensions of Feb79 data
long_Feb <- ncvar_get(Jan79, "lon")
lat_feb <- ncvar_get(Jan79, "lat", verbose = F)
t_feb <- ncvar_get(Jan79, "time")

# store the data in a 3-dimensional array of the variable 'sm' which in this case is the one we target to work with
Feb.array <- ncvar_get(Feb79, "sm")
#view the dimension of the array
dim(Feb.array)

# see what fill value was used for missing data
fillvalue <- ncatt_get(Feb79, "sm", "_FillValue")
fillvalue

# close the netCDF file
nc_close(Feb79)



#Replace all those fill values with the R-standard ‘NA’.
Feb.array[Feb.array == fillvalue$value] <- NA

# Slice the first day of February
Feb01 <- Feb.array[, , 1]
#View the dimensions
dim(Feb01)


#Now we can create a Raster Layer for February 01
Feb01Ras <- raster(t(Feb01), xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                   crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
#View the dimensions of the raster
dim(Feb01Ras)

#To orient the data properly we need to flip it
Feb01Ras <- flip(t(Feb01Ras), direction='y')


# Now we can plot the raster for Februry 01
plot(jan01Ras)

# save the raster as a GeoTIFF
writeRaster(Feb01Ras, 'Februry_o1.tif', 'GTiff', overwrite=TRUE)


# We can try to extract data for a specific location say Kenya for example (0.0236, 37.9062)
#To do this we will need to convert the entire 3d array of data to a raster brick(this may take some time)
Feb01_brick <- brick(Feb.array, xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                     crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# View the dimension of the brick (since it is well oriented we don't need to flip or transpose)
dim(Feb01_brick)

#Extract timeseries of data in Kenya (the study location) from the raster brick using the ‘extract()’ function.

Kenya_long <- 0.0236
Kenya_lat <-  37.962
Kenya_series <- extract(Feb01_brick, SpatialPoints(cbind(Kenya_long,Kenya_lat)), method='simple')

# Put the data into a dataframe and plot a graph (this did not plot a graph due o missing values)
Kenya_df <- data.frame(day= seq(from=01, to=28, by=1), sm=t(Kenya_series))
ggplot(data=Kenya_df, aes(x=day, y=sm, group=1)) +
  geom_line() + # make this a line plot
  ggtitle("Soil Moisture Data for Kenya") +     # Set title
  theme_bw() # use the black and white theme






