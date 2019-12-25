%% This is the main function for radar derived precipitatui field identification procedure
%% the relative fuctions listed in this functin are:
%% (1): Radar_image_filter.m(file, threshold_nullvalue_neighborhood, light_intensity_thresold)
%% (2): Rainy_pixel_segmenttion.m(intensity, filterpixels, convective_intensity_thresholds, hail_intensity_threshold, x_coordinates, y_coordinates)

%% Inputs: timelength                                            --- radar scanning time steps, for one day the value is 288;
%%             files                                                       --- 2-D radar images, by CAPPI scanning way, the polar cooedinates; 
%%                                                                                has been trasfered into cartesian cooedinates by 'nearest neighbor' method;
%%             base_threshold                                      --- minimum refectivity threshold for identifying rain cluster;
%%             rainypixel_threshold                             --- refelectivity threshold for identifying rain cluster, 
%%                                                                               19 is for light rain cluster and 37 is for the convective ones;
%%             convectivepixel_threshold                    --- convective reflectivity threshold for identifying number of convective pixels in rain cluster;
%%             threshold_nullvalueinneigburhoods     --- threshold for identifying connective precipitation area in a 3X3 area;
%%             area_threshold                                      --- minimum precipitation field threshold, default value is 9;
%%             x_coordinates, y_coordinates                --- coordinates of radar image pixel in cartesian coordinate system;

%% Outputs: raincells --- identified rain clusters at each moment which are orgnized in matlab 'cell' format;
%%          raincellsfeatures_1 --- Characters of rain clusters which are orgnized in a 2-D matrix,for each column:
%%                                  1. Area
%%                                  2. Maximum intensity
%%                                  3. Areal mean precipitation
%%                                  4. Center of mass at horizontal direction
%%                                  5. Center of mass at vertical direction
%%                                  6. Eccentricity
%%                                  7. Number of convective pixels
%%                                  8. Cumulative precipitation
%%                                  9. Perimeter (optional)
%%                                  10. Area of Convex rain cluster (optional)

 function [raincells, raincellsfeatures_1]=...       
                                             Raincluster_identification(timelength, files, base_threshold, ...
                                                                        rainypixel_threshold, convectivepixel_threshold, ...
                                                                        threshold_nullvalueinneigbourhoods, ...
                                                                        area_threshold, x_coordinates, y_coordinates)

raincells = cell([timelength,1]);
raincellsfeatures = cell([timelength,1]);
%clustercentroids is the center of mass not the geometric center

for i = 1:timelength 
    [intensity, filterpixels] = Radar_image_filter(files{i}, threshold_nullvalueinneigbourhoods, base_threshold);
    [cells, raincellfeature]=Rainypixel_segmentation(filterpixels,rainypixel_threshold, ...
        convectivepixel_threshold, area_threshold,  x_coordinates, y_coordinates);                                              
    numberofcells = length(cells);
    largercells = cell([1,numberofcells]);
    raincellsfeatures{i} = raincellfeature;

    
    for j1 = 1:numberofcells
        if(cells(j1,1).Area > area_threshold)
            largercells{j1} = struct2cell(cells(j1,1));
        end
        
    end
    
    id = cellfun('length', largercells);
    largercells(id==0)=[];
    raincells{i} = largercells;
end

id1 = cellfun('length', raincellsfeatures);
raincellsfeatures(id1 == 0) = [];
sizes = size(raincellsfeatures);

for i5 =1:sizes(1)
    raincellsfeatures{i5} = raincellsfeatures{i5}';
end

time = zeros(timelength,2);
for i = 1:timelength
    time(i,1) = i;
    time(i,2) = size(raincells{i},2);
end

time(time(:,2) == 0,:)=[];
sizes = size(time);
timesteps =  cell([sizes(1),1]);
for i = 1:sizes(1)
    timestep = time(i,1);
    numberofcluster = time(i,2);
    timestep_1 = zeros(numberofcluster,1);
    for j = 1:numberofcluster
        timestep_1(j,1) = timestep;
    end
    timesteps{i} = timestep_1;
end

timesteps = cell2mat(timesteps);
raincellsfeatures = cell2mat(raincellsfeatures); 
id = [1:1:size(raincellsfeatures)]';
raincellsfeatures_1 = [id, timesteps, raincellsfeatures];