clear all  
clc   %清除命令窗口  
load Data-Ass2;  
d=data';  %求转置  
dat=d(1:2500,1:2);  
labels=d(1:2500,3);  
  
  
inputNums=2; %输入层节点  
outputNums=1; %输出层节点  许多情况下直接用1表示  
hideNums=10; %隐层节点数  
maxcount=1000; %最大迭代次数  
samplenum=2500; %一个计数器，无意义  
precision=0.001; %预设精度  
alpha=0.01; %学习率设定值  
a=0.5; %BP优化算法的一个设定值，对上组训练的调整值按比例修改   
error=zeros(1,maxcount+1); %error数组初始化；目的是预分配内存空间  
errorp=zeros(1,samplenum); %同上  
w=rand(hideNums,outputNums); %10*3;w表隐层到输出层的权值  
  
%求聚类中心  
[Idx,C]=kmeans(dat,hideNums);  
%X 2500*2的数据矩阵   
%K 表示将X划分为几类   
%Idx 2500*1的向量，存储的是每个点的聚类标号   
%C 10*2的矩阵，存储的是K个聚类质心位置  
  
%求扩展常数  
dd=zeros(1,10);   
for i=1:10  
  dmin=10000;  
  for j=1:10   
    ddd=(C(i,1)-C(j,1))^2+(C(i,2)-C(j,2))^2;  
    if(ddd<dmin&&i~=j)  
    dmin=ddd;  
    end  
  end  
  dd(i)=dmin;  
end  
  
%b为进行计算后隐含层的输入矩阵  
b=zeros(2500,10);   
for i=1:2500  
  for j=1:10   
    b(i,j)=exp( -( (dat(i,1)-C(j,1))^2+(dat(i,2)-C(j,2))^2 )/(2*dd(j)) );%dd为扩展常数  
  end  
end  
  
  
count=1;  
while (count<=maxcount) %结束条件1迭代1000次  
  
c=1;  
while (c<=samplenum)%对于每个样本输入，计算输出，进行一次BP训练，samplenum为2500  
  
    %o输出的值  
    double o;  
    o=0.0;  
    for i=1:hideNums  
        o=o+b(c,i)*w(i,1);  
    end  
  
    %反馈/修改;   
    errortmp=0.0;    
    errortmp=errortmp+(labels(c,1)-o)^2; % 第一组训练后的误差计算    
    errorp(c)=0.5*errortmp;       
    yitao=labels(c,1)-o; %输出层误差  
    for i=1:hideNums  %调节到每个隐藏点到输出点的权重  
        w(i,1)=w(i,1)+alpha*yitao*b(c,i);%权值调整  
    end  
  
    c=c+1; %输入下一个样本数据  
end  %第二个while结束；表示一次训练结束  
  
  
%求最后一次迭代的误差  
double tmp;  
tmp=0.0; %字串8   
for i=1:samplenum  
    tmp=tmp+errorp(i)*errorp(i);%误差求和  
end  
tmp=tmp/c;  
error(count)=sqrt(tmp);%求迭代第count轮的误差求均方根,即精度  
if (error(count)<precision)%另一个结束条件  
    break;  
end  
count=count+1;%训练次数加1  
end  
  
%测试  
test=zeros(500,10);   
for i=2501:3000  
for j=1:10   
test(i-2500,j)=exp( -( (d(i,1)-C(j,1))^2+(d(i,2)-C(j,2))^2 )/(2*dd(j)) );%dd为扩展常数  
end  
end  
  
count=0;  
for i=2501:3000  
  net=0.0;  
  for j=1:hideNums  
    net=net+test(i-2500,j)*w(j,1);  
  end  
  if( (net>0&&d(i,3)==1) || (net<=0&&d(i,3)==-1) )  
  count=count+1;  
  end  
end  
