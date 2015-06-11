# london-icml15
Experiment code from London et al., "The Benefits of Learning with Strongly Convex Approximate Inference," ICML, 2015.

Requires UGM library, found at https://github.com/blondon/UGM .

Before running experiments, add the code to the path by running pathdef(path2ugm), where
path2ugm is the absolute path to the UGM repo (the full repo; not just the UGM code).

Brief Description of Code:
- data/grid/makedata_grid.m : A script to generate the grid data.
- gridexp_lok.m : A script to run the grid experiment, for low values of kappa (< .1).
- gridexp_slack.m : A script to run the grid experiment, for high values of kappa, using
    the slackened counting number optimization. Since this experiment takes considerably
    longer to run, it has been split along the data dimension w_s (the field
    potential), where gridexp_slack1.m is for w_s = .05, and gridexp_slack2.m is w_s = 1.

NOTE: In the experiment scripts the parameter wf corresponds to parameter w_s in the paper,
      and wi corresponds to w_p.

