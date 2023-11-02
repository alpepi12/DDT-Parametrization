% Function adds a set of lines add the end of the log file
% string_array: array of string to write, each cell is a new line (no need for newline character)
function Append_to_log(string_array)

    %Get working directory
    drive = pwd; %Get working directory drive
    drive = extractBefore(drive, "\groupDDT1");


[n,~] = size(string_array); %get amount of lines
file_location = strcat(drive,'\groupDDT1\Log\groupDDT1_LOG.TXT');

fid = fopen(file_location,'a+t'); %Open txt file and append

for i = 1:n %For each text line
    fprintf(fid, strcat(string_array(i), " \n")); %Write each line 
end

fprintf(fid, "\n"); %Extra line after
fclose(fid);

end