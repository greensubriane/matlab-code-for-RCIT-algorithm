select distinct(time_070526.clusterid), times.times, time_070526.center_x, time_070526.center_y 
from times, time_070526 where times.id = time_070526.timeid order by time_070526.clusterid ASC