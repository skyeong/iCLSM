function lesion = get_lesion_mask(fn_lesion,vref,idmask,SAVEmode)
global CLSM
LESIONpath = CLSM.LESIONpath;

%  Generate ROI from User Defined Mask Images
%--------------------------------------------------------------------------
[p0,f0,e0]=fileparts(fn_lesion);


% Get XYZ-Coordinates in user defined ROI image space
%--------------------------------------------------------------------------
v1  = spm_vol(fn_lesion);
IMG = spm_read_vols(v1);
idx = intersect(find(IMG>0),idmask);
[vx, vy, vz] = ind2sub(v1.dim,idx);
Vxyz = [vx, vy, vz, ones(size(vx,1),1)];


% Resampled in standard normalized space
%--------------------------------------------------------------------------
Rxyz = v1.mat*Vxyz';
Vxyz = round(pinv(vref.mat)*Rxyz); Rxyz = Rxyz(1:3,:)';
idroi = sub2ind(vref.dim, Vxyz(1,:), Vxyz(2,:), Vxyz(3,:));
idroi = unique(idroi);

lesion=struct();
lesion.idroi = idroi;
lesion.name = [f0,'_resampled'];
lesion.center = mean(Rxyz);


%  SAVE ROI AS NIFTI FILE FORMAT
%--------------------------------------------------------------------------
if SAVEmode
    outdir = fullfile(LESIONpath,'Lesions'); mkdir(outdir);
    vo = vref;
    vo.dt = [16, 0];
    vo.fname = fullfile(outdir, [f0, '_resampled.nii']);
    IMG = zeros(vref.dim);
    IMG(idroi) = 1;
    spm_write_vol(vo,IMG);
end



fprintf('\n=======================================================================\n');
fprintf('  Lesion mask was created: %s\n',f0);
fprintf('=======================================================================\n');
fprintf('\n\n');
