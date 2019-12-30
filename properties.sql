select celltracking_080726.cellid, celldatabase.clusterid, celldatabase.area, celldatabase.moment, celldatabase.max_precipitation_5min,
celldatabase.mean_precipitation_5min, celldatabase.orientation, celldatabase.center_x, celldatabase.center_y, celldatabase.majoraxis,
celldatabase.minoraxis, celldatabase.perimeter, celldatabase.eccentricity, celldatabase.numberofcells, 
celldatabase.coverage, celldatabase.cumrainfall_catchment_5min from celltracking_080726, celldatabase where (celltracking_080726.cellid = celldatabase.clusterid)