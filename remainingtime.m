function remainingtime(nJobs, nCompleted, timer)

elapsed = toc(timer);
fprintf('Finished %d of %d; elapsed: %.2f min; ETA: %.2f min \n', ...
	nCompleted, nJobs, elapsed/60, (nJobs-nCompleted)*(elapsed/nCompleted)/60);
