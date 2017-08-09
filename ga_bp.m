%% 程序说明
% 主程序：ga_bp.m
% 适应度函数：gabpEval.m
% 编解码子函数：gadecod.m
% 使用前需安装gaot工具箱，上述三个文件需放在同一文件夹中且将该文件夹
% 设置为当前工作路径
% 运行程序时只需运行主程序ga_bp.m即可
% 此程序仅为示例，针对其他的问题，只需将数据修改即可，但需注意变量名
% 保持一致，尤其是全局变量修改时（在gadecod.m和gabpEval.m中也要修改）
% 版权归MATLAB中文论坛所有，转载请注明
%% 清除环境变量
clear all
clc
warning off 
nntwarn off
%% 声明全局变量
global p     % 训练集输入数据
global t     % 训练集输出数据
global R     % 输入神经元个数
global S2    % 输出神经元个数
global S1    % 隐层神经元个数
global S     % 编码长度
S1=25;
%% 导入数据

% 训练数据
day=[0.9363 -0.9698 -0.9907 -0.9562 -0.9507 0.9363 -0.9164 0.9045 0.8918;
 -0.9358 -0.9751 0.9821 -0.9544 -0.9469 0.9426 0.9182 0.8967 -0.8841;
0.9516 -0.9781 -0.9744 -0.9525 0.9509 0.9368 0.9082 -0.8903 -0.8665;
 -0.9480 -0.9795 -0.9796 -0.9507 0.9509 0.9300 -0.9075 -0.8902 -0.8671;
 -0.9433 -0.9923 -0.9812 -0.9596 -0.9406 -0.9230 0.9071 -0.8864 -0.8547;
 -0.9424 1.0000 -0.9800 -0.9514 0.9349 -0.9089 0.9206 -0.8780 -0.8414;
0.9355 -0.9878 -0.9737 -0.9499 0.9337 0.9084 -0.9072 -0.8745 -0.8332];
% 数据归一化
[dayn,minday,maxday]=premnmx(day);
% 输入和输出样本
p=dayn(:,1:8);
t=dayn(:,2:9);
% 测试数据
k=[0.9435 0.9796 -0.9706 -0.9552 -0.9298 -0.9130 -0.9003 0.8708 0.8234;
    -0.9358 -0.9751 0.9821 -0.9544 -0.9469 0.9426 0.9182 0.8967 -0.8841;
0.9516 -0.9781 -0.9744 -0.9525 0.9509 0.9368 0.9082 -0.8903 -0.8665;
 -0.9480 -0.9795 -0.9796 -0.9507 0.9509 0.9300 -0.9075 -0.8902 -0.8671;
 -0.9433 -0.9923 -0.9812 -0.9596 -0.9406 -0.9230 0.9071 -0.8864 -0.8547;
 -0.9424 1.0000 -0.9800 -0.9514 0.9349 -0.9089 0.9206 -0.8780 -0.8414;
     -0.9496 -0.9778 -0.9693 -0.9536 -0.9352 -0.9111 -0.9076 0.8797 -0.8227];
% 数据归一化
 kn=tramnmx(k,minday,maxday);
%% BP神经网络

% 网络创建
net=newff(minmax(p),[S1,7],{'tansig','purelin'},'trainlm'); 
% 设置训练参数
net.trainParam.show=10;
net.trainParam.epochs=2000;
net.trainParam.goal=1.0e-28;
net.trainParam.lr=0.3;
% 网络训练
[net,tr]=train(net,p,t);
% 仿真测试
s_bp=sim(net,kn);    % BP神经网络的仿真结果
%% GA-BP神经网络

R=size(p,1);
S2=size(t,1);
S=R*S1+S1*S2+S1+S2;
aa=ones(S,1)*[-1,1];
popu=50;  % 种群规模
initPpp=initializega(popu,aa,'gabpEval');  % 初始化种群
gen=100;  % 遗传代数
% 调用GAOT工具箱，其中目标函数定义为gabpEval
[x,endPop,bPop,trace]=ga(aa,'gabpEval',[],initPpp,[1e-6 1 1],'maxGenTerm',gen,...
'normGeomSelect',[0.09],['arithXover'],[2],'nonUnifMutation',[2 gen 3]);
% 绘均方误差变化曲线
figure(1)
plot(trace(:,1),1./trace(:,3),'r-');
hold on
plot(trace(:,1),1./trace(:,2),'b-');
xlabel('Generation');
ylabel('Sum-Squared Error');
% 绘制适应度函数变化
figure(2)
plot(trace(:,1),trace(:,3),'r-');
hold on
plot(trace(:,1),trace(:,2),'b-');
xlabel('Generation');
ylabel('Fittness');
% 计算最优的权值和阈值
[W1,B1,W2,B2,val]=gadecod(x);
net.IW{1,1}=W1;
net.LW{2,1}=W2;
net.b{1}=B1;
net.b{2}=B2;
% 利用新的权值和阈值进行训练
net=train(net,p,t);
% 仿真测试
s_ga=sim(net,kn);     %遗传优化后的仿真结果

