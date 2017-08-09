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