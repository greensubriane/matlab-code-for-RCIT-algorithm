%% This is the main function for mean value of global motion vector identification algorithm,
%% two functions are implemented
%%                                                   1 --- the Particle Image Velocimetry algorithm;
%%                                                   2 --- the median filter way for post-processing generated motion vectors.

%% Inputs: timelength --- number of radar images, it is depend on the number of inputted radar images,
%%                                     here the radar images is inputted according to the rainy day, so the default value is 288;
%%             originalreflectivities --- raw radar images;

%% Outputs: global vector --- a 2-D matrix which contains the angle and speed of mean value of generated global motion vector at every 5 minutes;
%%                mean_x_vector, mean_y_vector(option) --- mean value of global motion vectors at horizontal and vertical direction seperately.
%% Created by Ting He in sep-2014, edited by Ting He in Mar-2015

function [global_vector, mean_x_vector, mean_y_vector] = Global_vector_generation(timelength, files)

global_vector = zeros(timelength,2);
mean_x_vector = zeros(timelength,1);
mean_y_vector = zeros(timelength,1);

for i = 1:timelength-1
    originalreflectivities_first = dlmread(files{i});
    originalreflectivities_second = dlmread(files{i+1});
    originalreflectivities_first(isnan(originalreflectivities_first)) = 0;
    originalreflectivities_second(isnan(originalreflectivities_second)) = 0;
    %% implementing PIV method for generating global displacements at each 5 minutes, the size of interrigation box is set to 32 km
    [xi,yi,iu,iv] = Particle_image_velocimetry(originalreflectivities_first, originalreflectivities_second, 32, 32, 0.5, 0.5, 20, 20, 1, 'mqd');
    
    [iu_ft, i_cond] = Post_process_motion_vector_median_filter(iu, 2);
    [iv_ft, i_cond] = Post_process_motion_vector_median_filter(iv, 2);
    
    iu_ft = iu_ft - iv_ft*0;
    iv_ft = iv_ft - iu_ft*0;
    
    iu_tmp = reshape(iu_ft, 1, size(iu_ft,1)*size(iu_ft,2));
    iv_tmp = reshape(iv_ft, 1, size(iv_ft,1)*size(iv_ft,2));
    tmp_x  = ~isnan(iu_tmp);
    tmp_y  = ~isnan(iv_tmp);
    iu_tmp = iu_tmp(tmp_x);
    iv_tmp = iv_tmp(tmp_y);
    iu_tmp = iu_tmp';
    iv_tmp = iv_tmp';
    mean_x_vector(i,1) = mean(iu_tmp);
    mean_y_vector(i,1) = mean(iv_tmp);
    direction = atan2d(iv_ft, iu_ft);
    size_direction = size(direction);
    
    %% generating the previaling wind direction according to the generated motion vector
    direction_1 = reshape(direction, size_direction(1,1)*size_direction(1,2),1);
    
    
    %% getting relative frequency of direction for global motion vector
    narginchk(1,inf);
    [cax,args,nargs] = axescheck(direction_1);
    y = args{1};
    
    if nargs == 1
        x = 1;
        
    elseif nargs == 2
        x = args{2};
        
    else
        if isempty(args{2})
            x = 1;
        else
            x = args{2};
        end
    end
    
    [m,n] = size(y);
    [nn,x]=hist(y,x); % frequency
    nn = nn./m;       % relative frequency
    
    if nargs == 3
        binwidth = x(2)-x(1);
        nn = nn./binwidth;
    end
    
    if nargout == 0
        
        if ~isempty(cax)
            bar(cax,x,nn,[min(y(:)) max(y(:))],'hist');
        else
            bar(x,nn,[min(y(:)) max(y(:))],'hist');
        end
        xlabel('y')
        
        if nargs == 3
            ylabel('relative frequency density')
        else
            ylabel('relative frequency')
        end
        
    else
        no_direction = nn;
        xo_direction = x;
    end
    
    frequency = [no_direction', xo_direction'];
    ids = frequency(:,1) ==  max(frequency(:,1));
    global_vector(i,1) = frequency(ids,2);
    distance = zeros(size(iu_ft,1), size(iu_ft,2));
    
    for i1 = 1:size(iu_ft,1)
        for i2 = 1:size(iu_ft,2)
            distance(i1,i2) = sqrt(iu_ft(i1,i2).^2 + iv_ft(i1,i2).^2);
        end
    end
    
    distance_tmp = reshape(distance, 1, size(distance,1)*size(distance,2));
    tmp = ~isnan(distance_tmp);
    distance_tmp = distance_tmp(tmp);
    mean_distance = median(abs(distance_tmp));
    global_vector(i,2) = mean_distance;
end