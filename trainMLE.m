function [w,nll,iters,funcnt] = trainMLE(examples,inferFunc,lambda,options,w)
%
% Trains an MRF using MLE.
%
% examples : cell array of examples
% inferFunc : inference function
% lambda : optional regularization constant or vector (def: 1)
% options : optimization options (optional)
% w : init weights (optional: def=zeros)

% Check input
assert(nargin >= 2,'USAGE: trainMLE(examples,inferFunc)')

% Regularization param
if nargin < 3
	lambda = 1;
end

% Optimization options
if nargin < 4 || ~isstruct(options)
	options = struct();
end
options.Method = 'lbfgs';
if ~isfield(options,'Display')
	options.Display = 'off';
end

% Inital point
if nargin < 5
	nParam = max(examples{1}.edgeMap(:));
	w = zeros(nParam,1);
end

% L2 regularization
if length(lambda) == 1
	lambda = lambda * ones(size(w));
end
obj = @(w) regularizedNLL(w,lambda,examples,inferFunc);

% Optimize using minFunc
[w,~,~,output] = minFunc(obj,w,options);
iters = output.iterations;
funcnt = output.funcCount;

% Compute NLL of solution
nll = UGM_CRFcell_NLL(w,examples,inferFunc);
% Normalize NLL by nExamples
nll = nll / length(examples);


function [nll,g] = regularizedNLL(w,lambda,examples,inferFunc)

if nargout == 1
    [nll] = UGM_CRFcell_NLL(w,examples,inferFunc);
else
    [nll,g] = UGM_CRFcell_NLL(w,examples,inferFunc);
end

% Normalize NLL by nExamples
nll = nll / length(examples);

% Add regularizer
nll = nll + sum(lambda .* (w.^2));

% Gradient
if nargout > 1
    g = g / length(examples) + 2 * lambda .* w;
end

