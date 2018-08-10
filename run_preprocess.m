%  EXCUTE the preprocessing
%--------------------------------------------------------------------------

global CLSM
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Preprocessing in temporal domain ...\n');
fprintf('=======================================================================\n');


%  Flag for Debug mode
%--------------------------------------------------------------------------

DEBUGmode = 0;



%  SPECIFY your own study
%--------------------------------------------------------------------------

fMRIpath  = CLSM.fMRIpath;
subjnames = CLSM.normalList;
ANApath   = CLSM.anal.OUTpath;
prefix    = CLSM.prep.prefix;



%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%--------------------------------------------------------------------------

TR        = CLSM.prep.TR;        % TR time: volume acquisition time
BW        = CLSM.prep.BW;        % frequency range for bandpass filter
dummyoff  = CLSM.prep.dummyoff;  % num. of dummy data from beginning
fmridir   = CLSM.prep.fmridir;   % fmri directory
FILTPARAM = [TR BW];             % set filtering parameters



%  Regression Parameters
%--------------------------------------------------------------------------

REGRESSORS(1) = CLSM.prep.GS;
REGRESSORS(2) = CLSM.prep.WM;
REGRESSORS(3) = CLSM.prep.CSF;




%  FIND REFERENCE FILE
%--------------------------------------------------------------------------

subjpath = fullfile(fMRIpath,'Data',subjnames{1},fmridir);
fn_nii = sprintf('^%s.*.nii$',prefix);
fns = spm_select('FPList',subjpath,fn_nii);
if isempty(fns)
    fn_img = sprintf('^%s.*.img$',prefix);
    fns = spm_select('FPList',subjpath,fn_img);
end

vref=spm_vol(fns(1,:));
if length(vref)>1,vref=vref(1);end;
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  CORRELATION ANALYSIS USING TIME SERIES
%--------------------------------------------------------------------------

set(handles.run_analysis,'ForegroundColor',[1 1 1]);
set(handles.run_analysis,'BackgroundColor',CLSM.colorblue);
pause(0.2);


nsubj = length(subjnames);


for c=1:nsubj,
    
    subj = subjnames{c};
    fprintf('  [%03d/%03d] subj %s is in analyzing ... (%.1f min.) \n',c,nsubj,subj,toc/60);
    
    
    %  TEMPORAL PREPROCESSING
    %----------------------------------------------------------------------
    
    msg_on_handle=sprintf('subj %03d/%03d (Preprocessing ...)  ',c,nsubj);
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor',CLSM.colorblue);
    set(handles.analcorr_status,'FontWeight','bold'); pause(1);
    fmri_prep_temporal(fullfile(fMRIpath,'Data'), fmridir, subj, REGRESSORS);
    
    set(handles.run_analysis,'ForegroundColor',CLSM.colorblue);
    set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);
    
    fprintf('\n')
    pause(0.2);
end

msg_on_handle = sprintf('Preprocessing was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');


