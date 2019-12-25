function [clusterboundingboxwithsearchbox, clusterboundingboxes, clustercentroids, ...
               clustercoords, clusterareas, clustercenterofmass] = Pre_process_tracking_procedure(timelength, ...
                                                                                                  files, threshold_nullvalueinneigbourhoods,...
                                                                                                  cellsize, light_intensity_threshold, ...
                                                                                                  convective_intensity_threshold, x_coordinates, y_coordinates)

clusterboundingboxwithsearchbox        =      cell([timelength,1]);
clusterboundingboxes                           =      cell([timelength,1]);
%clustercentroids is the center of mass not the geometric center
clustercentroids                                     =     cell([timelength,1]);
clustercoords                                         =     cell([timelength,1]);
clusterareas                                           =     cell([timelength,1]);
clustercenterofmass                               =     cell([timelength,1]);

for i = 1:timelength
    reflectivity = dlmread(files{i});
    reflectivity_1 = reflectivity;
    reflectivity = medfilt2(reflectivity, [3 3]);
    reflectivity(isnan(reflectivity)) = 0;
    neighbor_matrixs = Radar_pixel_neighbor_identification(reflectivity);
    siz = size(neighbor_matrixs);
    [row, column] = size(reflectivity);
    lengthwithnullvalue = zeros(siz(1),1);
    pixelandneighborlength = zeros(siz(1),2);
    
    for i1 = 1:siz(1)
        lengthwithnullvalue(i1,1) = length(find(isnan(neighbor_matrixs(i1,:))) == 1);
    end
    
    pixelandneighborlength(:,1) = neighbor_matrixs(:,1);
    pixelandneighborlength(:,2) = lengthwithnullvalue(:,1);
    
    for j = 1:siz(1)
        if((pixelandneighborlength(j,2) >= threshold_nullvalueinneigbourhoods) || (pixelandneighborlength(j,1) <= light_intensity_threshold))
            pixelandneighborlength(j,1) = NaN;
        end
    end
    
    pixels = pixelandneighborlength(:,1)';
    filterpixels = reshape(pixels, row, column);
    originalpixels = reflectivity_1;
    filterpixels_1 = reflectivity;
    [m,n]=size(filterpixels);
    filterpixels(isnan(filterpixels)) = 0;
    for i2 = 1:m
        for j2 = 1:n
            if filterpixels(i2,j2)<= convective_intensity_threshold
                filterpixels(i2,j2)=0;
            else
                filterpixels(i2,j2) = 1;
            end
        end
    end
    filterpixels = bwmorph(filterpixels, 'spur');
    [labeled,numObjects] = bwlabel(filterpixels,8);
    clusters = regionprops(labeled, 'all');
    allcellsarea=[clusters.Area];
    
    boundingwithsearchbox = zeros(numObjects,4);
    centroids = zeros(numObjects,2);
    %centerofmass = zeros(numObjects, 2);
    areas = zeros(numObjects,1);
    ids = find(allcellsarea > cellsize);
    coordinate = cell([length(ids), 1]);
    center_mass = zeros(length(ids),2);
    count=1;
    sizemat=1;
    coords=zeros(numObjects*m*n,3);
    intensities=zeros(m*n,2);
    clusterboundingbox=zeros(numObjects,4);
    for i3=1:numObjects
        if allcellsarea(i3) > cellsize
            [ycoords,xcoords] = find(labeled==i3);
            r=length(ycoords);
            coords(sizemat:(sizemat+r-1),1)=xcoords;
            coords(sizemat:(sizemat+r-1),2)=ycoords;
            coords(sizemat:(sizemat+r-1),3)=count;
            ii=1;
            for j1=sizemat:(sizemat+r-1)
                %intensities(j1,1)=originalpixels(ycoords(ii),xcoords(ii));
                intensities(j1,1)=filterpixels_1(ycoords(ii),xcoords(ii));
                intensities(j1,2)=count;
                ii=ii+1;
            end
            temp = [clusters(i3,1).BoundingBox(1)-10, clusters(i3,1).BoundingBox(2)-10, ...
                clusters(i3,1).BoundingBox(3)+20, clusters(i3,1).BoundingBox(4)+20];
            temp1 = [ min(x_coordinates) + (clusters(i3,1).Centroid(1))*1000, min(y_coordinates) + (clusters(i3,1).Centroid(2))*1000];
            %temps4 = ((((10.^(temps./10))./256).^(50/71))*300)./3600;
            temp2 = clusters(i3,1).BoundingBox;
            temp3 = allcellsarea(i3);
            
            boundingwithsearchbox(i3,:) = temp;
            centroids(i3,:) = temp1;
            areas(i3,:) = temp3;
            clusterboundingbox(i3,:) = temp2;
            sizemat=sizemat+r;
            count=count+1;
        end
    end
    coords=coords(1:(sizemat-1),:);
    x_direction = [coords(:,1), coords(:,3)];
    y_direction = [coords(:,2), coords(:,3)];
    id = unique(coords(:,3));
    
    for i4 = 1:length(id)
        temp_x = x_direction(x_direction(:,2) == i4);
        temp_y = y_direction(y_direction(:,2) == i4);
        temps_4 = intensities(intensities(:,2) == i4);
        %testing seperation method
        %temps_4(temps_4 > 37) = 37;
        %temps4 = ((((10.^(temps_4./10))./256).^(50/71))*300)./3600;
        %temps_1 = xcoords(xcoords(:,2) == i4);
        %temps_2 = ycoords(ycoords(:,2) == i4);
        % this part will use weighted centroid
        %[semimajor_axis, semiminor_axis, x0, y0, phi] = ellipse_fit(temp_x, temp_y);
        temp_weight_x = (temp_x' * temps_4)./sum(temps_4);
        temp_weight_y = (temp_y' * temps_4)./sum(temps_4);
        
        temp_weighted_xbar = min(x_coordinates) + temp_weight_x * 1000;
        temp_weighted_ybar = min(y_coordinates) + temp_weight_y * 1000;
        
        center_mass(i4,1) = temp_weighted_xbar;
        center_mass(i4,2) = temp_weighted_ybar;
        coordinate{i4} = [temp_x, temp_y];
    end
    
    ind = ~all(boundingwithsearchbox,2);
    boundingwithsearchbox(ind,:) = [];
    ind1 = ~all(centroids,2);
    centroids(ind1,:) = [];
    ind3 = ~all(areas,2);
    areas(ind3,:) = [];
    ind2 = ~all(clusterboundingbox,2);
    clusterboundingbox(ind2,:) = [];
    clusterboundingboxwithsearchbox{i} = boundingwithsearchbox;
    clusterboundingboxes{i} = clusterboundingbox;
    clustercentroids{i} = centroids;
    clustercoords{i} = coordinate;
    clusterareas{i} = areas;
    clustercenterofmass{i} = center_mass;
    %filterimages{i} = newpixels;
end