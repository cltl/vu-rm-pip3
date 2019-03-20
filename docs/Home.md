The VU Reading Machine Pipeline (VU-RM-PIP3) processes Dutch texts and generates high-level semantic interpretations: annotated concepts, entities (people, organisations, places), events and roles, time expressions and opinions. The interpretations are interesting for humanities researchers and social scientists that want to investigate the content of large text collections. 

The VU Reading Machine Pipeline is based on the Dutch NLP pipeline developed at the VU in the [NewsReader](http://www.newsreader-project.eu/) and [BiographyNet](http://www.biographynet.nl) projects. The pipeline uses a text streaming architecture in which modules take a text stream as input and generate a text stream as output in a predefined format: the Natural Language Annotation Format ([NAF](https://github.com/newsreader/NAF)). NAF uses a layered stand-off representation based on LAF and various other ISO proposals for NLP output representation.

The code for the VU RM Pipeline consists of a flexible, language-independent python 3 pipeline [wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md), as well as installation and execution scripts for the [Dutch pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md) on Linux and Windows. 

The VU-RM-PIP3 wrapper addresses the following needs:

- functionality: the pipeline is modelled as a graph, allowing for flexible scheduling; pipeline components are configured separately;
- robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
- clarity: the error outputs of individual components are logged, together with a report of completed/failed components.

The Dutch pipeline can easily be modified both at installation and execution:

- installation is performed through a shell script; versions of the pipeline components are recorded separately and can be updated very simply (see [configuration](https://github.com/cltl/vu-rm-pip3/blob/master/docs/configuration.md));
- the pipeline components and their execution details are recorded in a yaml configuration file. Besides, the wrapper arguments allow for fine-grained control of the pipeline execution (see [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md)). 


## Quick start
### Installation
This repository contains the wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the VU-RM-PIP3 repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./scripts/install.sh

See [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md) for a list of requirements and for installing the VU Reading Machine on Windows.

### Running the pipeline
The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./scripts/run-pipeline.sh < input.txt > output.naf

See [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md) for more options.

### Docker 
Alternatively, you can get and run a [Docker image of the pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/docker.md).

## Further reading

- [the pipeline wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md): information on the pipeline-wrapper operation, detailing configuration, filtering, execution and error handling; 
- [the Dutch pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md): lists the pipeline components used by the pipeline, as well as the dependencies between them;
- [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md): requirements for installing the pipeline and instructions for installing on Windows;
- [pipeline configuration](https://github.com/cltl/vu-rm-pip3/blob/master/docs/configuration.md): pipeline configuration, input/output files and instructions to modify the pipeline or its components.
- [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md): pipeline argument and advanced usage examples;
- [Docker image](https://github.com/cltl/vu-rm-pip3/blob/master/docs/docker.md): getting and running the docker image; 

## Contact

Please submit issues to the [issue tracker](https://github.com/cltl/vu-rm-pip3/issues).
Questions can be addressed to Sophie Arnoult: s.i.arnoult@vu.nl



