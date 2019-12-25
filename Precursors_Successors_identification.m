%% This function is used to get id of precursor and successor from celldatabase,
%% then the result will be implemented into the function Pre_successor_identification.m.
%% Edited by Ting He on Apr-25-2016

function[precursorid, successorid] = Precursors_Successors_identification(date, ref_threshold)
conn = database('celldatabase','postgres','ikoiko','Vendor','PostGreSQL');
selection_precursor = strcat('select track1.cellid as id, track2.cellid as precursorid from celltracking_', ...
                             date, '_', ref_threshold, ' as track1, celltracking_', ...
                             date, '_', ref_threshold, ' as track2 where (track1.cellid = track2.successorid) order by id ASC');
curs_precursor = exec(conn, selection_precursor);
curs_precursor = fetch(curs_precursor); 
precursorid = cell2mat(curs_precursor.Data);

selection_successor = strcat('select cellid, successorid from celltracking_', date, '_', ref_threshold);
curs_successor= exec(conn, selection_successor);
curs_successor = fetch(curs_successor); 
successorid = cell2mat(curs_successor.Data);