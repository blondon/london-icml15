function [examples] = datagen_grid(N,nSampX,nSampY,wfield,winter,attract,makePlots)

if ~exist('wfield','var')
	wfield = .5;
end
if ~exist('winter','var')
	winter = 1;
end
if ~exist('attract','var')
	attract = 0;
end
if ~exist('makePlots','var')
	makePlots = 1;
end

% Create N x N grid
G = latticeAdjMatrix4(N, N);
edgeStruct = UGM_makeEdgeStruct(G,2,1);
nNodes = N^2;
nEdges = edgeStruct.nEdges;

% Create a model
edgeStruct.nNodeParams = 2*nNodes;
edgeStruct.nEdgeParams = 4*nEdges;
edgeStruct.nParams = edgeStruct.nNodeParams + edgeStruct.nEdgeParams;
nodeMap = int32(reshape(1:edgeStruct.nNodeParams,[2,nNodes])');
edgeMap = int32(reshape(edgeStruct.nNodeParams+1:edgeStruct.nParams,[2,2,nEdges,1]));
w_s = wfield * kron(sign(randn(nNodes,1)),[-1 1]');
w_p = winter * repmat(2*eye(2)-1,[1 1 nEdges]);
if ~attract
	for e = 1:nEdges
		w_p(:,:,e) = w_p(:,:,e) * sign(randn);
	end
end
w = [w_s ; w_p(:)];

minX = 0;
maxX = 1;
X = minX + (maxX-minX)*rand(nNodes,nSampX);
Y = zeros(nNodes,nSampX);

examples = cell(nSampX,nSampY);
for i = 1:nSampX
	% Xnode is unif random number per node
	Xnode = reshape(X(:,i),[1,1,nNodes]);
	% Xedge is mean of (left,right) Xnode values
	Xedge = .5 * (Xnode(1,:,edgeStruct.edgeEnds(:,1)) + Xnode(1,:,edgeStruct.edgeEnds(:,2)));

	% Create potentials
	[nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);

	% Compute exact marginals
	[nodeBel,edgeBel,logZ] = UGM_Infer_Junction(nodePot,edgePot,edgeStruct);
	
	% Sample Y
	edgeStructSamp = edgeStruct;
	edgeStructSamp.maxIter = nSampY;
	samples = UGM_Sample_Junction(nodePot,edgePot,edgeStructSamp);
	samples = int32(samples);
	Y(:,i) = samples(1,:)';
	
	for j = 1:nSampY
		% Create example
		examples{i,j}.edgeStruct = edgeStruct;
		examples{i,j}.nodeMap = nodeMap;
		examples{i,j}.edgeMap = edgeMap;
		examples{i,j}.Xnode = Xnode;
		examples{i,j}.Xedge = Xedge;
		examples{i,j}.Y = samples(j,:)';
		examples{i,j}.nodePot = nodePot;
		examples{i,j}.edgePot = edgePot;
		examples{i,j}.nodeBel = nodeBel;
		examples{i,j}.edgeBel = edgeBel;
		examples{i,j}.logZ = logZ;
	end
end

% Plot examples
if makePlots
	figure(101); imagesc(X); title('X'); xlabel('Example'); ylabel('Node');
	figure(102); imagesc(Y); title('Y'); xlabel('Example'); ylabel('Node');
	figure(103);
	subplot(1,2,1); imagesc(reshape(X(:,1),[N N])); title('First example X');
	subplot(1,2,2); imagesc(reshape(Y(:,1),[N N])); title('First example Y');
end
