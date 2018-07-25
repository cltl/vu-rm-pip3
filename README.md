# vu-rm-pip3


The VU Reading Machine (RM) pipeline annotates Dutch documents for high-level semantic analysis. 
The pipeline builds on two projects, [Newsreader](http://www.newsreader-project.eu) and [BiographyNet](http://www.biographynet.nl), and aims at providing a flexible backbone for Digital Humanities projects.

The pipeline processes documents in [NAF](https://github.com/newsreader/NAF) format, passing them through a number of annotators. The pipeline currently uses fixed resources for each annotator, and runs them in a fixed order:

  - tokenizing: [ixa-pipe-tok](https://github.com/ixa-ehu/ixa-pipe-tok)
  - POS tagging, lemmatization and parsing: [Alpino NAF wrapper](https://github.com/cltl/morphosyntactic_parser_nl)
  - named entity recognition: [ixa-pipe-nerc](https://github.com/ixa-ehu/ixa-pipe-nerc/blob/master/README.md)
  - named entity disambiguation: [ixa-pipe-ned](https://github.com/ixa-ehu/ixa-pipe-ned)
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
The script *install.sh* will install the pipeline components, and most of their dependencies. 

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
Within the python environment of your choice (the pipeline was tested with python 2.7 and python 3.5.2), do:
```
pip install -r ./env/requirements.txt
```

#### Python 3 compatibility
Not all python components are python3-compatible yet. Call the script *./scripts/util/port-to-python3.sh* to back-up the relevant modules and convert them to python2/3-compatible code. The script uses 2to3, futurize and module-specific patches. 

#### Scripts
You can test the pipeline against a short reference document with the *test-components.sh* script. This will test each component against a reference NAF file.
```
./scripts/test-components.sh [-v]
```
The *v* flag creates a log file in the *./test/out/* folder.

A second test script, *test-pipeline.sh*, runs a raw NAF input through each component in the pipeline and tests whether each component adds a processing layer to the NAF header. 
```
./scripts/test-pipeline.sh [-v] [-i <naf.raw>]
```
By default, the script runs the pipeline on a short example raw NAF (*./test/example/test.raw.naf*), but you can provide your own input with the *i* flag. The script outputs all intermediary annotations in the same folder as the input file.

Finally, the run script *run-pipeline.sh* reads an input raw NAF from stdin, and outputs the result to stdout:
```
./scripts/run-pipeline.sh < naf.raw > naf.out
```

