clearvars -except N attract

if ~exist('N','var')
	N = 8;
end
if ~exist('attract','var')
	attract = 1;
end

% Make repeatable
rng(31179)

% Data gen parameters
nSampX = 20;
nSampY = 100;
wfield_range = [.05 1];
winter_range = [.1 .2 .5 1 2 5];
datasets = datagen_grid_multiparam(...
	N,nSampX,nSampY,wfield_range,winter_range,attract);

if attract
	save(sprintf('grid%d_%d_%d_a.mat',N,nSampX,nSampY),'-v7.3');
else
	save(sprintf('grid%d_%d_%d_m.mat',N,nSampX,nSampY),'-v7.3');
end
