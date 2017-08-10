%Generate some training data
clc;
clear;
interval=0.01;
x1=-1.5:interval:1.5;
x2=-1.5:interval:1.5;
F = 20+x1.^2-10*cos(2*pi*x1)+x2.^2-10*cos(2*pi*x2);
net=newrbe([x1;x2],F)

ty=sim(net,[x1;x2]);
figure
plot3(x1,x2,F,'g');
figure
plot3(x1,x2,ty,'b');
