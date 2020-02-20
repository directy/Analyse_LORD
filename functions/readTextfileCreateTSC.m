function [ tsc ] = readTextfileCreateTSC( file, Delimiter, startHeader )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

clc

disp(['read Texfile from: ' file]);

%% Lese Header aus
disp('read Header...');
fileID = fopen(file,'r');

for idHeader=1:startHeader
    HeaderString = fgetl(fileID); 
end

% count delimiter + 1 --> count elements
cntElements = size(strfind(HeaderString,Delimiter),2) + 1;

end_loop = cntElements;

header=strsplit(HeaderString,Delimiter);

disp('adjust Header...');
for idHeader=1:size(header,2)
   temp = strsplit(header{idHeader},':');
   % avoid double valid-vectors
   if strcmp(temp(end),'valid')
       temp = [temp{end-1} '-' temp{end}];
       header{idHeader} = temp;
       disp(temp);
   else
       header(idHeader) = temp(end);
        disp(temp(end));
   end     
end

%% Daten auslesen

disp('read date...');
formatSpec = '';

for idx=1:end_loop+1
    formatSpec = [formatSpec '%s'];
end
temp_data = textscan(fileID,formatSpec,'Delimiter',Delimiter);

Y_elements = size(temp_data{1},1);
data = zeros(Y_elements,cntElements);

for idy=1:Y_elements
    %temp = strsplit(temp_data{1}{idy},Delimiter); 
    for idx=1:cntElements
        %% ersetzt ',' durch '.'
        str = strrep(temp_data{idx}{idy}, ',' , '.');
        data(idy,idx)= str2double(str);
    end  
end
 
%% create time Vector

disp('create Time Vector...');
timeVector = zeros(Y_elements,1);
timeFormat = 'dd-mm-yyyy HH:MM:SS:FFF';
timeVector(1)= 0 ;

for idy=2:Y_elements
  %etime(t2,t1)
    time_diff = etime(datevec(datenum(temp_data{1}{idy})),...
                              datevec(datenum(temp_data{1}{idy-1})));                           
    timeVector(idy) = timeVector(idy-1) + time_diff;                    
end

startTime=datestr(datenum(temp_data{1}{1}),timeFormat);
endTime=datestr(datenum(temp_data{1}{end}),timeFormat);

disp(['StartTime :' startTime])
disp(['EndTime :' endTime])

%% create timeseries-objects
disp('create TimeSeriesCollection...');
for idx=2:cntElements

% removing missing items
    tempData= data(:,idx);
    % create help table
    helpTable = table(tempData,timeVector);
    % remove NAN
    helpTable = rmmissing(helpTable);
    
    if isempty(helpTable)
        continue
    end 
    
    %create timeseries
    ts_help = timeseries(helpTable.tempData,helpTable.timeVector,'Name',header{idx});
    ts_help.TimeInfo.Units='seconds';
    ts_help.TimeInfo.StartDate=temp_data{1}{1};
    % resample timeseries with old timeVector
    ts_help=resample(ts_help,timeVector);
    
    % last NANs to zero 
    ts_help.Data(isnan(ts_help.Data)) = 0;

    if idx == 2 % first run
        tsc = tscollection(ts_help);
    else
        tsc = addts(tsc,ts_help);
        %header{idx};
    end
    
end
   
disp(['duration:' tsc.TimeInfo.End])
disp('-finished-');

end

