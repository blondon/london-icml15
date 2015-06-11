clear

attract = 1;

sigthresh = .05;

jobs = 1:2;

saveplots = 1;

resultdir = '.';
fileext = 'eps'; pictype = 'epsc';
% fileext = 'png'; pictype = 'png';

% Load data
if attract
	subdir = 'attract';
	load([resultdir '/grid8_20_100_a.mat']);
else
	subdir = 'mixed';
	load([resultdir '/grid8_20_100_m.mat']);
end

% Convert to RMSE
margmse = sqrt(margmse);
margmse_model = sqrt(margmse_model);


%% 1) Plot RMSE vs kappa (learned)

if ismember(1,jobs)

	legendstr = {'C-Bethe','SC-Bethe','TRBP','SC-TRBP','C-Unif','SC-Unif'};
	
	plotcolors = {'k','r','b','g'};

	fontsize = 18;
	ticfontsize = 16;
	legfontsize = 12;
	linewidth = 3;
	markersize = 12;
	insetlinewidth = linewidth;
	insetmarkersize = markersize;

	msefig = 101;
	figure(msefig); pos = get(gcf,'Position'); set(gcf,'Position',[pos(1:2) pos(3:4)*1.5]);

	plotkvals = 2:(length(kvals));
	xaxiskvals = [kvals(kvals>0 & kvals<=.1) .12 .14 .16];
	
	sigwin = -ones(length(wfield_range),length(winter_range),nAlgos-1,length(plotkvals));
	
	msereduction = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefraction = zeros(length(wfield_range),length(winter_range),nAlgos-1);

	wfstr = {'lo','hi'};
	wistr = {'01','02','05','10','20','50'};
	
	plotwf = 1:length(wfield_range);
	plotwi = 3:length(winter_range);

	for wf = plotwf
		wfield = wfield_range(wf);
		if wf == 1
			plotkvals_wf = plotkvals(1:end);
			xaxiskvals_wf = xaxiskvals(1:end);
		else
			plotkvals_wf = plotkvals(1:end);
			xaxiskvals_wf = xaxiskvals(1:end);
		end

		for wi = plotwi
			winter = winter_range(wi);

			figure(msefig); clf;
			h1 = gca(); hold(h1,'on');
% 			title('Marginal RMSE (learned)');
			xlabel('\kappa','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
			set(h1,'FontSize',ticfontsize);

			maxavgmselowk = 0;
			for a = 2:nAlgos
				plotcolor = plotcolors{a};
				avgmse = mean(squeeze(margmse(a,wf,wi,end,:,:)),1);
				stdmse = std(squeeze(margmse(a,wf,wi,end,:,:)),[],1);
				plot(h1,xaxiskvals_wf,avgmse(1)*ones(1,length(xaxiskvals_wf)),...
					 [plotcolor 'o--'],'LineWidth',linewidth,'MarkerSize',markersize);
				plot(h1,xaxiskvals_wf,avgmse(plotkvals_wf),...
					 [plotcolor 'v-'],'LineWidth',linewidth,'MarkerSize',markersize);
				
				% Significant win?
				for k = 1:length(plotkvals)
					sigwin(wf,wi,a-1,k) = ttest(...
						squeeze(margmse(a,wf,wi,end,:,1)),...
						squeeze(margmse(a,wf,wi,end,:,plotkvals(k))),...
						sigthresh);
				end
				
				% Determine whether we need to rescale the plot.
				maxavgmselowk = max(maxavgmselowk, max(avgmse(kvals<.1)));
				
				% Improvement over baseline.
				msereduction(wf,wi,a-1) = (avgmse(1) - min(avgmse(2:end))) / avgmse(1);
				msefraction(wf,wi,a-1) = avgmse(1) / min(avgmse(2:end));
			end

			% Resize plots
			axis(h1,'tight');
			v = axis(h1); 
			if wf==1
				axis(h1,[v(1:3) maxavgmselowk+.0001]);
% 				set(h1,'XTick',.01:.01:.1);
				set(h1,'XTick',[.02:.02:.1 .12 .14 .16]); set(h1,'XTickLabel',[.02:.02:.1 .2 .5 1]);
			else
				axis(h1,[v(1:3) maxavgmselowk+.001]);
				set(h1,'XTick',[.02:.02:.1 .12 .14 .16]); set(h1,'XTickLabel',[.02:.02:.1 .2 .5 1]);
			end
			
			% Legend
% 			if wf==1 && (wi==plotwi(1)) %&& attract
				leg = legend(h1,legendstr,'Location','SouthWest','FontSize',legfontsize);
				figure(msefig); pause
% 			end
			
			% Save
			if saveplots
				if attract
					figure(msefig);
					saveas(gcf,sprintf('%s/fig/%s/mse_k/mse_k_wf-%s_wi-%s_att.%s',resultdir,subdir,wfstr{wf},wistr{wi},fileext),pictype);
				else
					figure(msefig);
					saveas(gcf,sprintf('%s/fig/%s/mse_k/mse_k_wf-%s_wi-%s_mix.%s',resultdir,subdir,wfstr{wf},wistr{wi},fileext),pictype);
				end
			end
		end
	end

	% Log significance tests
	plotwi = [1 3 4 5 6];
	plotkvalstr = strread(num2str(kvals(plotkvals)),'%s');
	for wf = 1:length(wfield_range)
		for wi = plotwi
			sigmat = squeeze(sigwin(wf,wi,:,:));
			fprintf('%s, wf=%.2f, wi=%.1f \n',subdir,wfield_range(wf),winter_range(wi));
			disptable(sigmat,plotkvalstr,{'SC-Bethe','SC-TRBP','SC-Unif'});
		end
	end
end


%% 2) Plot RMSE vs kappa (model)

if ismember(2,jobs)

	legendstr = {'C-Bethe','SC-Bethe','TRBP','SC-TRBP','C-Unif','SC-Unif'};
	
	plotcolors = {'k','r','b','g'};

	fontsize = 18;
	ticfontsize = 16;
	legfontsize = 12;
	linewidth = 3;
	markersize = 12;
	insetlinewidth = linewidth;
	insetmarkersize = markersize;

	msefig = 201;
	figure(msefig); pos = get(gcf,'Position'); set(gcf,'Position',[pos(1:2) pos(3:4)*1.5]);

	plotkvals = 2:(length(kvals));
	xaxiskvals = [kvals(kvals>0 & kvals<=.1) .12 .14 .16];
	
	sigwin = -ones(length(wfield_range),length(winter_range),nAlgos-1,length(plotkvals));

	msereduction = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefraction = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefrac_lbp = zeros(length(wfield_range),length(winter_range),nAlgos-1);

	wfstr = {'lo','hi'};
	wistr = {'01','02','05','10','20','50'};
	
	plotwf = 1:length(wfield_range);
	plotwi = 3:length(winter_range);

	for wf = plotwf
		wfield = wfield_range(wf);
		if wf == 1
			plotkvals_wf = plotkvals(1:end);
			xaxiskvals_wf = xaxiskvals(1:end);
		else
			plotkvals_wf = plotkvals(1:end);
			xaxiskvals_wf = xaxiskvals(1:end);
		end

		for wi = plotwi
			winter = winter_range(wi);

			figure(msefig); clf;
			h1 = gca(); hold(h1,'on');
% 			title('Marginal RMSE (learned)');
			xlabel('\kappa','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
			set(h1,'FontSize',ticfontsize);

			maxavgmselowk = 0;
			for a = 2:nAlgos
				plotcolor = plotcolors{a};
				avgmse = mean(squeeze(margmse_model(a,wf,wi,end,:,:)),1);
				stdmse = std(squeeze(margmse_model(a,wf,wi,end,:,:)),[],1);
				plot(h1,xaxiskvals_wf,avgmse(1)*ones(1,length(xaxiskvals_wf)),...
					 [plotcolor 'o--'],'LineWidth',linewidth,'MarkerSize',markersize);
				plot(h1,xaxiskvals_wf,avgmse(plotkvals_wf),...
					 [plotcolor 'v-'],'LineWidth',linewidth,'MarkerSize',markersize);
				
				% Significant win?
				for k = 1:length(plotkvals)
					sigwin(wf,wi,a-1,k) = ttest(...
						squeeze(margmse_model(a,wf,wi,end,:,1)),...
						squeeze(margmse_model(a,wf,wi,end,:,plotkvals(k))),...
						sigthresh);
				end
				
				% Determine whether we need to rescale the plot.
				maxavgmselowk = max(maxavgmselowk,max(avgmse(kvals<.1)));
				
				% Improvement over baseline.
				msereduction(wf,wi,a-1) = (avgmse(1) - min(avgmse(2:end))) / avgmse(1);
				msefraction(wf,wi,a-1) = avgmse(1) / min(avgmse(2:end));
				msefrac_lbp(wf,wi,a-1) = mean(squeeze(margmse_model(1,wf,wi,end,:,1))) / min(avgmse(2:end));
			end

			% Resize plots
			axis(h1,'tight');
			v = axis(h1); 
			if wf==1
% 				axis(h1,[v(1:3) maxavgmselowk+.0001]);
% 				set(h1,'XTick',.01:.01:.1);
				axis(h1,[v(1:3) maxavgmselowk+.001]);
				set(h1,'XTick',[.02:.02:.1 .12 .14 .16]); set(h1,'XTickLabel',[.02:.02:.1 .2 .5 1]);
			else
				axis(h1,[v(1:3) maxavgmselowk+.001]);
				set(h1,'XTick',[.02:.02:.1 .12 .14 .16]); set(h1,'XTickLabel',[.02:.02:.1 .2 .5 1]);
			end
			
			% Legend
% 			if wf==1 && (wi==plotwi(1)) %&& attract
				leg = legend(h1,legendstr,'Location','East','FontSize',legfontsize);
				figure(msefig); pause
% 			end
			
			% Save
			if saveplots
				if attract
					figure(msefig);
					saveas(gcf,sprintf('%s/fig/%s/mse_k/msemod_k_wf-%s_wi-%s_att.%s',resultdir,subdir,wfstr{wf},wistr{wi},fileext),pictype);
				else
					figure(msefig);
					saveas(gcf,sprintf('%s/fig/%s/mse_k/msemod_k_wf-%s_wi-%s_mix.%s',resultdir,subdir,wfstr{wf},wistr{wi},fileext),pictype);
				end
			end
		end
	end

	% Log significance tests
	plotwi = [1 3 4 5 6];
	plotkvalstr = strread(num2str(kvals(plotkvals)),'%s');
	for wf = 1:length(wfield_range)
		for wi = plotwi
			sigmat = squeeze(sigwin(wf,wi,:,:));
			fprintf('%s, wf=%.2f, wi=%.1f \n',subdir,wfield_range(wf),winter_range(wi));
			disptable(sigmat,plotkvalstr,{'SC-Bethe','SC-TRBP','SC-Unif'});
		end
	end	
end


close all;
