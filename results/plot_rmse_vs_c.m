clear

resultdir = '.';
fileext = 'eps'; pictype = 'epsc';
% fileext = 'png'; pictype = 'png';

saveplots = 1;

attract = 1;

% Load original exp results
if attract
	subdir = 'attract';
	load([resultdir '/grid8_20_100_a.mat']);
else
	subdir = 'mixed';
	load([resultdir '/grid8_20_100_m.mat']);
end

% Rename some variables so that they don't conflict
margmse1 = margmse;
margmsemod1 = margmse_model;
kvals1 = kvals;

% Load slack exp data
if attract
	load([resultdir '/grid8_20_100_slack_a.mat']);
else
	load([resultdir '/grid8_20_100_slack_m.mat']);
end
margmsemod = margmse_model;

legendstrbase = {'C-Bethe','TRBP','C-Unif'};
legendstrsc = {'SC-Bethe','SC-TRBP','SC-Unif'};

plotalgos = 2:3;

plotwf = 1:2;
plotwi = 4:6;

plotkvals = 1:length(kvals);

plotcvals = 1:length(cvals);

plotcolorsbase = {'k','r','b','g'};
plotcolorssc = {'c','m',[0 1 .5],[1 .5 0]};

fontsize = 18;
ticfontsize = 16;
legfontsize = 12;
linewidth = 3;
markersize = 12;
insetlinewidth = linewidth;
insetmarkersize = markersize;

msefig = 401;
figure(msefig); pos = get(gcf,'Position'); set(gcf,'Position',[pos(1:2) pos(3:4)*1.5]);

% Convert to RMSE
margmse = sqrt(margmse);
margmse1 = sqrt(margmse1);
margmsemod = sqrt(margmsemod);
margmsemod1 = sqrt(margmsemod1);

wfstr = {'lo','hi'};


%% Learned marginals

for wf = plotwf
	wfield = wfield_range(wf);

	for wi = plotwi
		winter = winter_range(wi);

		for a = plotalgos

			figure(msefig); clf;
			h1 = gca(); hold(h1,'on');
			xlabel('C','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
			set(h1,'FontSize',ticfontsize);
			legendstr = cell(1+length(plotkvals),1);

			mse_base = mean(squeeze(margmse1(a,wf,wi,end,:,1)));
% 				mse_base = mean(squeeze(margmse1(a,wf,wi,end,:,end-2)));
			plot(h1,log(cvals(plotcvals)),mse_base*ones(size(plotcvals)),...
				[plotcolorsbase{a} 'o--'],'LineWidth',linewidth,'MarkerSize',markersize);
			legendstr{1} = legendstrbase{a-1};

			for k = plotkvals

				mse_sc = squeeze(margmse(a,wf,wi,end,:,k,plotcvals));
				plot(h1,log(cvals(plotcvals)),mean(mse_sc,1),...
					'v-','Color',plotcolorssc{k},'LineWidth',linewidth,'MarkerSize',markersize);
				legendstr{k+1} = sprintf('%s k=%.1f',legendstrsc{a-1},kvals(k));
			end

			% Resize plots
			axis tight
			v = axis(h1); axis(h1,[log(cvals(plotcvals(1)))-.2 log(cvals(plotcvals(end)))+.2 v(3)-.01 v(4)+.01]);
			set(h1,'XTick',log(cvals(plotcvals))); set(h1,'XTickLabel',cvals(plotcvals));

			% Legend
			%if wf==1 && ismember(wi,plotwi(1:2)) && attract
				leg = legend(h1,legendstr,'Location','Best','FontSize',legfontsize);
			%end
			
			figure(msefig);
			pause

			% Save
			if saveplots
				if attract
					saveas(gcf,sprintf('%s/fig/%s/mse_c/mse_c_wf-%s_wi-%d_%d_att.%s',resultdir,subdir,wfstr{wf},winter,a,fileext),pictype);
				else
					saveas(gcf,sprintf('%s/fig/%s/mse_c/mse_c_wf-%s_wi-%d_%d_mix.%s',resultdir,subdir,wfstr{wf},winter,a,fileext),pictype);
				end
			end
		end
	end
end


%% Using true model

for wf = plotwf
	wfield = wfield_range(wf);

	for wi = plotwi
		winter = winter_range(wi);

		for a = plotalgos

			figure(msefig); clf;
			h1 = gca(); hold(h1,'on');
			xlabel('C','FontSize',fontsize+4); ylabel('Node Marginal RMSE','FontSize',fontsize);
			set(h1,'FontSize',ticfontsize);
			legendstr = cell(1+length(plotkvals),1);

			mse_base = mean(squeeze(margmsemod1(a,wf,wi,end,:,1)));
% 				mse_base = mean(squeeze(margmse1(a,wf,wi,end,:,end-2)));
			plot(h1,log(cvals(plotcvals)),mse_base*ones(size(plotcvals)),...
				[plotcolorsbase{a} 'o--'],'LineWidth',linewidth,'MarkerSize',markersize);
			legendstr{1} = legendstrbase{a-1};

			for k = plotkvals

				mse_sc = squeeze(margmsemod(a,wf,wi,end,:,k,plotcvals));
				plot(h1,log(cvals(plotcvals)),mean(mse_sc,1),...
					'v-','Color',plotcolorssc{k},'LineWidth',linewidth,'MarkerSize',markersize);
				legendstr{k+1} = sprintf('%s k=%.1f',legendstrsc{a-1},kvals(k));
			end

			% Resize plots
			axis tight
			v = axis(h1); axis(h1,[log(cvals(plotcvals(1)))-.2 log(cvals(plotcvals(end)))+.2 v(3)-.001 v(4)+.001]);
			set(h1,'XTick',log(cvals(plotcvals))); set(h1,'XTickLabel',cvals(plotcvals));

			% Legend
			%if wf==1 && ismember(wi,plotwi(1:2)) && attract
				leg = legend(h1,legendstr,'Location','Best','FontSize',legfontsize);
			%end
			
			figure(msefig);
			pause

			% Save
			if saveplots
				if attract
					saveas(gcf,sprintf('%s/fig/%s/mse_c/msemod_c_wf-%s_wi-%d_%d_att.%s',resultdir,subdir,wfstr{wf},winter,a,fileext),pictype);
				else
					saveas(gcf,sprintf('%s/fig/%s/mse_c/msemod_c_wf-%s_wi-%d_%d_mix.%s',resultdir,subdir,wfstr{wf},winter,a,fileext),pictype);
				end
			end
		end
	end
end

close all;
