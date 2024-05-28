function [voronoi_rg,vornb,vornb2] = polybnd_order1voronoi(pos,bnd_pnts)

%% =======================================================
% Order-2 Voronoi Diagram with set of points in 2D/3D polygon
% ========================================================
% version 1.01
% by Hyongju Park
%---------------------------------------------------------
% inputs: bnd_pnts      boundary points                m x 2
%         pos           points inside the boundary     n x 2
%---------------------------------------------------------
% outputs: voronoi_rg   order-2 Voronoi regions        ? x n  
%          vornb        Voronoi neighbors              1 x n
%          vornb2       Voronoi neighbors              1 x ? (repeating
%          neighbors removed)
% =========================================================================
% This functions works for d = 2, 3
% -------------------------------------------------------------------------
% This function requires:
%       vert2lcon.m (Matt Jacobson / Michael Keder)
%       pbisec.m (by me)
%       con2vert.m (Michael Keder)
%       inhull.m (John D'Errico)
% -------------------------------------------------------------------------
% Written by Hyongju Park, hyongju@gmail.com / park334@illinois.edu
% Change logs:
% 11 Aug 2015: skip error messages (version 1.01) 
% 5  May 2015: initial release (version 1.0)
% =========================================================================
% Known issues:
% Input points must satisfy assumptions such as non co-circularity and
% general position assumptions
% -------------------------------------------------------------------------
%%
[vornb,vorvx,~] = polybnd_voronoi(pos,bnd_pnts);      % 
% obtain set of voronoi neighbors/vertices
[Abnd,bbnd] = vert2lcon(bnd_pnts);              % obtain series of linear inequalities that defined Voronoi regions
%% create list
for i = 1:size(pos,1)
    k = 0;
    for j = 1:size(vornb{i},2)
        if vornb{i}(1,j) > i
            k = k + 1;
            vornb2{i}(1,k) = vornb{i}(1,j);
        end
    end
end

for m1 =1:size(vornb2,2)
    for j = 1:size(vornb2{m1},2)-1
        for k = j+1:size(vornb2{m1},2)
            c1 = m1
            c2 = vornb2{m1}(1,j)
            c3 = vornb2{m1}(1,k)
        clear Aag1 bag1 Aag2 bag2 Aagmt bagmt pos1 pos2
        % given (c1,c2) where c1< c2< c3
        % compute voronoi vertices of c1
        k = 0;
        for i = 1:size(pos,1)
            if i ~= c2
                k = k +1;
                pos1(k,:) = pos(i,:);
            end
        end
        % compute voronoi vertices of c2
        k = 0;
        for i = 1:size(pos,1)
            if i ~= c3
                k = k + 1;
                pos2(k,:) = pos(i,:);
            end
        end
        [~,v1,Aag1,bag1] = polybnd_voronoi(pos1,bnd_pnts);

        % compute voronoi vertices of c3
        k = 0;
        for i = 1:size(pos,1)
            if i ~= c1
                k = k +1;
                pos3(k,:) = pos(i,:);
            end
        end
        
        [~,v2,Aag2,bag2] = polybnd_voronoi(pos2,bnd_pnts);
        [~,v3,Aag3,bag3] = polybnd_voronoi(pos3,bnd_pnts);
        vetx = [v1,v2,v3];
        Aagmt = [Aag1{c1};Aag2{c2-1};Aag3{c3-1};Abnd];
        bagmt = [bag1{c1};bag2{c2-1};bag3{c3-1};bbnd];
        Vl{c1,c2,c3}= MY_con2vert(Aagmt,bagmt);
        IDl{c1,c2,c3} = convhull(Vl{c1,c2,c3});
        voronoi_rg{c1,c2,c3} = Vl{c1,c2,c3}(IDl{c1,c2,c3},:);
%         % remove Voronoi regions that are not in the boundary
%         if ~isempty(Vl{c1,c2,c3})
%             if inhull(Vl{c1,c2,c3},vorvx{c1},[],1.e-13*mean(abs(bnd_pnts(:)))) | inhull(Vl{c1,c2,c3},vorvx{c2},[],1.e-13*mean(abs(bnd_pnts(:))))|inhull(Vl{c1,c2,c3},vorvx{c3},[],1.e-13*mean(abs(bnd_pnts(:)))) 
%                 IDl{c1,c2,c3} = convhull(Vl{c1,c2,c3});
%                 voronoi_rg{c1,c2,c3} = Vl{c1,c2,c3}(IDl{c1,c2,c3},:);
%             else
%                 voronoi_rg{c1,c2,c3} = [];
%             end
%         else
%             voronoi_rg{c1,c2,c3} = [];
%         end
        end
    end
end
