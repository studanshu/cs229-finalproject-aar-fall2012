close all
clear all
clc



n1=100; 
n2=200;

%Lets generate the scores of two groups x,y 
%with x tending to exhibit smaller score values than y.
%For this example the inequality F_x(t)<F_y(t) for all t
%does not hold. This would hold for example in the case where
%the scores of the two groups follow two Normals with different means
%but with the same variance. Here, we just generate
%two populations that the one, loosely speaking, tends to exhibit
%higher score values. Here, we generate x from a Weibull distribution and 
%for y from a normal.

a1=3;b1=3;
x=wblrnd(a1,b1,n1,1);
a2=4;b2=1;
y=normrnd(a2,b2,n2,1);

%Now plot the two (true) underlying densities populations just to see our setting:
gr=0:0.01:10;
plot(gr,wblpdf(gr,a1,b1))
hold on
plot(gr,normpdf(gr,a2,b2),'r')


%%
close all
%Now suppose we want to construct the parametric ROC curve
%based on the assumption that X~Weibull, Y~Normal. The parameters
%of the models will be estimated via maximum likelihood (separately).

%We first define which models do we want to use:
models='weibull-normal'

%And then ask for the corresponding parametric ROC and its AUC (area under the curve): 
[rc aucparam]=paramroc(x,y,models)

%The rc is a function handle of the desired ROC curve and can be
%used to calclulate the value of ROC(t) at any t in [0,1]. For example:
at=[0.1 0.4 0.8 0.9 1];
rc(at)
hold on
plot(at,rc(at),'.r')


%%
close all

% You can additionally ask for the partial area under the curve (pAUC)
% that correspond to the range of the FPR (0.1 to 0.4)
[rc aucparam aucpartial]=paramroc(x,y,models,[0.1 0.4])


%%
close all

% You can additionally ask for the empirical (i.e. non parametric)
% ROC curve along with the corresponding AUC
[rc aucparam aucpartial aucemp]=paramroc(x,y,models,[0.1 0.4],1)

%%
close all

%You can derive a 95% confidence interval for the AUC of the parametric ROC
%based on the percentile bootstrap. Here we use 200 bootstrap samples:
%The CI is contained in CIareaparam.
[rc aucparam aucpartial aucemp CIareaparam]=paramroc(x,y,models,[],[],200)

%Note that now aucemp is NaN since the empirical curve is not requested
%You cou ask for
%[rc aucparam aucpartial aucemp CIareaparam]=paramroc(x,y,models,[],1,200)
%if you also want the empirical AUC

%%
%Based on the same number of the bootstrap samples you can additionally ask
%the CIs for a partial area as well as the empirical area:

[rc aucparam aucpartial aucemp CIareaparam CIareapartial CIareaemp]=paramroc(x,y,models,[0.1 0.4],1,200)

%% 
close all
%Finally you can derive the corresponding 95% confidence intervals for the
%parametric ROC. For this you must provide an array of values of t at which
%the 95% CIs of ROC(t) are to be derived. Suppose we need the
%CIs at t=[0.1 0.4 0.8]:
t=[0.1 0.4 0.8];
[rc aucparam aucpartial aucemp CIareaparam CIareapartial CIareaemp CIparamroc]=paramroc(x,y,models,[0.1 0.4],1,100,t)

%The outpout CIparamroc is a three column matrix.
%Its first column is the t that you have provided.
%Its second and third column are the lower and upper limits of the CIs
%respectively. These CIs are also plotted with blue dots.
%Again, if you do not want the empirical curve plotted in your graph you
%could ask for:
%[rc aucparam aucpartial aucemp CIareaparam CIareapartial CIareaemp CIparamroc]=paramroc(x,y,models,[0.1 0.4],[],100,t)

%%
%Finally if you want to see the 95% for a finer grid of t values: 
close all
t=[0:0.01:1];
[rc aucparam aucpartial aucemp CIareaparam CIareapartial CIareaemp CIparamroc]=paramroc(x,y,models,[0.1 0.4],1,100,t)
% close all
% [rc aucparam aucp aucemp ci]=paramroc(x,y,models,[0.1 0.4],[],100,t)



