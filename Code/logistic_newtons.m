%%%%%%% log_regression.m %%%%%%%
function [theta,ll] = logistic_newtons(X,Y,max_iters)
% rows of X are training samples
% rows of Y are corresponding 0/1 values
% newton raphson: theta = theta - inv(H)* grad;
% with H = hessian, grad = gradient
m = size(X,1);
n = size(X,2);
theta = zeros(n,1);
%max_iters = 50;
for i=1:max_iters
grad = zeros(n,1);
ll(i)=0;
H = zeros(n,n);
for j=1:m
hxj = sigmoid(X(j,:)*theta);
grad = grad + X(j,:)'*(Y(j) - hxj);
H = H - hxj*(1-hxj)*X(j,:)'*X(j,:);
ll(i) = ll(i) + Y(j)*log(hxj) + (1-Y(j))*log(1-hxj);
end
theta = theta - inv(H)*grad;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%