# Interface
Executing the pipeline requires two types of input files: 

- a yaml configuration file, declaring the pipeline components and their dependencies; 
- individual shell scripts, for the execution of each pipeline component. 

The configuration file defines a maximal pipeline with all available components; components can be filtered out by specifying input layers, goal layers or goal modules, as explained in the [operation](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md) and [usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md) pages. 

The pipeline writes the result NAF file to `stdout`. Besides, the `stderr` stream of each component and an execution summary are logged, as described [below](#logging).


## Configuration
The components used to create the pipeline are listed in a yaml configuration file. Each component specification defines a name, a shell-script name ('cmd'), output layers, and optionally, input layers and prerequisite modules ('after').
For example, the predicate-matrix tagger is identified as 'vua-ontotagging', it inputs and outputs a *terms* NAF layer, runs with the shell script 'vua-ontotagging.sh', and it runs after the 'vua-wsd' component.
```
- name: vua-ontotagging
  - terms
  output:
  - terms
  cmd: vua-ontotagging.sh
  after:
  - vua-wsd
```

## Execution scripts
The pipeline defines a common location for the executable scripts of its components. The name of that directory is prepended to the shell-script name of each component (defined through the 'cmd' spec in the configuration file) for execution. 

Each executable script defines where a given component is installed, as well as most arguments for the execution of that component. 
Current exceptions are the time-out for the Alpino wrapper, and the model data for the opinion miner. When arguments to these components are modified (`-s` option in the execution script), they are appended to the 'cmd' spec of the relevant component. For other cases, one can modify a component shell script to set arguments externally, and let the pipeline execution script set this argument through `-s`. 


## Logging
A log file is used to record the following information:

- whether components were called with non-default arguments;
- the `stderr` stream of each executed module;
- identified errors in the execution of a module if any, and the rescheduled pipeline;
- a summary upon completion, listing the scheduled modules, as well as the completed, failed and non-executed modules. 


## Next
Alternative paths to the input/output files can be provided to the pipeline as described on the [usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md) page.

