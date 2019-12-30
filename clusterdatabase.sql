select cell_070526.cellid, cell_070526.time, clusterdatabase.center_x, clusterdatabase.center_y, cell_070526.center_x, cell_070526.center_y 
from cell_070526, clusterdatabase where(clusterdatabase.center_x = cell_070526.center_x and clusterdatabase.center_y = cell_070526.center_y)


select times_19dbz.id, times_1.times from times_19dbz, times_1 where times_1.id = times_19dbz.timeid
