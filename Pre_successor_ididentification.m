%% The function for identifying the time chain of rain clusters.
%% Output of this function is the id rain cluster which orgnaized with parent/child rain cluster.

%% Inputs:    presurssor_successor_id --- id of child rain cluster at former moment or next moment,
%%                                                           which is generated from the relational database, 
%%                                                           the form this input variable is a 2-D matrix, the first cloumn is rain cluster id,
%%                                                           the second column is its parent/child rain cluster's id
%%                cellid --- id of rain cluster;

%% Outputs: precursor_successor --- the unique id of rain cluster, which is a 2-D matrix,
%%                                                      if the input is the id of rain cluster with its parent rain clusters, 
%%                                                      then the output is the unique id of rain cluster which contains id of its parent rain cluster,
%%                                                      if the input is the id of rain cluster with its child rain clusters,
%%                                                      then the output is the unique id of rain cluster which contains id of its child rain cluster.

function precursor_successor = Pre_successor_ididentification(precursor_successor_id, cellid)
precursor_successor_id(precursor_successor_id(:,2) == 0,:) = [];
ids = unique(precursor_successor_id(:,1));
index = cell([1, length(ids)]);
index_1 = cell([1, length(ids)]);
index_2 = zeros(1, length(ids));
for i5 = 1:length(ids)
    
    index{i5} = find(precursor_successor_id(:,1) == ids(i5));
end
index = index';
for j5 = 1:length(ids)
    if(length(index{j5,1}) >1)
        temps = zeros(1,length(index{j5,1}));
        for i6 = 1:length(index{j5,1})
            temps(1,i6) = precursor_successor_id(index{j5,1}(i6,1),2);
            index_1{j5} = unique(temps);
        end
    end
    if(length(index{j5,1}) ==1)
        index_1{j5} = precursor_successor_id(index{j5,1},2);
    end
    index_2(1,j5) = length(index_1{j5});
end
index_1 = index_1';
index_3 = zeros(length(ids), max(index_2));


for j1 = 1:length(ids)
    if(length(index_1{j1,1}) >1)
        index_3(j1,1:length(index_1{j1,1})) = index_1{j1,1};
    end
    if(length(index_1{j1,1})==1)
        index_3(j1,1) = index_1{j1,1};
    end
end

precursor_successor = zeros(length(cellid),max(index_2)+1);
precursor_successor(:,1) = cellid;
for i = 1:length(cellid)
    for i1 = 1:length(ids)
        if(ids(i1) == cellid(i))
            precursor_successor(i,2:max(index_2)+1) = index_3(i1,:);
        end
    end
end