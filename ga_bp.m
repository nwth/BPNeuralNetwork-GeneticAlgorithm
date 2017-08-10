%%程序说明
% 主程序：ga_bp.m
% 适应度函数：gabpEval.m
% 编解码子函数：gadecod.m
% 使用前需安装gaot工具箱，上述三个文件需放在同一文件夹中且将该文件夹
% 运行程序时只需运行主程序ga_bp.m即可
% 保持一致，尤其是全局变量修改时（在gadecod.m和gabpEval.m中也要修改）
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
p=[];
t=[];
% 测试数据
k=[];
Ttest=[];
%% BP神经网络

% 网络创建
net=newff(minmax(p),[S1,1],{'tansig','purelin'},'trainlm'); 
% 设置训练参数
net.trainParam.show=10;
net.trainParam.epochs=10000;
net.trainParam.goal=1.0e-3;
net.trainParam.lr=0.2;
% 网络训练
[net,tr]=train(net,p,t);
% 仿真测试
s_bp=sim(net,k);    % BP神经网络的仿真结果
s_bp;
plot(s_bp,'*');
hold on;
plot(s_bp,'-');
%% GA-BP神经网络
R=size(p,1);
S2=size(t,1);
S=R*S1+S1*S2+S1+S2;
aa=ones(S,1)*[-1,1];
popu=50;  % 种群规模
initPpp=initializega(popu,aa,'gabpEval');  % 初始化种群
gen=100;  % 遗传代数
% 调用GAOT工具箱，其中目标函数定义为gabpEval
[x,endPop,bPop,trace]=ga(aa,'gabpEval',[],initPpp,[1e-6 1 1],'maxGenTerm',gen,...'normGeomSelect',[0.09],['arithXover'],[2],'nonUnifMutation',[2 gen 3]);
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
s_ga=sim(net,k);     %遗传优化后的仿真结果

gabpEval.m
function[sol,val]=gabpEval(sol,options)
global S
for i=1:S
x(i)=sol(i);
end;
[W1,B1,W2,B2,val]=gadecod(x);

gabpcod.m
function[W1,B1,W2,B2,val]=gadecod(x)
global p
global t
global R
global S2
global S1
global S
% 前R*S1个编码为W1
for i=1:S1
    for k=1:R
        W1(i,k)=x(R*(i-1)+k);
    end
end
% 接着的S1*S2个编码(即第R*S1个后的编码)为W2
for i=1:S2
    for k=1:S1
        W2(i,k)=x(S1*(i-1)+k+R*S1);
    end
end
% 接着的S1个编码(即第R*SI+SI*S2个后的编码)为B1
for i=1:S1
    B1(i,1)=x((R*S1+S1*S2)+i);
end
%接着的S2个编码(即第R*SI+SI*S2+S1个后的编码)为B2
for i=1:S2
    B2(i,1)=x((R*S1+S1*S2+S1)+i);
end
% 计算S1与S2层的输出
A1=tansig(W1*p,B1);
A2=purelin(W2*A1,B2);
% 计算误差平方和
SE=sumsqr(t-A2);
% 遗传算法的适应值
val=1/SE;

