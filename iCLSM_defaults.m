function iCLSM_defaults
global CLSM


% Global Setting
CLSM.dir = fileparts(which('iCLSM'));
CLSM.colorblue = [0, 114, 189]/255.;


%--------------------------------------------------------------------------
% Parameters to change file name
%--------------------------------------------------------------------------
CLSM.fn_lesionlist = 'lesion_list.xlsx';
CLSM.fn_normallist = 'normal_list.xlsx';



%--------------------------------------------------------------------------
% Parameters for temporal preprocessing of normal database
%--------------------------------------------------------------------------
CLSM.prep.TR = 2;             % TR time: volume acquisition time
CLSM.prep.BW = [0.009 0.1];  % frequency range for bandpass filter
CLSM.prep.dummyoff = 5;
CLSM.prep.fmridir = 'rest';
CLSM.prep.prefix = 'swar';
CLSM.prep.nHM = 12; % 6 head motion and its time derivatives
CLSM.prep.CSF = 1;  % csf signal
CLSM.prep.WM  = 1;  % white matter signal
CLSM.prep.GS  = 1;  % global signal

% Don't use following option
CLSM.prep.PCA = 0;
CLSM.prep.nPCA= 0;  % Suggested by X.J. Chai et al. / NeuroImage 59 (2012) 1420?1428


%--------------------------------------------------------------------------
% Parameters for lesion network mapping
%--------------------------------------------------------------------------
CLSM.anal.mode = 'Preprocess';
CLSM.anal.uncorr_p = 0.00005; % p-value (R.R. Darby et al. Brain 2017)

CLSM.anal.lesiondir = 'lesion';
CLSM.anal.OUTpath = '';


% Do not change following option
CLSM.anal.FDthr = 0.2;
CLSM.anal.doScrubbing = 0;

CLSM.anal.BW = [0.009 0.08];
CLSM.anal.TR = 2;

