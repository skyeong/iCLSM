%  EXCUTE the preprocessing
%--------------------------------------------------------------------------

global CLSM
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Static Functional Connectivity ...\n');
fprintf('=======================================================================\n\n');


%  OPEN MATLABPOOL IF POSSIBLE
%--------------------------------------------------------------------------

try parpool; end;



%  Flag for Debug mode
%--------------------------------------------------------------------------

DEBUGmode = 0;



%  SPECIFY your own study
%__________________________________________________________________________

fMRIpath   = CLSM.fMRIpath;
LESIONpath = CLSM.LESIONpath;
normalList = CLSM.normalList;
lesionList = CLSM.lesionList;
OUTpath    = CLSM.anal.OUTpath;
prefix     = CLSM.prep.prefix;




%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%--------------------------------------------------------------------------

TR        = CLSM.prep.TR;        % TR time: volume acquisition time
BW        = CLSM.prep.BW;        % frequency range for bandpass filter
dummyoff  = CLSM.prep.dummyoff;  % num. of dummy data from beginning
FILTPARAM = [TR BW];             % set filtering parameters

fmridir   = CLSM.prep.fmridir;   % fmri directory
lesiondir = CLSM.anal.lesiondir;   % fmri directory


%  REGRESSORS SELECTION
%--------------------------------------------------------------------------

REGRESSORS(1) = CLSM.prep.GS;
REGRESSORS(2) = CLSM.prep.WM;
REGRESSORS(3) = CLSM.prep.CSF;


%  Scrubbing option
%--------------------------------------------------------------------------

FDthr       = CLSM.anal.FDthr;
doScrubbing = CLSM.anal.doScrubbing;



%  Find Reference File
%--------------------------------------------------------------------------

subjpath = fullfile(fMRIpath,'Data',normalList{1},fmridir);
fn_nii = sprintf('^%s.*._cleaned_bpf.nii$',prefix);
fns = spm_select('FPList',subjpath,fn_nii);
if isempty(fns)
    fn_nii = sprintf('^%s.*._cleaned_bpf.img$',prefix);
    fns = spm_select('FPList',subjpath,fn_nii);
end

try
    vref=spm_vol(fns(1,:));
catch
    fprintf('Cannot find cleaned_bpf image in [%s] folder.\n',fmridir);
    msg_on_handle=sprintf('Preprocessing first!');
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor','k');
    set(handles.analcorr_status,'FontWeight','normal');    return
end
if length(vref)>1,vref=vref(1);end;
DIM = vref.dim(1:3);
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  CORRELATION ANALYSIS USING TIME SERIES
%--------------------------------------------------------------------------

set(handles.run_analysis,'ForegroundColor',[1 1 1]);
set(handles.run_analysis,'BackgroundColor',CLSM.colorblue);
pause(0.1);


nlesion = length(lesionList);

for c=1:nlesion,
    
    lesionname = lesionList{c};
    fprintf('  [%03d/%03d] lesion %s, calculating clsm ... (%.1f min.) \n',c,nlesion,lesionname,toc/60);
    msg_on_handle=sprintf('lesion %03d/%03d (computing clsm...)  ',c,nlesion);
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor',CLSM.colorblue);
    set(handles.analcorr_status,'FontWeight','bold'); pause(1);
    
    
    %  Get lesion mask
    %----------------------------------------------------------------------
    SAVEmode=1;
    fn_lesion = spm_select('FPList',fullfile(LESIONpath,'Data',lesionname,lesiondir),'^w.*.nii');
    lesion = get_lesion_mask(fn_lesion,vref,idbrainmask,SAVEmode);
    
    
    %  Functional Connectivity
    %------------------------------------------------------------------
    h = waitbar(0,'1','Name',sprintf('CLSM for %03d/%03d lesion...', c, nlesion));
    
    for k=1:length(normalList)
        
        waitbar(k/length(normalList),h,sprintf('%d/%d',k,length(normalList)));
        
        normalsubj = normalList{k};
        subjpath = fullfile(fMRIpath,'Data',normalsubj,fmridir);
        fn_nii = sprintf('^%s.*._cleaned_bpf.nii$',prefix);
        fns = spm_select('FPList',subjpath,fn_nii);
        
        if ~exist(fns,'file'),
            fprintf('  rs-fmri for [%s] does not exist!\n',normalsubj);
            continue
        else
            vs = spm_vol(fns);
        end
        Z = spm_read_vols(vs);
        Z = reshape(Z, prod(vs(1).dim), length(vs));
        
        
        %  Compute Frame-wise displacement for scrubbing time-series
        %------------------------------------------------------------------
        
        fn_motion = dir(fullfile(subjpath,'rp_*.txt'));
        fn_motion = fullfile(subjpath,fn_motion(1).name);
        
        if ~exist(fn_motion,'file'),
            fprintf('Cannot find rp*.txt file in\n%s\n',subjpath);
            break;
        end
        motion = dlmread(fn_motion);
        FD_val = compute_fd(motion(dummyoff+1:end,:),'spm');
        
        if doScrubbing,
            % scrubbing 1 back and 2 forward neighbors as performed by Power et al
            idxScrubbing = find(FD_val>FDthr);
            idxScrubbing_b1 = idxScrubbing-1;
            idxScrubbing_a1 = idxScrubbing+1;
            idxScrubbing_a2 = idxScrubbing+2;
            idxScrubbing = [idxScrubbing(:); idxScrubbing_b1(:); idxScrubbing_a1(:); idxScrubbing_a2(:)];
            idxScrubbing = unique(idxScrubbing);
            idxScrubbing(idxScrubbing==0)=[];
            Z(:,idxScrubbing) = [];
            fprintf('    : scrubbing %d scans by FD>%.1f ...\n', length(idxScrubbing), FDthr);
        end
        
        
        %  Lesion-based functional connectivity
        %------------------------------------------------------------------
        
        zs=fmri_connectivity(Z(idbrainmask,:),DIM,lesion,idbrainmask);
        
        
        %  WRITE RESULTS ...
        %------------------------------------------------------------------
        vo = vref;
        SAVEpath=fullfile(OUTpath,'clsm_zmaps',lesionname,CLSM.prep.fmridir); mkdir(SAVEpath);
        SAVEname=sprintf('zscore_%s_%s.nii',lesionname,normalsubj);
        
        vo.fname=fullfile(SAVEpath, SAVEname);
        vo.dt=[16 0];
        IMG = zeros(vref.dim);
        IMG(idbrainmask) = zs;
        spm_write_vol(vo,IMG);
        
    end
    delete(h); % remove progress bar
    fprintf('\n');
    
end

set(handles.run_analysis,'ForegroundColor',CLSM.colorblue);
set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);
pause(0.1);


msg_on_handle=sprintf('Static FC was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');


