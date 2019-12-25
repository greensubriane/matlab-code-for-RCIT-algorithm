%% post-process for the identified mostlikely child rain cluster,
%% the overlap of rain cluster and maximum speed between center of mass for two consecutive time-step's rain clusters
%% are used for eliminated the child rain clusters which are unusual

%% Inputs: clusterdatabse --- 2-D matrix which contains the parent rain cluster and its most matched child rain cluster;
%%         cellid --- the id of parent rain cluster;
%%         speed_threhold --- the speed threshold for eliminating unusal child rain cluster;
%%         overlap_threshold --- the overlap threshold for eliminating unusal child rain cluster;

%% Outputs: resultss --- 2-D matrix which contains the parent rain cluster and its most matched child rain cluster after post-process;

function resultss = Post_process_most_matched_child_rain_cluster(clusterdatabase, cellid, speed_threshold, overlaps, ref_threshold, date)

%% reading rain clusters which stored in the relational database (the second and the third parameters of database function can be set by user themselves)
conn = database('celldatabase','postgres','ikoiko','Vendor','PostGreSQL');
selection_1 = strcat('select celltracking_', date, '_', ref_threshold, '_1.successor_x, celltracking_', date, '_', ...
                  ref_threshold, '_1.successor_y,cell_', date, '_', ref_threshold, '.cellid from celltracking_', ...
                  date, '_', ref_threshold, '_1, cell_', date, '_', ref_threshold, ' where (cell_', ...
                  date, '_', ref_threshold, '.center_x = celltracking_', date, '_', ref_threshold, ... 
                  '_1.successor_x and cell_', date, '_', ref_threshold, '.center_y = celltracking_', date, '_', ref_threshold, '_1.successor_y)');

curs = exec(conn, selection_1);
curs= fetch(curs);
datawithsuccessorid = cell2mat(curs.Data);
selection_2 = strcat('select cell_', date, '_', ref_threshold, '.cellid from cell_', date, '_', ref_threshold, ... 
    ', celltracking_', date, '_', ref_threshold, '_1 where (celltracking_', date, '_', ref_threshold, '_1.center_x  = cell_', date, ...
    '_', ref_threshold, '.center_x',...
    ' and celltracking_', date, '_', ref_threshold, '_1.center_y = cell_', date, '_', ref_threshold, '.center_y)');
curs1 = exec(conn, selection_2);
curs1 = fetch(curs1);
selection_3 = strcat('select clusterid, segmentarea from celldatabase_', ref_threshold);
curs2 = exec(conn, selection_3);
curs2 = fetch(curs2);
area = cell2mat(curs2.Data);
celltrackingid = cell2mat(curs1.Data);
speed = zeros(size(clusterdatabase, 1),1);

%% starting the main process
for i1 = 1:size(clusterdatabase, 1)
    if(clusterdatabase(i1,3) > 0)
        speed(i1,1) = floor(((clusterdatabase(i1,1) - clusterdatabase(i1,3)).^2 + (clusterdatabase(i1,2) - clusterdatabase(i1,4)).^2).^0.5 ./300);
    end
end

%overlap_threshold = 0.16;
celltracking = [celltrackingid, clusterdatabase(:,1), clusterdatabase(:,2), datawithsuccessorid, speed, clusterdatabase(:,5)];
potentialsuccessornumber = tabulate(celltracking(:,1));
potentialsuccessornumber(potentialsuccessornumber(:,2) <=1,:) = [];
potentialsuccessornumber = potentialsuccessornumber(:,1);

for i5 = 1:size(celltracking,1)
    for j = 1:size(potentialsuccessornumber,1)
        
        if((celltracking(i5,1) == potentialsuccessornumber(j,1))&&(celltracking(i5,8) <= overlaps))
            celltracking(i5,4) = 0;
            celltracking(i5,5) = 0;
            celltracking(i5,6) = 0;
            celltracking(i5,7) = 0;
            celltracking(i5,8) = 0;
        end
    end
end

celltracking(celltracking(:,1) == 0, :) = [];
result = celltracking(:,1:8);

celltracking_1 = [result(:,1), result(:,6)];
potentialprecursornumbers = tabulate(celltracking_1(:,2));
potentialprecursornumbers(potentialprecursornumbers(:,1) == 0, :) = [];
potentialprecursornumbers(potentialprecursornumbers(:,2) <=1,:) = [];
potentialprecursornumbers = potentialprecursornumbers(:,1:2);

for i2 = 1:size(celltracking_1,1)
    for j2 = 1:size(potentialprecursornumbers,1)
        if((result(i2,6) == potentialprecursornumbers(j2,1))&&(result(i2,8) <= overlaps))
            result(i2,4) = 0;
            result(i2,5) = 0;
            result(i2,6) = 0;
            result(i2,7) = 0;
            result(i2,8) = 0;
        end
    end
end

result(result(:,1) == 0, :) = [];
results = result(:,1:8);
indexs = find(results(:,8) <= overlaps);

for i3= 1:length(indexs)
    results(indexs(i3), 4:8) = zeros(1,5);
end

resultss = [results, zeros(size(results,1),2)];

for j3 = 1:size(results,1)
    for i4 =  1:size(area,1)
        if(results(j3,6) == area(i4,1))
            resultss(j3,size(resultss,2)) = area(i4,2);
        end
        if(results(j3,1) == area(i4,1))
            resultss(j3,size(resultss,2)-1) = area(i4,2);
        end
    end
end

index = cell([1, size(cellid)]);

for i5 = 1:size(cellid)
    index{i5} = find(resultss(:,1) == cellid(i5));
end

index = index';
for j5 = 1:size(cellid)
    
    if(length(index{j5,1}) >1)
        area_difference = zeros(length(index{j5,1}), 1);
        instancespeed = zeros(length(index{j5,1}), 1);
        
        for i6 = 1:length(index{j5,1})
            area_difference(i6,1) = abs(resultss(index{j5,1}(i6,1),size(resultss,2)-1) - resultss(index{j5,1}(i6,1),size(resultss,2)));
            instancespeed(i6,1) = resultss(index{j5,1}(i6,1),size(resultss,2)-3);
        end
        
        for j6 = 1:length(index{j5,1})
            if((area_difference(j6,1) ~= min(area_difference))&&(instancespeed(j6,1) > speed_threshold))
                resultss(index{j5,1}(j6,1),size(resultss,2)-6:size(resultss,2)-2) = zeros(1,5);
                resultss(index{j5,1}(j6,1),size(resultss,2)) = 0;
            end
        end
    end
    
    if(length(index{j5,1}) == 1)
        if((resultss(index{j5,1},8) <= overlaps) && (resultss(index{j5,1},7) > speed_threshold))
            resultss(index{j5,1},size(resultss,2)-6:size(resultss,2)-2) = zeros(1,5);
            resultss(index{j5,1},size(resultss,2)) = 0;
        end
    end
end