function [theta, ll] = logistic_grad_ascent(X,y, alpha, max_iters)

% rows of X are training samples
% rows of Y are corresponding 0/1 values

% output ll: vector of log-likelihood values at each iteration
% ouptut theta: parameters

% code edit from class by Alice 11/15/12 - pass in alpha and max_iters as
% parameters
% alpha = 0.0001;
% max_iters = 500;

[m,n] = size(X);

X = [ones(size(X,1),1), X]; % append col of ones for intercept term

theta = zeros(n+1, 1);  % initialize theta
%theta = zeros(n,1);
for k = 1:max_iters
  hx = sigmoid(X*theta);
  theta = theta + alpha * X' * (y-hx); 
  ll(k) = sum( y .* log(hx) + (1 - y) .* log(1 - hx) );
end



