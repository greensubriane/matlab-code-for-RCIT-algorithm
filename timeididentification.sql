select times.id as timeid, celldatabase.moment as times, celltracking_070526_1.center_x as centroid_x, 
celltracking_070526_1.center_y as centroid_y from times, celldatabase, celltracking_070526_1 where 
times.times = celldatabase.moment and celldatabase.gravitycenter_x = celltracking_070526_1.center_x and 
celldatabase.gravitycenter_y = celltracking_070526_1.center_y