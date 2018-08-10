function [caseGs,classes,variables]=fmri_load_studylist(fn)

fp=fopen(fn);

ct=0; caseGs=[];
cct=0; classes=[];
vct=0; variables=[];
while(1)
    if feof(fp), break; end;
    str=fgets(fp);
    [r,l]=strtok(str);
    
    switch r,
        case 'Input',
            [caseG,l]=strtok(l);
            [grp,l]=strtok(l);
            iid=findstr(l,'#');
            if ~isempty(iid),
                l=l(1:iid(1)-1);
            end;
            age=str2num(l);
            in.caseG=caseG;
            in.grp=grp;
            in.var=age;
            ct=ct+1;
            caseGs{ct}=in;
            
        case 'Class',
            cct=cct+1;
            ii=(isspace(l)==1);l(ii)=[];
            classes{cct}=deblank(l);
            
        case 'Variables',
            while(1),
                if isempty(deblank(l)), break;end;
                [t,r]=strtok(l);
                lr=t; l=r;
                vct=vct+1;
                ii=(isspace(lr)==1);lr(ii)=[];
                variables{vct}=deblank(lr);
            end;
    end;
end;

fclose(fp);