function Y = BEM_rectify(X, Type)
% Y = BEM_rectify(X, Type)
%
% Input
%   X        [matrix] values to apply rectifier to
%   Type     [string] 'ReLU'         Set negatives to 0.
%                     'half-square'  Set negatives to 0. Square positives.
%                     'softplus'     Gentle exponent.
%                       
% Apply the desired rectifier function to inputs.

% Changelog
% 05/10/2018    Written
%

%% Main

% Various options
switch Type
    case 'ReLU'
        Y = max(X, 0);
    
    case 'half-square'
        Y = max(X, 0) .^ 2;
        
    case 'softplus'
        Y = log(1 + exp(X));
end

% Done
%