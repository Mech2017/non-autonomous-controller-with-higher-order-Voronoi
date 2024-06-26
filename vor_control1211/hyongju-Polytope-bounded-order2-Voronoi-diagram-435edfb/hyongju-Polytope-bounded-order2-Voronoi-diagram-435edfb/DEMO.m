function vor_rg = DEMO
% This DEMO calculates an order-2 Voronoi diagram with arbitrary points in arbitrary
% polytope in 2D/3D
%% generate random samples
n = 4;         % number of points
d = 2;          % dimension e.g., 2, 3 
p1_0 = haltonset(d,'Skip', 1e3,'Leap', 1e2);
p1_1 = scramble(p1_0,'RR2');
p1_2 = net(p1_1,n);
m = 100000;                                    % number of points for boundary
bnd0 = net(p1_1,m);                         % generate boundary point-candidates
K = convhull(bnd0);
bnd_pnts = bnd0(K,:);                       % take boundary points from vertices of convex polytope formed with the boundary point-candidates
pos = p1_2(inhull(p1_2,bnd0,[],0.001),:);            % n' out of n points contained in bnd_pnts

%% call function "polybnd_order2voronoi.m"
%% 
% =========================================================================
% INPUTS:
% pos       points that are in the boundary      n' x d matrix (n': number of points d: dimension) 
% bnd_pnts  points that defines the boundary     m  x d matrix (m : number of vertices for the convex polytope
% boundary d: dimension)
% -------------------------------------------------------------------------
% OUTPUTS: 
% voronoi_rg   order-2 Voronoi regions        ?  x n'  
% vornb        Voronoi neighbors              1  x n' 
% vornb2       Voronoi neighbors              1  x ?  (repeating neighbors
% removed)
% =========================================================================

[voronoi_rg,vornb] = polybnd_order2voronoi(pos,bnd_pnts);
%% plot
h0 = figure('position',[0 0 700 700],'Color',[1 1 1]);

switch d
    case 2
        k = 0;        
        col = distinguishable_colors(size(voronoi_rg,1)*size(voronoi_rg,2));

        for i = 1:size(voronoi_rg,1)
            for j = 1:size(voronoi_rg,2)
                i
                j
%                 pause(3)
                if ~isempty(voronoi_rg{i,j})
                    k = k+1;
                    patch(voronoi_rg{i,j}(:,1),voronoi_rg{i,j}(:,2),col(k,:));
%                     pause(3)
                    hold on;
                end
            end
        end
        bdp = convhull(bnd_pnts);
        plot(bnd_pnts(bdp,1),bnd_pnts(bdp,2),'k-');
        hold on;
        plot(pos(:,1),pos(:,2),'Marker','o','MarkerSize',12,'MarkerFaceColor','r','Color','b','LineStyle','none');hold on;
        axis('equal')
        axis([0 1 0 1]);
        set(gca,'xtick',[0 1]);
        set(gca,'ytick',[0 1]);  
    case 3
        k = 0;
        col = distinguishable_colors(size(voronoi_rg,1)*size(voronoi_rg,2));
        for i = 1:size(voronoi_rg,1)
            for j = 1:size(voronoi_rg,2)
                if ~isempty(voronoi_rg{i,j})
                    k = k+1;
                    K2 = convhulln(voronoi_rg{i,j});
                    trisurf(K2,voronoi_rg{i,j}(:,1),voronoi_rg{i,j}(:,2),voronoi_rg{i,j}(:,3),'FaceColor',col(k,:),'FaceAlpha',0.5,'EdgeColor',col(k,:),'EdgeAlpha',1);
                    hold on;
                end
            end
        end
        bdp = convhull(bnd_pnts);
        plot3(bnd_pnts(bdp,1),bnd_pnts(bdp,2),bnd_pnts(bdp,3),'k-');
        hold on;
        plot3(pos(:,1),pos(:,2),pos(:,3),'Marker','o','MarkerSize',12,'MarkerFaceColor','r','Color','b','LineStyle','none');hold on;
        axis('equal')
        axis([0 1 0 1 0 1]);
        view(3);
        set(gca,'xtick',[0 1]);
        set(gca,'ytick',[0 1]);  
        set(gca,'ztick',[0 1]);  
end
end


