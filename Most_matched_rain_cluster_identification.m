%% functions for searching most matched child rain cluster for each rain cluster,
%% based on the potential successors identified in function getall potential successors
%% Edited by Ting He 21-Sep-2015

%% Inputs:    timelength --- total scanning time of radar image.Here,the value is 288;
%%                clustercenterofmass --- weighted center of parent successors;
%%                clustercoords --- coordinates of pixels contained in the parent rain cluster;
%%                clusterareas --- areas of parent rain cluster;
%%                all_potential_centroids --- weighted center of all child rain clusters within the bounding box of parent cluster;
%%                all_potential_coords --- coordinates of all child rain cluster within the bounding box of parent cluster;
%%                all_potential_areas --- areas of all child rain cluster within the bounding box of parent cluster;
%%                vectors --- mean global vector at each time step.
%%                distance_coefficient --- coefficient value for determination of upper limits of distance difference between parent and child rain cluster,
%%                                                      the default value is 3;
%%                angle_coefficient_1 --- coefficient value for determination of upper limits of angle difference between parent and child rain cluster,
%%                                                    (for the case of single child rain cluster), the default value is 40
%%                angle_coefficient_2 --- coefficient value for determination of upper limits of angle difference between parent and child rain cluster,
%%                                                    (for the case of multi child rain cluster), the default value is 20

%% Outputs: overlaps --- overlaps between the child rain cluster and parent rain cluster;
%%                themostlikelysuccessors --- the identified most matched child rain clusters;
%%                distances(option) --- the distance between child rain clusters and parent rain cluster;
%%                directions(option) --- the angle between child rain clusters and parent rain cluster;
%%                clusterdatabase --- the 2-D matrix which contains the weighted centers of parent rain cluster and their most matched child rain cluster.

function [overlaps, themostlikelysuccessors, ....
          distances, directions, clusterdatabase] = Most_matched_rain_cluster_identification(timelength, clustercenterofmass, ...
                                                                                             clustercoords, clusterareas, all_potential_centroids, ...
                                                                                             all_potential_coords, all_potential_areas, vectors, ...
                                                                                             distance_coefficient, angle_coefficeient_1, angle_coefficeient_2)

%% defining the parameters of this function
themostlikelysuccessors = cell([timelength,1]);
overlaps = cell([timelength,1]);
overlaps_1 = cell([timelength,1]);
distances = cell([timelength,1]);  %% distance between parent rain cluster and child rain cluster
directions = cell([timelength,1]); %% angle between parent rain cluster and child rain cluster

%% Starting the main process
for i = 1:timelength-1
    clustercentroid = clustercenterofmass{i};
    clustercoord = clustercoords{i};
    clusterarea = clusterareas{i};
    themostlikelysuccessor = themostlikelysuccessors{i};
    p_overlap_1 = overlaps_1{i};
    overlapss = overlaps{i};
    distance = distances{i};
    direction = directions{i};
    potentialsuccessor_centroid = all_potential_centroids{i};
    potentialsuccessor_coord = all_potential_coords{i};
    potentialsuccessor_area = all_potential_areas{i};
    size_centroid = size(clustercentroid);
    %%
    for i1 = 1: size_centroid(1)
        size_potentialsuccessors_centroid = size(potentialsuccessor_centroid{i1});
        numberofpotentialsuccessors = size_potentialsuccessors_centroid(2);
        temp_potentialcentroid = reshape(potentialsuccessor_centroid{i1}, numberofpotentialsuccessors, 1);
        temp_potentialarea = reshape(potentialsuccessor_area{i1}, numberofpotentialsuccessors, 1);
        temp_potentialarea_1 = cell2mat(temp_potentialarea);
        temp_potentialcentroid_1 =  cell2mat(temp_potentialcentroid);
        
        size_temp_potentialcentroid_1 = size(temp_potentialcentroid_1);
        
        %% determination of most matched rain cluster from the distance and angle difference (for the case of single child rain cluster)
        if (size_temp_potentialcentroid_1(1) == 1)
            
            if ((temp_potentialcentroid_1(1,1) ~= 0) && (temp_potentialcentroid_1(1,2) ~= 0) && (temp_potentialarea_1(1,1) ~= 0))
                overlap = ismember(potentialsuccessor_coord{i1}{1},clustercoord{i1}, 'rows');
                overlap_2 = length(find(overlap(:,1) == 1));
                overlap_3 = overlap_2 ./ (size(potentialsuccessor_coord{i1}{1},1) + size(clustercoord{i1},1) - overlap_2);
                overlapss{i1} = overlap_3;
                p_overlap_1{i1} = overlap_3;
                d_x = (clustercentroid(i1,1) - temp_potentialcentroid_1(1,1))./1000;
                d_y = (clustercentroid(i1,2) - temp_potentialcentroid_1(1,2))./1000;
                direction{i1} = floor(mod(90-atan2d(d_y, d_x),360));
                distance{i1} = floor(sqrt(d_x.^2 + d_y.^2));
                themostlikelysuccessor{i1} = temp_potentialcentroid_1;
                
                if ((overlapss{i1} == 0) && (abs(direction{i1} - floor(mod(90-vectors(i,1),360))) > angle_coefficeient_1)) ||...
                        ((overlapss{i1} == 0) &&(distance{i1} > distance_coefficient*floor(vectors(i,2))))
                    themostlikelysuccessor{i1} = [];
                    p_overlap_1{i1} = [];
                end
                
            else
                themostlikelysuccessor{i1} = [];
                p_overlap_1{i1} = [];
                distance{i1} = [];
                direction{i1} = [];
                overlapss{i1} = 2;
            end
            
        end
        %% determination of most matched rain cluster from the distance and angle difference (for the case of multi child rain cluster)
        if (size_temp_potentialcentroid_1(1) > 1)
            temps_centroid = cell([1, size_temp_potentialcentroid_1(1)]);
            temps_areadifference = cell([1, size_temp_potentialcentroid_1(1)]);
            temps_areadifference_temp = cell([1, size_temp_potentialcentroid_1(1)]);
            temps_overlap = cell([1, size_temp_potentialcentroid_1(1)]);
            p_temps_overlap = cell([1, size_temp_potentialcentroid_1(1)]);
            
            for i2 = 1: size_temp_potentialcentroid_1(1)
                
                if ((temp_potentialcentroid_1(i2,1) ~= 0) && (temp_potentialcentroid_1(i2,2) ~= 0) && (temp_potentialarea_1(i2,1) ~= 0))
                    d_x_1 = (clustercentroid(i1,1)- temp_potentialcentroid_1(i2,1))./1000;
                    d_y_1 = (clustercentroid(i1,2)- temp_potentialcentroid_1(i2,2))./1000;
                    direction{i1}{i2} =floor(mod(90-atan2d(d_y_1, d_x_1),360));
                    distance{i1}{i2} = floor(sqrt(d_x_1.^2 + d_y_1.^2));
                    overlap_1 = ismember(potentialsuccessor_coord{i1}{i2},clustercoord{i1}, 'rows');
                    overlap_21 = length(find(overlap_1(:,1) == 1));
                    overlap_31 = overlap_21 ./(size(potentialsuccessor_coord{i1}{i2},1) + size(clustercoord{i1},1) - overlap_21);
                    temps_overlap{i2} = overlap_31;
                    p_temps_overlap{i2} = overlap_31;
                    temps_centroid{i2} = temp_potentialcentroid_1(i2,:);
                    temps_areadifference{i2} = [];
                    temps_areadifference_temp{i2} = abs(clusterarea(i1,1) - temp_potentialarea_1(i2,1));
                    
                    if ((temps_overlap{i2} == 0)&&(abs(direction{i1}{i2} - floor(mod(90-vectors(i,1),360))) <= angle_coefficeient_2)) ...
                            && ((temps_overlap{i2} == 0)&&(distance{i1}{i2} <= distance_coefficient*floor(vectors(i,2))))
                        temps_areadifference{i2} = abs(clusterarea(i1,1) - temp_potentialarea_1(i2,1));
                    end
                    
                    if ((temps_overlap{i2} == 0)&&(abs(direction{i1}{i2} - floor(mod(90-vectors(i,1),360))) > angle_coefficeient_2))...
                            || ((temps_overlap{i2} == 0)&&(distance{i1}{i2} > distance_coefficient*floor(vectors(i,2))))
                        temps_centroid{i2} = [];
                        p_temps_overlap{i2} = [];
                    end
                    
                else
                    temps_centroid{i2} = [];
                    temps_overlap{i2} = 2;
                    p_temps_overlap{i2} = [];
                    temps_areadifference{i2} = [];
                    direction{i1}{i2} = [];
                    distance{i1}{i2} = [];
                end
            end
            
            id = cellfun('length', temps_centroid);
            temps_centroid(id == 0) = [];
            p_id = cellfun('length', p_temps_overlap);
            p_temps_overlap(p_id == 0) = [];
            id1 = cellfun('length', temps_areadifference);
            temps_areadifference(id1 == 0) = [];
            temps_areadifference_temp = cell2mat(temps_areadifference);
            temps_areadifference_2 = min(temps_areadifference_temp);
            lengths = size(temps_areadifference);
            
            if(lengths(2) > 1)
                
                for i3 = 1:lengths(2)
                    
                    if(temps_areadifference{i3} ~= temps_areadifference_2)
                        temps_centroid{i3} = [];
                        p_temps_overlap{i3} = [];
                    end
                end
            end
            
            id2 = cellfun('length', temps_centroid);
            temps_centroid(id2 == 0) = [];
            p_id2 = cellfun('length', p_temps_overlap);
            p_temps_overlap(p_id2 == 0) = [];
            lengthss = size(temps_centroid);
            tempss = reshape(temps_centroid, lengthss(2), 1);
            tempsss = cell2mat(tempss);
            p_tempsss = cell2mat(p_temps_overlap);
            themostlikelysuccessor{i1}= tempsss;
            p_overlap_1{i1} = p_tempsss;
            overlapss{i1} = temps_overlap;
        end
        
        if (numberofpotentialsuccessors == 0)
            themostlikelysuccessor{i1} = [];
            p_overlap_1{i1} = [];
            overlapss{i1} = 2;
            direction{i1} = [];
            distance{i1} = [];
        end
        %%
    end
    %%
    %%
    themostlikelysuccessors{i} = themostlikelysuccessor;
    overlaps_1{i} = p_overlap_1;
    overlaps{i} =overlapss;
    distances{i} = distance;
    directions{i} = direction;
end

%% Determination of most match child rain cluster from the result of area difference
size_potential_centroid_2 = size(all_potential_centroids{timelength});
if (isempty(size_potential_centroid_2(1)) == 0)
    for i7 = 1:size_potential_centroid_2(2)
        themostlikelysuccessors{timelength}{i7} = zeros(1, 2);
        overlaps_1{timelength}{i7} = 0;
        overlaps{timelength}{i7} = 2;
        directions{timelength}{i7} = [];
        distances{timelength}{i7} = [];
    end
end
%%

%% post-process and generated output --- clusterdatabse
clustercentroids_1 =  clustercenterofmass;
themostlikelysuccessors_1 = themostlikelysuccessors;
id_clustercentroids_1 = cellfun('length', clustercentroids_1);
id_themostlikelysuccessors_1 = cellfun('length', themostlikelysuccessors_1);
clustercentroids_1(id_clustercentroids_1 == 0 ) = [];
themostlikelysuccessors_1(id_themostlikelysuccessors_1 == 0) = [];

lengthofclusterdatabase = size(themostlikelysuccessors_1);
clusterdatabases_1 = cell([lengthofclusterdatabase(1),1]);
%%

%%
for i = 1:lengthofclusterdatabase(1)
    clustercentroid_1 = clustercentroids_1{i};
    mostlikelysuccessor_1 = themostlikelysuccessors_1{i};
    size_mostlikelysuccessor_1 = size(mostlikelysuccessor_1);
    
    for j = 1:size_mostlikelysuccessor_1(2)
        temps_2 = clustercentroid_1(j,:);
        size_mostlikelysuccessor_2 = size(mostlikelysuccessor_1{j});
        
        if (size_mostlikelysuccessor_2(1) ~= 0)
            temps = zeros(size_mostlikelysuccessor_2(1),4);
            
            for m = 1:size_mostlikelysuccessor_2(1)
                temps(m,:)= [temps_2, mostlikelysuccessor_1{j}(m,:)];
            end
            
            clusterdatabases_1{i}{j} = temps;
        else
            
            temps_1 = [temps_2, 0, 0];
            clusterdatabases_1{i}{j} = temps_1;
        end
    end
    
    clusterdatabases_1{i} = reshape(clusterdatabases_1{i}, size_mostlikelysuccessor_1(2),1);
    clusterdatabases_1{i} = cell2mat(clusterdatabases_1{i});
end
%%
%%
clusterdatabases = cell2mat(clusterdatabases_1);
overlaps_2 = overlaps_1;
id_clustercentroids_1 = cellfun('length', clustercentroids_1);
id_overlap_2 = cellfun('length', overlaps_2);
clustercentroids_1(id_clustercentroids_1 == 0 ) = [];
overlaps_2(id_overlap_2 == 0) = [];

lengthofclusteroverlap = size(overlaps_2,1);
clusteroverlaps_1 = cell([lengthofclusteroverlap,1]);
%%

%%
for i = 1:lengthofclusteroverlap
    clustercentroid_1 = clustercentroids_1{i};
    p_overlap_2 = overlaps_2{i};
    size_overlap_2 = size(p_overlap_2,2);
    
    for j = 1:size_overlap_2
        temps_21 = clustercentroid_1(j,:);
        size_p_overlap_2 = size(p_overlap_2{j},2);
        
        if (size_p_overlap_2(1) ~= 0)
            temps_22 = zeros(size_p_overlap_2(1),3);
            for m = 1:size_p_overlap_2
                temps_22(m,:)= [temps_21, p_overlap_2{j}(1,m)];
            end
            clusteroverlaps_1{i}{j} = temps_22;
            
        else
            temps_1 = [temps_21, 0];
            clusteroverlaps_1{i}{j} = temps_1;
        end
    end
    clusteroverlaps_1{i} = reshape(clusteroverlaps_1{i}, size_overlap_2,1);
    clusteroverlaps_1{i} = cell2mat(clusteroverlaps_1{i});
end
%%
%%
clusteroverlaps = cell2mat(clusteroverlaps_1);
clusterdatabase = [clusterdatabases, clusteroverlaps(:,3)];
end