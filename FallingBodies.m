clear all 
format long
% %Mock script for the simulation of a ballistic computer model which has the
% %goal of simulating an sniper shooting situation where the shooter is
% %helped to hit a target, given that the sniper is mounted to the ground.
% %The sniper is mounted thanks to a bipode that holds to the ground and
% %allows the rifle to be rotated around the center of it. The origin is the
% %center of mass of the bipode (the upper corner where the two legs intersect).
% %% Parameters
% %Rifle design parameter:
L1 = 1; %rifle right body length
L2 = 0.5; %scope length
h = 0.1; %length between body and scope
% %Projectile motion parameters:
v = 15; %sniper rifle bullet speed (arclength velocity)
theta = 1.52; %shooting angle in radians
g = -10; %constant gravitational force
dt = 0.01; %step size in time

% %% lets shoot at different angles drawing the resulting trajectories
% theta_deg = input("Shooting angle (in degrees): ");
% while (((0<=theta_deg)&&(theta_deg <= 90))||((270<=theta_deg)&&(theta_deg<=360)))
% theta = theta_deg*(pi/180);
% fprintf("Shot at %d degrees\n",theta_deg);
% t_air = AirTime(v,theta,L1,g,-10);
% fprintf("Time in air : %d\n",t_air);
% X(1) = L1*cos(theta);
% Y(1) = L1*sin(theta);
% for n =1:ceil(t_air/dt)
%       X(n+1) = GetX(n*dt,v,theta,L1);
%       Y(n+1) = GetY(n*dt,v,theta,L1,g);
% end
% plot(X,Y,'red');
% X = [];
% Y = [];
% hold on;
% theta_deg = input("Shooting angle (in degrees): ");
% end
%% testing the resulting trajectories with many thetas equally spaced (finding the safety region)
% T = linspace(0,2*pi,2000);
% for t=1:length(T)
%     theta = T(t);
%     t_air = AirTime(v,theta,L1,g,-10);
%     X(1) = L1*cos(theta);
%     Y(1) = L1*sin(theta);
%     for n =1:ceil(t_air/dt)
%       X(n+1) = GetX(n*dt,v,theta,L1);
%       Y(n+1) = GetY(n*dt,v,theta,L1,g);
%     end
%     plot(X,Y,'red');
%     X = [];
%     Y = [];
%     hold on;
% end
% xlabel("x");
% ylabel("y");
% title("Safety region (outside of the red)");
% axis equal;

%% Finding the 2 shooting angles to hit a REACHABLE (outside safety region) target T
T(1,1) = input("Tx:");
T(2,1) = input("Ty:");
Sweet_Angles = [];
F = @(x,c1,c2,c3,c4,c5)0.5*c4/(c3^2)*(sec(x)^2)*(c1-c5*cos(x))^2+tan(x)*(c1-c5*cos(x))+(c5*sin(x)-c2);
c1 = T(1,1);
c2 = T(2,1);
c3 = v;
c4 = g;
c5 = L1;
K = 4; %order of partition of the interval [0,2pi] for initial guessing
for i=1:K
    theta_knot = i*(2*pi/K);
    angle = fzero(@(x)F(x,c1,c2,c3,c4,c5),theta_knot); %newton iterations on F 
    %look for valid angles (that is, where the time till hit is positive)
    t_air = (T(1,1)-L1*cos(angle))/(v*cos(angle)); %find its respective t and ensure it is positive to be a time
    if (t_air >= 0)
        if (size(Sweet_Angles,1) == 0) %first angle found 
            Sweet_Angles(1,1) = angle;
        else
            if (Sweet_Angles(1,1) ~= angle) %second angle found
                Sweet_Angles(2,1) = angle;
                break;
            end
            %otherwise, the angle was repeated so keep searching
        end
    end
end
%Plot the 2 trajectories according to each angle found
for j=1:2
    t_air = AirTime(v,Sweet_Angles(j,1),L1,g,T(2,1));  
for l=1:(ceil(t_air/dt)+1)
        X(l,1) = GetX((l-1)*dt,v,Sweet_Angles(j,1),L1);
        Y(l,1) = GetY((l-1)*dt,v,Sweet_Angles(j,1),L1,g);
end
plot(X,Y,'red');
axis equal
grid on;
hold on;
%drawing the sniper geometry on the plot
plot([0.5*L1*cos(pi+Sweet_Angles(j,1)) L1*cos(Sweet_Angles(j,1))],[0.5*L1*sin(pi+Sweet_Angles(j,1)),L1*sin(Sweet_Angles(j,1)) ],'color','black')
plot([0 L2/4],[0 -L2/2],'color','black');
plot([-L2/4 0],[-L2/2 0],'color','black');
plot([h*cos(0.5*pi+Sweet_Angles(j,1)) sqrt(L2^2+h^2)*cos(atan(h/L2)+Sweet_Angles(j,1))],[h*sin(0.5*pi+Sweet_Angles(j,1)) sqrt(L2^2+h^2)*sin(atan(h/L2)+Sweet_Angles(j,1))],'color','black');
plot([0 h*cos(0.5*pi+Sweet_Angles(j,1))],[0 h*sin(0.5*pi+Sweet_Angles(j,1))],'color','black');
plot([L2*cos(Sweet_Angles(j,1)), sqrt(L2^2+h^2)*cos(atan(h/L2)+Sweet_Angles(j,1)) ],[L2*sin(Sweet_Angles(j,1)) sqrt(L2^2+h^2)*sin(atan(h/L2)+Sweet_Angles(j,1))],'color','black')
%vertical correction calculation:
vertical_correction = abs(T(1,1))*tan(Sweet_Angles(j,1))
%visualize the line of sight. The intersection should be
%vertical_correction units different in the vertical direction of T
hold on;
plot([sqrt(L2^2+h^2)*cos(atan(h/L2)+Sweet_Angles(j,1)) sqrt(L2^2+h^2)*cos(atan(h/L2)+Sweet_Angles(j,1))+1],[sqrt(L2^2+h^2)*sin(atan(h/L2)+Sweet_Angles(j,1)) sqrt(L2^2+h^2)*sin(atan(h/L2)+Sweet_Angles(j,1))+tan(Sweet_Angles(j,1))],'color','magenta');
hold on;
X = [];
Y = [];
end
%since the target is usually a body, the target point is the center of it
%so we allow an error of at most eps units of distance while still serving
%as a hit on target.
A = linspace(0,2*pi,1001);
for u=1:length(A)
    X(u) = T(1,1)+0.5*cos(A(u));
    Y(u) = T(2,1)+0.5*sin(A(u));
end
plot(X,Y,'--','color','blue');
hold on;
scatter(T(1,1),T(2,1),'filled','green');
title("Shooting angles");
xlabel("x");
ylabel("y");
function x = GetX(t,v,theta,L1)
x = L1*cos(theta)+v*cos(theta)*t;
end
function y = GetY(t,v,theta,L1,g)
y = L1*sin(theta)+v*sin(theta)*t +0.5*g*t^2;
end
%time in air 
function t = AirTime(v,theta,L1,g,y0) %supposing that the ground is at y = y0
t = (-v*sin(theta)-sqrt(v^2*(sin(theta))^2-2*g*(L1*sin(theta)-y0)))/(g);
end



% Example of animating a sine wave using drawnow in MATLAB
% 
% x = linspace(0, 2*pi, 100);
% for t = 1:100
%     y = sin(x - t);
%     plot(x, y);
%     xlabel('X-axis');
%     ylabel('Y-axis');
%     title('Sine Wave Animation');
%     drawnow; % Update the figure window
% end

