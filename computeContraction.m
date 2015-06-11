function [coeff,maxcoeff] = computeContraction(nodeBel,edgeBel,edgeStruct)

nEdges = edgeStruct.nEdges;
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;

% All contraction coefficients
coeff = zeros(nEdges,2);
for e = 1:nEdges
	n1 = edgeEnds(e,1);
	n2 = edgeEnds(e,2);
	% p( y_n1 | y_n2 )
	condprob = zeros(nStates(n1),nStates(n2));
	for l2 = 1:nStates(n2)
		for l1 = 1:nStates(n1)
			condprob(l1,l2) = edgeBel(l1,l2,e) / nodeBel(n2,l2);
		end
	end
	for l2_1 = 1:nStates(n2)
		for l2_2 = 1:nStates(n2)
			tvnorm = 0.5 * sum(abs(condprob(:,l2_1) - condprob(:,l2_2)));
			coeff(e,2) = max(coeff(e,2), tvnorm);
		end
	end
	% p( y_n2 | y_n1 )
	condprob = zeros(nStates(n2),nStates(n1));
	for l1 = 1:nStates(n1)
		for l2 = 1:nStates(n2)
			condprob(l2,l1) = edgeBel(l1,l2,e) / nodeBel(n1,l1);
		end
	end
	for l1_1 = 1:nStates(n1)
		for l1_2 = 1:nStates(n1)
			tvnorm = 0.5 * sum(abs(condprob(:,l1_1) - condprob(:,l1_2)));
			coeff(e,1) = max(coeff(e,1), tvnorm);
		end
	end
end

% Maximum contraction coefficient
maxcoeff = max(coeff(:));
