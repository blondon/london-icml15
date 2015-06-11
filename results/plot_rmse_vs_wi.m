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


%% 1) Plot RMSE vs w_inter (learned)

if ismember(1,jobs)

	msefig = 100;
	plotcolors = {'k','r','b','g'};	
	
	
	plotwi = 1:length(winter_range);
	
	fontsize = 18;
	ticfontsize = 16;
	legfontsize = 12;
	linewidth = 3;
	markersize = 12;
	insetlinewidth = linewidth;
	insetmarkersize = markersize;
	
	sigwin = -ones(length(wfield_range),2*(nAlgos-1),length(plotwi));
	msered_lbp = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefrac_lbp = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msered_base = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefrac_base = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	
	wfstr = {'lo','hi'};
	
	for wf = 1:length(wfield_range)
		
		wfield = wfield_range(wf);
		figure(msefig + wf); clf;
		pos = get(gcf,'Position'); set(gcf,'Position',[pos(1:2) pos(3:4)*1.5]);
		h1 = gca(); hold(h1,'on');
% 		title(h1,sprintf('Marginal RMSE (%s, ws = %.2f)',subdir,wfield),'FontSize',fontsize);
		xlabel('\omega_p','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
		set(h1,'FontSize',ticfontsize);

		% LBP
		plotcolor = plotcolors{1};
		mse_lbp = squeeze(margmse(1,wf,plotwi,end,:,1));
		avgmse_lbp = mean(mse_lbp,2);
		stdmse_lbp = std(mse_lbp,[],2);
		plot(h1,log(winter_range(plotwi)),avgmse_lbp,[plotcolor 'o--'],...
			'LineWidth',linewidth,'MarkerSize',markersize);
		
		for a = 2:nAlgos
			
			% Convex baseline
			plotcolor = plotcolors{a};
			mse_base = squeeze(margmse(a,wf,plotwi,end,:,1));
			avgmse_base = mean(mse_base,2);
			stdmse_base = std(mse_base,[],2);
			plot(h1,log(winter_range(plotwi)),avgmse_base,[plotcolor 'o--'],...
				'LineWidth',linewidth,'MarkerSize',markersize);
		
			% SC
			bestmse = min(squeeze(margmse(a,wf,plotwi,end,:,2:end)),[],3);
			avgmse = mean(bestmse,2);
			stdmse = std(bestmse,[],2);
			plot(h1,log(winter_range(plotwi)),avgmse,[plotcolor 'v-'],...
				'LineWidth',linewidth,'MarkerSize',markersize);
			
			for i = 1:length(plotwi)
				% Significant win?
				sigwin(wf,2*(a-2)+1,i) = ttest(...
					mse_lbp(plotwi(i),:),...
					bestmse(plotwi(i),:),...
					sigthresh);
				sigwin(wf,2*(a-2)+2,i) = ttest(...
					mse_base(plotwi(i),:),...
					bestmse(plotwi(i),:),...
					sigthresh);
				% Improvement over LBP/baseline
				msered_lbp(wf,i,a-1) = (avgmse_lbp(plotwi(i)) - avgmse(plotwi(i))) / avgmse_lbp(plotwi(i));
				msefrac_lbp(wf,i,a-1) = avgmse_lbp(plotwi(i)) / avgmse(plotwi(i));
				msered_base(wf,i,a-1) = (avgmse_base(plotwi(i)) - avgmse(plotwi(i))) / avgmse_base(plotwi(i));
				msefrac_base(wf,i,a-1) = avgmse_base(plotwi(i)) / avgmse(plotwi(i));
			end
			
		end		

		% Resize plots
		axis(h1,'tight');
		v = axis(h1); axis(h1,[log(winter_range(plotwi(1)))-.2 log(winter_range(plotwi(end)))+.1 v(3)-.005 v(4)+0]);
% 		v = axis(h2); axis(h2,[log(winter_range(1))-.2 log(winter_range(2))+.1 v(3:4)]);
		set(h1,'XTick',log(winter_range(plotwi))); set(h1,'XTickLabel',winter_range(plotwi));
% 		set(h2,'XTick',log(winter_range(1:2))); set(h2,'XTickLabel',winter_range(1:2));
		
		% Legend
		legendstr = {'LBP','C-Bethe','SC-Bethe','TRBP','SC-TRBP','C-Unif', 'SC-Unif'};
		if wf==1 %&& attract
			leg = legend(h1,legendstr,'Location','SouthWest','FontSize',legfontsize);
% 			pos = get(leg,'Position'); set(leg,'Position',[.2 .22 pos(3)-.001 pos(4)+.001]);
		else
			leg = legend(h1,legendstr,'Location','West','FontSize',legfontsize);
% 			pos = get(leg,'Position'); set(leg,'Position',[.2 .22 pos(3)-.001 pos(4)+.001]);
		end
		pause
		
		% Save
		if saveplots
			if attract
				saveas(gcf,sprintf('%s/fig/%s/mse_wi/mse_wi_wf-%s_att.%s',resultdir,subdir,wfstr{wf},fileext),pictype);
			else
				saveas(gcf,sprintf('%s/fig/%s/mse_wi/mse_wi_wf-%s_mix.%s',resultdir,subdir,wfstr{wf},fileext),pictype);
			end
		end
	end

	% Log significance tests
	plotwistr = strread(num2str(winter_range(plotwi)),'%s');
	for wf = 1:length(wfield_range)
		sigmat = squeeze(sigwin(wf,:,:))';
		fprintf('%s, wf=%.2f \n',subdir,wfield_range(wf));
		disptable(sigmat,{'SC-B v L','SC-B v C-B','SC-T v L','SC-T v T','SC-U v L','SC-U v C-U'},plotwistr);
	end
	
	% Log MSE reduction
	msered_lbp
	msered_base
	
end


%% 2) Plot RMSE vs w_inter (model)

if ismember(2,jobs)

	msefig = 200;
	plotcolors = {'k','r','b','g'};	
	
	
	plotwi = 1:length(winter_range);
	
	fontsize = 18;
	ticfontsize = 16;
	legfontsize = 12;
	linewidth = 3;
	markersize = 12;
	insetlinewidth = linewidth;
	insetmarkersize = markersize;
	
	sigwin = -ones(length(wfield_range),2*(nAlgos-1),length(plotwi));
	msered_lbp = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefrac_lbp = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msered_base = zeros(length(wfield_range),length(winter_range),nAlgos-1);
	msefrac_base = zeros(length(wfield_range),length(winter_range),nAlgos-1);

	wfstr = {'lo','hi'};
	
	for wf = 1:length(wfield_range)
		
		wfield = wfield_range(wf);
		figure(msefig + wf); clf;
		pos = get(gcf,'Position'); set(gcf,'Position',[pos(1:2) pos(3:4)*1.5]);
		h1 = gca(); hold(h1,'on');
% 		title(h1,sprintf('Marginal RMSE (%s, ws = %.2f)',subdir,wfield),'FontSize',fontsize);
		xlabel('\omega_p','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
		set(h1,'FontSize',ticfontsize);

		% LBP
		plotcolor = plotcolors{1};
		mse_lbp = squeeze(margmse_model(1,wf,plotwi,end,:,1));
		avgmse_lbp = mean(mse_lbp,2);
		stdmse_lbp = std(mse_lbp,[],2);
		plot(h1,log(winter_range(plotwi)),avgmse_lbp,[plotcolor 'o--'],...
			'LineWidth',linewidth,'MarkerSize',markersize);
				
		for a = 2:nAlgos

			% Convex baseline
			plotcolor = plotcolors{a};
			mse_base = squeeze(margmse_model(a,wf,plotwi,end,:,1));
			avgmse_base = mean(mse_base,2);
			stdmse_base = std(mse_base,[],2);
			plot(h1,log(winter_range(plotwi)),avgmse_base,[plotcolor 'o--'],...
				'LineWidth',linewidth,'MarkerSize',markersize);
			
			% SC
			bestmse = min(squeeze(margmse_model(a,wf,plotwi,end,:,2:end)),[],3);
			avgmse = mean(bestmse,2);
			stdmse = std(bestmse,[],2);
			plot(h1,log(winter_range(plotwi)),avgmse,[plotcolor 'v-'],...
				'LineWidth',linewidth,'MarkerSize',markersize);

			for i = 1:length(plotwi)
				% Significant win?
				sigwin(wf,2*(a-2)+1,i) = ttest(...
					mse_lbp(plotwi(i),:),...
					bestmse(plotwi(i),:),...
					sigthresh);
				sigwin(wf,2*(a-2)+2,i) = ttest(...
					mse_base(plotwi(i),:),...
					bestmse(plotwi(i),:),...
					sigthresh);
				% Improvement over LBP/baseline
				msered_lbp(wf,i,a-1) = (avgmse_lbp(plotwi(i)) - avgmse(plotwi(i))) / avgmse_lbp(plotwi(i));
				msefrac_lbp(wf,i,a-1) = avgmse_lbp(plotwi(i)) / avgmse(plotwi(i));
				msered_base(wf,i,a-1) = (avgmse_base(plotwi(i)) - avgmse(plotwi(i))) / avgmse_base(plotwi(i));
				msefrac_base(wf,i,a-1) = avgmse_base(plotwi(i)) / avgmse(plotwi(i));
			end
			
		end

		% Resize plots
		axis(h1,'tight');
		v = axis(h1); axis(h1,[log(winter_range(plotwi(1)))-.2 log(winter_range(plotwi(end)))+.1 v(3)-.005 v(4)+0]);
% 		v = axis(h2); axis(h2,[log(winter_range(1))-.2 log(winter_range(2))+.1 v(3:4)]);
		set(h1,'XTick',log(winter_range(plotwi))); set(h1,'XTickLabel',winter_range(plotwi));
% 		set(h2,'XTick',log(winter_range(1:2))); set(h2,'XTickLabel',winter_range(1:2));
		
		% Legend
		legendstr = {'LBP','C-Bethe','SC-Bethe','TRBP','SC-TRBP','C-Unif', 'SC-Unif'};
		if wf==1 %&& attract
			leg = legend(h1,legendstr,'Location','SouthWest','FontSize',legfontsize);
% 			pos = get(leg,'Position'); set(leg,'Position',[.2 .22 pos(3)-.001 pos(4)+.001]);
		else
			leg = legend(h1,legendstr,'Location','West','FontSize',legfontsize);
% 			pos = get(leg,'Position'); set(leg,'Position',[.2 .22 pos(3)-.001 pos(4)+.001]);
		end
		pause

		% Save
		if saveplots
			if attract
				saveas(gcf,sprintf('%s/fig/%s/mse_wi/msemod_wi_wf-%s_att.%s',resultdir,subdir,wfstr{wf},fileext),pictype);
			else
				saveas(gcf,sprintf('%s/fig/%s/mse_wi/msemod_wi_wf-%s_mix.%s',resultdir,subdir,wfstr{wf},fileext),pictype);
			end
		end
	end

	% Log significance tests
	plotwistr = strread(num2str(winter_range(plotwi)),'%s');
	for wf = 1:length(wfield_range)
		sigmat = squeeze(sigwin(wf,:,:))';
		fprintf('%s, wf=%.2f \n',subdir,wfield_range(wf));
		disptable(sigmat,{'SC-B v L','SC-B v C-B','SC-T v L','SC-T v T','SC-U v L','SC-U v C-U'},plotwistr);
	end
	
	% Log MSE fraction
	msefrac_lbp
	msefrac_base
	
end




close all;
