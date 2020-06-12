function Aperture = BEM_aperture(Type, Size, Nsteps, Options)
% Aperture = BEM_aperture(Type, Size, Nsteps, [Options])
%
% Input
%   Type         [string] full, bar
%   Size         [scalar] width/height, in pixels
%   Nsteps       [scalar] number of aperture steps
%   Options      [struct]
%       .BarWidth   [scalar] width of the bar, in pixels
%       .BarOri     [scalar] lr, up, diag1, diag2
%
% Output
%   Ap           [matrix] m x n x a, where m x n is a binary aperture and 
%                         a are aperture steps
%
% Changelog
% 05/06/2019    Written
% 11/06/2019    Clarified aperture step vs. frame terminology
%

%% Input

if nargin < 1
    help BEM_aperture
    return
end

%% Main

% Various options
switch Type
    
    case 'full'
       
        %% Full-field aperture

        % Generate
        Aperture = ones(Size, Size, Nsteps);
        
    case 'bar'
        
        %% Sweeping bar aperture

        % Bar positions
        EndPoint = round(linspace(1, Size + Options.BarWidth, Nsteps));
        StartPoint = EndPoint - Options.BarWidth;
        
        % Start with a blank image
        Aperture = zeros(Size, Size, Nsteps);

        % Create bar positions in left-right orientation
        for i = 1 : Nsteps
            Bar = StartPoint(i) : EndPoint(i);
            Bar(Bar < 1 | Bar > Size) = [];
            Aperture(:, Bar, i) = 1;
            
            % Change orientation
            switch Options.BarOri
                case 'lr'
                    % Do nothing
                    
                case 'ud'
                    Aperture(:,:,i) = imrotate(Aperture(:,:,i), -90);
                    
                case 'diag1'
                    Aperture(:,:,i) = imrotate(Aperture(:,:,i), -45, 'crop');
                    
                case 'diag2'
                    Aperture(:,:,i) = imrotate(Aperture(:,:,i), -225, 'crop');
            end
        end
end

% Convert to logical
Aperture = logical(Aperture);

% Done
%