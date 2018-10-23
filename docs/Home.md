# Welcome to the VU-RM-PIP3 Wiki

The VU-RM-PIP3 pipeline builds on the Dutch NewsReader pipeline for syntactic and semantic document analysis, improving it with a graph-based wrapper for increased functionality.   

## What is NewsReader?
The NewsReader pipelines were developed as part of the [Newsreader project](http://www.newsreader-project.eu/), for advanced syntactic and semantic analysis of documents in Dutch, English, Italian and Spanish. These pipelines annotate documents following the [NAF annotation scheme](https://github.com/newsreader/NAF), which provides layers of annotations at the token, sentence and inter-document level.  

The NewsReader pipeline we use here is a version of the [Dutch NewsReader pipeline](docs/newsreader.md). This pipeline consists of a number of components that are responsible for creating or enriching the various NAF layers (see below for a graphical representation). 

## The VU-RM-PIP3 pipeline
The VU-RM-PIP3 pipeline addresses the following needs:

- functionality: a python 3 wrapper allows for control of pipeline configuration and scheduling;
- robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
- clarity: the error output of components are logged, together with a report of completed/failed components.


## Installation and usage
The VU-RM-PIP3 pipeline repository contains the python 3 wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the VU-RM-PIP3 repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./install.sh

The [requirements](docs/requirements.md) lists requirements for installation and execution of the pipeline.

The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file `pipeline.log` in the directory from which it is called. 
You will find more information on running the pipeline on the [advanced usage](docs/usage.md) page.

## Further reading
- [installation and execution requirements](docs/requirements.md)
- [the Dutch NewsReader pipeline](docs/newsreader.md): NAF layers and pipeline components
- [the pipeline wrapper](docs/operation.md): pipeline configuration, filtering, execution and error handling 
- [pipeline interface](docs/interface.md): input and output files
- [advanced usage](docs/usage.md): pipeline argument and advanced usage examples

![Pipeline graph](docs/pipe-graph.png)

