function Z=fmri_NUIS_regress(Y, X)
% Y : input spatio-temporal data,  scans x voxels
% Z : regressed data,  scans x voxels

nscans = size(Y,1);
if ~isempty(X),
    %Z = (eye(nscans) - NUIS*pinv(NUIS))*Y;
    beta_hat = pinv(X'*X)*X'*Y;
    Z = (eye(nscans)*Y - X*beta_hat); clear beta_hat X;
else
    Z = Y;
end
