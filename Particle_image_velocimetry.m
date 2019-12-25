%% This function is the main function of Particle Image Velocimetry method which is used for
%% derving global vector from two successive radar images.

%% Inputs: image_t1 --- original radar image at time t;
%%         image_t2 --- original radar image at time t+dt;
%%         sub_window_size_horizontal --- sub window size at horizontal direction, default value is 32 (km);
%%         sub_window_size_vertical --- sub window size at vertical direction, default value is 32 (km);
%%         overlap_horizontal, overlap_vertical --- overlaps between sub windows at horizontal and vertical direction seperately, default value is 0.5;
%%         max_vector_horizontal --- upper limit of vector at horizontal direction, default value is 20(km/5min);
%%         max_vector_vertical --- upper limit of vector at vertical direction, default value is 20(km/5min);
%%         dt --- number of interval for two succesive radar images, here the value is set to 1;
%%         methodtype --- the method for calculating vector for each sub window, the default value is 'mqd' --- Minimum Quadric Differences method

%% Outputs: position_horizontal --- position of motion vector at horizontal direction;
%%          position_vertical --- position of motion vector at vertical direction;
%%          vector_horizontal --- motion vector at horizontal direction;
%%          vector_vertical --- motion vector at vertical dirction;

function [position_horizontal,position_vertical,...
          vector_horizontal,vector_vertical]=Particle_image_velocimetry(image_t1, image_t2,...
                                                                        sub_window_size_horizontal, sub_window_size_vertical,...
                                                                        overlap_horizontal, overlap_vertical,...
                                                                        max_vector_horizontal, max_vector_vertical, dt, methodtype)

%% preprocessing
%% transpose of the matrix immage(y,x) to image(x,y)
image_1 = double(image_t1');
image_2 = double(image_t2');

%% calculating horizontal and vertical size of image
size_row_1  = size(image_1,1);
size_column_1  = size(image_1,2);

size_row_2 = size(image_2,1);
size_column_2 = size(image_2,2);

if ((size_row_1 ~= size_row_2) || (size_column_1 ~= size_column_2))
    error('Error: image sizes are different, exit!')
end

sub_window_size_horizontal = round(sub_window_size_horizontal);
sub_window_size_vertical = round(sub_window_size_vertical);

%% set the limits of overlap between sub windows, the upper limit is 0.9
if (overlap_horizontal > 0.9 || overlap_vertical > 0.9)
    error('Error: the overlap ratio is too large, exit!')
end

%% selecting the method for calculting the motion vectors,
%% the common way is maximum cross-correlation method,
%% in this study, the minimum quadric difference method is applied (defaultpivtype is 'mqd')

defaultpivtype = 'mqd';
logicalpivtype = strcmp(methodtype, defaultpivtype);

if (logicalpivtype == 1)
    %% calling the mqd method
    [position_horizontal, position_vertical, vector_horizontal, vector_vertical] = Minimum_quadric_difference(image_1, image_2, ...
        sub_window_size_horizontal, sub_window_size_vertical, overlap_horizontal, overlap_vertical, ...
        max_vector_horizontal, max_vector_vertical);
else
    error('Error: Invalid piv type, exit!');
end

%% deriving the motion vector
vector_horizontal = vector_horizontal/dt;
vector_vertical = vector_vertical/dt;