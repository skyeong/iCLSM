%  EXCUTE the preprocessing
%--------------------------------------------------------------------------

global CLSM
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Statistical Analysis (Group-level)...\n');
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
ngrp      = hist(group,1:length(unique(group)));

%--------------------------------------------------------------------------
% Creating lesion network maps (group-level)
%--------------------------------------------------------------------------
fmri = cell(0);
for j=1:length(lesionList),
    lesion_name = lesionList{j};
    fmri{j,1} = fullfile(OUTpath,'stat_individual',lesion_name,'con_0001.nii');
end


%--------------------------------------------------------------------------
% Group Stat for each group
%--------------------------------------------------------------------------
for i=1:length(ngrp),
    clear matlabbatch;
    outdir = fullfile(OUTpath,'stat_group',['group' num2str(i)]); mkdir(outdir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {outdir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {fmri{group==i}}';
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    
    fn_spm = fullfile(outdir,'SPM.mat');
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fn_spm};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = {fn_spm};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'positive connectivity';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'negative connectivity';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    %spm_jobman('interactive',matlabbatch);
    spm_jobman('run',matlabbatch);
end



%--------------------------------------------------------------------------
% Two-sample t-test: Group 1 vs Group 2
%--------------------------------------------------------------------------
if size(ngrp,2)==2,
    clear matlabbatch;
    outdir = fullfile(OUTpath,'stat_group','twosample'); mkdir(outdir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {outdir};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = {fmri{group==1}}';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {fmri{group==2}}';
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    
    fn_spm = fullfile(outdir,'SPM.mat');
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fn_spm};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = {fn_spm};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Experiment > Control';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Experiment < Control';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 11];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
   
    %spm_jobman('interactive',matlabbatch);
    spm_jobman('run',matlabbatch);
end

