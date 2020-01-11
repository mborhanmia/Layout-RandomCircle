clear all;
close all;
clc;

%% setup CNSTdefaultValues file

% save file name
fname='random_circle';
fname_gds=[fname,'.gds'];                                  % file name
fname_script=[fname,'.cnst'];                              % file name for cnst script

% save folder
fpath='.\layout\';                                         % save your directory for klayout
if (exist(fpath) == 0)
    mkdir (fpath);
end

% open & replace the saving folder
fid=fopen('CNSTdefaultValues.xml','r');
f=fread(fid,'*char')';
fclose(fid);
fs_ind1=strfind(f,'<SaveToDirectory>')+17;
fs_ind2=strfind(f,'</SaveToDirectory>')-1;
f=strrep(f,f(fs_ind1:fs_ind2),fpath);
fid=fopen('CNSTdefaultValues.xml','w');
fprintf(fid,'%s',f);
fclose(fid);
%% geometric parameters
% unit: um
%layout size
xmax=500;
ymax=500;
offx=2;
offy=2;

% circle parameters
rad=1;                                              % circle radius 
angle=0;
min_dis=2*rad+0.3;                                  % center to center distance
%% random points for circle
x = (xmax-offx)*rand(1, 50000);
y = (ymax-offy)*rand(1, 50000);
minAllowableDistance = min_dis;
numberOfPoints = 50000;
% Initialize first point.
keeperX = x(1);
keeperY = y(1);
% Try dropping down more points.
counter = 2;
for k = 2 : numberOfPoints
  % Get a trial point.
  thisX = x(k);
  thisY = y(k);
  % See how far is is away from existing keeper points.
  distances = sqrt((thisX-keeperX).^2 + (thisY - keeperY).^2);
  minDistance = min(distances);
  if minDistance >= minAllowableDistance
    keeperX(counter) = thisX;
    keeperY(counter) = thisY;
    counter = counter + 1;
  end
end

%% layout generation - cnst file
% open cnst file
fileID = fopen(fname_script,'w');
fprintf(fileID,'0.001 gdsReso\n');
fprintf(fileID,'0.001 shapeReso\n\n');
%center waveguide and ring
fprintf(fileID,'<random_circle struct>\n\n\n');
for k=1:length(keeperX)
fprintf(fileID,'1 layer\n');
fprintf(fileID,[num2str(keeperX(k)),' ',num2str(keeperY(k)),' ',num2str(rad),' ',num2str(rad),' ',num2str(angle),' ellipseVector\n\n']);

end
fprintf(fileID,'4 layer\n');
fprintf(fileID,[num2str(0),' ',num2str(0),' ',num2str(xmax),' ',num2str(ymax),' ',num2str(angle),' rectangleLH\n\n\n']);

%marker 
xm=500;
ym=500;
anglem=0;
L=10;
for k=1:2
fprintf(fileID,'6 layer\n');
fprintf(fileID,[num2str((k-1)*(xm-L)),' ',num2str(0),' ',num2str(L),' ',num2str(L),' ',num2str(anglem),' rectangleLH\n']);
fprintf(fileID,[num2str((k-1)*(xm-L)),' ',num2str(ym-L),' ',num2str(L),' ',num2str(L),' ',num2str(anglem),' rectangleLH\n']);

end

fprintf(fileID,'8 layer\n');
fprintf(fileID,['<{{Random Circles' '}}',' ','{{Arial}}',' ',num2str(12),' ',num2str(xmax/2),' ',num2str(ymax*1.03),' ','textgdsC>\n\n']);


fclose(fileID);
%% generate layout

% run the java code from matlab
[status,cmdout] = dos(join(['java -jar CNSTNanolithographyToolbox.jar cnstscripting ',fname_script,' ',fname]));
status, cmdout

% % % run klayout code from matlab
[status,cmdout] = dos(join(['"C:\Software\klayout\klayout" ' fpath,'/',fname]));
status, cmdout



