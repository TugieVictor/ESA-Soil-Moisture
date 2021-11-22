library(raster)
library(ncdf4)
library(ggplot2)

# get data into path
jan79 <- "../data/Monthly-Files/Jan79.nc"

# Create a raster brick for variable sm
j79.brick <- brick(jan79, var = 'sm')

# Viw the dimensions
dim(j79.brick)

# Create a df for all layers in the brick
j79.df <- as.data.frame(j79.brick[[1:31]], xy=T)

# View the first 5 rows of the df
head(j79.df)

# Get max value
max(j79.df$X1979.01.01, na.rm = T)

# Get minimum value
min(j79.df$X1979.01.01, na.rm = T)

# Get mean value
mean(j79.df$X1979.01.01, na.rm = T)

# Save data as csv
write.csv(j79.df, "csv/sm_j79.csv")







Jan79 <- nc_open("../data/Monthly-Files/Jan79.nc")

Jan79

# Get the dimensions of Jan79 data
long <- ncvar_get(Jan79, "lon")
lat <- ncvar_get(Jan79, "lat", verbose = F)
t <- ncvar_get(Jan79, "time")


# store the data in a 3-dimensional array
jan.array <- ncvar_get(Jan79, "sm")
#view the dimension of the array
dim(jan.array)

# see what fill value was used for missing data
fillvalue <- ncatt_get(Jan79, "sm", "_FillValue")
fillvalue

# close the netCDF file
nc_close(Jan79)




jan01_brick <- brick(jan.array, xmn=min(long), xmx=max(long), ymn=min(lat), ymx=max(lat),
                     crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
# View the dimension of the brick (since it is well oriented we don't need to flip or transpose)
dim(jan01_brick)


jan_01Df <- as.data.frame(jan01_brick[[31]], xy= T)


head(jan_01Df)


write.csv(jan_01Df, file.choose())


plot(jan_01Df)

