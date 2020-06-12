function Poolobj = BEM_parpool(Parameters)
% Poolobj = BEM_parpool(Parameters)
%
% Input
%   Parameters   [struct] See BEM_parameters
%
% Output
%   Poolobj      [handle] Parallel pool handle
%
% If a parallel pool is requested in Parameters.ParallelPool and the system
% allows it, create a parallel pool.
% If a pool already exists in the current session, return the handle.

% Changelog
% 02/07/2018    Written
% 12/07/2018    Better handling when parallel pool is disabled
%

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
    
    % No parallel pool
    Poolobj = [];
end

% Done
%