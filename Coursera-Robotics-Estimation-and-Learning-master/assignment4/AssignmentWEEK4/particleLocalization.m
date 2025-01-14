% Robotics: Estimation and Learning 
% WEEK 4
% 
% Complete this function following the instruction. 
function myPose = particleLocalization(ranges, scanAngles, map, param)

% Number of poses to calculate
N = size(ranges, 2);
%n = size(scanAngles, 1);
% Output format is [x1 x2, ...; y1, y2, ...; z1, z2, ...]
myPose = zeros(3, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% % the number of grids for 1 meter.
r = param.resol;
% % the origin of the map in pixels
myOrigin = param.origin; 

% The initial pose is given
myPose(:,1) = param.init_pose;

% You should put the given initial pose into myPose for j=1, ignoring the j=1 ranges. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = 1500;                            % Please decide a reasonable number of M, 
                               % based on your experiment using the practice data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create M number of particles
P = repmat(myPose(:,1), [1, M]);
Weights = ones(1,M) * (1/M); 

%scanAngles = -scanAngles;

for j = 2:N % You will start estimating myPose from j=2 using ranges(:,2).
% 
     if j < 20
         %M = 200;
         noise_sigma = diag([0.1 0.1 0.035]);
     else
         M = 700 ;
         noise_sigma = diag([0.025 0.025 0.03]);
     end
    noise_u = [0 0 0];
    %dynamic_sigma = diag([0.04 0.04 0.03]);
    %noise_sigma = diag([0.04 0.04 0.03]);
    %dynamic  = mvnrnd(noise_u, dynamic_sigma)';
    %P(:) = P(:) +  mvnrnd(noise_u,noise_sigma)'; 
    for m = 1:M
      % 1) Propagate the particles
        %P(:,m) = P(:,m) +  mvnrnd(noise_u,noise_sigma)';
        P(:,m) = myPose(:,j-1) +  mvnrnd(noise_u,noise_sigma)';
        w = 0;
%     % 2) Measurement Update 
%     % 2-1) Find grid cells hit by the rays (in the grid map coordinate frame)    
        %for angle = 1:n
        % Find grids hit by the rays (in the gird map coordinate)
         x_o = ranges(:,j) .* cos(scanAngles + P(3,m)) + P(1,m);
         y_o = -ranges(:,j) .* sin(scanAngles + P(3,m)) + P(2,m);
            
         occ_x = ceil(x_o*r)+myOrigin(1);
         occ_y = ceil(y_o*r)+myOrigin(2);
         occ_x_ = occ_x';
         occ_y_ = occ_y';
            
            %car = [ceil(P(1,m)*r) + myOrigin(1)  ceil(P(2,m)*r) + myOrigin(2)];
         del_occ =  occ_x_<1 | occ_y_<1 |  occ_x_ > size(map,2) |  occ_y_ > size(map,1);

         occ_x_(del_occ) = [];
         occ_y_(del_occ) = [];


         occ_index = sub2ind(size(map),occ_y_',occ_x_');
         %disp(sum(sum(map(occ_index) >= 0.5)));
         %disp(sum(sum(map(occ_index) < 0.5)));
         w =  w + sum(sum(map(occ_index) >= 0.5)) * 10;
         w =  w - sum(sum(map(occ_index) < -0.2)) * 2;
           
%        x_o = ranges(angle,j) * cos(scanAngles(angle,1) + P(3,m)) + P(1,m);
%        y_o = -1*ranges(angle,j) * sin(scanAngles(angle,1) + P(3,m)) + P(2,m);
%       
%        occ= [ceil(x_o*r)+myOrigin(1)  ceil(y_o*r) + myOrigin(2)];
%        car = [ceil(P(1,m)*r) + myOrigin(1)  ceil(P(2,m)*r) + myOrigin(2)];
%             
%        if occ(2)>0 && occ(1)>0 &&  occ(2) < size(map,1)+1 &&  occ(1) < size(map,2)+1
%           w =  w + (map(occ(2),occ(1)) > 0.5) * 10;
%           w =  w - (map(occ(2),occ(1)) < 0.5) * 5;
%        end
        
%     %   2-2) For each particle, calculate the correlation scores of the particles
          %  [freex,freey]  = bresenham(car(1),car(2),occ(1),occ(2));  
        
           % if size(freex,2)>0
           %     freex_ = freex';
           %     freey_ = freey';
           %     del_index = freex_< 1 | freex_()> size(map,2) | freey_<1 | freey_>size(map,1);
        
           %     freex_(del_index) = [];
           %     freey_(del_index) = [];
           %     freex = freex_';
           %     freey = freey_';
           %     free = sub2ind(size(map),freey,freex);

            %    w = w - sum((map(free)>0.5) * 5);
            %    w = w + sum((map(free)<0.5) * 1);
            %end
%     %   2-3) Update the particle weights         
        
         %Weights(1,m) = Weights(1,m) * w;   
         Weights(1,m) = w;  
    end
%     %   2-4) Choose the best particle to update the pose
        Weights = Weights/sum(Weights);
        [Max_,Ind_] = max(Weights);
        myPose(:,j) = P(:,Ind_);
        %disp(Weights);
%     % 3) Resample if the effective number of particles is smaller than a threshold
        n_effective = sum(Weights) * sum(Weights) / sumsqr(Weights);
        disp(n_effective);
        disp(j);
        %disp(Weights)
%         
%         if n_effective <50
%            c_w = cumsum(Weights);
%            P_new = repmat([0;0;0], [1, M]);
%            Weights_new = ones(1,M) * (1/M); 
%            for k = 1:min(M)
%                rand_n = rand();
%                index_ = check_index(rand_n, c_w);
%                P_new(:,k) = P(:,index_); 
%                Weights_new(k) = Weights(index_);
%            end
%         P = P_new;
%         Weights = Weights_new;
%         end
        
        
        
        %disp(Weights);
        %n_effective = sum(Weights) * sum(Weights) / sumsqr(Weights);
        %disp(n_effective);
        

        %disp(n_effective);
%     % 4) Visualize the pose on the map as needed

end

