function coverage = sensing_function(pos,alpha,beta)

ko = 1;
x=0:0.001:1;
y=0:0.001:1;
[X,Y]=meshgrid(x,y);
s=pos;
a=[];
if ko==1
    for i = 1:length(s)
        Z{i} = alpha*exp(-beta*((X-s(i,1)).^2+(Y-s(i,2)).^2));
    end
end
targ = Z{1};
for j=2:length(s)
    
    targ = targ+Z{j};
end

coverage = targ;
end