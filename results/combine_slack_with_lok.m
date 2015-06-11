clear

for attract = [0 1]
	
	% Load the slack data
	if attract
		load('grid8_20_100_slack_a.mat','margmse','margmse_model');
	else
		load('grid8_20_100_slack_m.mat','margmse','margmse_model');
	end
	margmse_slack = margmse;
	margmse_mod_slack = margmse_model;
	
	% Choose best C for each kappa
	margmse_slack = min(margmse_slack,[],7);
	margmse_mod_slack = min(margmse_mod_slack,[],7);
% 	% Or, just set C=100;
% 	margmse_slack = margmse_slack(:,:,:,:,:,:,end-1);
% 	margmse_mod_slack = margmse_mod_slack(:,:,:,:,:,:,end-1);
	
	% Load the low-kappa data
	if attract
		load('grid8_20_100_lok_a.mat');
	else
		load('grid8_20_100_lok_m.mat');
	end
	% Concatenate hi-k and regular data
	margmse = cat(6,margmse,margmse_slack);
	margmse_model = cat(6,margmse_model,margmse_mod_slack);
	kvals = [kvals .1 .2 .5 1];
	
	clear margmse_slack;
	clear margmse_model_slack;
	clear kvals_slack;
	
	if attract
		save('grid8_20_100_a.mat');
	else
		save('grid8_20_100_m.mat');
	end
	
	clearvars -except attract

end
