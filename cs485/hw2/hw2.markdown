1. Solution 1:

![solution1](https://github.com/jmorton/academic/blob/master/cs485/hw2/problem-1/s1.jpg)

x0 = [  0  0 pi ];
xg = [ 10 10    ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-15 15 -15 15]);

Solution 2:

x0 = [ 10 10 0 ];
xg = [  9 10 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-15 15 -15 15]);

Solution 3:
x0 = [  0 -6 (3/2)*pi ];
xg = [  0   0 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-10 10 -10 10]);

Solution 4:
x0 = [  -1 -6 (3/2)*pi ];
xg = [  0   0 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-10 10 -10 10]);

Solution 5:
x0 = [  -1 -6 (3/2)*pi ];
xg = [  0   0 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-10 10 -10 10]);

Solution 6:
x0 = [  -2 -6 pi ];
xg = [  0   0 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-10 10 -10 10]);

Solution 7:
x0 = [  -2 -2 (7*pi)/6 ];
xg = [  0   0 ];
r  = sim('sl_drivepoint');
q  = r.find('yout');
plot(q(:,1), q(:,2))
axis([-10 10 -10 10]);

I 

X1:
r = go_to_point(0, 0, pi/2, 10, 10);

X2:
r = go_to_point(0, 0, pi, 10, 10);

X3:
r = go_to_point(0, 0, 0, 10, 10);

X4:
r = go_to_point(0, 0, (3*pi/2), 10, 10);

X5:
r = go_to_point(0, 0, pi/4, 10, 10);
