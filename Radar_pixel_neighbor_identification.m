%% This function is used to generate the neighbor pixels for pixel which is contained in radar image
%% this m file is based on Wolfgang Schwanghart (http://www.mathworks.com/matlabcentral/fileexchange/16991-neighbor-indexing)
%% Inputs: raw_radar_image --- Original radar images
%% Outputs: neighbor_pixels --- pixel matrix which contains pixel's neighbor pixels, for each column:
%%                              1. neighbor pixel on the right side
%%                              2. neighbor pixel on the down side
%%                              3. neighbor pixel on the left side
%%                              4. neighbor pixel on the up side
%%                              5. neighbor pixel on the up-right side
%%                              6. neighbor pixel on the up-left side
%%                              7. neighbor pixel on the down-right side
%%                              8. neighbor pixel on the dowm-left side
%%                              9. pixel

function neighbor_pixels = Radar_pixel_neighbor_identification(raw_radar_image)

X = raw_radar_image;

siz = size(X);
nrc = siz(1)*siz(2);
In  = isnan(X);

if nargin==1
    method = 'getall';
elseif nargin==2
    ix = raw_radar_image;
    if islogical(ix)
        if size(X) ~= size(ix)
            error('if I is logical I and X must have same size')
        end
    else
        ixvec = ix(:);
        ix = false(siz);
        ix(ixvec) = true;
    end
    ix = ~In & ix;
    method = 'getsome';
else
    error('wrong number of input arguments')
end

% replace values in X by index vector
X   = reshape((1:nrc)',siz);
X(In) = NaN;

% Pad array ........
ic  = nan(siz(1)+2,siz(2)+2);
ic(2:end-1,2:end-1) = X;
%ic(1)
switch method
    case 'getall'
        I   = ~isnan(ic);
    case 'getsome'
        % Pad logical array
        I = false(siz(1)+2,siz(2)+2);
        I(2:end-1,2:end-1) = ix;
end

icd = zeros(nnz(I),8);
neighbor_matrix = zeros(siz(1)*siz(2), 9);
% Shift logical matrix I across the neighbors
icd(:,1) = ic(I(:,[end 1:end-1]));                        % shift to the right
icd(:,2) = ic(I([end 1:end-1],:));                        % shift down
icd(:,3) = ic(I(:,[2:end 1]));                               % shift left
icd(:,4) = ic(I([2:end 1],:));                               % shift up
icd(:,5) = ic(I([2:end 1],[end 1:end-1]));           % shift up and right
icd(:,6) = ic(I([2:end 1],[2:end 1]));                  % shift up and left
icd(:,7) = ic(I([end 1:end-1],[end 1:end-1]));    % shift down and right
icd(:,8) = ic(I([end 1:end-1],[2:end 1]));           % shift down and left

% Create output
ic = repmat(ic(I(:)),8,1);
neighbor_matrix(1:siz(1)*siz(2),1) = ic(1:siz(1)*siz(2),1);
neighbor_matrix(1:siz(1)*siz(2),2:9) = icd(:,1:8);
neighbor_pixels = nan(siz(1)*siz(2),9);
X = reshape(raw_radar_image, siz(1)*siz(2), 1);
tt = neighbor_matrix(:,2:9);
tt(isnan(tt)) = 0;
for t = 1:siz(1)*siz(2)
    neighbor_pixels(t,1) = X(t,1);
    for k = 2:9
        if(tt(t,k-1) > 0)
            neighbor_pixels(t,k) = X(tt(t,k-1));
        end
    end
end