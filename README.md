# Exploring the neural interplay of conscious perception and task representations.

## Background

Human planning is efficient—it frugally deploys limited cognitive resources to accomplish difficult tasks—and flexible—adapting to novel problems and environments. Computational approaches suggest that people construct simplified mental representations of their environment, balancing the complexity of a task representation with its utility. These models imply a nested optimisation in which planning shapes perception, and perception shapes planning - but the perceptual and attentional mechanisms governing how this interaction unfolds remain unknown. Here, we harness virtual maze navigation to characterise how spatial attention controls which aspects of a task representation enter subjective awareness and are available for planning. We find that spatial proximity governs which aspects of a maze are available for planning, and that when task-relevant information follows natural (lateralised) contours of attention, people can more easily construct simplified and useful maze representations. This influence of attention varies considerably across individuals, explaining differences in people’s task representations and behaviour. Inspired by the ‘spotlight of attention’ analogy, we incorporate the effects of visuospatial attention into existing computational accounts of value-guided construal. Together, our work bridges computational perspectives on perception and decision-making to better understand how individuals represent their environments in aid of planning


## Data

Behaviour csv file containing all data collected in Experiment 3. This included participants' awareness reports, reaction times, and the sVGC model predictions for each obstacle on every trial.  Eye-tracking data is available from the authors upon reasonable request. 

Data from experiments 1 and 2 are available from the [VGC project github](https://github.com/markkho/value-guided-construal/tree/main). Please see [Ho et al., 2022](https://www.nature.com/articles/s41586-022-04743-9) for details on the experimental procedures and the data

## Description of the code

The TaskVGCCode folder contains code to run experiment 3 (i.e., the Eye-tracking experiment). To see the Maze stimuli used for this experiment, please see the mazes folder inside this directory.

The preprocess script contains all the code for preprocessing and analyzing the Eye-tracking data of experiment 3. 

The R script Exp3_behaviour_analysis contains all of the analyses related to experiment 3.

The Plotting_VGC_maze script contains all the code necessary to visualize the maze stimuli and test for differences in nuisance covariates. This script requires the [VGC python package](https://github.com/markkho/value-guided-construal). 

The E-life_review script contains all of the additional analyses included in the revised version of the manuscript. 

## Citation
Please cite the following paper:
Jason da Silva Castanheira, Nicholas Shea, Stephen M Fleming 2025 [How attention simplifies mental representations for planning](https://elifesciences.org/reviewed-preprints/108034 ) eLife14:RP108034
