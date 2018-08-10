function FD_Power = compute_fd(motion,mode)
% Power et al. NeuroImage (2012)

if nargin < 2,
    mode = 'afni';
end

Mdiff = diff(motion);
Mdiff = [zeros(1,6); Mdiff];

if strcmp(mode, 'spm'),
    Mdiff(:,4:6) = Mdiff(:,4:6)*50;  % rotation in [rad]
end

FD_Power=sum(abs(Mdiff),2);
