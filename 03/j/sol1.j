NB. Assume the forest is provided as a 2D array in var `forest`
height =: 0 { $ forest
width =: 1 { $ forest

NB. Builds a mask of sled arrival positions
mask =. 3 : 0
slope =: y

right =: 0 { slope
down =: 1 { slope

NB. Calculate interval that sled arrives at in forest shaped array
NB. Account for offsets, where a line is skipped
interval =: +/ slope * (1, width)
indices =: i. $ forest
offsets =: width * (((interval * i. height) % down) - (width * i. height)) <.@% width

NB. All indices that are an integral multiple of the interval
result =: 0= interval | offsets + indices

NB. Set the 0,0 position to 0, just to be safe
result =: result * -. 0= i. $ result
)

NB. Given a slope, count forest's trees that intersect with slope's mask
count_trees =. 3 : 0
+/, forest * mask y
)

NB. Count trees for slope 3 1 of problem 1
count_trees 3 1
