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


The pipeline wrapper assembles the modules into a valid pipeline based on input/output layers and on module precedence (specified through 'after'); module precedence is useful for modules that must run in order while operating on the same layer. An example configuration file for the whole pipeline is provided in *./tests/data/example/pipeline.yml*.

The pipeline assembled by the wrapper runs on 'stdin' input. The tokenization module script provided here currently expects a raw text input, but it can be modified to read a raw NAF input. Execution scripts for the modules are located in *./scripts/bin/*. To run the pipeline from outside the repository's directory, the path to these scripts can be specified with the option *-d*.

The wrapper reads the 'stderr' stream produced by each module. Upon an error message, the wrapper rebuilds and runs a pipeline with the remaining modules. The wrapper produces the following files (in the directory from which it is called):

- *pipeline.out*: the NAF file produced by the pipeline;
- *cfg_out.yml*: the output configuration file copies the input configuration file and adds the execution 'status' of each module (this can be 'completed', 'failed' or 'not_run');
- *pipeline.log*: the log file provides the 'stderr' stream produced by each module, and prints out an execution summary with the scheduled pipeline, the executed pipeline and the failing or remaining modules.


The output configuration file and output NAF can be given again as input to the wrapper; this is useful if some module failed and can be fixed. The wrapper then builds a pipeline based on module status: previously 'failed' or 'not_run' modules are scheduled for execution, while the 'completed' modules are checked for validation (the layers in the NAF input are read from the 'completed' modules rather than from the NAF file itself). 

#### Usage
The wrapper produces output files in the directory from which it is called, e.g. 'workdir'. Assuming this directory contains an input configuration file 'cfg.yml' and an input file 'text.txt':
```
cat text.txt | python <path-to-repo>/wrapper/pipeline.py -c cfg.yml -d <path-to-repo>/scripts/bin/ 
```

