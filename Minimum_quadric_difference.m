%% This function is the main function of Minimum quadric Different method

%% Inputs: image_t1 --- radar image at time t;
%%         image_t2 --- radar image at time t + dt(5 minutes);
%%         sub_window_size_horizontal --- sun window size at horizontal direction the default is 32(km)
%%         sub_window_size_vertical --- sub window size at vertical direction, the default value is 32(km)
%%         overlap_x --- overlap between sub windows at horizontal direction, the default value is 0.5;
%%         overlap_y --- overlap between sub windows at vertical direction, the default value is 0.5;
%%         max_vector_horizontal --- upper limit for motion vector at horizontal direction, the default value is 20(km/5min);
%%         max_vector_vertical --- upper limit for motion vector at vertical direction, the default value is 20(km/5min);

%% Outputs: position_horizontal --- horizontal position for derived motion vector;
%%          position_vertical --- vertical position for derived motion vector;
%%          vector_horizontal --- horizontal motion vector;
%%          vector_vertical --- vertical motion vector;

function [position_horizontal, position_vertical, ...
          vector_horizontal, vector_vertical] = Minimum_quadric_difference(image_t1, image_t2, ...
                                                                           sub_window_size_horizontal, sub_window_size_vertical, ...
                                                                           overlap_x, overlap_y, max_vector_horizontal, max_vector_vertical)

%% defining ratio of maximum and mean
r_MMR = 1.10;

%% defining ratio of the first and the second mqd peak value
r_PPR = 1.05;

%% set the percentage of sun window for defining the search area
percentage_search = 1/3;

%% setting lower and upper value limits for MQD result.
mqd_min = 10^(-5);
mqd_max = Inf;

%% getting size of radar image

size_row_t1 = size(image_t1,1);
size_column_t1 = size(image_t1,2);

%% defining the searching area

if ((max_vector_horizontal <= 0) || (max_vector_vertical <= 0))
    %% the searching area is defined by the 1/3 rule
    max_move_distance_horizontal = ceil(percentage_search*sub_window_size_horizontal);
    max_move_distance_vertical = ceil(percentage_search*sub_window_size_vertical);
else
    
    %% the searching area is defined by maximum vector at horizontal and vertical direction
    max_move_distance_horizontal = floor(max_vector_horizontal);
    max_move_distance_vertical = floor(max_vector_vertical);
    
    if (max_move_distance_horizontal >= sub_window_size_horizontal)
        max_move_distance_horizontal = sub_window_size_horizontal;
    end
    if (max_move_distance_vertical >= sub_window_size_vertical)
        max_move_distance_vertical = sub_window_size_vertical;
    end
end

%% calculating searching area
nx_search  = 2*max_move_distance_horizontal + 1;
ny_search  = 2*max_move_distance_vertical + 1;

%% obtaing the center locatons for each sub window
[position_horizontal, position_vertical, dx_center, dy_center] ...
    = Position_particle_image_velocimetry('mqd', size_row_t1, size_column_t1, sub_window_size_horizontal, ...
                                          sub_window_size_vertical, overlap_x, overlap_y);

%% getting number of vector for each sub window
number_x = max(size(position_horizontal));
number_y = max(size(position_vertical));

%% main process
for i_y = 1: number_y
    for i_x = 1:number_x

        %% creating the target window from the first image and getting area of target subwindow
        ix1 = position_horizontal(i_x) - dx_center;
        ix2 = ix1 + sub_window_size_horizontal - 1;
        iy1 = position_vertical(i_y) - dy_center;
        iy2 = iy1 + sub_window_size_vertical - 1;
        
        %% getting the center of target window
        ix_center = (ix1 - 1 + dx_center);
        iy_center = (iy1 - 1 + dy_center);
        f1 = image_t1(ix1:ix2, iy1:iy2);
        
        %% calculating the MQD value
        C = zeros(nx_search,ny_search);
        
        isy = 0;
        for jy = -max_move_distance_vertical : max_move_distance_vertical
            isx = 0;
            isy = isy + 1;
            
            for jx = -max_move_distance_horizontal : max_move_distance_horizontal
                isx = isx + 1;
                
                %% creating the searhing sub window fron the second subwindow
                f2 = zeros(sub_window_size_horizontal,sub_window_size_vertical);
                
                kx1 = ix1 + jx;
                kx2 = kx1 + sub_window_size_horizontal - 1;
                ky1 = iy1 + jy;
                ky2 = ky1 + sub_window_size_vertical - 1;
                
                if ((kx1 >= 1) && (kx2 <= size_row_t1) && (ky1 >= 1) && (ky2 <= size_column_t1))
                    f2 = image_t2(kx1:kx2, ky1:ky2);
                    n  = size(image_t2,1)*size(image_t2,2);
                    d = sum(sum(abs(f1 - f2)))/n;
                    if (d ~= 0)
                        C(isx,isy) = d;
                    else
                        C(isx,isy) = mqd_min;
                    end
                    
                else
                    C(isx,isy) = mqd_max;
                end
            end
        end
        
        %% for simple calculation, the MQD result is diveded by 1
        C = 1./C;
        size_x = size(C,1);
        size_y = size(C,2);
        
        %% calculating the position of the peak value
        [peak_location_horizontal, peak_location_vertical, SNR, MMR, PPR] = MQD_peak_searching(C,2);
        
        if (rem(size_x,2) == 0)
            ix_peak = peak_location_horizontal - (size_x/2+0.5);
        else
            ix_peak = peak_location_horizontal - ceil(size_x/2);
        end
        if (rem(size_y,2) == 0)
            iy_peak = peak_location_vertical - (size_y/2+0.5);
        else
            iy_peak = peak_location_vertical - ceil(size_y/2);
        end
        
        if (MMR < r_MMR || PPR < r_PPR)
            ix_peak = NaN;
            iy_peak = NaN;
        end
        
        %% eliminating the motion vectors which exceed the upper limits
        if (abs(ix_peak) >= max_vector_horizontal)
            ix_peak = NaN;
            iy_peak = NaN;
        end
        if (abs(iy_peak) >= max_vector_vertical)
            ix_peak = NaN;
            iy_peak = NaN;
        end
        
        is_x(i_x,i_y) = ix_peak;
        is_y(i_x,i_y) = iy_peak;
    end
end

vector_horizontal = is_x;
vector_vertical = is_y;