function varargout = iCLSM(varargin)
%iCLSM
% Requirements:
%   Before using iCLSM, SPM should be installed previously.
%   Refer to SPM website
%   http://www.fil.ion.ucl.ac.uk/spm/


global CLSM;
warning('off','all');

if nargin == 0  % LAUNCH GUI
    
    exepath=which('iCLSM');
    [p,f,e]=fileparts(exepath);
    CLSM.iCLSMpath = p;
    
    addpath(genpath(p));
    spm_dir = which('spm');
    if isempty(spm_dir),
        errordlg('SPM path should be added before executing this program.');
        return;
    end
    CLSM.spmVer = spm('ver');
    
    license=fullfile(p,'license.txt');
    if exist(license,'file')==0, fprintf('No license file...\n'); return; end;
    
    
    % Generate a structure of handles to pass to callbacks, and store it.
    fig = openfig(mfilename,'new');
    handles = guihandles(fig);
    guidata(fig, handles);
    set(fig, 'Name','Expanding your insight with iCLSM');
    
    iCLSM_defaults;
    iCLSM_init(handles);
    
    CLSM.handle=fig;
    CLSM.figure.handles=handles;
    
    fprintf('--------------------------------------------------\n');
    fprintf('  Welcome to iCLSM\n');
    fprintf('  Copyright (c) 2018 Sunghyon Kyeong \n');
    fprintf('--------------------------------------------------\n');
    
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end




%**************************************************************************
% INITIALIZE
%**************************************************************************

function iCLSM_init(handles)
global CLSM

nHM = CLSM.prep.nHM;
fprintf('Number of head motions: %d \n',nHM);


set(handles.edit_prep_BW, 'String', sprintf('[%.3f, %.3f]',CLSM.prep.BW));
set(handles.edit_prep_dummy, 'String', num2str(CLSM.prep.dummyoff));
set(handles.edit_prefix, 'String', CLSM.prep.prefix);




%**************************************************************************
%  Methods for loading lesion data
%**************************************************************************

function select_lesionpath_Callback(hObject, eventdata, handles)
global CLSM
LESIONpath = uigetdir(pwd,'Select Lesion Project Path');
set(handles.LESIONpath,'String',LESIONpath);
CLSM.LESIONpath = LESIONpath;
CLSM.anal.OUTpath = fullfile(CLSM.LESIONpath,'Results');
mkdir(CLSM.anal.OUTpath);


fn_lesionList = fullfile(CLSM.LESIONpath,CLSM.fn_lesionlist);
if ~exist(fn_lesionList,'file')
    errordlg(sprintf('cannot find %s',CLSM.fn_lesionlist));
    return;
end
lesionList = readtable(fn_lesionList);
CLSM.lesionList = lesionList.subjname;
fprintf('Number of lesions = %3d\n',length(CLSM.lesionList));
CLSM.group = lesionList.group;
fprintf('Number of groups = %3d\n',length(unique(CLSM.group)));


function LESIONpath_Callback(hObject, eventdata, handles)
global CLSM

CLSM.LESIONpath = get(hObject,'String');
CLSM.anal.OUTpath = fullfile(CLSM.LESIONpath,'Results');
mkdir(CLSM.anal.OUTpath);


fn_lesionList = fullfile(CLSM.LESIONpath,CLSM.fn_lesionlist);
if ~exist(fn_lesionList,'file')
    errordlg(sprintf('cannot find %s',CLSM.fn_lesionlist));
    return;
end
lesionList = readtable(fn_lesionList);
CLSM.lesionList = lesionList.subjname;
fprintf('Number of lesions = %3d\n',length(CLSM.lesionList));
CLSM.group = lesionList.group;
fprintf('Number of groups = %3d\n',length(unique(CLSM.group)));


%**************************************************************************
%  Methods for loading normal database
%**************************************************************************

function select_fmripath_Callback(hObject, eventdata, handles)
global CLSM
fMRIpath = uigetdir(pwd,'Select fMRI DATA path');
set(handles.fMRIpath,'String',fMRIpath);
CLSM.fMRIpath = fMRIpath;

% Load normal subject list
fn_normalList = fullfile(CLSM.fMRIpath,CLSM.fn_normallist);
if ~exist(fn_normalList,'file')
    errordlg(sprintf('cannot find %s',CLSM.fn_normallist));
    return;
end
normalList = readtable(fn_normalList);
CLSM.normalList = normalList.subjname;
fprintf('Number of normal subjects = %3d\n',length(CLSM.normalList));


function fMRIpath_Callback(hObject, eventdata, handles)
global CLSM
fMRIpath = get(hObject,'String');
CLSM.fMRIpath = fMRIpath;


% Load normal subject list
fn_normalList = fullfile(CLSM.fMRIpath,CLSM.fn_normallist);
if ~exist(fn_normalList,'file')
    errordlg(sprintf('cannot find %s',CLSM.fn_normallist));
    return;
end
normalList = readtable(fn_normalList);
CLSM.normalList = normalList.subjname;
fprintf('Number of normal subjects = %3d\n',length(CLSM.normalList));




%**************************************************************************
% Temporal Preprocessing
%**************************************************************************

function edit_prefix_Callback(hObject, eventdata, handles)
global CLSM
CLSM.prep.prefix = get(hObject,'String');


function edit_prep_BW_Callback(hObject, eventdata, handles)
global CLSM
BW = get(hObject,'String');
fprintf('  Bandpass filter: %s Hz\n', BW);
CLSM.prep.BW = eval(BW);


function edit_prep_dummy_Callback(hObject, eventdata, handles)
global CLSM
dummyoff = get(hObject,'String');
CLSM.prep.dummyoff = eval(dummyoff);


function edit_prep_TR_Callback(hObject, eventdata, handles)
global CLSM
TR = get(hObject,'String');
CLSM.prep.TR = eval(TR);


function edit_fmripath_Callback(hObject, eventdata, handles)
global CLSM
fmripath = get(hObject,'String');
CLSM.prep.fmridir = fmripath;


function edit_lesiondir_Callback(hObject, eventdata, handles)
global CLSM
lesiondir = get(hObject,'String');
CLSM.anal.lesiondir = lesiondir;


function checkbox_scrubbing_Callback(hObject, eventdata, handles)
global CLSM
CLSM.anal.doScrubbing = get(hObject,'Value');


function edit_FDthr_Callback(hObject, eventdata, handles)
global CLSM
CLSM.anal.FDthr = str2double(get(hObject,'String'));



%**************************************************************************
% Functional connectivity analysis
%**************************************************************************

function run_analysis_Callback(hObject, eventdata, handles)
global CLSM

if strcmpi(CLSM.anal.mode,'Preprocess'),
    if check_iCLSM_params(0)==1,
        run_preprocess;
    end
    
elseif strcmpi(CLSM.anal.mode,'CLSM'),
    if check_iCLSM_params(1)==1,
        run_clsm;
    end
elseif strcmpi(CLSM.anal.mode,'Stat (Individual)'),
    if check_iCLSM_params(1)==1,
        run_stat_individual;
    end
elseif strcmpi(CLSM.anal.mode,'Stat (Group)'),
    if check_iCLSM_params(1)==1,
        %run_stat_group;
        run_lesion_network_mapping;
    end
elseif strcmpi(CLSM.anal.mode,'Lesion Overlapping'),
    if check_iCLSM_params(1)==1,
        run_lesion_overlapping;
    end
else
    errordlg('Specify parameters correctly!!','Error Dialog');
    return
end




% --- Executes on selection change in popupmenu_analmode.
function popupmenu_analmode_Callback(hObject, eventdata, handles)
global CLSM
button_state = get(hObject,'Value');
if button_state == 1,
    analmode = 'Preprocess';
elseif button_state == 2,
    analmode = 'CLSM';
elseif button_state == 3,
    analmode = 'Stat (Individual)';
elseif button_state == 4,
    analmode = 'Stat (Group)';
elseif button_state == 5,
    analmode = 'Lesion Overlapping';
end
CLSM.anal.mode = analmode;
fprintf('analysis mode: %s \n',analmode);
