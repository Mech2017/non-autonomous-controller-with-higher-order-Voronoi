clc;clear all;clf;close all;

%% generate random samples
n = 6;  % number of points
d = 2;  % dimension e.g., 2, 3 
p1_0 = haltonset(d,'Skip', 1e3,'Leap', 1e2);
p1_1 = scramble(p1_0,'RR2');
p1_2 = net(p1_1,n);
m = 10000000;   % number of points for boundary
bnd0 = net(p1_1,m); % generate boundary point-candidates
K = convhull(bnd0);
bnd_pnts = bnd0(K,:); % take boundary points from vertices of convex polytope formed with the boundary point-candidates

pos = [0.093 0.7;0.5 0.6;0.4 0.5;0.9 0.8;0.15 0.2;0.53 0.4]; %initial positions of agents

ko = 2; % order of voronoi diagram
kp = 25; % gain for coverage metric control
% gain for collision avoidance, it can be set to zero to disable collision
% avoidance feature
%kpca = 0;
kpca = 1*10^-7;
tho1 = 0.1; % time-invarient density
% parameters for sensing function
sigma = 0.08; 
beta = 10;
alpha = 500;

deltat = 1; % iteration steps


s = [0.27,0.9;0.7,0.1;0.9,0.67]; % initial positions of 3 targets
% velocity of targets, it can be set to zero to simulate time-invarient
% environment
V = [1.8,-2.3;1.2,2.5;-1.5,-2.5]*10^-3*0.9; 
%V = [0,0;0,0;0,0];

%Collision Avoidance Terms
radius= 0.05;
R = 0.15;

% construct 1st order vor diagram
switch ko
    case 1
        mx=0:0.001:1;
        my=0:0.001:1;
        [X,Y]=meshgrid(mx,my);
        
        %density function of each target
        for i = 1:length(s)
            Z{i} = exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
        end
        
        %density distribution over workspace
        targ = Z{1};
        for j=2:length(s)
            
            targ = targ+Z{j};
        end

        tho = tho1+targ;
 
        %Initialize of vornoi diagram
        [vornb,vorvx,~] = polybnd_voronoi(pos,bnd_pnts);
        
        px = pos(:,1);
        py = pos(:,2);
        
        %Coverage area of agents
        coverage = sensing_function(pos,alpha,beta);
        
        
        %Control of each agent
        for i=1:length(px)

                funj = @(x,y) (alpha*(exp(-beta*((x-px(i)).^2+(y-py(i)).^2)))).*((V(1,1)*(x-s(1,1))+V(1,2)*(y-s(1,2))).*exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                              (V(2,1)*(x-s(2,1))+V(2,2)*(y-s(2,2))).*exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                              (V(3,1)*(x-s(3,1))+V(3,2)*(y-s(3,2))).*exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));

                %total density 
                fun = @(x,y) tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));
                           
                fun2x = @(x,y) x.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                fun2y = @(x,y) y.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                
                %new density function
                fun1 = @(x,y) ((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                fun3x = @(x,y) x.*(((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                           
                fun3y = @(x,y) y.*(((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                
                vorvx5{1,i} = vorvx{1,i};
                [vorvxn{1,i},ia,ic]=unique([vorvx5{1,i}(:,1),vorvx5{1,i}(:,2)],'rows','stable');
                                  
%               Polygon triangulation
                T = [];
                for k=1:length(vorvxn{1,i}(:,1))-2
                    T1 = [1,k+1,k+2];
                    T=[T;T1];
                end
                P = vorvxn{1,i};
                       
                TR = triangulation(T,P);
                rtotal = 0;
                rtotal2x = 0;
                rtotal2y = 0;
                rtotalj=0;
                rtotalcjx = 0;
                rtotalcjy=0;
                for k=1:length(T(:,1))
                    tp = [P(T(k,:),1),P(T(k,:),2)];

                    %new mass & centroid
                    r = intm2(fun1,tp);
                    r2x = intm2(fun3x,tp);
                    r2y = intm2(fun3y,tp);

                    rtotal = rtotal+r;
                    rtotal2x = rtotal2x+r2x;
                    rtotal2y = rtotal2y+r2y;
                    
                    %mass & centroid of target
                    rj = intm2(funj,tp);
                    
                    rtotalj = rtotalj+rj;
                end
                
                Mvi{i} = rtotal;
                Cvi{i} = (1/Mvi{i}).*[rtotal2x,rtotal2y];

                Hp{i} = (Mvi{i}.*(Cvi{i}-pos(i,:)));
                Ht{i} = (1/sigma^2)*rtotalj;
        
                a{i} = Cvi{i}-pos(i,:);
                ui{i} = ((Hp{i})./((Hp{i}(1))^2+(Hp{i}(2))^2)).*(kp*(a{i}(1)^2+a{i}(2)^2)-Ht{i});
                ppos{i} = pos(i,:).';
                pos(i,:) = pos(i,:)+deltat.*ui{i};
                
                %check agents' position is inside the workspace
                if pos(i,1)>1
                    pos(i,1)=1;
                end
                
                if pos(i,1)<0
                    pos(i,1)=0;
                end
                
                if pos(i,2)>1
                    pos(i,2)=1;
                end
                
                if pos(i,2)<0
                    pos(i,2)=0;
                end
                
        end
        
        for t=1:500*(1/deltat)
            clf;
            t
            
            %density plot
            subplot(1,2,1);
            s=s+deltat.*V;
            ss=surf(X, Y, tho,'Facealpha','0.5');
            ss.EdgeColor = 'none';
            shading interp
            view(2);
            colormap(flipud(gray(256)));
            colorbar;
            %pause(2)
            caxis([0 0.6])
            hold on
            for i = 1:length(s)
                
                Z{i} = exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
                
            end
            
            targ = Z{1};
            for j=2:length(s)
                
                targ = targ+Z{j};
            end
            
            tho = tho1+targ;
            
            
            %voronoi plot
            [vornb,vorvx,~] = polybnd_voronoi(pos,bnd_pnts);
            px = pos(:,1);
            py = pos(:,2);

            [vx,vy] = voronoi(px,py);
            plot(vx,vy,'b-');
            axis('equal');
            axis([0 1 0 1]);
            set(gca,'xtick',[0 1]);
            set(gca,'ytick',[0 1]);
            hold on
            
            for i=1:length(px)
                %density of target
                
                funj = @(x,y) (alpha*(exp(-beta*((x-px(i)).^2+(y-py(i)).^2)))).*((V(1,1)*(x-s(1,1))+V(1,2)*(y-s(1,2))).*exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                              (V(2,1)*(x-s(2,1))+V(2,2)*(y-s(2,2))).*exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                              (V(3,1)*(x-s(3,1))+V(3,2)*(y-s(3,2))).*exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));

                
                %total density 
                fun = @(x,y) tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));
                           
                fun2x = @(x,y) x.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                fun2y = @(x,y) y.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                
                %new density function
                fun1 = @(x,y) ((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                fun3x = @(x,y) x.*(((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                           
                fun3y = @(x,y) y.*(((2*alpha*beta)*exp(-beta*((x-px(i)).^2+(y-py(i)).^2))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                
                vorvx5{1,i} = vorvx{1,i};
                [vorvxn{1,i},ia,ic]=unique([vorvx5{1,i}(:,1),vorvx5{1,i}(:,2)],'rows','stable');
                                  
%               Polygon Triangulation
                T = [];
                for k=1:length(vorvxn{1,i}(:,1))-2
                    T1 = [1,k+1,k+2];
                    T=[T;T1];
                end
                P = vorvxn{1,i};
                       
                TR = triangulation(T,P);
                rtotal = 0;
                rtotal2x = 0;
                rtotal2y = 0;
                rtotalj=0;
                rtotalcjx = 0;
                rtotalcjy=0;
                for k=1:length(T(:,1))
                    tp = [P(T(k,:),1),P(T(k,:),2)];

                    %new mass & centroid
                    r = intm2(fun1,tp);
                    r2x = intm2(fun3x,tp);
                    r2y = intm2(fun3y,tp);

                    rtotal = rtotal+r;
                    rtotal2x = rtotal2x+r2x;
                    rtotal2y = rtotal2y+r2y;
                    
                    %mass & centroid of target
                    rj = intm2(funj,tp);
                    
                    rtotalj = rtotalj+rj;

                end
                
                Mvi{i} = rtotal;
                Cvi{i} = (1/Mvi{i}).*[rtotal2x,rtotal2y];
                

                Hp{i} = (Mvi{i}.*(Cvi{i}-pos(i,:)));
                Ht{i} = (1/sigma^2)*rtotalj;
        
                a{i} =Cvi{i}-pos(i,:);
                ui{i} = ((Hp{i})./((Hp{i}(1))^2+(Hp{i}(2))^2)).*(kp*(a{i}(1)^2+a{i}(2)^2)-Ht{i});
                
                plot(pos(i,1),pos(i,2),'Marker','o','MarkerSize',9,'MarkerEdgeColor','k','MarkerFaceColor',[0.8 0.8 0.8],'LineStyle','none');
                
                hold on
                ppos{i}=[ppos{i},pos(i,:).'];
                pos(i,:) = pos(i,:)+deltat.*ui{i};
                
                plot(Cvi{i}(1),Cvi{i}(2),'Marker','s','MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor',[0.2 0.2 0.2],'LineStyle','none');
                hold on
                plot(ppos{i}(1,:),ppos{i}(2,:),'black');
                
            end
            
            %check agents' position is inside the workspace
            if pos(i,1)>1
                pos(i,1)=1;
            end
            
            if pos(i,1)<0
                pos(i,1)=0;
            end
            
            if pos(i,2)>1
                pos(i,2)=1;
            end
            
            if pos(i,2)<0
                pos(i,2)=0;
            end

            %Coverage area of agents
            coverage = sensing_function(pos,alpha,beta);
            subplot(1,2,2);
            ca = surf(X, Y, coverage, 'Facealpha','1');
            ca.EdgeColor = 'none';
            shading interp
            view(2);
            colormap(flipud(gray(256)));
            colorbar;
          
            axis('equal');
            axis([0 1 0 1]);
            set(gca,'xtick',[0 1]);
            set(gca,'ytick',[0 1]);
            
            M(t) = getframe;
        end
         
    case 2
        mx=0:0.001:1;
        my=0:0.001:1;
        [X,Y]=meshgrid(mx,my);
        
        %density function of each target
        for i = 1:length(s)
            Z{i} = exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
        end
        
        %density distribution over workspace
        targ = Z{1};
        for j=2:length(s)
            
            targ = targ+Z{j};
        end

        tho = tho1+targ;
        
        [voronoi_rg,vornb] = polybnd_order2voronoi(pos,bnd_pnts);
        Mvij = voronoi_rg;
        
        col = distinguishable_colors(size(voronoi_rg,1)*size(voronoi_rg,2));
        
        px = pos(:,1);
        py = pos(:,2);
        
        for i = 1:size(voronoi_rg,1)
            for j = 1:size(voronoi_rg,2)
                % density of target
                funj = @(x,y) (alpha*(exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2))))).*((V(1,1)*(x-s(1,1))+V(1,2)*(y-s(1,2))).*exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                    (V(2,1)*(x-s(2,1))+V(2,2)*(y-s(2,2))).*exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                    (V(3,1)*(x-s(3,1))+V(3,2)*(y-s(3,2))).*exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));

                % total density
                fun = @(x,y) tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));
                
                fun2x = @(x,y) x.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                
                fun2y = @(x,y) y.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                    exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                
                % new density function
                fun1 = @(x,y) ((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                fun3x = @(x,y) x.*(((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                           
                fun3y = @(x,y) y.*(((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                           
                % Coverage metric function
                covm = @(x,y)(alpha*(exp(-beta*((x-px(i)).^2+(y-py(i)).^2+(x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));

                
                if ~isempty(voronoi_rg{i,j})
                    
                    vorvx5{i,j} = voronoi_rg{i,j};
                    [vorvxn{i,j},ia,ic]=unique([vorvx5{i,j}(:,1),vorvx5{i,j}(:,2)],'rows','stable');
                    
                    % Polygon Triangulation
                    T = [];
                    for k=1:length(vorvxn{i,j}(:,1))-2
                        T1 = [1,k+1,k+2];
                        T=[T;T1];
                    end
                    P = vorvxn{i,j};
                    
                    TR = triangulation(T,P);
                    rtotal = 0;
                    rtotal2x = 0;
                    rtotal2y = 0;
                    rtotalj=0;
                    rtotalcjx = 0;
                    rtotalcjy=0;
                    rtotalcov = 0;
                    for k=1:length(T(:,1))
                        tp = [P(T(k,:),1),P(T(k,:),2)];
                        
                        %new mass & centroid
                        r = intm2(fun1,tp);
                        r2x = intm2(fun3x,tp);
                        r2y = intm2(fun3y,tp);
                        
                        rtotal = rtotal+r;
                        rtotal2x = rtotal2x+r2x;
                        rtotal2y = rtotal2y+r2y;
                        
                        %mass & centroid of target
                        rj = intm2(funj,tp);
                        
                        rtotalj = rtotalj+rj;

                        %coverage metric
                        rcovm = intm2(covm,tp);
                        rtotalcov = rtotalcov + rcovm;

                    end

                    Mvij{i,j}=rtotal;
                    Cvij{i,j}=(1/Mvij{i,j}).*[rtotal2x,rtotal2y];
                    Htij{i,j} = (1/sigma^2)*rtotalj;
                    Covm{i,j} = rtotalcov;
                    
                end
            end
        end
        bdp = convhull(bnd_pnts);
        t=1;
        H(t) = 0;
        
        for i=1:n
            if i<=size(voronoi_rg,1)
                Mvi{i}=sum([Mvij{i,:}])+sum([Mvij{:,i}]);
                Hti{i}=sum([Htij{i,:}])+sum([Htij{:,i}]);
                H(t) = H(t) + sum([Covm{i,:}]);
            else
                Mvi{i}=sum([Mvij{:,i}]);
                Hti{i}=sum([Htij{:,i}]);
            end
        end
        
        for i = 1:size(voronoi_rg,1)
            for j = 1:size(voronoi_rg,2)
                if isempty(Mvij{i,j})&&j<=i
                    Mvij{i,j}=Mvij{j,i};
                    Cvij{i,j}=Cvij{j,i};
                end
            end
        end
        
        for i = 1:n
            a=[0 0];
            b=[0,0];
            
            for j = 1:n
                if i<=size(voronoi_rg,1) && ~isempty(Mvij{i,j})
                    a=a + (Mvij{i,j}.*(Cvij{i,j}-pos(i,:)));
                    b=b+ (Mvij{i,j}.*Cvij{i,j});
                elseif i>size(voronoi_rg,1) && j<=size(voronoi_rg,1) && ~isempty(Mvij{j,i})
                    a=a + (Mvij{j,i}.*(Cvij{j,i}-pos(i,:)));
                    b=b+ (Mvij{j,i}.*Cvij{j,i});
                end
            end
            Cvi{i} = b/Mvi{i};
            Hp{i} = (Mvi{i}.*(Cvi{i}-pos(i,:)));
            c{i} = Cvi{i}-pos(i,:);
            ui{i} = ((Hp{i})./((Hp{i}(1))^2+(Hp{i}(2))^2)).*(kp*(c{i}(1)^2+c{i}(2)^2)-Hti{i});
            ppos{i} = pos(i,:)';
            pos(i,:) = pos(i,:)+deltat.*ui{i};
            
            %check agents' position is inside the workspace
            if pos(i,1)>1
                pos(i,1)=1;
            end
            
            if pos(i,1)<0
                pos(i,1)=0;
            end
            
            if pos(i,2)>1
                pos(i,2)=1;
            end
            
            if pos(i,2)<0
                pos(i,2)=0;
            end
            
        end
        
        for t=2:100*(1/deltat)
            clf;
            t
            s=s+deltat.*V;
            ss=surf(X, Y, tho);
            ss.EdgeColor = 'none';
            shading interp
            view(2);
            hold on
            colormap(flipud(gray(128)));
            colorbar;
            caxis([0 1])
            for i = 1:length(s)
                
                Z{i} = exp(-((X-s(i,1)).^2+(Y-s(i,2)).^2)/(2*sigma^2));
                
            end
            
            targ = Z{1};
            for j=2:length(s)
                
                targ = targ+Z{j};

            end
            
            tho = tho1+targ;
            
            [voronoi_rg,vornb] = polybnd_order2voronoi(pos,bnd_pnts);
            Mvij = voronoi_rg;
            
            axis('equal')
            axis([0 1 0 1]);
            set(gca,'xtick',[0 1], 'FontSize', 11, 'FontWeight', 'bold');
            set(gca,'ytick',[0 1], 'FontSize', 11, 'FontWeight', 'bold');
            hold on;
            
            k = 0;
            col = distinguishable_colors(size(voronoi_rg,1)*size(voronoi_rg,2));
            
            px = pos(:,1);
            py = pos(:,2);
            for i = 1:n
                for j = 1:n
                    if i~=j
                        Dis{i,j} = pdist2([px(i),py(i)],[px(j),py(j)]);
                        
                        if Dis{i,j}>radius && Dis{i,j}<R
                            CAij{i,j} = 4*(R^2-radius^2)*(Dis{i,j}^2-R^2).*[px(i)-px(j),py(i)-py(j)]./(Dis{i,j}^2-radius^2)^3;
                        else
                            CAij{i,j} = [0,0];
                        end
                    end
                    
                    
                end
                CAi{i} = [0,0];
                for j=1:n
                    if i~=j
                        CAi{i} = CAi{i}+CAij{i,j};
                    end
                end
                
            end
            Dis{1,3};
            CAi{1};
            
            
            for i = 1:size(voronoi_rg,1)
                for j = 1:size(voronoi_rg,2)
                    %Coverage metric function
                    covm = @(x,y)(alpha*(exp(-beta*((x-px(i)).^2+(y-py(i)).^2+(x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                               exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                           
                    %density of target
                    funj = @(x,y) (alpha*(exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2))))).*((V(1,1)*(x-s(1,1))+V(1,2)*(y-s(1,2))).*exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        (V(2,1)*(x-s(2,1))+V(2,2)*(y-s(2,2))).*exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        (V(3,1)*(x-s(3,1))+V(3,2)*(y-s(3,2))).*exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));
                    
                    % total density
                    fun = @(x,y) tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)));
                    
                    fun2x = @(x,y) x.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                    
                    fun2y = @(x,y) y.*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                    
                    %new density function
                    fun1 = @(x,y) ((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2))));
                    
                    fun3x = @(x,y) x.*(((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                    
                    fun3y = @(x,y) y.*(((2*alpha*beta)*exp(-beta*(((x-px(i)).^2+(y-py(i)).^2)+((x-px(j)).^2+(y-py(j)).^2)))).*(tho1+(exp(-((x-s(1,1)).^2+(y-s(1,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(2,1)).^2+(y-s(2,2)).^2)/(2*sigma^2))+...
                        exp(-((x-s(3,1)).^2+(y-s(3,2)).^2)/(2*sigma^2)))));
                    
                    
                    if ~isempty(voronoi_rg{i,j})
                        
                        plot(voronoi_rg{i,j}(:,1),voronoi_rg{i,j}(:,2),'b-','lineWidth',1);
                        
                        vorvx5{i,j} = voronoi_rg{i,j};
                        [vorvxn{i,j},ia,ic]=unique([vorvx5{i,j}(:,1),vorvx5{i,j}(:,2)],'rows','stable');
                        
                        %  Polygon Triangulation
                        T = [];
                        for k=1:length(vorvxn{i,j}(:,1))-2
                            T1 = [1,k+1,k+2];
                            T=[T;T1];
                        end
                        P = vorvxn{i,j};
                        
                        TR = triangulation(T,P);
                        rtotal = 0;
                        rtotal2x = 0;
                        rtotal2y = 0;
                        rtotalj=0;
                        rtotalcjx = 0;
                        rtotalcjy=0;
                        rtotalcov = 0;
                        for k=1:length(T(:,1))
                            tp = [P(T(k,:),1),P(T(k,:),2)];
                            
                            %new mass & centroid
                            r = intm2(fun1,tp);
                            r2x = intm2(fun3x,tp);
                            r2y = intm2(fun3y,tp);
                            
                            rtotal = rtotal+r;
                            rtotal2x = rtotal2x+r2x;
                            rtotal2y = rtotal2y+r2y;
                            
                            %mass & centroid of target
                            rj = intm2(funj,tp);
                            
                            rtotalj = rtotalj+rj;

                            %coverage metric
                            rcovm = intm2(covm,tp);
                            rtotalcov = rtotalcov + rcovm;
                        end
                        

                        Mvij{i,j}=rtotal;
                        Cvij{i,j}=(1/Mvij{i,j}).*[rtotal2x,rtotal2y];
                        Htij{i,j}=rtotalj;
                        Covm{i,j}=rtotalcov;
                        
                    end
                end
            end
            bdp = convhull(bnd_pnts);
            plot(bnd_pnts(bdp,1),bnd_pnts(bdp,2),'b-', 'lineWidth', 1);
            H(t) = 0;

            
            for i=1:n
                if i<=size(voronoi_rg,1)
                    Mvi{i}=sum([Mvij{i,:}])+sum([Mvij{:,i}]);
                    Hti{i}=sum([Htij{i,:}])+sum([Htij{:,i}]);
                    H(t) = H(t) + sum([Covm{i,:}]);
                else
                    Mvi{i}=sum([Mvij{:,i}]);
                    Hti{i}=sum([Htij{:,i}]);
                end
            end
            
            for i = 1:size(voronoi_rg,1)
                for j = 1:size(voronoi_rg,2)
                    if isempty(Mvij{i,j})&&j<=i
                        Mvij{i,j}=Mvij{j,i};
                        Cvij{i,j}=Cvij{j,i};
                    end
                end
            end
            
            for i = 1:n
                a=[0 0];
                b=[0 0];
                
                for j = 1:n
                    if i<=size(voronoi_rg,1) && ~isempty(Mvij{i,j})
                        a=a + (Mvij{i,j}.*(Cvij{i,j}-pos(i,:)));
                        b=b+ (Mvij{i,j}.*Cvij{i,j});
                    elseif i>size(voronoi_rg,1) && j<=size(voronoi_rg,1) && ~isempty(Mvij{j,i})
                        a=a + (Mvij{j,i}.*(Cvij{j,i}-pos(i,:)));
                        b=b+ (Mvij{j,i}.*Cvij{j,i});
                    end
                end
                Cvi{i} = b/Mvi{i};
                plot(Cvi{i}(1,1),Cvi{i}(1,2),'Marker','s','MarkerSize',9,'MarkerEdgeColor','k','MarkerFaceColor','r','LineStyle','none','lineWidth',1,'DisplayName','target');hold on
                
                Hp{i} = (Mvi{i}.*(Cvi{i}-pos(i,:)));
                
                c{i} =Cvi{i}-pos(i,:);
                
                ui{i} = ((Hp{i})./((Hp{i}(1))^2+(Hp{i}(2))^2)).*(kp*(c{i}(1)^2+c{i}(2)^2)-Hti{i});

                plot(ppos{i}(1,:),ppos{i}(2,:),'black','lineWidth',2,'DisplayName','trajectory');hold on
                ppos{i}= [ppos{i},pos(i,:)'];
                plot(pos(i,1),pos(i,2),'Marker','o','MarkerSize',7,'MarkerEdgeColor','k','MarkerFaceColor','[0.5 1 0.5]','LineStyle','none','lineWidth',1,'DisplayName','agent');hold on
                pos(i,:) = pos(i,:)+deltat.*(ui{i}-kpca*CAi{i});
                
                %check agents' position is inside the workspace
                if pos(i,1)>1
                    pos(i,1)=1;
                end
                
                if pos(i,1)<0
                    pos(i,1)=0;
                end
                
                if pos(i,2)>1
                    pos(i,2)=1;
                end
                
                if pos(i,2)<0
                    pos(i,2)=0;
                end
                
            end
            ax = gca;
            ax.SortMethod = 'childorder';
            M(t) = getframe;
        end
        ax.Children
        %ax.Children = ax.Children([1,4,7,10,13,16,3,6,9,12,15,18,2,5,8,11,14,17,19,20,21,22,23,24,25,26,27,28]);
        ax.Children = ax.Children([1,4,7,10,13,16,3,6,9,12,15,18,2,5,8,11,14,17,19,20,21,22,23,24,25,26,27,28,29]);
        ax = gca;
        outerpos = ax.OuterPosition;
        ti = ax.TightInset;
        left = outerpos(1) + ti(1);
        bottom = outerpos(2) + ti(2);
        ax_width = outerpos(3) - ti(1) - ti(3);
        ax_height = outerpos(4) - ti(2) - ti(4);
        ax.Position = [left bottom ax_width ax_height];
        %exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\initial_configuration.png','Resolution',600)
        %exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_invarient_config_without_collision_avoidance.png','Resolution',600)
        %exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_invarient_config_with_collision_avoidance.png','Resolution',600)
        %exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_varying_config_without_collision_avoidance.png','Resolution',600)
        %exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_varying_config_with_collision_avoidance.png','Resolution',600)
        exportgraphics(ax,'D:\Research_2nd_Voronoi_2024_4_17\Figure\test.png','Resolution',600)
        figure2 = figure;
        time = 0:200;
        H = [18, H];
        plot(time, H, 'LineWidth',1.5);
        grid on;
        bx = gca;
        bx.GridLineStyle = '--';
        xlabel('Time [Sec]','FontSize', 11, 'FontWeight', 'bold');
        ylabel('Coverage Metrics, H','FontSize', 11, 'FontWeight', 'bold');
        %exportgraphics(figure2,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_varying_coverage.png','Resolution',600)
        %exportgraphics(figure2,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_invarient_coverage.png','Resolution',600)

end







