function [tracks_area, tracks_cumprecip, tracks_meanprecip, tracks_maxprecip, ...
    tracks_velocity_horizontial, tracks_velocity_vertical, center_x, center_y, tracks_convectivepixels] = Timeseries_parameter_rainfield(experimenttracking, ref_threshold)

   tracks_area = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_cumprecip = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_velocity_x = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_velocity_y = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_velocity_horizontial = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_velocity_vertical = zeros(size(experimenttracking,1), size(experimenttracking,2));
   center_x = zeros(size(experimenttracking,1), size(experimenttracking,2));
   center_y = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_meanprecip = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_maxprecip = zeros(size(experimenttracking,1), size(experimenttracking,2));
   tracks_convectivepixels = zeros(size(experimenttracking,1),size(experimenttracking,2));
   conn = database('celldatabase','postgres','ikoiko','Vendor','PostGreSQL');
   selection = strcat('select clusterid, segmentarea, cumulativeprecipitation, ',... 
                      'gravitycenter_x, gravitycenter_y, meanprecipitation, ' ,...
                      'maximumprecipitation, convectivepixels from celldatabase_', ref_threshold);
   curs = exec(conn, selection);
   curs= fetch(curs);
   result = cell2mat(curs.Data);
   %result = curs.data;
   for i = 1:size(experimenttracking,1)
      for j = 1:size(experimenttracking,2)
         if experimenttracking(i,j) == 0
          tracks_area(i,j) = 0;   
          tracks_cumprecip(i,j) = 0;
          tracks_velocity_x(i,j) = 0;
          tracks_velocity_y(i,j) = 0;
          center_x(i,j) = 0;
          center_y(i,j) = 0;
          tracks_meanprecip(i,j) = 0;
          tracks_maxprecip(i,j) = 0;
          tracks_convectivepixels(i,j) = 6000;
         else
          for i1 = 1:size(result,1)
              if (result(i1,1) == experimenttracking(i,j))
                 tracks_area(i,j) = result(i1,2);   
                 tracks_cumprecip(i,j) = result(i1,3);
                 tracks_velocity_x(i,j) = result(i1,4);
                 tracks_velocity_y(i,j) = result(i1,5);
                 center_x(i,j) = result(i1,4);
                 center_y(i,j) = result(i1,5);
                 tracks_meanprecip(i,j) = result(i1,6);
                 tracks_maxprecip(i,j) = result(i1,7);
                 tracks_convectivepixels(i,j) = result(i1,8);
              end
          end
         end
      end
   end
   for i2 = 1:size(experimenttracking,1)-1
       for j2 = 1:size(experimenttracking,2)
           %temp_velocity = ((tracks_velocity_x(i2,j2) -  tracks_velocity_x(i2+1,j2)).^2 + (tracks_velocity_y(i2,j2) -  tracks_velocity_y(i2+1,j2)).^2).^0.5 ./300;
           temp_velocity_horizontial = (center_x(i2+1,j2) - center_x(i2,j2))./300;
           temp_velocity_vertical = (center_y(i2+1,j2) - center_y(i2,j2))./300;
           %temp_direction = mod(90-atan2d((tracks_velocity_y(i2,j2) -  tracks_velocity_y(i2+1,j2)), (tracks_velocity_x(i2,j2) -  tracks_velocity_x(i2+1,j2))),360);
           tracks_velocity_horizontial(i2+1,j2) = temp_velocity_horizontial;
           tracks_velocity_vertical(i2+1,j2) = temp_velocity_vertical;
       end
   end
   
   for i3 = 1:size(experimenttracking,1)
      for j3 = 1:size(experimenttracking,2)
          if(abs(tracks_velocity_horizontial(i3,j3)) > 1000)
             tracks_velocity_vertical(i3,j3) = 0;
             tracks_velocity_horizontial(i3,j3) = 0;         
          end
          %if(tracks_direction(i3,j3) == 90)
          %    tracks_direction(i3,j3) = 0;
          %end
      end
   end   
  %for i4 = 1:size(tracks_velocity,2)
  %   index = find(tracks_velocity(:,i4)>0);
  %   temps_speed = zeros(length(index),1);
  %   temps_direction = zeros(length(index),1);
  %   for i5 = 1:length(index)
  %     temps_speed(i5,1)  = tracks_velocity(index(i5),i4);
  %     temps_direction(i5,1) = tracks_direction(index(i5),i4);
  %   end
  %   [no_direction,xo_direction] = rhist(temps_direction);
  %   frequency = [no_direction', xo_direction'];
  %   ids = frequency(:,1) ==  max(frequency(:,1));
  %   tracks_prevaildirection(1,i4) = frequency(ids,2);
  %   tracks_meanvelocity(1,i4) = mean(temps_speed);
  %end
  %tracks_meanvelocity = tracks_meanvelocity';
  %tracks_prevaildirection = tracks_prevaildirection';