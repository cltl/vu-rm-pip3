# Usage

## Basic Usage
The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:

    ./scripts/run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file `pipeline.log` in the directory from which it is called. Internally, the script calls the python module `wrapper` with standard arguments from the repository's directory. The script is set to accept the python wrapper arguments as command-line arguments.

## Advanced usage
This section describes arguments to the python pipeline wrapper. 

### Configuration file
The pipeline wrapper uses a configuration file (provided in the repository under `./cfg/pipeline.yml`) to define the pipeline components, their dependencies, and the name of their execution script. A different configuration file may be specified through the `-c` option.

### Execution scripts
The pipeline wrapper relies on individual shell scripts for the execution of its components. Scripts for the components of the Dutch NewsReader pipeline are located by default under `./scripts/bin/`. The wrapper allows to define a different location through the `-d` option.
The arguments of some components can be set from the execution script through the `-s` option. This currently concerns the following elements:

- vua-alpino wrapper around Alpino: time-out `-t`
- model data for the opinion miner: data `-d`

The argument of `-s` is parsed to extract the component IDs and the relevant arguments. This is used to modify the component script calls produced by the configuration file.

### Log file
By default, a log file is written to `pipeline.log`, in the directory from which `run-pipeline.sh` is called. A different file path can be specified through the `-l` option.

### Filtering options
By default, the wrapper executes all the components listed in the configuration file. The pipeline can however be customized by filtering input or output layers and components:

- excluded components (`-e`): excludes components when building the pipeline
- input layers (`-i`): filters out components for upstream layers; the pipeline is set to start producing the specified layers 
- goal layers (`-o`): the wrapper will execute all components up to and including those that output these layers, and filter out downstream components;

Layers and components are documented [here](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md).

### Summary
The pipeline wrapper arguments are summarized in the following table:

option | description | format 
:------|:------------|:------
-c | configuration file path | *absolute path* 
-d | component scripts directory | *absolute path* 
-l | log file path | *absolute path* 
-i | input layers | *comma-separated naf layers string* 
-o | goal layers | *comma-separated naf layers string* 
-e | exclude components | *comma-separated components string* 
-s | component arguments | *semicolumn-separated triplets component-id:option:value*

### Examples
#### Specifying custom paths to files
Suppose that you adopted the following structure for your project, and are working from `/home/jdoe`, with the alternative location `custom/bin` for the components shell scripts, and an alternative configuration file `custom/pipeline.yml`.
```
/home/jdoe/
|___vu-rm-pip3
|___custom
|   |___bin
|   |___ pipeline.yml
|___data
    |___ test.txt
```

To call the pipeline on `data/test.txt` from `/home/jdoe` and output a log file `test.log` under `data/`, run:

    ./vu-rm-pip3/scripts/run-pipeline.sh -c /home/jdoe/custom/pipeline.yml \
                                         -d /home/jdoe/custom/bin/ \
                                         -l /home/jdoe/data/test.log \
                                         < data/test.txt > data/test.naf


#### Filtering the pipeline
The following command allows to build a pipeline excluding the `ixa-pipe-ned` component; the execution graph is then filtered to keep components that produce the *deps* layer, and downstream components ending with the production of the *entities* layer. 

    ./vu-rm-pip3/scripts/run-pipeline.sh -e ixa-pipe-ned -i deps -o entities < data/test.tok.naf > data/test.out

Note that the `-i` option assumes that upstream NAF layers are present in the input file (the pipeline does not test this).  


#### Specifying component arguments
The following call sets the Alpino time out to 0.2 min per sentence, and the opinion miner's model to 'hotel':

    ./vu-rm-pip3/scripts/run-pipeline.sh -s 'vua-alpino:-t:0.2;opinion-miner:-d:hotel' < data/test.txt > data/test.out


## RDF extraction
The NAF pipeline output can be converted to RDF using the [EventCoreference](https://github.com/cltl/EventCoreference) component. The NAF file should contain the following layers: *text*, *terms*, *entities*, *srl*, *coreferences*, *timeExpressions*.
Call the script `./scripts/bin/naf2sem-grasp.sh` to extract an RDF file from a pipeline output file:

    ./vu-rm-pip3/scripts/bin/naf2sem-grasp.sh < data/test.out > data/test.rdf


