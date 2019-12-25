%% load workspace
load('Inputs.mat');

%% Light Rain cluster identification (threshold > 19dBZ)
[raincells_19dBZ, raincellsfeatures_19dBZ] = Raincluster_identification(288, files, 7, 19, 37, 5, 9, x_coordinates, y_coordinates);

%% Storing result raincellsfratures_19dBZ into a relational database(PostgreSQL version 9.3) (table name: celldatabase)

%% Example for tracking procedure for light rain cluster (threshold > 19dBZ)
[global_vector, mean_x_vector, mean_y_vector] = Global_vector_generation(288, files);

[clusterboundingboxwithsearchbox_19dbz, clusterboundingboxes_19dbz, ...
 clustercentroids_19dbz, clustercoords_19dbz, clusterareas_19dbz, clustercenterofmass_19dbz] = Pre_process_tracking_procedure(288, files, 5, 9, 7, 19, ...
 x_coordinates, y_coordinates);

[all_potential_centroids_19dbz, all_potential_coords_19dbz, all_potential_areas_19dbz] = Get_child_rain_cluster(288, ...
 clusterboundingboxes_19dbz, clusterboundingboxwithsearchbox_19dbz, clustercenterofmass_19dbz, clustercoords_19dbz, clusterareas_19dbz);

[overlaps_19dbz, themostlikelysuccessors_19dbz, ...
 distances_19dbz, directions_19dbz, clusterdatabase_19dbz] = Most_matched_rain_cluster_identification(288, clustercenterofmass_19dbz, ...
 clustercoords_19dbz, clusterareas_19dbz, all_potential_centroids_19dbz, ...
 all_potential_coords_19dbz, all_potential_areas_19dbz, global_vector, 3, 40, 20);
%% storing the first four clomus of clusterdatabase_19dbz into database table celltracking_....._1

resultss_19dbz = Post_process_most_matched_child_rain_cluster(clusterdatabase_19dbz, cellid, 30, 0.2);

%% storing resultss_19dbz into relational database and retriving the id of rain cluster including parent/child rain cluster (table name: celltracking_...).
%% in this demo, the id of parent/child rain clusters has been presented in the worksapce with name of precursor/successor
%% cellid is the first column of matrix raincellsfeatures_19dBZ
precursors_19dbz = Unique_raincluster_identification(precursor, cellid);
successors_19dbz = Unique_raincluster_identification(successor, cellid);

tracks_19dbz = Trajectory_generation(precursors_19dbz, cellid, successors_19dbz,288);
