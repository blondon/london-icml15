clear
gridsizes = 2:2:16;%[5 10 20 50 100 200 500 1000];
kvals = [.01 .02 .05 .06 .07 .08 .1];
C = 100;

for N = gridsizes

	% Create N x N grid
	G = latticeAdjMatrix4(N, N);
	edgeStruct = UGM_makeEdgeStruct(G,2,1);
	edgeStruct.edgeDist = UGM_makeEdgeDistribution(edgeStruct,4,[N N]);
	
	% Bethe counts
	[nCntB,eCntB] = UGM_BetheCounts(edgeStruct);
	
	for k = kvals

		% Run SC-Bethe optimization
		[nCnt1,eCnt1,~,flags] = UGM_ConvexBetheCounts(edgeStruct,k,1,1,C);
		fprintf('QP flag: %d CB flag: %d \n', flags.qp, flags.cb);
	
% 		% Run SC-Unif optimization
% 		[nCnt2,eCnt2,~,flags] = UGM_ConvexBetheCounts(edgeStruct,k,2,1,C);
% 		fprintf('QP flag: %d CB flag: %d \n', flags.qp, flags.cb);
% 	
% 		% Run SC-TRBP optimization
% 		[nCnt3,eCnt3,~,flags] = UGM_ConvexBetheCounts(edgeStruct,k,3,1,C);
% 		fprintf('QP flag: %d CB flag: %d \n', flags.qp, flags.cb);
	
	end
end
