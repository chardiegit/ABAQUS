%% Now in GIT
%% Import data from Abaqus SDV report file
clear all

data_title = 'GMAT Rot thetax';
file='.\GMAT\170818\COORDGMAT.rpt'
%inputfile='.\SDV reader\a1e-3b1.inp'
nCol = 13;
plotx=30;
ploty=20;

% Original GMAT

GMAT=[0.7071 -0.7071 0;0.7071 0.7071 0; 0 0 1];
GMATT=inv(GMAT);

%% Read SDV Report

F = AbaqusReport(file, nCol);

nodes=F(:,1);

for i=1:size(F,1)
    
    xcoord(nodes(i),1) = F(i,2);
    ycoord(nodes(i),1) = F(i,3);
    zcoord(nodes(i),1) = F(i,4);
    SDV1(nodes(i),1)=F(i,5);
    SDV2(nodes(i),1)=F(i,6);
    SDV3(nodes(i),1)=F(i,7);
    SDV4(nodes(i),1)=F(i,8);
    SDV5(nodes(i),1)=F(i,9);
    SDV6(nodes(i),1)=F(i,10);
    SDV7(nodes(i),1)=F(i,11);
    SDV8(nodes(i),1)=F(i,12);
    SDV8(nodes(i),1)=F(i,13);
end

% Select first plane of nodes at x = 0 for cross-section

    nodeplot = F(F(:,2)<1e-5,1);
    xcoord = F(F(:,2)<1e-5,2);
    ycoord = F(F(:,2)<1e-5,3);
    zcoord = F(F(:,2)<1e-5,4);
    SDV1 = F(F(:,2)<1e-5,5);
    SDV2 = F(F(:,2)<1e-5,6);
    SDV3 = F(F(:,2)<1e-5,7);
    SDV4 = F(F(:,2)<1e-5,8);
    SDV5 = F(F(:,2)<1e-5,9);
    SDV6 = F(F(:,2)<1e-5,10);
    SDV7 = F(F(:,2)<1e-5,11);
    SDV8 = F(F(:,2)<1e-5,12);
    SDV9 = F(F(:,2)<1e-5,13);
    
%% Build rotation matrices to check compliance (not needed - temp for checking)

for i=1:size(nodeplot)
    
    R(i, 1,1)=SDV1(i);
     R(i, 1,2)=SDV2(i);
      R(i, 1,3)=SDV3(i);
       R(i, 2,1)=SDV4(i);
        R(i, 2,2)=SDV5(i);
         R(i, 2,3)=SDV6(i);
          R(i, 3,1)=SDV7(i);
           R(i, 3,2)=SDV8(i);
            R(i, 3,3)=SDV9(i);
end

% Rdiff

for i=1:size(nodeplot)
    
    R2D(1:3,1:3)=R(i,1:3,1:3);
    Rdiff(i, 1:3,1:3)=R2D*GMATT;
end

% Rdiff(Rdiff>1)=1;


%% Temporary check

% Check the determinant of each rotation matrix to confirm that it's equal
% to 1:
    for i=1:size(nodeplot)
        
        Rcheck(1:3,1:3)=Rdiff(i,1:3,1:3);
        checkdet(i)=det(Rcheck);
    end
    
%% Get Euler angles:

theta=zeros(size(nodeplot));
phi1=zeros(size(nodeplot));
phi2=zeros(size(nodeplot));

Rdiff(Rdiff>1)=1;

for i=1:size(nodeplot)

if abs(Rdiff(i,3,3))
theta(i,1)=acos(Rdiff(i,3,3));
else
theta(i,1)=0;    
end
if abs(Rdiff(i,3,1)/(Rdiff(i,3,2)*-1))>0
phi1(i,1)=atan(Rdiff(i,1,3)/(Rdiff(i,2,3)*-1));
% if phi1(i,1)<0
%     phi1(i,1)=phi1(i,1)+2*pi();
end

% end

if abs(Rdiff(i,1,3)/(Rdiff(i,2,3)))>0
phi2(i,1)=atan(Rdiff(i,3,1)/(Rdiff(i,3,2))); % atan -> atan2 to ensure correct quadrant
end

thetax(i,1)=atan2(Rdiff(i,3,2),Rdiff(i,3,3));
thetay(i,1)=-1*asin(Rdiff(i,3,1));
thetaz(i,1)=atan2(Rdiff(i,2,1),Rdiff(i,1,1));
end

zcoord=cat(1, zcoord,zcoord);
ycoord=cat(1, ycoord,-1*ycoord);
thetax=cat(1, thetax,-1*thetax);
thetay=cat(1,thetay, thetay);
thetaz=cat(1,thetaz,thetaz*-1);

 SDVplot=thetax;  

% phi2(phi2<-1.5)=(phi2(phi2<-1.5)+pi())*-0.5;
% phi2(phi2>1.5)=(phi2(phi2>1.5)-pi())*-0.5;
% phi1(phi1<-1.5)=(phi1(phi1<-1.5)+pi())*-0.5;
% phi1(phi1>1.5)=(phi1(phi1>1.5)-pi())*-0.5;

% theta(isnan(theta))=0;
% phi1(isnan(phi1))=0;
% phi2(isnan(phi2))=0;

   

% % Get node coordinates from input file
% 
% fid=importdata(inputfile);
% 
% if size(fid.data, 1) == size(nodes, 1)
%     
%     nodeplot = fid.data(fid.data(:,2)==0,1);
%     ycoord = fid.data(fid.data(:,2)==0,3);
%     zcoord = fid.data(fid.data(:,2)==0,4);
%     SDVplot=SDV20(nodeplot);
% else
%     print('Error number of nodes found in SDV output does not match nodes in input file'
% end

    %Create regular grid across data space

    [X,Y] = meshgrid(linspace(min(ycoord),max(ycoord),size(SDVplot,1)), linspace(min(zcoord),max(zcoord),size(SDVplot,1)));

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create surf
surf(X,Y,griddata(ycoord,zcoord,SDVplot,X,Y),'Parent',axes1,'EdgeColor','none');


% Create ylabel
ylabel({'z (µm)'});

% Create xlabel
xlabel({'y (µm)'});

% Create title
title(data_title);

%  X-limits of the axes
xlim(axes1,[-1*plotx plotx]);
% Y-limits of the axes
ylim(axes1,[0 ploty]);

grid(axes1,'on');
axis(axes1,'ij');
% Set the remaining axes properties
set(axes1,'CLim',[min(SDVplot) max(SDVplot)],'DataAspectRatio',[1 1 1],...
    'PlotBoxAspectRatio',[50 50 1]);
% Create colorbar
colorbar('peer',axes1);
colormap jet






