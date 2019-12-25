%% The function get_potentialsuccessor is used to get the candidating child rain cluster at next moments, 
%% which corresponded to the section 2.5.2 in Chapter2.
%% Input parameters: timelength --- total scanning time of radar image.Here,the value is timelength, which means that one day can 
%%                                                       be devided into timelength of 5 minutes;
%%                               clusterboundingboxes --- the boundary box of each rain cluster;
%%                               clusterboundingboxwithsearchbox --- the boundary box of each parent rain cluster which is defiend according to 
%%                                                                                             the defination of boundary in section 2.5.2 in Chapter2;
%%                               clustercenterofmass --- the weighted center of rain cluster;
%%                               clustercoords --- the Cartesian position of pixel which is contained in the rain cluster;
%%                               clusterareas --- the area of rain cluster.

%% Output parameters: all_potentional_centroids --- the weighted centers for all the potential child clusters;
%%                                  all_potential_coords --- the coordinates of pixels which contained in the potential rain cluster;
%%                                  all_potential_areas --- the areas of all the child rain clusters.

function [all_potential_centroids, all_potential_coords, all_potential_areas] = Get_child_rain_cluster(timelength, ...
                                                                                                                                                     clusterboundingboxes, clusterboundingboxwithsearchbox, ...
                                                                                                                                                     clustercenterofmass, clustercoords, clusterareas)

%% setting parameters of this function
potentialsuccessors_centroid = cell([timelength,1]);
potentialsuccessors_coords = cell([timelength,1]);
potentialsuccessors_areas = cell([timelength,1]);

clusterboundingboxes_1 = cell([timelength+1,1]);
clustercentroid_1 = cell([timelength+1,1]);
clustercoords_1 = cell([timelength+1,1]);
clusterareas_1 = cell([timelength+1,1]);


%% starting the main process
for j = 1:timelength
  clusterboundingboxes_1{j} = clusterboundingboxes{j};
  %clustercentroid_1{j} = clustercentroids{j};
  clustercentroid_1{j} = clustercenterofmass{j};
  clustercoords_1{j} = clustercoords{j};
  clusterareas_1{j} = clusterareas{j};
end
iiii=1;

for i = 1:timelength   
    boundingbox = clusterboundingboxes_1{i+1};
    centroid = clustercentroid_1{i+1};
    coords = clustercoords_1{i+1};
    areas = clusterareas_1{i+1};
    boundingandcentroid = [boundingbox, centroid];
    boundingboxwithsearchbox = clusterboundingboxwithsearchbox{i};  

    sizes = size(boundingboxwithsearchbox);
    rows = sizes(1);
    size_1 = size(boundingandcentroid);
    rows_1 = size_1(1);
    actul_centroid = cell([rows,1]);
    actual_coordinate = cell([rows,1]);
    actual_area = cell([rows,1]);
    potentialsuccessor_centroid = cell([rows_1,1]);
    potentialsuccessor_coordinate = cell([rows_1,1]);
    potentialsuccessor_area = cell([rows_1,1]);
    iiii=iiii+1;
    stringss = strcat('the loopss is:', num2str(iiii));
    disp(stringss);
    iii=1;
 %% searching the child rain clusters which contained in the bounding box of parent rain cluster
  for i3 = 1:rows 
    x_direction = [(boundingboxwithsearchbox(i3,1)-0.5):1:(boundingboxwithsearchbox(i3,1)-0.5 + boundingboxwithsearchbox(i3,3)-1)]';
    y_direction = [(boundingboxwithsearchbox(i3,2)-0.5):1:(boundingboxwithsearchbox(i3,2)-0.5 + boundingboxwithsearchbox(i3,4)-1)]';
    
    boundingboxwithsearchbox_matrix = zeros(length(y_direction)*length(x_direction)+1, 2);
    tempral = [1:length(y_direction):length(y_direction)*length(x_direction)+1];
    
    for tt = 1:length(tempral)-1
       boundingboxwithsearchbox_matrix(tt:(tt+length(x_direction)-1),1) = x_direction(tt,1);
       boundingboxwithsearchbox_matrix(tt:(tt+length(y_direction)-1),2) = y_direction(:,1);
    end
       iii=iii+1;
       strings = strcat('the loops is:', num2str(iii));
       disp(strings);
       ii=1;
    for i1 = 1:rows_1
          overlap = intersect(boundingboxwithsearchbox_matrix, coords{i1});
          overlaps = isempty(overlap);
          ii=ii+1;
          string = strcat('the loop is:', num2str(ii));
          disp(string);
          if (overlaps == 0)  
           potentialsuccessor_centroid{i1} = boundingandcentroid(i1,5:6); 
           potentialsuccessor_coordinate{i1} = coords{i1};
           potentialsuccessor_area{i1} = areas(i1,1);
           
          else
           potentialsuccessor_centroid{i1} = [];
           potentialsuccessor_coordinate{i1} = [];
           potentialsuccessor_area{i1} = [];
          end          
    end
    
    id = cellfun('length', potentialsuccessor_centroid);
    potentialsuccessor_centroid(id==0)=[];
    id1 = cellfun('length', potentialsuccessor_coordinate);
    potentialsuccessor_coordinate(id1==0)=[];
    id2 = cellfun('length', potentialsuccessor_area);
    potentialsuccessor_area(id2==0)=[];
    actul_centroid{i3} = potentialsuccessor_centroid;    
    actual_coordinate{i3} = potentialsuccessor_coordinate;
    actual_area{i3} = potentialsuccessor_area;
  end
  
  potentialsuccessors_centroid{i} = actul_centroid;
  potentialsuccessors_coords{i} = actual_coordinate;
  potentialsuccessors_areas{i} = actual_area;
end

all_potential_centroids = cell([timelength,1]);
all_potential_coords = cell([timelength,1]);
all_potential_areas = cell([timelength,1]);

nullvalueforcentroidandcoords = cell([1]);
nullvalueforcentroidandcoords{1} = [0,0];
nullvalueforareas = cell([1]);
nullvalueforareas{1} = 0;

for j4 = 1:timelength
  clustercentroid = clustercenterofmass{j4};
  potentialsuccessor_centroid_1 = potentialsuccessors_centroid{j4};
  potentialsuccessor_coord_1 = potentialsuccessors_coords{j4};
  potentialsuccessor_area_1 = potentialsuccessors_areas{j4};
  size_centroid = size(clustercentroid);
  
  for j5 = 1: size_centroid(1)
    size_potentialsuccessors_centroid = size(potentialsuccessor_centroid_1{j5});
    
    if size_potentialsuccessors_centroid(1) > 1
      potentialsuccessor_centroid_1{j5} = reshape(potentialsuccessor_centroid_1{j5}, 1, size_potentialsuccessors_centroid(1));
      potentialsuccessor_coord_1{j5} = reshape(potentialsuccessor_coord_1{j5}, 1, size_potentialsuccessors_centroid(1));
      potentialsuccessor_area_1{j5} = reshape(potentialsuccessor_area_1{j5}, 1, size_potentialsuccessors_centroid(1));
    end
    
    all_potential_centroids{j4}{j5} = potentialsuccessor_centroid_1{j5};
    all_potential_coords{j4}{j5} = potentialsuccessor_coord_1{j5};
    all_potential_areas{j4}{j5} = potentialsuccessor_area_1{j5};
    size_potentialcentroid = size(all_potential_centroids{j4}{j5});
    
    if ((size_potentialcentroid(1) == 0) || (size_potentialcentroid(2) == 0))
      all_potential_centroids{j4}{j5} = nullvalueforcentroidandcoords;
      all_potential_coords{j4}{j5} = nullvalueforcentroidandcoords;
      all_potential_areas{j4}{j5} = nullvalueforareas;
    end
  end
end
end