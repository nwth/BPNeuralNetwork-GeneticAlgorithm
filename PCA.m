function y = pca(mixedsig)

%程序说明：y = pca(mixedsig)，程序中mixedsig为 n*T 阶混合数据矩阵，n为信号个数，T为采样点数
% y为 m*T 阶主分量矩阵。
% n是维数，T是样本数。

if nargin == 0
    error('You must supply the mixed data as input argument.');
end
if length(size(mixedsig))>2
    error('Input data can not have more than two dimensions. ');
end
if any(any(isnan(mixedsig)))
    error('Input data contains NaN''s.');
end

%去均值
meanValue = mean(mixedsig')';
[m,n] = size(mixedsig);
%mixedsig = mixedsig - meanValue*ones(1,size(meanValue)); %当数据本身维数很大时容易出现Out of memory
for s =  1:m
    for t = 1:n
        mixedsig(s,t) = mixedsig(s,t) - meanValue(s);
    end
end
[Dim,NumofSampl] = size(mixedsig);
oldDimension = Dim;
fprintf('Number of signals: %d\n',Dim);
fprintf('Number of samples: %d\n',NumofSampl);
fprintf('Calculate PCA...');
firstEig = 1;
lastEig = Dim;
covarianceMatrix = corrcoef(mixedsig');    %计算协方差矩阵
[E,D] = eig(covarianceMatrix);          %计算协方差矩阵的特征值和特征向量

%计算协方差矩阵的特征值大于阈值的个数lastEig
%rankTolerance = 1;
%maxLastEig = sum(diag(D) >= rankTolerance);
%lastEig = maxLastEig;
lastEig = 10;

%降序排列特征值
eigenvalues = flipud(sort(diag(D)));

%去掉较小的特征值
if lastEig < oldDimension
    lowerLimitValue = (eigenvalues(lastEig) + eigenvalues(lastEig + 1))/2;
else
    lowerLimitValue = eigenvalues(oldDimension) - 1;
end
lowerColumns = diag(D) > lowerLimitValue;

%去掉较大的特征值
if firstEig > 1
    higherLimitValue = (eigenvalues(firstEig - 1) + eigenvalues(firstEig))/2;
else
    higherLimitValue = eigenvalues(1) + 1;
end
higherColumns = diag(D) < higherLimitValue;
%合并选择的特征值
selectedColumns =lowerColumns & higherColumns;
%输出处理的结果信息
fprintf('Selected [%d] dimensions.\n',sum(selectedColumns));
fprintf('Smallest remaining (non-zero) eigenvalue[ %g ]\n',eigenvalues(lastEig));
fprintf('Largest remaining (non-zero) eigenvalue[ %g ]\n',eigenvalues(firstEig));
fprintf('Sum of removed eigenvalue[ %g ]\n',sum(diag(D) .* (~selectedColumns)));
%选择相应的特征值和特征向量
E = selcol(E,selectedColumns);
D = selcol(selcol(D,selectedColumns)',selectedColumns);
%——————————计算白化矩阵———————————
whiteningMatrix = inv(sqrt(D)) * E';
dewhiteningMatrix = E * sqrt(D);
%——————————提取主分量————————————
y = whiteningMatrix * mixedsig;
%——————————行选择子程序———————————
function newMatrix = selcol(oldMatrix,maskVector)
if size(maskVector,1)~= size(oldMatrix,2)
    error('The mask vector and matrix are of uncompatible size.');
end
numTaken = 0;
for i = 1:size(maskVector,1)
    if maskVector(i,1) == 1  
        takingMask(1,numTaken + 1) = i;
        numTaken = numTaken + 1;
    end
end
newMatrix = oldMatrix(:,takingMask);

%清屏 
clear 
%初始化数据 
a=[六维目标矩阵]；
x=a; 
%调用princomp函数 
[coef,score,latent,t2] = princomp(x); 
score 
%测试score是否和score_test一样 
score_test=bsxfun(@minus,x,mean(x,1))*coef; 
score_test;
latent=100*latent/sum(latent);
%将latent总和统一为100，便于观察贡献率 
pareto(latent);
%调用matlab画图
