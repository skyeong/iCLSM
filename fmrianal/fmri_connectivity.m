function Z=fmri_connectivity(Y,DIM,lesion,idbrainmask)
% Y : either volume with DIM
%     or npoint x nscans
% lesion : either nseed x num of neighbor points
%         or 1 x nscans


dim1=size(Y);
if length(dim1)==4,
    Y = reshape(Y,dim1(1:3),dim1(4));
    Y = Y(idbrainmask,:);
end;

npoint=size(Y,1);
nscans=size(Y,2);


% Averaging for extracting Seed region Time Course
zs = zeros(1,nscans);
a1 = zeros(DIM);
for k=1:nscans,
    a1(idbrainmask)=Y(:,k);
    idroi=lesion.idroi;
    zs(:,k) = mean(a1(idroi));
end
clear a1;



% CALCULATE CROSS-CORRELATION
%--------------------------------------------------------------------------

Rs=zeros(npoint,1);
parfor j=1:npoint,
    XX = Y(j,:)';
    r = corrcoef(XX,zs);
    Rs(j)= r(1,2);
end;


% FISHER'S R-TO-Z CONVERT
%--------------------------------------------------------------------------

Z = (log(1+Rs) - log(1-Rs+eps)) .* 0.5;
