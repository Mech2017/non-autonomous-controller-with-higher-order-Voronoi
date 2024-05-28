clc;clear all;clf;close all;
N = 5; % number of generators
% x = [2,3,4.5,5,7,8,9,1,6,4]
% y = [6,2,9,4.5,5.5,9,8,7,1,3]

x = double.empty(0,N);
y = double.empty(0,N);
W = double.empty(0,N);
for k=1:N
    x(k) = rand*10;
    y(k) = rand*10;
    W(k) = 1;
end
[WW,sortIndex]= sort(W);
sx = x(sortIndex);
sy = y(sortIndex);
% sx = x;
% sy = y;
h = 10; % length of y coordinate
w = 10; % length of x coordinate

f2=figure;
plot(sx,sy,'r*')
axis([0 h 0 w]);

for i = 1:N-1
    for j = i+1:N

        ei=sx(i)^2+sy(i)^2;
        ej=sx(j)^2+sy(j)^2;
        be=WW(j)-WW(i);
        cp=(ej-ei-be)/2; 
        ap=sx(j)-sx(i);
        bp=sy(j)-sy(i);
        slope=-ap/bp;
        b=cp/bp;
        d1=(sx(i)-sx(j))^2+(sy(i)-sy(j))^2; % distance (i,j)
        
        if b>0 && b<h % start point of bisector is (0,b) if intercept is larger than 0 and smaller than height
          x0=0;
          y0=b;
        
        else
            if slope>0 % start point of bisector is (-b/slope,0) if slope is positive and intercept is out of screen
                x0=-b/slope;y0=0;

            else % start point of bisector is (-b/slope,0) if slope is negative and intercept is out of screen
                x0=(h-b)/slope;
                y0=h;
          
            end
        end
        
        yy=slope*w+b; % value of y at the x=w
        if yy>0 && yy<h %in this condition end point of the bisector is at (w,yy)
          xa1=w;
          ya1=yy;
        
        else
            if slope>0
                xa1=(h-b)/slope;
                ya1=h;
                
            else
                xa1=-b/slope;
                ya1=0;
            end
        end
        
        l=1; %store the leftmost point of bisector(i,j)
        kx = double.empty(0,100);
        ky = double.empty(0,100);

        kx(l)=x0;
        ky(l)=y0;
%         diffx1 = sx(j)-sx(i);
%         diffy1 = sy(j)-sy(i);
        
        for k=1:N
            if k~=i && k~=j
                ek=sx(k)^2+sy(k)^2;
                be2=WW(k)-WW(i);
                cp2=(ek-ei-be2)/2;
                ap2=sx(k)-sx(i);
                bp2=sy(k)-sy(i);
                slope3=-ap2/bp2;
                b2=cp2/bp2;
                d2=(sx(i)-sx(k))^2+(sy(i)-sy(k))^2;

                y20=slope3*x0+b2;
                y21=slope3*xa1+b2;
                diff0=y0-y20;
                diff1=ya1-y21;

                if diff0*diff1<=0
                    l=l+1;
                    kx(l)=(b2-b)/(slope-slope3);
                    ky(l)=slope*kx(l)+b;
                end    
            end
        end
        
        l=l+1; % the intersection is at end point
        kx(l)=xa1;
        ky(l)=ya1;
        
            % now there are l intersections on the bisector(i,j)
        [skx,sortIndex]= sort(kx);
         sky = ky(sortIndex);
            
         for k=1:l-1 %intervals between two intersections
             k2 = k+1;
             xx=(skx(k)+skx(k2))/2; %mid point
             yy2=slope*xx+b;
             ds=(xx-sx(i))^2+(yy2-sy(i))^2-WW(i);
             br2=0;
             for u=1:N
                 if u~=i && u~=j
                     us=(xx-sx(u))^2+(yy2-sy(u))^2-WW(u);
                     if us<ds
                         br2=br2+1;
                     end
                 end
             end
             if br2<3
                 xz=skx(k);
                 xz;
                 xz2=skx(k2);
                 xz2;
                 yz=sky(k);
                 yz;
                 yz2=sky(k2);
                 yz2;
                 hold on
                 if br2==0
                    line([xz xz2],[yz yz2],'Color',[0 1 0],'LineStyle','none')
                 elseif br2==1
                    line([xz xz2],[yz yz2],'Color',[0 0 1]) 
                 elseif br2==2
                    line([xz xz2],[yz yz2],'Color',[1 0 0],'LineStyle','none') 
                 end
             end
         end
    end
end
