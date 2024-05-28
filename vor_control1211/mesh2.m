clc;clear all;clf;close all;

x=0:0.01:1;
y=0:0.01:1;
[X,Y]=meshgrid(x,y);
sigma = 0.1;
tho1 = 0.02;
s=[0.5,0;0.57,0;0.47,1;1,0.67;1,0;1,1];
v=[-0.2,0.2;0,0.283;-0.2,-0.2;-0.2,-0.2;-0.2,0.2;-0.2,-0.2]*10^-2;
a=[];
for i = 1:length(s)
    Z{i} = tho1+exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
    
%     surf(X, Y, Z{i},'edgecolor','none');
%     shading interp
%     view(2);
%     hold on
end
m = sum(Z{i});

colormap(flipud(gray(256)));
colorbar;

for t=1:150
    clf;
    s=s+v;
    for i = 1:length(s)
        Z{i} = tho1+exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
        
        surf(X, Y, Z{i},'edgecolor','none');
        shading interp
        view(2);
        hold on
    end
    
    colormap(flipud(gray(256)));
    colorbar;
    M(t) = getframe;
end
