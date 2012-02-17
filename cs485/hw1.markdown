1. (5) Consider rigid body transformations in the plane. Draw a right triangle
defined by three points A = (2,1),B = (4,1),C = (4,6).

T1: [ cos(θ) -sin(θ) ; sin(θ) cos(θ) ]

1a. What is the determinant of the matrix?

~~~
cos^2(theta) + sin^2(theta) = 1.
~~~

The determinant of any 2x2 matrix [ a b; c d ] is ad - bc.

T2 = [ sin(\theta) cos(\theta) ; cos(\theta) -sin(\theta) ]

1b. Is the matrix orthonormal?

~~~
No, because the column 1 vector and column 2 vector are not orthogonal unit vectors.
~~~

1b. What is the determinant of the matrix?

~~~
- cos^2(\theta) - sin^2(\theta) = -1.
~~~

  * Orthonormal matrix implies columns and rows are orthogonal unit vectors.

  * The determinant of any 2x2 matrix [ a b ; c d ] is ad - bc.

1c. Is T2 rigid body transformation? What is the difference between T1 and T2,
how are the results different.

    Answer 1. No, it is not a rigid body transformation (like the rotation
    matrix).

    Answer 2. T1 is a rotation matrix whereas T2 is not a rotation matrix.

    Answer 3. You can see from drawing the transformed triangle that the red and
    green triangle are rotations using T1, whereas the white and yellow
    triangles seem to be something like a reflection.

2. Answer:

~~~
[  cos(x),          -sin(x),           0       ;
   cos(x)\*sin(x),   cos(x)^2,        -sin(x)  ;
   sin(x)^2,         cos(x)\*sin(x),   cos(x)  ]
~~~

I obtained this by defining two orthonormal matrices and multiplying them
together. Order is important! My work in Matlab.

~~~
syms x p1 p2 p3
rx = [ 1       0        0      ;
       0       cos(x)  -sin(x) ;
       0       sin(x)   cos(x) ]
rz = [ cos(x) -sin(x)   0      ;
       sin(x)  cos(x)   0      ;
       0       0        1      ]
ps = [ p1 ; p2 ; p3 ]
rr = rx * rz * ps
~~~

3.  omega:  1.8138 
    axis:   1.0472    1.0472    1.0472

    r   = [ 0.1729 -0.1468 0.9739 ; 0.9739 0.1729 -0.1468 ; -0.1468 0.9739 0.1729 ]
    r2  = [ r(3,2)-r(2,3) r(1,3)-r(3,1) r(2,1)-r(1,2) ]
     
    omega = acos((trace(r)-1)/2)
    omega_over_determinant = (1/(2*sin(omega)))*r2


  b. v is the eigenvector, lamda is an orthormal rotation matrix so
     rotation does not change the eigenvector.

    [v, lambda] = eig(r)

    v =
     
      -0.2887 + 0.5000i  -0.2887 - 0.5000i   0.5774          
       0.5774             0.5774             0.5774          
      -0.2887 - 0.5000i  -0.2887 + 0.5000i   0.5774          
     
     
    lambda =
     
      -0.2406 + 0.9706i        0                  0          
            0            -0.2406 - 0.9706i        0          
            0                  0             1.0000 



4. I describe the transformation in order to help indicate if I misunderstand the
   problem description or the material or both.

   T:ab, means from B to A.
   - Rotate about Z by theta = 180 degrees
   - Horizontal translation along X axis
   - Dv = [ -d ; 0 ; 0 ] 

   Matlab: subs( Rz, theta, pi )

   [  0 -1  0
      1  0  0
      0  0  1 ]  * T + Dv   

   T:bc, means from C to B.  It appears that this requires a more complex rotation
   in order to align the three axis of frame C to frame B.
   - Rotate about Y by 90 degrees.
   - Rotate about Z by 30+90 degrees.
   - Dv = [ 0 ; 0 ; -d ] 

   Matlab: subs( Rz, theta, 2*pi/3 ) * subs( Ry, theta, pi/2 )

   [ -0.0000   -0.8660    0.5000   ;
      0.0000   -0.5000   -0.8660   ;
      1.0000         0    0.0000   ] * T + Dv

   T:cb, means from B to C
   - Rotate about Z by -(30+90) degrees.
   - Rotate about Y by -90 degrees.
   - (transpose of previous matrix?)
   - Dv = [ 0 ; 0 ; d ] 

   Matlab: subs( Ry, theta, -pi/2 ) * subs( Rz, theta, -2*pi/3 )

   [  -0.0000    0.0000    1.0000
      -0.8660   -0.5000         0
       0.5000   -0.8660    0.0000 ] * T + Dv

   I use the following to calculate rotations:

   Rz = [  cos(theta)  -sin(theta)    0    ;
           sin(theta)   cos(theta)    0    ;
           0            0             1    ]

   Ry = [  cos(theta)   0  -sin(theta)     ;
           0            1            0     ;
           sin(theta)   0   cos(theta)     ]

   Rx = [  1            0            0     ;
           0   cos(theta)  -sin(theta)     ;
           0   sin(theta)   cos(theta)     ]
   

5. The determinant is...

~~~
l1*l2*sin(theta1 + theta2)*cos(theta1) - l1^2*cos(theta1 + theta2)*sin(theta1)
~~~

   ...solved using matlab...

~~~
   syms l1 l2 theta1 theta2
   x = l1 * cos(theta1) + l2 * cos(theta1 + theta2)
   y = l1 * sin(theta1) + l1 * sin(theta1 + theta2)
   J = [  diff(x, 'theta1') diff(x, 'theta2')  ;
          diff(y, 'theta1') diff(y, 'theta2')  ]
   det(J)
~~~

Part two answer:

~~~
   In general, combinations of theta1 and theta2 that result in zero terms on both
   parts of the jacobian will result in a zero determinant and are not reachable by
   the arm.

   theta1 = 90, theta2 = -90 is one singularity.  This will create a zero in each
   term of the product.  theta1 = 270, theta2 = -270, theta1 = 0, theta2 = 0.
~~~

Elaboration:

... singularities occur where the matrix is not invertible.  This occurs where
the determinant is zero.  I'm not clear on the best way to calculate this using
matlab or express the function of all possible theta1, theta2.  But here are
some examples:




6. Longer time steps increase the radius of the turn.

steps_1 = diffdrive([100;50;pi/4] , 1 , pi/90 , 200, 1) % red
steps_2 = diffdrive([100;50;pi/4] , 1 , pi/90 , 200, 2) % blue
steps_3 = diffdrive([100;50;pi/4] , 1 , pi/90 , 200, 3) % green

The code for the differential drive:

~~~
%
% example usage:
% steps = diffdrive([4;4;pi/4] , 1 , pi/90 , 100, 1)
% plot(steps(1,:), steps(2,:), 'r')
% axis([-5 5 -5 5])
%
function [ R ] = diffdrive( I, v, omega, steps, delta )

    % These are used to accumulate values that
    % will be plotted later.
    x     = I(1,1);
    y     = I(2,1);
    theta = I(3,1);
    
    xs = [];
    ys = [];
    thetas = [];

    % Let us take a walk...
    for i=1:steps
        
        x = cos(theta) * v * delta + x;
        y = sin(theta) * v * delta + y;
        theta = theta + omega;

        xs     = [ xs, x ];
        ys     = [ ys, y ];
        thetas = [ thetas, theta ];
      
    end
  
    % R is for (R)esult
    R = [ xs; ys; thetas ]
  
end
~~~