The VU Reading Machine provides an up-to-date NewsReader pipeline for Dutch, for use on Linux or with Docker. 

NewsReader pipelines processe Dutch texts and generates high-level semantic interpretations: annotated concepts, entities (people, organisations, places), events and roles, time expressions and opinions. The interpretations are interesting for humanities researchers and social scientists that want to investigate the content of large text collections.
Documents are annotated with the Natural Language Annotation Format [NAF](https://github.com/newsreader/NAF), version 3.

The VU Reading Machine was developed with the intention to provide a robust and flexible pipeline. A simple scheduler allows to specify which components to run in a flexible manner, and attention has been brought to identify and report possible component failures as they occur to prevent silent failures. 

## Documentation

You will find detailed installation and usage instructions in the [documentation](https://vu-rm-pip3.readthedocs.io/en/latest/).

## Quick start
### Linux
Clone the repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Set up a python 3 environment and install `requirements.txt`, then run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./scripts/install.sh

The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./scripts/run-pipeline.sh < input.txt > output.naf


### Docker 
You can also pull and run a Docker image from DockerHub: 

    docker pull vucltl/vu-rm-pip3

To run the image on an input file `./example/test.txt`: 

    docker run -v $(pwd)/example/:/wrk/ vucltl/vu-rm-pip3 /wrk/test.txt > example/test.out 2> example/test.log

### RDF

The script `scripts/bin/naf2sem-grasp.sh` allows to extract RDF files from pipeline output NAF files. 

## Contact

Please submit issues to the [issue tracker](https://github.com/cltl/vu-rm-pip3/issues).
Questions can be addressed to Sophie Arnoult: s.i.arnoult@vu.nl



