function Ap = BEM_aperture_wedge(ImSize, Position, WedgeWidth, Direction)
% Ap = BEM_aperture_wedge(ImSize, Position, WedgeWidth, Direction)
%
% Input
%       ImSize       [scalar] Number of pixels in x,y
%       Position     [vector] Starting point of the wedge, in degrees
%       WedgeWidth   [scalar] Width of the wedge, in degrees
%       Direction    [string] '+' = clockwise
%                             '-' = counter-clockwise
% Output
%       Ap           [matrix] Binary image matrix with each frame 
%                             corresponding to one entry in Position
%
% Create a logical matrix of wedge apertures. 
% Position 0 is zero on the unit circle, i.e. at the 3 o'clock position

% Note that the starting edge of the wedge is determined by the Direction 
% variable. For example, a wedge with Position 0 and Direction +, will
% start at the horizontal line and extend towards the bottom of the image. 
% A wedge with Position 0 and Direction - will start at the horizontal line
% and extend towards the top of the image.

% Changelog
% 
% 25/05/2021    Written
% 
% Ivan Alvarez
% FMRIB Centre, University of Oxford

%% Main

% Defaults
Resolution = 100;

% Convert degree inputs to radians
Position = deg2rad(Position);
WedgeWidth = deg2rad(WedgeWidth);

% Convert direction to wedge width sign
if strcmpi(Direction, '-')
    WedgeWidth = -WedgeWidth;
end

% How many positions
P = length(Position);

% Center point
C = ImSize / 2;

% Start with a blank image
Ap = zeros(ImSize, ImSize, P);

% Loop positions
for i = 1:P
    
    % Define wedge as polygon vertices

    % First spoke
    T1 = repmat(Position(i), [1 Resolution]);
    R1 = linspace(0, ImSize / 2, Resolution);

    % Outer edge
    T2 = linspace(Position(i), Position(i) + WedgeWidth, Resolution);
    R2 = repmat(ImSize / 2, [1 Resolution]);

    % Second spoke
    T3 = repmat(Position(i) + WedgeWidth, [1 Resolution]);
    R3 = linspace(0, ImSize / 2, Resolution);
   
    % Flatten
    Theta = [T1, T2, T3];
    Rho = [R1, R2, R3];
    
    % Convert to Cartesian coordinates
    [X, Y] = pol2cart(Theta, Rho);
    
    % Shift to the middle of the image
    X = X + C;
    Y = Y + C;
    
    % Polygon to binary aperture
    Ap(:,:,i) = poly2mask(X, Y, ImSize, ImSize);
end
 
% Convert to logical
Ap = logical(Ap);

% Done
%