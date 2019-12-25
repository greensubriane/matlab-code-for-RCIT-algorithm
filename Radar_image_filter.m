%% This function is used for filtering raw radar image by median filter algorithm
%% Inputs: file --- sequence of raw radar images;
%%             threshold_null_value_in_neighbourhoods --- the threshold for identifying the number of null value pixels in
%%                                                                                    a 3*3 pixel window, the default value is 5
%%             base_threshold --- the threshold for identifying the rainy pixel, the default value is 7 dBZ

%% Outputs: intensity --- the original radar image with form of 256*256 matrix.
%%                filterpixels --- the radar image after Gaussian mediam filtering algorithm
%% Created by Ting He in sep-2014, Edited by Ting He in Mar-2015
 
function [intensity, filterpixels] = Radar_image_filter(file, threshold_null_value_in_neigbourhoods, base_threshold)

%% read raw radar image 
intensity = dlmread(file);

%% applying the gaussian median filtering algorithm
intensity_1 = medfilt2(intensity, [3 3]);
intensity_1(isnan(intensity_1)) = 0;

%% identifying neighbour pixels for every radar pixel contained in the raw radar image
neighbor_matrixs = Radar_pixel_neighbor_identification(intensity_1);
siz = size(neighbor_matrixs);
[row, column] = size(intensity_1);
length_with_null_value = zeros(siz(1),1);
pixel_and_neighbor_length = zeros(siz(1),2);

for i1 = 1:siz(1)
    length_with_null_value(i1,1) = length(find(isnan(neighbor_matrixs(i1,:))) == 1);
end

pixel_and_neighbor_length(:,1) = neighbor_matrixs(:,1);
pixel_and_neighbor_length(:,2) = length_with_null_value(:,1);

for j = 1:siz(1)

%% for every pixel neighbour hoods if its 5 neighbour pixel is null or the pixel is not the rainy pxel, 
%% then this pixel is set to null
    if((pixel_and_neighbor_length(j,2) >= threshold_null_value_in_neigbourhoods) || (pixel_and_neighbor_length(j,1) <= base_threshold))
        pixel_and_neighbor_length(j,1) = NaN;
    end
end

pixels = pixel_and_neighbor_length(:,1)';
filterpixels = reshape(pixels, row, column);