library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(dplyr)

# Set your working directory
setwd("/home/victor/Documents/Victor/Tugie/R/ICRAF/SoilMoisture/")

# load the .nc file into r
moisture_data <- nc_open("../data/1979/ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-19790101000000-fv04.4.nc")


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


# Get the dimensions
long_1 <- ncvar_get(moisture_data, "lon")
lat_1 <- ncvar_get(moisture_data, "lat", verbose = F)
t_1 <- ncvar_get(moisture_data, "time")

# look at the first few entries in the longitude vector
head(long_1)

# store the data in a 3-dimensional array
sm.array <- ncvar_get(moisture_data, "sm")
dim(sm.array)


# see what fill value was used for missing data
fillvalue <- ncatt_get(moisture_data, "sm", "_FillValue")
fillvalue



# close the netCDF file
nc_close(moisture_data)



# Save data in a raster (provide coordinate reference system 'CRS')
ras <- raster(t(sm.array), xmn=min(long_1), xmx=max(long_1), ymn=min(lat_1), ymx=max(lat_1),
              crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84+0,0,0"))


#flip to orient the data correctly
ras <- flip(ras, direction='y')


# plot the raster to visualize the data
plot(ras)


# save the raster as a GeoTIFF
writeRaster(ras, 'ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-19790101000000-fv04.4.tif', 'GTiff', overwrite=TRUE)




#pick a longitude and a latitude for plotting graph
(long_1[10])

(lat_1[10])

# Asign day
Day <- as.Date(t_1, origin="1979-01-01")


data_frame(month=Day,
           temp=sm.array[10,10,],
           col=ifelse(temp<0, "#b2182b", "#2166ac")) %>%
  ggplot(aes(month, temp)) +
  geom_point(aes(color=col), size=0.15) +
  scale_color_identity() +
  theme_bw()




# We can try to extract data for a specific location say Kenya for example (0.0236, 37.9062)
#To do this we will need to convert the entire 3d array of data to a raster brick(this may take some time)
jan01_brick <- brick(sm.array, xmn=min(long_1), xmx=max(long_1), ymn=min(lat_1), ymx=max(lat_1),
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



# Refference (https://rpubs.com/boyerag/297592)
