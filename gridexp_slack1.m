clearvars -except datasets N nSampX nSampY wfield_range winter_range save2file diaryfile

% Required variables
assert(exist('datasets','var')==1,'datasets missing');
assert(exist('N','var')==1,'N missing');
assert(exist('nSampX','var')==1,'nSampX missing');
assert(exist('nSampY','var')==1,'nSampY missing');
assert(exist('wfield_range','var')==1,'wfield_range missing');
assert(exist('winter_range','var')==1,'winter_range missing');

% Number of trials/examples per trial
nTrials = nSampX;
nExTrial = nSampY;

% Train/test sizes
trainsizes = nExTrial;

% Kappa values
kvals = [.1 .2 .5 1];

% Trade-off parameter C values
cvals = 10.^(-3:3);

% Values of wf,wi to run
runwf = 1;
runwi = 1:length(winter_range);

% 1: LBP, 2: ConvexBethe, 3: TRW, 4: CBP unif c_e
nAlgos = 4;

% CountBP
cbp = @UGM_Infer_CountBP;

% Result storage
trainTime = zeros(nAlgos,length(wfield_range),length(winter_range),length(trainsizes),nTrials,length(kvals),length(cvals));
inferTime = zeros(nAlgos,length(wfield_range),length(winter_range),length(trainsizes),nTrials,length(kvals),length(cvals));
margmse = zeros(nAlgos,length(wfield_range),length(winter_range),length(trainsizes),nTrials,length(kvals),length(cvals));
margmse_model = zeros(nAlgos,length(wfield_range),length(winter_range),length(trainsizes),nTrials,length(kvals),length(cvals));

% Progress
nJobs = length(runwf)*length(winter_range)*length(trainsizes)*nTrials;
nCompleted = 0;
totaltimer = tic;
if exist('diaryfile','var')
	diary(diaryfile);
end

% Over all wfield
for wf = runwf
	
	wfield = wfield_range(wf);
	
	% Over all winter
	for wi = runwi
		
		winter = winter_range(wi);
		
		dataset = datasets{wf,wi};
		
		% Over all training sizes
		for nt = 1:length(trainsizes)

			nTrain = trainsizes(nt);
			
			% For nTrials
			for t = 1:nTrials
				
				% Grab data for trial
				examples = dataset(t,:);

				% All examples use the same edgeStruct.
				edgeStruct = examples{1}.edgeStruct;

				% Training params
				nNodes = double(examples{1}.edgeStruct.nNodes);
				nEdges = double(examples{1}.edgeStruct.nEdges);
				lambda = 1 / sqrt(nTrain);
				options.Display = 'off';


				%% Convexified Bethe (Meshi et al., UAI'09)

				a = 2;
				for k = 1:length(kvals)
					kappa = kvals(k);
					for c = 1:length(cvals)
						C = cvals(c);
						fprintf('Convexified Bethe (k=%.2f, C=%.3f) \n', kappa, C)
						[nodeCount,edgeCount] = UGM_ConvexBetheCounts(edgeStruct,kappa,1,0,C);
						examples = assigncounts(examples,nodeCount,edgeCount);
						% Train
						timer = tic;
						w = trainMLE(examples(1:nTrain),cbp,lambda,options);
						trainTime(a,wf,wi,nt,t,k,c) = toc(timer);
						% Test
						ex = examples{1};
						[nodePot,edgePot] = UGM_CRF_makePotentials(w,ex.Xnode,ex.Xedge,ex.nodeMap,ex.edgeMap,ex.edgeStruct);
						timer = tic;
						[nodeBel,edgeBel,logZ] = cbp(nodePot,edgePot,ex.edgeStruct);
						inferTime(a,wf,wi,nt,t,k,c) = toc(timer);
						[margmse(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						[nodeBel,edgeBel,logZ] = cbp(ex.nodePot,ex.edgePot,ex.edgeStruct);
						[margmse_model(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						fprintf('  Elapsed train : %f s ; avg infer : %f ms \n', trainTime(a,wf,wi,nt,t,k,c), inferTime(a,wf,wi,nt,t,k,c)*1000);
						fprintf('  MSE node margs (learned) : %f \n', margmse(a,wf,wi,nt,t,k,c));
						fprintf('  MSE node margs (model) : %f \n', margmse_model(a,wf,wi,nt,t,k,c));
					end
				end


				%% TRW with unif dist over all spanning trees

				a = 3;
				fprintf('TRW \n')
				edgeStruct.edgeDist = UGM_makeEdgeDistribution(edgeStruct,4,[N N]);
				[nodeCount,edgeCount] = UGM_TRBPCounts(edgeStruct);
				examples = assigncounts(examples,nodeCount,edgeCount);
				for k = 1:length(kvals)
					kappa = kvals(k);
					for c = 1:length(cvals)
						C = cvals(c);
						fprintf('TRW (k=%.2f, C=%.0f) \n', kappa, C)
						[nodeCount,edgeCount] = UGM_ConvexBetheCounts(edgeStruct,kappa,3,0,C);
						examples = assigncounts(examples,nodeCount,edgeCount);
						% Train
						timer = tic;
						w = trainMLE(examples(1:nTrain),cbp,lambda,options);
						trainTime(a,wf,wi,nt,t,k,c) = toc(timer);
						% Test
						ex = examples{1};
						[nodePot,edgePot] = UGM_CRF_makePotentials(w,ex.Xnode,ex.Xedge,ex.nodeMap,ex.edgeMap,ex.edgeStruct);
						timer = tic;
						[nodeBel,edgeBel,logZ] = cbp(nodePot,edgePot,ex.edgeStruct);
						inferTime(a,wf,wi,nt,t,k,c) = toc(timer);
						[margmse(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						[nodeBel,edgeBel,logZ] = cbp(ex.nodePot,ex.edgePot,ex.edgeStruct);
						[margmse_model(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						fprintf('  Elapsed train : %f s ; avg infer : %f ms \n', trainTime(a,wf,wi,nt,t,k,c), inferTime(a,wf,wi,nt,t,k,c)*1000);
						fprintf('  MSE node margs (learned) : %f \n', margmse(a,wf,wi,nt,t,k,c));
						fprintf('  MSE node margs (model) : %f \n', margmse_model(a,wf,wi,nt,t,k,c));
					end
				end


				%% CBP with uniform c_e (Hazan & Shashua, UAI'08)

				a = 4;
				for k = 1:length(kvals)
					kappa = kvals(k);
					for c = 1:length(cvals)
						C = cvals(c);
						fprintf('Uniform CBP (k=%.2f, C=%.0f) \n', kappa, C)
						[nodeCount,edgeCount] = UGM_ConvexBetheCounts(edgeStruct,kappa,2,0,C);
						examples = assigncounts(examples,nodeCount,edgeCount);
						% Train
						timer = tic;
						w = trainMLE(examples(1:nTrain),cbp,lambda,options);
						trainTime(a,wf,wi,nt,t,k,c) = toc(timer);
						% Test
						ex = examples{1};
						[nodePot,edgePot] = UGM_CRF_makePotentials(w,ex.Xnode,ex.Xedge,ex.nodeMap,ex.edgeMap,ex.edgeStruct);
						timer = tic;
						[nodeBel,edgeBel,logZ] = cbp(nodePot,edgePot,ex.edgeStruct);
						inferTime(a,wf,wi,nt,t,k,c) = toc(timer);
						[margmse(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						[nodeBel,edgeBel,logZ] = cbp(ex.nodePot,ex.edgePot,ex.edgeStruct);
						[margmse_model(a,wf,wi,nt,t,k,c)] = marginalerror(ex.nodeBel,nodeBel,ex.edgeBel,edgeBel);
						fprintf('  Elapsed train : %f s ; avg infer : %f ms \n', trainTime(a,wf,wi,nt,t,k,c), inferTime(a,wf,wi,nt,t,k,c)*1000);
						fprintf('  MSE node margs (learned) : %f \n', margmse(a,wf,wi,nt,t,k,c));
						fprintf('  MSE node margs (model) : %f \n', margmse_model(a,wf,wi,nt,t,k,c));
					end
				end
				
				%% Log progress
				nCompleted = nCompleted + 1;
				fprintf('\n');
				remainingtime(nJobs,nCompleted,totaltimer);
				fprintf('\n');
			end
			
		end
		
		% Save the entire workspace (except for data)
		if exist('save2file','var')
			save(save2file,'-regexp','^(?!(datasets|dataset|examples)$).');
		end
	end
end

diary off;
