function Poolobj = BEM_parpool(Parameters)
% Poolobj = BEM_parpool(Parameters)
%
% Input
%   Parameters   [struct] See BEM_parameters
%
% Output
%   Poolobj      [handle] Parallel pool handle
%
% Three options:
%  (1) If a parallel pool is present, return the handle
%  (2) If no parallel pool present, create one and return the handle
%  (3) If not requested, return a dummy handle
%
% Changelog
% 02/07/2018    Written
% 12/07/2018    Better handling when parallel pool is disabled
% 17/11/2020    Create dummy pool

%% Main

% Optional
if Parameters.ParallelPool
    
    % Is there a current pool?
    Poolobj = gcp('NoCreate');
    
    % If none exists, open a new one
    if isempty(Poolobj)

        % How many cores
        nCores = feature('numCores');
        
        % Open the parallel pool
        Poolobj = parpool(nCores);
        
        % Disable idle time
        Poolobj.IdleTimeout = Inf;        
    end    
else
    % Don't allow auto-creation of parallel pool
    Ps = parallel.Settings;
    Ps.Pool.AutoCreate = false;
    
    % Make dummy parallel pool
    Poolobj = struct;
    Poolobj.NumWorkers = 0;
end

% Done
%