function [rc aucparam aucpartial aucemp CIareaparam CIareapartial CIareaemp CIparamroc]=paramroc(x,y,models,fprrange,np,bootssams,atwhich)

%Constructs the parametric ROC curve based on parametric choices
%provided by the user. Estimation is done via maximum likelihood.
%The area under the curve (AUC)is also computed. If
%requested, a partial area under the curve can also be obtained.
%The empirical (non-parametric) ROC is also provided.
%Bootstrap based 95% intervals can be obtained for the
%corresponding AUC, the partial AUC, as well as the empirical based AUC.
%95% confidence intervals can also be obtained for the parametric ROC curve 
%itself. An informative plot depending on the choices of the user is
%provided automatically.

%The following parametric models are supported: Normal, Gamma, Lognormal
%and Weibull with all their possible pairwise combinations. 

%INPUT ARGUMENTS:
%x:      a column vector of the score values that tend to be lower than the
%        score values in y.
%y:      a column vector of the score values that tend to be larger than the 
%        score values in x.
%models: a string that refers to the models assummed for the x and y. Any
%        combination of the distributions, normal, gamma, lognormal,
%        weibull can be %used. If, for example, we want to assume that 
%        X~Normal and Y~Gamma then we must set this input argument
%        as 'normal-gamma'. Other examples might be 'gamma-lognormal', 
%        'weibull-gamma', 'gamma-weibull', 'normal-normal' .. 
%        or any other combination. The first model refers to x and the
%        second to y.
%
%OPTIONAL INPUT ARGUMENTS:
%fprrange: a row vector of two elements. That is, the range of the FPR upon 
%          which the partial area under the curve is to be calculated. If, for
%          example, the partial area under the curve is wanted from FPR=0.2 to
%          FPR=0.5, then this input argument should be [0.2 0.5]. (The second element
%          must be greater than the first). You can set this as [] if you
%          do not want to define this input argument and want to proceed to
%          the next.
%np      : a scalar value. Set it equal to 1 if the empirical ROC curve is
%          also wanted. Any other value will not have an impact. You can 
%          set this as [] if you do not want to define this input argument 
%          and want to proceed to the next.
%bootssams:The number of bootstrap samples to be used for inference (i.e. 95% CIs
%          for the parametric AUC of the ROC curve, the partial AUC, the empirical AUC 
%          or the ROC itself). The percentile bootstrap is employed. 
%          This is a nice choice since you cannot get
%          inappropriate CIs, namely, CIs out of [0,1].
%atwhich:  A row vector containing the values of the FPR(=t) at which the CIs 
%          of the TPR=ROC(t) curve are to be evaluated.



%OUTPUT ARGUMENTS:
%rc            : a function handle of the ROC curve. That is for a given t
%                the ROC(t) can be evaluated as rc(t)
%aucparam      : the area under the parametric ROC curve.
%aucpartial    : the partial area under the parametric ROC curve. The range
%                should be specified by the "fprrange" input argument.
%aucemp        : the area under the empirical (i.e. non parametric) ROC
%                curve.
%CIareaparam   : 95% confidence intervals for the area under the parametric
%                ROC curve based on the percentile bootstrap. The number of
%                the bootstrap samples used must be specified by the 
%                "bootssams" input argument.
%CIareapartial : 95% confidence intervals for the partial area under the 
%                parametric ROC curve based on the percentile bootstrap. 
%                The number of the bootstrap samples used must be specified
%                by the "bootssams" input argument.
%CIareaemp     : 95% confidence intervals for the area under the empirical
%                ROC curve based on the percentile bootstrap. The number of
%                the bootstrap samples used must be specified by the 
%                "bootssams" input argument.
%CIparamroc   :  95% pointwise confidence intervals for the ROC curve based
%                on the percentile bootstrap. The number of the bootstrap 
%                samples used must be specified by the "bootssams" input 
%                argument. These CIs will be calculated ONLY for the  FPR 
%                values provided by the input argument "atwhich". This
%                output is a three column matrix. In the first column the
%                "atwhich" is contained and in the two following columns,
%                the corresponding 95% CIs for the ROC are provided 
%                (these are also plotted)
%
%
%
%See also the "examples" file for a cell by cell illustration.
%
%Author: 
%Leonidas E. Bantis
%University of the Aegean,
%e-mail: lbantis@aegean.gr, leobantis@gmail.com
%Release 1
%November 19, 2012.



if nargin<3;error('At least three input arguments are needed');end
%if nargin>5;error('Too many input arguments');end

if nargin>3 && isempty(fprrange)~=1
if fprrange(1)<0;error('The FPRs in the ''fprrange'' must lie between zero and one');end
if fprrange(1)>1;error('The FPRs in the ''fprrange'' must lie between zero and one');end
if fprrange(1)>fprrange(2);error('The first elemt of the fprrange must be less than the second');end
end

    
    
if nargin>4
if length(np)>1;error('The ''np'' input argument must be scalar, and equal to one if the empirical ROC is also wanted');end
if isempty(np)==1;aucemp=NaN;end
end
 %models='weibull-normal'

 if nargout>=5 && nargin<6;error('No CIs can be computed if ''bootssams'' is not provided');end
 
 
 
 
n1=length(x);n2=length(y);
[rc a1 b1 a2 b2]=gettheroc(x,y,models);
 


t=0:0.01:1; 
plot(t,rc(t))
xlabel('t=FPR');ylabel('ROC(t)=TPR')
legend('parametric ROC', 'Location','SouthEast')

if strcmpi(models, 'normal-normal')~=1
    aucparam=quadgk(@(x) rc(x),0,1);
else
    aa=(a2-a1)/b2;bb=b1/b2;
    aucparam=normcdf(aa/sqrt(1+bb^2));
end


if nargin>=4
    if isempty(fprrange)==1
        aucpartial=aucparam;
    else
        aucpartial=quadgk(@(x) rc(x), fprrange(1),fprrange(2));
    end
    
else
    aucpartial=NaN;
end


if nargin>4
    if np==1
        %n1=length(x);n2=length(y);
        labels=[zeros(n1,1);ones(n2,1)];
        scores=[x;y];
        [X,Y,~,aucemp] = perfcurve(labels,scores,1);
        hold on
        plot(X,Y,'k')
        legend('parametric ROC', 'empirical ROC', 'Location','SouthEast')

    end
    
else
    aucemp=NaN;
end






%---Start bootstrap:

if nargin>=6 && nargout>=5
    
areaparamb=zeros(bootssams,1);
areapartialb=areaparamb;
areaempb=areaparamb;
for boots=1:bootssams
   atx=randsample(1:n1,n1,'true');
   aty=randsample(1:n2,n2,'true');
   xb=x(atx);
   yb=y(aty);
   [rcb a1 b1 a2 b2]=gettheroc(xb,yb,models);
   
   
    if strcmpi(models, 'normal-normal')~=1
        areaparamb(boots)=quadgk(@(x) rcb(x),0,1);
    else
        aa=(a2-a1)/b2;bb=b1/b2;
        areaparamb(boots)=normcdf(aa/sqrt(1+bb^2));
    end
      
   if nargin>=4 && isempty(fprrange)~=1
   areapartialb(boots)=quadgk(@(x) rcb(x), fprrange(1),fprrange(2));
   end
   
   if nargin>=5 && isempty(np)~=1
   areaempb(boots)=rocauc(xb,yb);
   end

end



CIareaparam  =prctile(areaparamb,[2.5 97.5]);
CIareapartial=prctile(areapartialb,[2.5 97.5]); 
CIareaemp    =prctile(areaempb,[2.5 97.5]); 

if isempty(fprrange)==1;CIareapartial=[NaN NaN];end
if isempty(np)==1;CIareaemp=[NaN NaN];end


end

if nargin==7
if size(atwhich,2);atwhich=atwhich';end  %make the atwhich a row vector
end


%--Start bootstrap for the ROC:
if nargout==8 && nargin==7 
    M=zeros(boots,length(atwhich));
    for boots=1:bootssams
        atx=randsample(1:n1,n1,'true');
        aty=randsample(1:n2,n2,'true');
        xb=x(atx);
        yb=y(aty);
        rcb=gettheroc(xb,yb,models);
        M(boots,:)=rcb(atwhich);
    end
    
    CIMlow=zeros(1,size(M,2));CIMupp=CIMlow;
    for i=1:size(M,2) 
        CIMlow(i)=prctile(M(:,i),2.5);
        CIMupp(i)=prctile(M(:,i),97.5);
    end
    hold on
    plot(atwhich,CIMlow,'.')
    plot(atwhich,CIMupp,'.')
    
    if nargin>4 && isempty(np)~=1
        legend('parametric ROC', 'empirical ROC', sprintf('95%% CIs for the \n parametric ROC'), 'Location','SouthEast')
    else
        legend('parametric ROC', sprintf('95%% CIs for the \n parametric ROC'), 'Location','SouthEast')
        %legend(sprintf('First line and\nsecond line'));
    end

    
    CIparamroc=[atwhich CIMlow' CIMupp'];
    
end


if nargin>3 && isempty(fprrange)~=1
    hold on
    pt=linspace(fprrange(1),fprrange(2),1000);
    yy=rc(pt);
    xx=pt;
    basey = min(0,min(y));
    h = fill([xx xx(end) xx(1)], [yy basey basey], 'b');
    set(h,'EdgeColor','none')
    alpha(0.2)
    
end


%[rc aucparam aucpartial aucemp
if nargout==2
    title(['AUC (parametric)=', num2str(aucparam)])
elseif nargout==2 && isnan(aucpartial)==1
    title(['AUC (parametric)=', num2str(aucparam)])
elseif nargout==3 && isnan(aucpartial)~=1
    title(['AUC (parametric)=', num2str(aucparam), '  AUC (partial)=', num2str(aucpartial)])
elseif nargout>=4 && isnan(aucpartial)==1 && isnan(aucemp)==1
    title(['AUC (parametric)=', num2str(aucparam)])
elseif nargout>=4 && isnan(aucpartial)~=1 && isnan(aucemp)==1
    title(['AUC (parametric)=', num2str(aucparam), '  AUC (partial)=', num2str(aucpartial)])
elseif nargout>=4 && isnan(aucpartial)==1 && isnan(aucemp)~=1    
    title(['AUC (parametric)=', num2str(aucparam), '  AUC (empirical)=', num2str(aucemp)])
elseif nargout>=4 && isnan(aucpartial)~=1 && isnan(aucemp)~=1
    title(['AUC (parametric)=', num2str(aucparam), '  AUC (partial)=', num2str(aucpartial), '  AUC (empirical)=', num2str(aucemp)])
else
   title(['AUC (parametric)=', num2str(aucparam)]) 
end
    
    
    

    


hold off

end





















%------------INTERIOR FUNCTIONS:----------------



function [rc a1 b1 a2 b2]=gettheroc(x,y,models)


 if strcmpi(models, 'weibull-weibull')==1
    parsx=wblfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=wblfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-wblcdf((wblinv(1-t,a1,b1)),a2,b2)); %biweibull
    
 elseif strcmpi(models, 'gamma-gamma')==1
 
    parsx=gamfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=gamfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-gamcdf((gaminv(1-t,a1,b1)),a2,b2)); %bigamma
    
 elseif strcmpi(models, 'lognormal-lognormal')==1
    
    parsx=lognfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=lognfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-logncdf((logninv(1-t,a1,b1)),a2,b2)); %bilognormal
    
 elseif strcmpi(models, 'normal-normal')==1     
    
    [a1 b1]=normfit(x);%a1=parsx(1);b1=parsx(2); 
    [a2 b2]=normfit(y);%a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-normcdf((norminv(1-t,a1,b1)),a2,b2)); %binormal
    
 elseif strcmpi(models, 'weibull-gamma')==1
    
    parsx=wblfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=gamfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-gamcdf((wblinv(1-t,a1,b1)),a2,b2));   %biweibull
    
 elseif strcmpi(models, 'weibull-lognormal')==1
    
    parsx=wblfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=lognfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-logncdf((wblinv(1-t,a1,b1)),a2,b2)); %biweibull
    
 elseif strcmpi(models, 'weibull-normal')==1
    
    parsx=wblfit(x);a1=parsx(1);b1=parsx(2); 
    [a2 b2]=normfit(y);%a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-normcdf((wblinv(1-t,a1,b1)),a2,b2)); %biweibull   
    
 elseif strcmpi(models, 'gamma-weibull')==1
    
    parsx=gamfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=wblfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-wblcdf((gaminv(1-t,a1,b1)),a2,b2)); %bigamma
    
 elseif strcmpi(models, 'gamma-lognormal')==1
    
    parsx=gamfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=lognfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-logncdf((gaminv(1-t,a1,b1)),a2,b2)); %bigamma
    
 elseif strcmpi(models, 'gamma-normal')==1
     
    parsx=gamfit(x);a1=parsx(1);b1=parsx(2); 
    [a2 b2]=normfit(y);%a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-normcdf((gaminv(1-t,a1,b1)),a2,b2)); %bigamma

 elseif strcmpi(models, 'lognormal-weibull')==1
     
    parsx=lognfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=wblfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-wblcdf((logninv(1-t,a1,b1)),a2,b2)); 
 
 elseif strcmpi(models, 'lognormal-gamma')==1
   
    parsx=lognfit(x);a1=parsx(1);b1=parsx(2); 
    parsy=gamfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-gamcdf((logninv(1-t,a1,b1)),a2,b2)); 
 
 elseif strcmpi(models, 'lognormal-normal')==1
     
    parsx=lognfit(x);a1=parsx(1);b1=parsx(2); 
    [a2 b2]=normfit(y);%a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-normcdf((logninv(1-t,a1,b1)),a2,b2));
    
 elseif strcmpi(models, 'normal-weibull')==1
     
    [a1 b1]=normfit(x);%a1=parsx(1);b1=parsx(2); 
    parsy=wblfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-wblcdf((norminv(1-t,a1,b1)),a2,b2)); 
 
 elseif strcmpi(models, 'normal-gamma')==1
     
    [a1 b1]=normfit(x);%a1=parsx(1);b1=parsx(2); 
    parsy=gamfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-gamcdf((norminv(1-t,a1,b1)),a2,b2)); 
 
 elseif strcmpi(models, 'normal-lognormal')==1
     
    [a1 b1]=normfit(x);%a1=parsx(1);b1=parsx(2); 
    parsy=lognfit(y);a2=parsy(1);b2=parsy(2);
    rc=@(t) (1-logncdf((norminv(1-t,a1,b1)),a2,b2)); 
 else 
     error('Please check again the names of the models and which models are supported');
 end



end





function out=rocauc(x,y)

%Calculates the area under an ROC curve
% The ordering is X<Y

sizex=size(x);nx=max(sizex);
sizey=size(y);ny=max(sizey);
if sizex(1)~=1 && sizex(2)~=1;error('Check the dimensions of the input in the rocauc function');end
if sizey(1)~=1 && sizey(2)~=1;error('Check the dimensions of the input in the rocauc function');end

if sizex(1)>1;x=x';end
if sizey(1)>1;y=y';end



X=repmat(x,ny,1);X=X(1:end);
Y=repmat(y,1,nx);

p1=length(find(X<Y))/length(X);
p2=length(find(X==Y))/length(X);
out=p1+0.5*p2;


end


 
 

 
 
 
 
 
 
 