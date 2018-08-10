function passed = check_iCLSM_params(analmode)

global CLSM

passed = 1;
if isempty(CLSM.normalList),
    errordlg('Normal Database does not specified.');
    passed = 0;
end


if isempty(CLSM.lesionList),
    errordlg('Lesion info does not specified.');
    passed = 0;
end


if analmode==1,
    if isempty(CLSM.anal.OUTpath),
        errordlg('OUT path does not specified.');
        passed = 0;
    end
end