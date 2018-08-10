function [idbrainmask,idgm,idwm,idcsf] = fmri_load_maskindex(vref)

warning('off','all');
idbrainmask = iRSFC_brainmask(vref,0.1,0);    % nearest neighbour

idgm   = iRSFC_apriorimask(vref,0.2,0.5,0.5,'gm');
idwm   = iRSFC_apriorimask(vref,0.3,0.2,0.4,'wm');
idcsf  = iRSFC_apriorimask(vref,0.3,0.7,0.4,'csf');

end

%--------------------------------------------------------------------------
%  GENERATE WHOLE BRAIN MASK
%--------------------------------------------------------------------------

function idbrainmask = iRSFC_brainmask(vref,prob,sorder)

if strcmpi(spm('ver'),'spm12'),
    maskbm = fullfile(spm('dir'), 'tpm', 'mask_ICV.nii');
elseif strcmpi(spm('ver'),'spm8'),
    maskbm = fullfile(spm('dir'), 'apriori', 'brainmask.nii');
end

vmask  = spm_vol_nifti(maskbm);
BM     = spm_read_vols(vmask);

if ischar(vref),
    vol = spm_vol(vref);
else
    vol=vref;
end;

vol = vol(1);

[x,y,z]= meshgrid(1:vol.dim(2),1:vol.dim(1),1:vol.dim(3));
x = x(:); y = y(:); z = z(:);
xyz = [y x z ones(size(x))]';% Coord. in fmri : x & y ! in SPM5, SPM8
xyz = (vmask.mat\vol.mat) * xyz;
xyz = xyz';  % Coord. in template

bmsample  = spm_sample_vol(BM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
idbrainmask = find(bmsample>prob);
end


%  GENERATE BRAIN MASK FOR GM / WM / CSF
%__________________________________________________________________________

function idvol = iRSFC_apriorimask(vref,gmprob,whprob,csfprob,modality)

 % nearest neighbour
sorder = 0;          

if strcmpi(spm('ver'),'spm12'),
    maskgm  = fullfile(spm('dir'), 'tpm', 'TPM.nii,1');
    maskwm  = fullfile(spm('dir'), 'tpm', 'TPM.nii,2');
    maskcsf = fullfile(spm('dir'), 'tpm', 'TPM.nii,3');
elseif strcmpi(spm('ver'),'spm8'),
    maskgm  = fullfile(spm('dir'), 'apriori', 'grey.nii');
    maskwm  = fullfile(spm('dir'), 'apriori', 'white.nii');
    maskcsf = fullfile(spm('dir'), 'apriori', 'csf.nii');
end

vgm  = spm_vol(maskgm);
GM   = spm_read_vols(vgm);

vwm  = spm_vol(maskwm);
WM   = spm_read_vols(vwm);

vcsf  = spm_vol(maskcsf);
CSF   = spm_read_vols(vcsf);

if ischar(vref),Masking
    vol = spm_vol(vref);
else
    vol=vref;
end;
vol = vol(1);

[x,y,z]= meshgrid(1:vol.dim(2),1:vol.dim(1),1:vol.dim(3));
x = x(:); y = y(:); z = z(:);
xyz = [y x z ones(size(x))]';% Coord. in fmri : x & y ! in SPM5, SPM8
xyz = (vgm.mat\vol.mat) * xyz;
xyz = xyz'; % Coord. in template

gmsample  = spm_sample_vol(GM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
wmsample  = spm_sample_vol(WM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
csfsample = spm_sample_vol(CSF,xyz(:,1),xyz(:,2),xyz(:,3),sorder);

idwm = find(gmsample<gmprob & wmsample>whprob & csfsample<csfprob);
idgm = find(gmsample>gmprob & wmsample<whprob & csfsample<csfprob);
idcsf = find(gmsample<gmprob & wmsample<whprob & csfsample>csfprob);

switch lower(modality),
    case('wm'),
        idvol = idwm;
    case('gm'),
        idvol = idgm;
    case('csf'),
        idvol = idcsf;
end
end