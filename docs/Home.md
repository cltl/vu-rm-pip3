The VU Reading Machine VU-RM-PIP3 is a Dutch NewsReader pipeline for syntactic and semantic document analysis.   

The NewsReader pipelines were developed as part of the [Newsreader project](http://www.newsreader-project.eu/), for advanced syntactic and semantic analysis of documents in Dutch, English, Italian and Spanish. These pipelines annotate documents following the [NAF annotation scheme](https://github.com/newsreader/NAF), which provides layers of annotations at the token, sentence and inter-document level.  

VU-RM-PIP3 provides a flexible, language-independent pipeline wrapper for NewsReader pipelines, as well as installation and execution scripts for a Dutch pipeline. The components used in this pipeline are described in this [NewsReader deliverable](http://kyoto.let.vu.nl/newsreader_deliverables/NWR-D4-2-3.pdf) (see below for a graphical representation). 

The VU-RM-PIP3 wrapper addresses the following needs:

- functionality: the pipeline is modelled as a graph, allowing for flexible scheduling; pipeline components are configured separately;
- robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
- clarity: the error outputs of individual components are logged, together with a report of completed/failed components.


## Quick start
### Installation
The VU-RM-PIP3 pipeline repository contains the (python 3) wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the VU-RM-PIP3 repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./scripts/install.sh

See [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md) for a list of requirements and for installing the VU Reading Machine on Windows.

### Docker 
Alternatively, you can get and run a [Docker image of the pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/docker.md).

### Running the pipeline
The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./scripts/run-pipeline.sh < input.txt > output.naf

See [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md) for more options.

## Changing the pipeline or its components
The wrapper is generic and can be used for a different pipeline than the Dutch NewsReader pipeline. See [modifying the pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/modify-pipeline.md) for instructions to change pipeline or its components.  

## Further reading
- [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md)
- [the Dutch NewsReader pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md): NAF layers and pipeline components
- [the pipeline wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md): pipeline configuration, filtering, execution and error handling 
- [pipeline configuration](https://github.com/cltl/vu-rm-pip3/blob/master/docs/configuration.md): pipeline configuration, input/output files 
- [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md): pipeline argument and advanced usage examples
- [Docker image](https://github.com/cltl/vu-rm-pip3/blob/master/docs/docker.md): getting and running the docker image 
- [modifying the pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/modify-pipeline.md): changing the pipeline or its components

## Contact

Please submit issues to the [issue tracker](https://github.com/cltl/vu-rm-pip3/issues).
Questions can be addressed to Sophie Arnoult: sophie.arnoult@posteo.net


<img src=https://github.com/cltl/vu-rm-pip3/blob/master/docs/pipe-graph.png width="400" align="middle">

