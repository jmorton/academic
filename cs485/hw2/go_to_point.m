% x0 : initial pose x, y, theta
% xg : goal x, y
%
function [R] = go_to_point(xi, xg)
  % break up the initial pose and goal
  x        = xi(1);
  y        = xi(2);
  theta    = xi(3);
  xd       = xg(1);
  yd       = xg(2);
  
  % keep a record of where the robot moves
  xs       = [x];
  ys       = [y];
  thetas   = [theta];
  vs       = [0];
  
  % gain and other params
  delta    = 1;  
  ka       = 0.1;
  kb       = 0.1;
  kr       = 0.1;
  t        = 1;
  
  hold;
  
  plot_robot(x, y, theta);
  
  while t < 30 % need to break out when at goal.
    deltaX  = (x-xd);
    deltaY  = (y-yd);
  
    rho      = sqrt( deltaX^2 + deltaY^2 );    
    alpha    = atan2(deltaY, deltaX) - theta;
    
    if abs(alpha) > pi
        alpha = alpha - sign(alpha)*2*pi;
    end;
    
    beta = -theta - alpha;
    
    %rhot(t)  = rho;
    %alpha(t) = alpha;
    %betat(t) = beta;
    v        = (kr*rho);
    omega    = (ka*alpha + kb*beta);
    
    if ((alpha > -pi/2) & (alpha <= pi/2))
    else
      v = -v;
    end
    
    t = t+1;
    
    x = cos(theta) * v * delta + x;
    y = sin(theta) * v * delta + y;
    theta = theta + omega * delta;
    
    xs      = [ xs, x ];
    ys      = [ ys, y ];
    thetas  = [ thetas, theta ];
    vs      = [ vs, v ];
    
    plot_robot(x, y, theta);
    
  end
    
  R = [ xs ; ys ; thetas ];
  
end