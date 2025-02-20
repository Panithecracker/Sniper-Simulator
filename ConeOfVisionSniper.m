clear all
format long
clear figure
clc

%just testing before implementing the algorithm to render the cone of
%vision emanating out of the sniper scope eye point
%rotation parameters of the rifle scope
phi = pi/4;
theta = 0;
%geomemtric params:
h = 0.5;
L1 = 5;
L2 = 1.5;
%field of vision params :
visual_angle = pi/4; 
y_max = 20; %cone of vision frontal distance limit (for plotting)
c = tan(visual_angle/2); %long run Field of vision length rate of change with respect to frontal distance y
%current positions of the scope ends  based on the parameters
A = [0;0;0];
B = zeros(3,1);
C = zeros(3,1); %position of the eye-side of the scope
D = zeros(3,1); %position of the other end of the scope
E = zeros(3,1);
F = zeros(3,1);
G = zeros(3,1);
H = zeros(3,1);

%% RIFLE LINE PLOTS INTITIALIZATION 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%draw the ground (plane z = 0)
figure
x = [-y_max, y_max, y_max, -y_max]; %adding the ground at z = -0.375*L1 where the bipod legs stand up from 
y = [-y_max, -y_max, y_max, y_max];
z = [-0.375*L1, -0.375*L1, -0.375*L1, -0.375*L1];
fill3(x, y, z,[0.6 0.2 0.0]);
alpha(0.2); % Adjust transparency
hold on;
C_ref = scatter3([C(1,1)],[C(2,1)],[C(3,1)],'filled', 'b'); % Blue color for C and text saying C
C_text = text(C(1,1), C(2,1), C(3,1), '  C', 'Color', 'b'); 
hold on;
D_ref = scatter3([D(1,1)],[D(2,1)],[D(3,1)], 'filled', 'r'); % Red color for D and text saying D
D_text = text(D(1,1), D(2,1), D(3,1), '  D', 'Color', 'r'); 
hold on
S_ref = plot3([C(1,1) D(1,1)],[C(2,1) D(2,1)], [C(3,1) D(3,1)],'Color','black'); %segment line plot of the scope
set(S_ref,'LineWidth',3);
hold on;
B_ref = plot3([0 0],[0 0],[0 0],'Color','black','Linewidth',3); %body line plot
hold on;
Ls_ref =  plot3([0 0],[0 0],[0 0],'Color','black','Linewidth',3); %left scope support line plot
hold on;
Rs_ref =  plot3([0 0],[0 0],[0 0],'Color','black','Linewidth',3); %right scope support line plot
hold on;
Bl_ref =  plot3([0 0],[0 0],[0 0],'Color','black','Linewidth',3); %left bipod leg line plot
hold on;
Br_ref = plot3([0 0],[0 0],[0 0],'Color','black','Linewidth',3); %right bipod leg line plot
hold on
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cone and local scope coordinates line plots initialization
Y_hat = linspace(0,y_max,1001);
X_hat = [0*Y_hat 0*Y_hat c*Y_hat -c*Y_hat];
Z_hat = [c*Y_hat -c*Y_hat 0*Y_hat 0*Y_hat];
Y_hat = [Y_hat Y_hat Y_hat Y_hat];
X = [];
Y = [];
Z = [];
Cv_ref = scatter3([],[],[],'yellow','Marker','.'); %cone of vision object 
hold on;
v1_ref = plot3([0 0],[0 0],[0 0],'Color','r');  %basis vectors of the scope coordinate system line plots
set(v1_ref,'LineWidth',2);
hold on;
v2_ref = plot3([0 0],[0 0],[0 0],'Color','g');
set(v2_ref,'LineWidth',2);
hold on;
v3_ref = plot3([0 0],[0 0],[0 0],'Color','b');
set(v3_ref,'LineWidth',2);
hold on;
N = 1000; %number of vertices 
V = zeros(3,N); %generate a set of vertices that form a unit circle about the x-z axis of world coordinates
for i=1:N
    V(1,i) = cos(i*(2*pi)/(N));
    V(2,i) = 5;
    V(3,i) = sin(i*(2*pi)/(N));
end
scatter3(V(1,:),V(2,:),V(3,:),'red','Marker','.');
T = zeros(3,3); %matrix that transforms scope local coordinates into shifted coordinates about C
xlabel("X");
ylabel("Y");
zlabel("Z");
grid on
axis equal

%% OBJECT DEFINITION AND SCOPE SCREEN CREATION:
figure 
u = linspace(0,2*pi,1000);
x = cos(u);
y = sin(u);
Scope_hud = scatter(x,y,'black','Marker','.');
hold on;
plot([-1 1],[0 0],'black');
hold on;
plot([0 0],[-1 1],'black');
hold on;
W = zeros(3,N); %same vertices inside V but described in scope coordinates
Visible_W = []; %same vertices as those inside W but only the subset that is visible by the scope
Scope_handle = scatter(W(1,:),W(3,:),'red','Marker','.'); %initialize the scatter plot handle to the scope screen 
axis([-1,1,-1,1]);
xlabel("x");
ylabel("y");
title("Scope's perspective");
axis equal
grid on
% axis equal;

%% Visualization of the rifle in space with observable scope coordinate system
theta =0.5*pi;
phi = theta;

%compute the coordinates of both ends of the scope based on derivations
B = [L1*sin(phi)*cos(theta);L1*sin(phi)*sin(theta);L1*cos(phi)];
C = [h*sin(phi-pi/2)*cos(theta); h*sin(phi-pi/2)*sin(theta); h*cos(phi-pi/2)];
D = [sqrt(h^2+L2^2)*sin(phi-atan(h/L2))*cos(theta);sqrt(h^2+L2^2)*sin(phi-atan(h/L2))*sin(theta);sqrt(h^2+L2^2)*cos(phi-atan(h/L2))];
E = [0.5*L1*sin(phi)*cos(pi+theta);0.5*L1*sin(phi)*sin(pi+theta);0.5*L1*cos(phi-pi)];
F = [-0.25*L1;0;-0.375*L1];
G = [0.25*L1;0;-0.375*L1];
H = [L2*sin(phi)*cos(theta);L2*sin(phi)*sin(theta);L2*cos(phi)];

%update the data in their respective line plots 
set(C_ref, {'XData', 'YData', 'ZData'}, {C(1,1), C(2,1), C(3,1)});
set(D_ref, {'XData', 'YData', 'ZData'}, {D(1,1), D(2,1), D(3,1)});
set(C_text,'Position',[C(1,1), C(2,1), C(3,1)]);
set(D_text,'Position',[D(1,1), D(2,1), D(3,1)]);
set(S_ref, {'XData', 'YData', 'ZData'}, {[C(1,1) D(1,1)], [C(2,1) D(2,1)], [C(3,1) D(3,1)]});
set(B_ref,{'XData','YData','ZData'},{[E(1,1) B(1,1)],[E(2,1) B(2,1)], [E(3,1) B(3,1)]});
set(Ls_ref,{'XData','YData','ZData'},{[A(1,1) C(1,1)],[A(2,1) C(2,1)], [A(3,1) C(3,1)]});
set(Rs_ref,{'XData','YData','ZData'},{[H(1,1) D(1,1)],[H(2,1) D(2,1)],[H(3,1) D(3,1)]});
set(Bl_ref,{'XData','YData','ZData'},{[F(1,1) A(1,1)],[F(2,1) A(2,1)],[F(3,1) A(3,1)]});
set(Br_ref,{'XData','YData','ZData'},{[G(1,1) A(1,1)],[G(2,1) A(2,1)], [G(3,1) A(3,1)]});

%% cone of vision coordinate transformation 
%define matrix that maps scope coords->coords translated around C
T = GetCameraMatrix(theta,phi,L2,h);
%draw the basis vectors emanating from C
set(v1_ref,{'XData','YData','ZData'},{[C(1,1) C(1,1)+T(1,1)],[C(2,1) C(2,1)+T(2,1)],[C(3,1) C(3,1)+T(3,1)]});
set(v2_ref,{'XData','YData','ZData'},{[C(1,1) C(1,1)+T(1,2)],[C(2,1) C(2,1)+T(2,2)],[C(3,1) C(3,1)+T(3,2)]});
set(v3_ref,{'XData','YData','ZData'},{[C(1,1) C(1,1)+T(1,3)],[C(2,1) C(2,1)+T(2,3)],[C(3,1) C(3,1)+T(3,3)]});
%draw the cone of vision emanating from the eye side of the scope i.e. : C
for i=1:size(Y_hat,2)
    result_vect = T*[X_hat(i);Y_hat(i);Z_hat(i)]+C;
    X(i) = result_vect(1,1);
    Y(i) = result_vect(2,1);
    Z(i) = result_vect(3,1);
end
set(Cv_ref,{'XData','YData','ZData'},{X,Y,Z});
%% project visible vertices onto the scope screen (without taking into account depth )
%first find the vertices coordinates from scope which is done by
%using the inverse of T
T_inverse = inv(T);
W = T_inverse*V; %W now has the object vertices with respect to scope coordinate system
dir = T_inverse*C;
for col =1:size(W,2)
    W(:,col) = W(:,col)-dir;
end
near = 1;
far = 1000;
for i=1:size(W,2) %repeat the algorithm for each vertex (culling algorithm ie: taking only the vertices that are inside the visible region)
    if (near<= W(2,i)) && (W(2,i)<= far) %the object is frontally visible by scope
        if (abs(W(1,i)) <= c*W(2,i)) %the object is laterally visible by scope
%             z_max = sqrt((c*W(2,i))^2-(W(1,i))^2); %cone of vision model
              z_max = c*W(2,i); %view frustum model
            if (abs(W(3,i)) <= z_max) % the object is vertically visible and inside cone overall
                W(1,i) = (W(1,i))/(c*W(2,i)); %scale x coordinate based on y
                W(2,i) = 0; %projection onto y = 0 plane so set this to 0
                W(3,i) = (W(3,i))/(z_max); %scale z coordinate based on x and y.
                if (sqrt(W(1,i)^2+W(3,i)^2) <= 1) %inside the scope reticle
                    Visible_W = [Visible_W W(:,i)]; %it is inside the visible region so keep it 
                end
            end
        end
    end
end 
%set the data of scope scatter plot using the visible vertices 
if size(Visible_W,2) > 0
    set(Scope_handle,{'XData','YData'},{Visible_W(1,:),Visible_W(3,:)});
end
%draw the updated changes on all the plots and pause:
drawnow();
pause(0.001);
%clear the vectors used for another time
Visible_W = [];

%Function that finds the (World-C) -> Scope coordinates transformation matrix
function [T] = GetCameraMatrix(theta,phi,L2,h)
    C = [h*sin(phi-pi/2)*cos(theta); h*sin(phi-pi/2)*sin(theta); h*cos(phi-pi/2)]; %left end of the scope (where the eye is placed)
    D = [sqrt(h^2+L2^2)*sin(phi-atan(h/L2))*cos(theta);sqrt(h^2+L2^2)*sin(phi-atan(h/L2))*sin(theta);sqrt(h^2+L2^2)*cos(phi-atan(h/L2))]; %right end of scope 
    T(:,2) = (D-C)/(norm(D-C)); %frontal direction is given by the scope direction vector normalized 
    T(:,1) = [cos(theta-0.5*pi) sin(theta-0.5*pi) 0 ]; %a vector orthogonal to the scope direction vector such that whats on the right of the eye means positive x 
    T(:,3) = cross(T(:,1),T(:,2));
    T(:,3) = (T(:,3))/(norm(T(:,3)));
end

