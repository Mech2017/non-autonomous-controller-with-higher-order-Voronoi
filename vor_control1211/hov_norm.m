clc;clear all;clf;close all;
N = 5; % number of generators
% x = [2,3,4.5,5,7,8,9,1,6,4]
% y = [6,2,9,4.5,5.5,9,8,7,1,3]

x = double.empty(0,N);
y = double.empty(0,N);
W = double.empty(0,N);
for k=1:N
    x(k) = rand*1000;
    y(k) = rand*1000;
    W(k) = 2;
end
[WW,sortIndex]= sort(W);
sx = x(sortIndex);
sy = y(sortIndex);
% sx = x;
% sy = y;
% WW = W;
h = 1000; % length of y coordinate
w = 1000; % length of x coordinate

f2=figure;
plot(sx,sy,'r*')
axis([0 h 0 w]);

for i = 1:N-1
    for j = i+1:N
        eps=0.01;
        eps2=0.1;
        coumax=100;
        ysyo = ((sy(i)+sy(j))/2.0-100.0);
        while ysyo<(sy(i)+sy(j))/2.0+100.0
            for xI=0:w
                yr=ysyo;
                yr1=-100;
                ff=100;
                cou=0;
                while abs(ff)>eps && cou<coumax
                    yr1=yr;
                    kou1= ((abs(xI-sx(i)))^WW(i)+(abs(yr-sy(i)))^WW(i))^(1/WW(i));
                    kou2= ((abs(xI-sx(j)))^WW(j)+(abs(yr-sy(j)))^WW(j))^(1/WW(j));
                    ff=kou1-kou2;
                    kou1b=hov_norm_abm(yr,sy(i),WW(i)-1)*((abs(xI-sx(i)))^WW(i)+(abs(yr-sy(i)))^WW(i))^(1/WW(i)-1);
                    kou2b=hov_norm_abm(yr,sy(j),WW(j)-1)*((abs(xI-sx(j)))^WW(j)+(abs(yr-sy(j)))^WW(j))^(1/WW(j)-1);
                    ffbi=kou1b-kou2b;
                    yr=yr-ff/ffbi;
                    cou=cou+1;
                end
                if abs(ff)<eps
                    br2=0;
                    if kou1/kou2>1.0+eps2 || kou2/kou1>1.0+eps2
                        br2=100;
                    end
                    if br2==0
                        mind=((abs(xI-sx(i)))^WW(i)+(abs(yr-sy(i)))^WW(i))^(1/WW(i));
                        for k=1:N
                            if k~=i&&k~=j
                                e12=((abs(xI-sx(k)))^WW(k)+(abs(yr-sy(k)))^WW(k))^(1/WW(k));
                                if e12<mind
                                    br2=br2+1;
                                end
                            end
                        end
                    end
                    if br2<=2
                        hold on
                        if br2==0
                            line([xI xI],[yr yr],'Color',[0 0 1],'LineStyle','none')
                        elseif br2==1
                            plot([xI xI],[yr yr],'b.')
                        elseif br2==2
                            line([xI xI],[yr yr],'Color',[1 0 0],'LineStyle','none')
                        end
                    end
                end
            end
            ysyo=ysyo+100.0;
        end
        xsxo=(sx(i)+sx(j))/2.0-100.0;
        while xsxo<(sx(i)+sx(j))/2.0+100.0+1
            for yI=0:h
                xr=xsxo;
                xr1=-100;
                ff=100;
                cou=0;
                while abs(ff)>eps && cou<coumax
                    xr1=xr;
                    kou1= ((abs(xr-sx(i)))^WW(i)+(abs(yI-sy(i)))^WW(i))^(1/WW(i));
                    kou2= ((abs(xr-sx(j)))^WW(j)+(abs(yI-sy(j)))^WW(j))^(1/WW(j));
                    ff=kou1-kou2;
                    kou1b=hov_norm_abm(xr,sx(i),WW(i)-1)*((abs(xr-sx(i)))^WW(i)+(abs(yI-sy(i)))^WW(i))^(1/WW(i)-1);
                    kou2b=hov_norm_abm(xr,sx(j),WW(j)-1)*((abs(xr-sx(j)))^WW(j)+(abs(yI-sy(j)))^WW(j))^(1/WW(j)-1);
                    ffbi=kou1b-kou2b;
                    xr=xr-ff/ffbi;
                    cou=cou+1;
                end
                if abs(ff)<eps
                    br2=0;
                    if kou1/kou2>1.0+eps2 || kou2/kou1>1.0+eps2
                        br2=100;
                    end
                    if br2==0
                        mind=((abs(xr-sx(i)))^WW(i)+(abs(yI-sy(i)))^WW(i))^(1/WW(i));
                        for k=1:N
                            if k~=i&&k~=j
                                e12=((abs(xr-sx(k)))^WW(k)+(abs(yI-sy(k)))^WW(k))^(1/WW(k));
                                if e12<mind
                                    br2=br2+1;
                                end
                            end
                        end
                    end
                    if br2<=2
                        hold on
                        if br2==0
                            line([xr xr],[yI yI],'Color',[0 0 1],'LineStyle','none')
                        elseif br2==1
                            plot([xr xr],[yI yI],'b.')
                        elseif br2==2
                            line([xr xr],[yI yI],'Color',[1 0 0],'LineStyle','none')
                        end
                    end
                end
            end
            xsxo=xsxo+100.0;
        end
    end
end
        
                                

        
        
        
       
             
