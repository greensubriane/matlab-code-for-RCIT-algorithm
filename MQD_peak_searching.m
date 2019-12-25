%% This function is used for calculting peak value from MQD result

%% Inputs: mqd_matrix --- 2-D matrix which contain the MQD peak value;
%%         option --- method for finding peak value, 1--- normal algorithm, 2 --- Gaussian subpixel algorithm,
%%                    the default value is 2;

%% Outputs: peak_location_horizontal --- location for mqd peak value at horizontal direction;
%%          peak_location_vertical --- location for mqd peak value at vertical direction;
%%          SNR --- ratio of peak value of mean value of mqd_matrix;
%%          MMR --- maximum value to mean ratio;
%%          PPr --- ratio between the first peak to the second peak;

function [peak_location_horizontal, peak_location_vertical, SNR, MMR, PPR] = MQD_peak_searching(mqd_matrix, option)

size_x = size(mqd_matrix,1);
size_y = size(mqd_matrix,2);
size_mqd_matrix  = size_x*size_y;
n0 = size(mqd_matrix(~isnan(mqd_matrix)),1);

%% removing unsual value
if ((n0 == 0) || (size_mqd_matrix==0) || (max(max(mqd_matrix))==0))
    peak_location_horizontal = NaN;
    peak_location_vertical = NaN;
    SNR = NaN;
    MMR = NaN;
    PPR = NaN;
    return
end

%% Peak searching with normal way
%% Searching the first peak

peak_location_horizontal = -1;
peak_location_vertical = -1;
f_max = mqd_matrix(1,1);

for iy=1:size_y
    g = mqd_matrix(:,iy);
    [g_max, ig] = max(g);
    
    if (g_max >= f_max)
        f_max = g_max;
        peak_location_horizontal  = ig;
    end
end

f_max = mqd_matrix(1,1);

for ix=1:size_x
    g = mqd_matrix(ix,:);
    [g_max, ig] = max(g);
    
    if (g_max >= f_max)
        f_max = g_max;
        peak_location_vertical  = ig;
    end
end

%% searching the second peak

h = mqd_matrix(peak_location_horizontal,peak_location_vertical);
ip_x0 = peak_location_horizontal;
ip_y0 = peak_location_vertical;

%% peak searching way with Gaussian subpixel way: the gaussian function is given:
%% f(x) = A*exp(-(x0-x)^2/B), it is based on the three point curve fitting
%% the peak value location at horizontal and vertical direction is given seperatly:
%% x0 = 0.5*(lnR(i-1,k)-lnR(i+1,j))/(lnR(i-1,j)-2lnR(i,j)+lnR(i+1,j))
%% y0 = 0.5*(lnR(i,j-1)-lnR(i,j+1))/(lnR(i,j-1)-2lnR(i,j)+2lnR(i,j+1))
if (abs(option) == 2)
    
    if ((peak_location_horizontal == -1) || (peak_location_vertical == -1))
        peak_location_horizontal = NaN;
        peak_location_vertical = NaN;
        return
    end
    
    %% calculating sub-pixel peak value at horizontal position

    g = mqd_matrix(:,peak_location_vertical);
    [h, ih] = max(g);
    g = g/h;
    
    if (ih == 1)
        ix_subpeak = 1;
        
    elseif (ih == size_x)
        ix_subpeak = size_x;
    else
        
        if (g(ih+1)~=0 && g(ih)~=0 && g(ih-1)~=0)
            ix_subpeak = ih-0.5*(log(g(ih+1))-log(g(ih-1)))/(log(g(ih+1))-2*log(g(ih))+log(g(ih-1)));
        else
            ix_subpeak = NaN;
        end
    end
    
    %% calculating sub-pixel peak value at vertical position
    g = mqd_matrix(peak_location_horizontal,:);
    [h, ih] = max(g);
    g = g/h;
    
    if (ih == 1)
        iy_subpeak = 1;
        
    elseif (ih == size_y)
        iy_subpeak = size_y;
    else
        
        if (g(ih+1)~=0 && g(ih)~=0 && g(ih-1)~=0)
            iy_subpeak = ih-0.5*(log(g(ih+1))-log(g(ih-1)))/(log(g(ih+1))-2*log(g(ih))+log(g(ih-1)));
        else
            iy_subpeak = NaN;
        end
    end
    
    ip_x0 = peak_location_horizontal;
    ip_y0 = peak_location_vertical;
    peak_location_horizontal  = ix_subpeak;
    peak_location_vertical  = iy_subpeak;
    
end

%% searching the second peak
%% calculating the maximum value of the first peak

peak_1=h;
g =mqd_matrix;
dia_peak = round(sqrt(3*size_x)/2.5);

lx1 = ip_x0 - dia_peak;
lx2 = ip_x0 + dia_peak;
ly1 = ip_y0 - dia_peak;
ly2 = ip_y0 + dia_peak;

if (lx1 < 1)
    lx1 = 1;
    
elseif (lx2 > size_x)
    lx2 = size_x;
end

if (ly1 < 1)
    ly1 = 1;
    
elseif (ly2 > size_y)
    ly2 = size_y;
end

g(lx1:lx2,ly1:ly2) = 0;
peak_2 = max(max(g));

%% postprocessing
%% calculating the ratio of signal to noise
if (option > 1)
    g = mqd_matrix;
else
    g = mqd_matrix(find(mqd_matrix));
end

if (max(size(g)) > 2)
    f_max = max(max(g));
    f_std = std2(g);
    f_mean = mean2(g);
    f_amean = mean2(abs(g));
else
    f_max = NaN;
    f_std = NaN;
    f_mean = NaN;
    f_amean = NaN;
end

MMR = f_max/f_amean;
SNR = (f_max-f_mean)/f_std;

%% calculating the ratio of peak to peak
if (peak_2~=0)
    PPR = peak_1/peak_2;
else
    PPR = Inf;
end