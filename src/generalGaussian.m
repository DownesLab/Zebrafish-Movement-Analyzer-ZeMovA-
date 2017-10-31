function window=generalGaussian(M,p,sig)
% M is the number of points needed
% p is the Shape parameter.  p = 1 is identical to `gaussian`, p = 0.5 is
%       the same shape as the Laplace distribution
% sig is The standard deviation
% this is ported from scipy.signal.general_gaussian. Refer to 
% https://github.com/scipy/scipy/blob/v0.14.0/scipy/signal/windows.py#L1043
% Note that this only returns a symmetric window and not a periodic one
% author: Abhay Mittal

if M<1
    window=[];
    return ;
end

if M==1
    window=[1];
    return ;
end
n = 0:M-1;
n=n - (M - 1.0) / 2.0;

window= exp(-0.5*abs(n/sig).^(2*p));
end