%% This function is for generating rain cluster trajectories based on the output from
%% function Unique_raincluster_identification

%%  Inputs: precursor --- unique id of rain cluster which contains its parent rain clusters;
%%          cellid --- id of rain cluster;
%%          successor --- unique id of rain clutser which contains its child rain clusters;
%%          timelength --- number of radar images, the default value is 288.

%%  Outputs: tracks --- trajectories of rain clusters which are presented by id of rain clutser,
%%                      this output is orgnized as a 2-D matrix where each column is represented the identified trajectory.

function tracks = Trajectory_generation(precursor, cellid, successor,timelength)

precursor = precursor(:,2:size(precursor,2));
successor = successor(:,2:size(successor,2));

rowdata = [precursor, cellid, successor];
%% if the cellid is zero, then the corresponded precursor and successor id are set to zero
for i = 1:size(cellid,1)
    if(sum(rowdata(i,:)) == rowdata(i,(size(precursor,2)+1)))
        rowdata(i,1:size(rowdata,2)) = zeros(1,size(rowdata,2));
    end
end

%% eliminating the row with cellid being zero
rowdata(rowdata(:,(size(precursor,2)+size(cellid,2))) == 0,:) = [];

lengths = 0;
temp_indexes = cell([size(precursor,2)-1,1]);

for m = 1:size(precursor,2)-1
    if(size(precursor,2)>2)
       temp_value = rowdata(:,size(precursor,2)+m-2);
    else
       temp_value = rowdata(:,size(precursor,2)-m+1);
    end
    temp_index = find(temp_value(:,1)>0);
    temp_indexes{m} = temp_index;
    lengths = lengths + length(temp_index);
end

rowdata_1 = zeros(size(rowdata,1) + lengths,size(rowdata,2));

for i1 = 1:size(rowdata,1)
    rowdata_1(i1,1) = rowdata(i1,1);
    rowdata_1(i1,(size(precursor,2)+size(cellid,2)):size(rowdata,2)) = rowdata(i1,(size(precursor,2)+size(cellid,2)):size(rowdata,2));
end

lengths_3 = 0;
%id1 = cellfun('length', temp_indexes);
%temp_indexes(id1==0)=[];
for n = 1:size(precursor,2)-1
    if (n == 1)
        for temp_i = 1:length(temp_indexes{n})
            rowdata_1(size(rowdata,1)+temp_i,1) = rowdata(temp_indexes{n}(temp_i,1),n+1);
            rowdata_1(size(rowdata,1)+temp_i,(size(precursor,2)+size(cellid,2)):size(rowdata,2)) =...
            rowdata(temp_indexes{n}(temp_i,1),(size(precursor,2)+size(cellid,2)):size(rowdata,2));
        end
    end
    if (n >1)
        lengths_3 = lengths_3+length(temp_indexes{n-1});
        for temp_i = 1:length(temp_indexes{n})
            rowdata_1(size(rowdata,1)+lengths_3+temp_i,1) = rowdata(temp_indexes{n}(temp_i,1),n+1);
            rowdata_1(size(rowdata,1)+lengths_3+temp_i,(size(precursor,2)+size(cellid,2)):size(rowdata,2)) =...
            rowdata(temp_indexes{n}(temp_i,1),(size(precursor,2)+size(cellid,2)):size(rowdata,2));
        end
    end
end

rowdata_2 = [rowdata_1(:,1), rowdata_1(:,(size(precursor,2)+size(cellid,2)):size(rowdata,2))];
temp3 = rowdata_2;
rowdata_2(rowdata_2(:,1) > 0,:) = [];

lengths_4 = 0;
temp_indexes_2 = cell([size(successor,2)-1,1]);

for m = 1:size(successor,2)-1
    if(size(successor,2)>2)
       temp_value = rowdata_2(:,size(rowdata_2,2)+m-2);
    else
       temp_value = rowdata_2(:,size(rowdata_2,2)-m+1);
    end
    temp_index = find(temp_value(:,1)>0);
    temp_indexes_2{m} = temp_index;
    lengths_4 = lengths_4 + length(temp_index);
end

temp_5 = zeros(size(rowdata_2,1)+lengths_4,3);

for ii = 1:size(rowdata_2,1)
    temp_5(ii,1) = rowdata_2(ii,1);
    temp_5(ii,2) = rowdata_2(ii,2);
    temp_5(ii,3) = rowdata_2(ii,3);
end

lengths_5 = 0;
%id = cellfun('length', temp_indexes_2);
%temp_indexes_2(id == 0) = [];
for n = 1:size(successor,2)-1  
    if (n == 1)
        for index_id = 1:length(temp_indexes_2{n})
            temp_5(size(rowdata_2,1)+index_id,1) = rowdata_2(temp_indexes_2{n}(index_id,1),1);
            temp_5(size(rowdata_2,1)+index_id,2) = rowdata_2(temp_indexes_2{n}(index_id,1),2);
            temp_5(size(rowdata_2,1)+index_id,3) = rowdata_2(temp_indexes_2{n}(index_id,1),size(rowdata_2,2));
        end
    end
    if (n > 1)
        lengths_5 = lengths_5 + length(temp_indexes_2{n-1});
        for index_id = 1:length(temp_indexes_2{n})
            temp_5(size(rowdata_2,1)+lengths_5+index_id,1) = rowdata_2(temp_indexes_2{n}(index_id,1),1);
            temp_5(size(rowdata_2,1)+lengths_5+index_id,2) = rowdata_2(temp_indexes_2{n}(index_id,1),2);
            temp_5(size(rowdata_2,1)+lengths_5+index_id,3) = rowdata_2(temp_indexes_2{n}(index_id,1),size(rowdata_2,2)-n+1);
        end
    end
end

rowdata_3 = temp3;
rowdata_3(rowdata_3(:,1) == 0,:) = [];

%% connecting successors by their cellids at different moments
lengths_1 = 0;
temp_indexes_1 = cell([size(successor,2)-1,1]);

for m = 1:size(successor,2)-1
    if(size(successor,2)>2)
      temp_value = rowdata_3(:,size(rowdata_3,2)+m-2); 
    else
      temp_value = rowdata_3(:,size(rowdata_3,2)-m+1); 
    end
    temp_index = find(temp_value(:,1)>0);
    temp_indexes_1{m} = temp_index;
    lengths_1 = lengths_1 + length(temp_index);
end

rowdata_4 = zeros(size(rowdata_3,1)+lengths_1,3);

for i6 = 1:size(rowdata_3,1)
    rowdata_4(i6,1) = rowdata_3(i6,1);
    rowdata_4(i6,2) = rowdata_3(i6,2);
    rowdata_4(i6,3) = rowdata_3(i6,3);
end

lengths_2 = 0;
%id2 = cellfun('length', temp_indexes_1);
%temp_indexes_1(id2 ==0) = [];
for n = 1:size(successor,2)-1
    if (n == 1)
        for index_id = 1:length(temp_indexes_1{n})
            rowdata_4(size(rowdata_3,1)+index_id,1) = rowdata_3(temp_indexes_1{n}(index_id,1),1);
            rowdata_4(size(rowdata_3,1)+index_id,2) = rowdata_3(temp_indexes_1{n}(index_id,1),2);
            rowdata_4(size(rowdata_3,1)+index_id,3) = rowdata_3(temp_indexes_1{n}(index_id,1),size(rowdata_3,2));
        end
    end
    if (n > 1)
        lengths_2 = lengths_2 + length(temp_indexes_1{n-1});
        for index_id = 1:length(temp_indexes_1{n})
            rowdata_4(size(rowdata_3,1)+lengths_2+index_id, 1) = rowdata_3(temp_indexes_1{n}(index_id,1),1);
            rowdata_4(size(rowdata_3,1)+lengths_2+index_id, 2) = rowdata_3(temp_indexes_1{n}(index_id,1),2);
            rowdata_4(size(rowdata_3,1)+lengths_2+index_id, 3) = rowdata_3(temp_indexes_1{n}(index_id,1),size(rowdata_3,2)-n+1);
        end
    end
end

%% generating trajectory matrix
tracks = zeros(timelength, size(rowdata_4,1));
tracks(1,1:size(temp_5,1)) = temp_5(:,1)';
tracks(2,1:size(temp_5,1)) = temp_5(:,2)';
tracks(3,1:size(temp_5,1)) = temp_5(:,3)';

for t = 4:timelength
    for i9 = 1:size(rowdata_4,1)
        value = tracks(t-1,i9);
        value_1 = tracks(t-2, i9);
        temps_9 = find(tracks(t-1,:) == value);
        temps_10 = find(tracks(t-2,:) == value_1);
        temps_tracks  = intersect(temps_9,temps_10);
        temps_8 = find(rowdata_4(:,1) == value_1);
        temps_11 = find(rowdata_4(:,2) == value);
        temps_rowdata = intersect(temps_8, temps_11);
        remvalue = rem(length(temps_tracks), length(temps_rowdata));
        if(remvalue == 0)
            for iiii = 1:(length(temps_tracks)/length(temps_rowdata))
                for iii = 1:length(temps_rowdata)
                    tracks(t,temps_tracks(1,iii+iiii-1)) = rowdata_4(temps_rowdata(iii,1),3);
                end
            end
        end
        
        if(length(temps_rowdata) > length(temps_tracks))
            addedvalue = zeros(timelength,length(temps_rowdata)-length(temps_tracks));
            for i10 = 1:size(addedvalue,2)
                addedvalue(:,i10) = tracks(:,i9);
            end
            T = sum(tracks);
            lengths = length(find(T ~= 0));
            tracks = [tracks(:,1:lengths), addedvalue, zeros(timelength, (size(rowdata_4,1)-lengths-size(addedvalue,2)))];
            index9 = find(tracks(t-1,:) == value);
            index10 = find(tracks(t-2,:) == value_1);
            index_tracks = intersect(index9, index10);
            for i11 = 1:length(index_tracks)
                tracks(t,index_tracks(1,i11)) = rowdata_4(temps_rowdata(i11,1),3);
            end
        end
        
        if((length(temps_rowdata) > 1) && (length(temps_rowdata) < length(temps_tracks)))
            addedvalue_1 = zeros(length(temps_tracks)-length(temps_rowdata), size(rowdata_4,2));
            
            for i13 = 1: size(addedvalue_1,1)
                addedvalue_1(i13,1) = value_1;
                addedvalue_1(i13,2) = value;
            end
            
            rowdata_4_1 = [rowdata_4;addedvalue_1];
            index13 = find(rowdata_4_1(:,1) == value_1);
            index14 = find(rowdata_4_1(:,2) == value);
            temps_rowdata_1 = intersect(index13, index14);
            
            for i12 = 1:length(temps_tracks)
                tracks(t,temps_tracks(1,i12)) = rowdata_4_1(temps_rowdata_1(i12,1),3);
            end
        end
        
        if((length(temps_rowdata) ==1) && (length(temps_rowdata) < length(temps_tracks)))
            for i14 = 1:length(temps_tracks)
                tracks(t,temps_tracks(1,i14)) = rowdata_4(temps_rowdata,3);
            end
        end
    end
end
tracks(:,tracks(2,:)==0) = [];

tracks_1 = tracks';
tracks_1(:,sum(tracks_1(:,1))==0) = [];
tracks = tracks_1';