
global CLSM
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Lesion Network Overlapping (Group-level)...\n');
fprintf('=======================================================================\n\n');



%  SPECIFY your own study
%--------------------------------------------------------------------------

LESIONpath = CLSM.LESIONpath;
normalList = CLSM.normalList;
lesionList = CLSM.lesionList;
OUTpath    = CLSM.anal.OUTpath;




%  Loading variables
%--------------------------------------------------------------------------

fmridir   = CLSM.prep.fmridir;   % fmri directory
lesiondir = CLSM.anal.lesiondir;   % fmri directory
group     = CLSM.group;
groupids   = unique(group);
ngrp      = length(groupids);

for i=1:ngrp
    g = groupids(i);
    %----------------------------------------------------------------------
    % Creating positive lesion network maps (group-level)
    %----------------------------------------------------------------------
    CNT=[];
    for j=1:length(lesionList)
        if group(j)~=g, continue; end
        lesion_name = lesionList{j};
        fn = spm_select('FPList',fullfile(LESIONpath,'Lesions'),sprintf('wl%s.*.nii',lesion_name));
        vo = spm_vol(fn);
        I = spm_read_vols(vo);
        if isempty(CNT)
            CNT = I;
        else
            CNT = CNT+I;
        end
    end
    
    outdir = fullfile(OUTpath,'lesion_overlapping'); mkdir(outdir);
    fn_out = fullfile(outdir,sprintf('overlapping_g%d.nii',g));
    vout = vo;
    vout.dt=[16,0];
    vout.fname=fn_out;
    spm_write_vol(vout,CNT);
    
end
fprintf('lesion overlapping maps were created!\n');
