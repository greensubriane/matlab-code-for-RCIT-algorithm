select track1.cellid as id, track2.cellid as precursorid from celltracking_070526_19dbz as track1, celltracking_070526_19dbz as track2 
where (track1.cellid = track2.successorid) order by id ASC