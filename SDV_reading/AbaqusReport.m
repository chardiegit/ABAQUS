function F = AbaqusReport(file, nCol) %CDH changed from dimensios to nCol 26/07/18
% Reads in an abaqus report file

% Open the file for reading
fid = fopen(file);


% Read a line at a time until a line starting with *Node is found
line = fgetl(fid);
while (strncmp(repmat('-',1,10),line,10) == 0)
    line = fgetl(fid);
end

% Scan in repeating groups of node number and sufficient coordinates

% nCol = 4;% 12 %dimensions*3+3;
%fmt = strjoin({'%d',repmat('%f', 1, nCol-1)}); 
fmt = ['%d',repmat('%f', 1, nCol-1)]; 
% for eacht field pt [nodeNum, T, U, VMS] = F[4]
F = fscanf(fid, fmt, [nCol Inf]);
F = F';



% Read a line at a time until a line starting with *Element is found
% line = fgetl(fid);
% while (strncmp('*Element',line,8) == 0)
%     line = fgetl(fid);
% end
% 
% % Scan in repeating groups of element number and sufficient nodes
% sizeELEMENTS = [1+nodes_per_element Inf];
% fmt = strjoin({'%d',repmat(',%d', 1, nodes_per_element)});
% nc0 = fscanf(fid, fmt, sizeELEMENTS);
% nc0 = nc0';
% 
% nc = nc0(:,2:end);

fclose(fid);
end 

