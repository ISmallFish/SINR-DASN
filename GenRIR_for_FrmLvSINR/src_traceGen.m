function [trajectory, vec_as_arr, choosed_idx] = src_traceGen(room_size,vec_rs,vec_as,mov_dis)

% Length x Width
room_length = room_size(1);
room_width  = room_size(2);

% The initial position and movement direction of the source.
x0 = vec_rs(1); 
y0 = vec_rs(2); 

vx = vec_rs(1) - vec_as(1);  
vy = vec_rs(2) - vec_as(2);  
vz = vec_rs(3) - vec_as(3);  

step_dis = 0.001;
v        = step_dis*[vx vy]/sqrt(vx^2+vy^2);
vx       = v(1);
vy       = v(2);

% Simulate the trajectory of the source.
num_steps       = round(mov_dis/step_dis); % The number of simulation steps.

trajectory      = zeros(num_steps, 2);     % The array for storing the trajectory.
vec_as_arr      = zeros(num_steps, 3);
vec_as_arr(:,3) = vec_as(3);

for step = 1:num_steps
    
    % Update pos. of source
    x0 = x0 + vx;
    y0 = y0 + vy;
    
    % Check if the x-axis boundary is crossed; if so, apply collision and rebound.
    if x0 < 0 || x0 > room_length
        vx = -vx;
        x0 = max(0, min(room_length, x0)); % Adjust the position to ensure it remains within the boundaries.
    end
    
    % Check if the y-axis boundary is crossed; if so, apply collision and rebound.
    if y0 < 0 || y0 > room_width
        vy = -vy;
        y0 = max(0, min(room_width, y0)); % Adjust the position to ensure it remains within the boundaries.
    end
    
    % Store the current position in the trajectory array.
    trajectory(step, :) = [x0, y0];
    
    vec_as_arr(step, 1) = - vx/sqrt(vx^2+vy^2)*sqrt(1 - vz^2) + x0;
    vec_as_arr(step, 2) = - vy/sqrt(vx^2+vy^2)*sqrt(1 - vz^2) + y0;

end

choosed_idx = (1:10)*floor(num_steps/10);
