clc;
clear all;
clf;
close all;
N = 20; % number of generators
x = rand(1,N)*10;
y = rand(1,N)*10;

h = 10; % length of y coordinate
w = 10; % length of x coordinate

f2=figure;
plot(x,y,'.')
axis([0 h 0 w]);

for i = 1:N-1
    [x(i),y(i)];
    for j = i+1:N
        [x(j),y(j)];
        % bisector(i,j) is represented as y = slope*x+b
        br=0;
        slope2 = (y(i)-y(j))/(x(i)-x(j)); % slope of the line segment(i,j)
        slope = -1/slope2; % slope of bisector(i,j)
        cpy=(y(i)+y(j))/2; % midpoint y coordinate
        cpx=(x(i)+x(j))/2; % midpoint x coordinate
        b=cpy-cpx*slope; % intercept of the bisector on y coordinate
        d1=(x(i)-x(j))^2+(y(i)-y(j))^2; % distance (i,j)
        
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
        [x0,y0];
        
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
        [xa1,ya1];
        
        l=1; %store the start point of bisector(i,j)
        kx = double.empty(0,100);
        ky = double.empty(0,100);
        kx(l)=x0;
        ky(l)=y0;
        diffx1 = x(j)-x(i);
        diffy1 = y(j)-y(i);
        
        for k=1:N
            if k~=i && k~=j
                slope4=(y(i)-y(k))/(x(i)-x(k));
                slope3=-1/slope4;
                cpy2=(y(i)+y(k))/2;
                cpx2=(x(i)+x(k))/2;
                b2=cpy2-cpx2*slope3;
                d2=(x(i)-x(k))^2+(y(i)-y(k))^2;

                y20=slope3*x0+b2;
                y21=slope3*xa1+b2;
                diff0=y0-y20;
                diff1=ya1-y21;
                diffx2=x(k)-x(i);
                diffy2=y(k)-y(i);
            
                if diffx1*diffx2>0 && diffy1*diffy2>0
                    flag=1;
                else
                    flag=0;
                end
                if diff0*diff1>0 && d1>d2 && flag==1
                    br=1;
                    break;
                end
                if diff0*diff1<0 || d1<d2 || flag~=0
                    if diff0*diff1<0 || d1>d2
                        l=l+1;
                        kx(l)=(b2-b)/(slope-slope3);
                        ky(l)=slope*kx(l)+b;
                    end
                end
            end
        end
        kx(l)
        ky(l)
        if br==0
            l=l+1; % the intersection is at end point
            kx(l)=xa1;
            ky(l)=ya1;

            % now there are l intersections on the bisector(i,j)
            [skx,sortIndex]= sort(kx);
            sky = ky(sortIndex);
            [skx,sky];
            for k=1:l-1 %intervals between two intersections
                k2 = k+1;
                xx=(skx(k)+skx(k2))/2; %mid point
                yy2=slope*xx+b;
                ds=(xx-x(i))^2+(yy2-y(i))^2;
                br2=0;
                for u=1:N
                    if u~=i && u~=j
                        us=(xx-x(u))^2+(yy2-y(u))^2;
                        if us<ds
                            br2=1;
                            break;
                        end
                    end
                end
                if br2==0
                    xz=skx(k);
                    xz2=skx(k2);
                    yz=sky(k);
                    yz2=sky(k2);
                    [xz,xz2;yz,yz2];
                    hold on
                    line([xz xz2],[yz yz2])
                    break;
                end
            end
        end
    end
end


            
