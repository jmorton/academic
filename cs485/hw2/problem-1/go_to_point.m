function [R] = go_to_point(x, y, theta, xd, yd)

  delta    = 1;
  
  xs       = [x];
  ys       = [y];
  thetas   = [theta];
  vs       = [0];
  
  
  vK      = 0.1;
  omegaK  = 0.1;

  plot_robot(x, y, theta);
  
  hold;

  for i=1:100
  
    % The velocity is...
    v = vK * sqrt( (x-xd)^2 + (y-yd)^2 );  
  
    % Relative angle between vehicle and goal
    theta_d = atan( (yd-y) / (xd-x) );
  
    % The angle is...
    omega  = omegaK * angdiff(theta_d, theta);
    
    x = cos(theta) * v * delta + x;
    y = sin(theta) * v * delta + y;
    theta = theta + omega * delta;

    xs      = [ xs, x ];
    ys      = [ ys, y ];
    thetas  = [ thetas, theta ];
    vs      = [ vs, v ];
    
    plot_robot(x, y, theta);
    
  end
  
  hold off
    
  R = [ xs ; ys ; thetas ];
  
end
