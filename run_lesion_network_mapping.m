
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
groupids  = unique(group);
ngrp      = length(groupids);

for i=1:ngrp
    g = groupids(i);
    
    %----------------------------------------------------------------------
    % Creating positive lesion network maps (group-level)
    %----------------------------------------------------------------------
    fprintf('Create Group Maps for Group ID=%d\n',g);
    CNT=[];
    for j=1:length(lesionList)
        if group(j)~=g, continue; end
        lesion_name = lesionList{j};
        fn = fullfile(OUTpath,'stat_individual',lesion_name,'spmT_0001_thr.nii');
        vo = spm_vol(fn);
        I = spm_read_vols(vo);
        if isempty(CNT)
            CNT = I;
        else
            CNT = CNT+I;
        end
    end
    PCT = CNT/sum(group==g);
    idremove = find(PCT<0.85);
    PCT(idremove)=0;
    CNT(idremove)=0;
    
    outdir = fullfile(OUTpath,'lesion_network_mapping','positive'); mkdir(outdir);
    fn_out = fullfile(outdir,sprintf('count_g%d.nii',g));
    vout = vo;
    vout.dt=[16,0];
    vout.fname=fn_out;
    spm_write_vol(vout,CNT);
    
    fn_out = fullfile(outdir,sprintf('percent_g%d.nii',g));
    vout = vo;
    vout.dt=[16,0];
    vout.fname=fn_out;
    spm_write_vol(vout,PCT);
    
    
    
    %----------------------------------------------------------------------
    % Creating negative lesion network maps (group-level)
    %----------------------------------------------------------------------
    CNT=[];
    for j=1:length(lesionList)
        if group(j)~=g, continue; end
        lesion_name = lesionList{j};
        fn = fullfile(OUTpath,'stat_individual',lesion_name,'spmT_0002_thr.nii');
        vo = spm_vol(fn);
        I = spm_read_vols(vo);
        if isempty(CNT)
            CNT = I;
        else
            CNT = CNT+I;
        end
    end
    PCT = CNT/sum(group==g);
    idremove = find(PCT<0.84);
    PCT(idremove)=0;
    CNT(idremove)=0;
    
    outdir = fullfile(OUTpath,'lesion_network_mapping','negative'); mkdir(outdir);
    fn_out = fullfile(outdir,sprintf('count_g%d.nii',g));
    vout = vo;
    vout.fname=fn_out;
    spm_write_vol(vout,CNT);
    
    fn_out = fullfile(outdir,sprintf('percent_g%d.nii',g));
    vout = vo;
    vout.fname=fn_out;
    spm_write_vol(vout,PCT);
end
fprintf('lesion network mapping was done!\n');
