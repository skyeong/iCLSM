%  EXCUTE the preprocessing
%--------------------------------------------------------------------------

global CLSM
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Statistical Analysis (Individual-level)...\n');
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
uncorr_p  = CLSM.anal.uncorr_p;    % p-value (uncorrected)




%--------------------------------------------------------------------------
% Creating lesion network maps (individual-level)
%--------------------------------------------------------------------------
h = waitbar(0,'1','Name',sprintf('Individual mapping...'));
for i=1:length(lesionList),
    lesion_name = lesionList{i};
    waitbar(i/length(lesionList),h,sprintf('lesion %03d/%03d',i,length(lesionList)));
    outdir = fullfile(OUTpath,'stat_individual',lesion_name); mkdir(outdir);
    
    fmri = cell(0);
    for j=1:length(normalList)
        normal_name = normalList{j};
        fmri{j} = spm_select('FPList',fullfile(OUTpath,'clsm_zmaps',lesion_name,fmridir),['^zscore_.*', normal_name ,'.nii']);
    end
    
    clear matlabbatch;
    matlabbatch{1}.spm.stats.factorial_design.dir = {outdir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = [fmri'];
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    
    fn_spm = fullfile(outdir,'SPM.mat');
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fn_spm};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = {fn_spm};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'positive';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'negative';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    
    matlabbatch{4}.spm.stats.results.spmmat = {fn_spm};
    matlabbatch{4}.spm.stats.results.conspec(1).titlestr = 'positive_thr';
    matlabbatch{4}.spm.stats.results.conspec(1).contrasts = 1;
    matlabbatch{4}.spm.stats.results.conspec(1).threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec(1).thresh = uncorr_p;
    matlabbatch{4}.spm.stats.results.conspec(1).extent = 0;
    matlabbatch{4}.spm.stats.results.conspec(1).conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec(1).mask.none = 1;
    matlabbatch{4}.spm.stats.results.conspec(2).titlestr = 'negative_thr';
    matlabbatch{4}.spm.stats.results.conspec(2).contrasts = 2;
    matlabbatch{4}.spm.stats.results.conspec(2).threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec(2).thresh = uncorr_p;
    matlabbatch{4}.spm.stats.results.conspec(2).extent = 0;
    matlabbatch{4}.spm.stats.results.conspec(2).conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec(2).mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.binary.basename = 'thr';

    %spm_jobman('interactive',matlabbatch);
    spm_jobman('run',matlabbatch);
    
end
delete(h)