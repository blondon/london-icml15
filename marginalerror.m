function [nodeerr,edgeerr] = marginalerror(nodeBel1,nodeBel2,edgeBel1,edgeBel2)
%
% Computes the MSE of the marginals.
%

nodeerr = sum((nodeBel1(:) - nodeBel2(:)).^2) / size(nodeBel1,1);

if nargin >= 4
	edgeerr = sum((edgeBel1(:) - edgeBel2(:)).^2) / size(edgeBel1,3);
end
