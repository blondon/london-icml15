clear

for attract = [0 1]

	% Load the slack2 data
	if attract
		load(sprintf('grid8_20_100_slack2_a.mat',i),'margmse','margmse_model');
	else
		load(sprintf('grid8_20_100_slack2_m.mat',i),'margmse','margmse_model');
	end
	margmse_slack2 = margmse;
	margmse_model_slack2 = margmse_model;
	
	% Load the slack1 data
	if attract
		load(sprintf('grid8_20_100_slack1_a.mat',i));
	else
		load(sprintf('grid8_20_100_slack1_m.mat',i));
	end
	
	% Combine slack data
	margmse(:,2,:,:,:,:,:) = margmse_slack2(:,2,:,:,:,:,:);
	margmse_model(:,2,:,:,:,:,:) = margmse_model_slack2(:,2,:,:,:,:,:);

	clear margmse_slack2;
	clear margmse_model_slack2;
	
	if attract
		save('grid8_20_100_slack_a.mat');
	else
		save('grid8_20_100_slack_m.mat');
	end
	
	clearvars -except attract

end
