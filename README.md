# vu-rm-pip3


The VU Reading Machine (RM) pipeline annotates Dutch documents for high-level semantic analysis. 
The pipeline builds on two projects, [Newsreader](http://www.newsreader-project.eu) and [BiographyNet](http://www.biographynet.nl), and aims at providing a flexible backbone for Digital Humanities projects.

The pipeline processes documents in [NAF](https://github.com/newsreader/NAF) format, passing them through a number of annotators. The pipeline currently uses fixed resources for each annotator:

  - tokenizing: [ixa-pipe-tok](https://github.com/ixa-ehu/ixa-pipe-tok)
  - POS tagging, lemmatization and parsing: [Alpino NAF wrapper](https://github.com/cltl/morphosyntactic_parser_nl)
  - named entity recognition: [ixa-pipe-nerc](https://github.com/ixa-ehu/ixa-pipe-nerc/blob/master/README.md)
  - word sense disambiguation: [svm-wsd](https://github.com/cltl/svm_wsd)
  - time/date standardisation: [ixa-heideltime](https://github.com/ixa-ehu/ixa-heideltime) 
  - semantic role labelling: [vua-srl-nl](https://github.com/newsreader/vua-srl-nl)
  - FrameNet labelling: [OntoTagger](https://github.com/cltl/OntoTagger)
  - predicate matrix tagging: [OntoTagger](https://github.com/cltl/OntoTagger)
  - nominal event detection: [OntoTagger](https://github.com/cltl/OntoTagger)
  - nominal event predicate labelling: [vua-srl-dutch-nominal-events](https://github.com/newsreader/vua-srl-dutch-nominal-events)
  - factuality: [multilingual_factuality](https://github.com/cltl/multilingual_factuality)
  - opinion mining: [opinion_miner_deluxePP](https://github.com/cltl/opinion_miner_deluxe)
  - event coreference: [EventCoreference](https://github.com/cltl/EventCoreference)


----
## Installation
The script *install.sh* will install the pipeline components (in *./components*), and most of their dependencies. 

Missing dependencies notably include [timbl](http://ilk.uvt.nl/timbl). Please refer to the home page of the relevant modules for additional information. 

#### Requirements
You will need Maven 3 (we tested the installation with Maven 3.5.4) and Java 8 for the installation. You should set $MAVEN_HOME, $JAVA_HOME and $PATH in, e.g., *~/.bash_profile*:
```shell
export JAVA_HOME=<path-to-jdk>/jdk1.8.0_x
export MAVEN_HOME=<path-to-maven>/apache-maven-3.5.4
export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}
``` 

----
## Running the pipeline
#### Python environment
The file *./env/requirements.txt* lists the python packages needed to run the pipeline. 
Within the python environment of your choice (the pipeline was tested with python 3.5.2), do:
```
pip install -r ./env/requirements.txt
```

#### Python 3 compatibility
Not all python components are python3-compatible yet. Call the script *./scripts/util/port-to-python3.sh* to back-up the relevant modules and convert them to python2/3-compatible code. The script uses 2to3, futurize and module-specific patches. 

#### Python wrapper 
The pipeline runs with the *./wrapper/pipeline.py* script (for python 3 only). 

The pipeline expects a yaml configuration file specifying which modules constitute the pipeline; each module specification provides the following information:
- input layers: lists input NAF layers required by the module;
- output layers: lists the NAF layers produced or modified by the module;
- name: name of the module
- [after]: lists the names of modules that need to be run before the module;
- cmd: name of the shell script for running the module 


The pipeline wrapper assembles the modules into a valid pipeline based on input/output layers and on module precedence (specified through 'after'); module precedence is useful for modules that must run in order while operating on the same layer. An example configuration file for the whole pipeline is provided in *./example/pipeline.yml*. You can specify a path to another config file with the *-c* option.

The pipeline assembled by the wrapper runs on 'stdin' input. The tokenization module script provided here currently expects a raw text input, but it can be modified to read a raw NAF input. Execution scripts for the modules are located in *./scripts/bin/*. This path can be modified to another location with the option *-d*. Output NAF files are written to 'stdout'.

The wrapper reads the 'stderr' stream produced by each module. Upon an error message, the wrapper rebuilds and runs a pipeline with the remaining modules. A log file records the 'stderr' stream of each module and an execution summary indicating: the scheduled modules (in order); which modules were completed; which failed; which could not run because of failing dependencies. The log file is written to *pipeline.log*, in the directory from which the script is called. Another file path can be provided through option *-l*.

The wrapper takes a number of options that allow to control pipeline flow:
- o -- goal_layers: the pipeline will only run the modules needed to produce the specified layers
- m -- goal_modules: the pipeline will only run the modules needed to produce the specified modules
- i -- input_layers: these layers are assumed present in the NAF input file; accordingly, modules that produce these layers are removed from the pipeline; 

Specification of goal modules and input layers can be combined: this is handy if one needs to run only part of the modules that can operate on a layer. Suppose for instance that the 'terms' layer was created, but that some modules modifying it fail and need to be rerun; one can specify 'terms' as input layer, and, e.g., 'vua_wsd,pm_tagger' as goal modules. To proceed further than the 'terms' layer afterwards, one will nee to specify 'terms' as input layer again, without goal modules. 

#### Bash script
The *./run-pipeline.sh* allows to run the pipeline with the same options as the python wrapper. 
Running the following command will load a base configuration file, run the full pipeline on *input.txt*, and write a log file *pipeline.log* to your working directory.
```
cat input.txt | <path-to-repo>/run-pipeline.sh > output.naf
```

