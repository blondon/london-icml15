function datasets = datagen_grid_multiparam(N,nTrials,nSampY,wfield_range,winter_range,attract)
%
% Generates datasets of size (nTrials x nSampY),
% where each example is an (N x N) grid,
% for a range of (wfield,winter) parameter values.
%
% wfield_range : a vector of values for wfield.
% winter_range : a vector of values for winter.
% attract : attractive potentials? (def: 0)
%
% datasets : a (length(wfield_range) x length(winter_range)) cell matrix,
%			 wherein each cell is a (nEx x 1) cell array of examples.

if ~exist('attract','var')
	attract = 0;
end

nJobs = length(wfield_range) * length(winter_range);
nCompleted = 0;
timer = tic;

for i = 1:length(wfield_range)
	wfield = wfield_range(i);
	for j = 1:length(winter_range)
		winter = winter_range(j);
		fprintf('Computing data for (wfield,winter) = (%f,%f) \n', wfield, winter);
		for t = 1:nTrials
			datasets{i,j}(t,:) = datagen_grid(N,1,nSampY,wfield,winter,attract,0);
		end
		nCompleted = nCompleted + 1;
		remainingtime(nJobs,nCompleted,timer);
	end
end
