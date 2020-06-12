function g = BEM_linearcheck(Size, Squares)
% g = BEM_linearcheck(Size, Squares)
%
% Inputs
%   Size     [scalar] width/height in pixels
%   Squares  [vector] Number of squares to place along X and Y
%   
% Generate a linear checkerboard image.

% Changelog
% 28/08/2019    Written
%

%% Parse inputs

% Check inputs
if numel(Size) == 1
    Size = [Size, Size];
end
if numel(Squares) == 1
    Squares = [Squares, Squares];
end

% Safety check
if sum((Size ./ Squares) < 1)
    error('Size cannot be smaller than the number of Squares.');
end

%% Main

% Create a 2x2 checkerboard array
Im = eye(2);

% Find nearest square pixel size for the desired dimensions
Pix = Size ./ Squares;

% If the desired size is not divisible by the desired number of squares
% add an extra square
S = ceil(Squares + ceil(mod(Pix, round(Pix)) > 0));

% Expand to the desired number of checkers
Im = repmat(Im, ceil(S / 2));
Im = Im(1 : S(1), 1 : S(2));

% Strech each dimension
Im = repelem(Im, floor(Pix(1)), floor(Pix(2)));

% Cut down to the desired dimension, clipping the left and bottom edges if
% necessary
g = Im(1 : Size(1), 1 : Size(2));

% Done 
%