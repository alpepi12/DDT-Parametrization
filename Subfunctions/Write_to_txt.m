
% Function writes a set of lines of text to a specified text file in Equations folder
% string_array: array of string to write, each cell is a new line (no need for newline character)
% file_name: file name + extension of file to write
% extra_dir: additional sub folder
function Write_to_txt(string_array, file_name, extra_dir, append_flag)

if ~exist('extra_dir','var')
    extra_dir = "";
else
    extra_dir = strcat(extra_dir, "\");
end

if exist('append_flag','var') %if we append
    append = true;
else
    append = false;
end
    
%Get working directory
    drive = pwd; %Get working directory drive
    drive = extractBefore(drive, "\groupDDT1");


file_location = strcat(drive, "\groupDDT1\Solidworks\Equations\", extra_dir, file_name);

[n,~] = size(string_array); %get amount of lines

if (append == true)
    fid = fopen(file_location,'a+t'); %Open txt file and overwrite
else
    fid = fopen(file_location,'w+t'); %Open txt file and overwrite
end



for i = 1:n %For each text line
    fprintf(fid, strcat(string_array(i), " \n")); %Write each line 
end
fclose(fid);

end