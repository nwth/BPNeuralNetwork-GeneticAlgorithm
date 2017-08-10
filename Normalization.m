function normal = normalization(x,kind)
%输入
%x:样本数据，每列为一个样本，每行为一类特征属性
% kind :1 or 2表示第一类与第二类归一化
x=[样本数据];
kind=2;
%输出：
%normal1：归一化后的数据
if nargin < 2
    kind = 2;%kind = 1 or 2 
end
 
[m,n]  = size(x);
normal = zeros(m,n);
%% normalize the data x to [0,1]
if kind == 1
    for i = 1:m
        ma = max( x(i,:) );
        mi = min( x(i,:) );
        normal(i,:) = ( x(i,:)-mi )./( ma-mi );
    end
end
%% normalize the data x to [-1,1]
if kind == 2
    for i = 1:m
        mea = mean( x(i,:) );
        va = var( x(i,:) );
        normal(i,:) = ( x(i,:)-mea )/va;
    end
end
