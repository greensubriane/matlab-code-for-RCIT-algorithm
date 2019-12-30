select cell_080719_37dbz.cellid, cell_080719_37dbz.time, celltracking_080719_37dbz_1.center_x, celltracking_080719_37dbz_1.center_y 
from cell_080719_37dbz, celltracking_080719_37dbz_1 
where (celltracking_080719_37dbz_1.center_x  = cell_080719_37dbz.center_x and celltracking_080719_37dbz_1.center_y = cell_080719_37dbz.center_y) 
order by cell_080719_37dbz.cellid ASC