# Usage

## Basic Usage
The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:

    ./run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file `pipeline.log` in the directory from which it is called. Internally, the script calls the python module `wrapper/pipeline` with standard arguments from the repository's directory. The script is set to accept the python wrapper arguments as command-line arguments.

## Advanced usage
This section describes arguments to the python pipeline wrapper. 

### Configuration file
The pipeline wrapper uses a configuration file (provided in the repository under `./example/pipeline.yml`) to define the pipeline components, their dependencies, and the name of their execution script. A different configuration file may be specified through the `-c` option.

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

- input layers (`-i`): the wrapper executes all components from the ones acting on, i.e., creating or modifying the input layers; 
- goal layers (`-o`): the wrapper will execute all components up to and including those that output these layers, and filter out downstream components;
- excluded components (`-m`): (in combination with given input/output layers): excludes components acting on the given input/output layers.

Layers and components are documented [here](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md).

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
|   vu-rm-pip3
|___custom
|   |___bin
|       pipeline.yml
|___data
        test.txt
```

To call the pipeline on `data/test.txt` from `/home/jdoe` and output a log file `test.log` under `data/`, run:

    ./vu-rm-pip3/run-pipeline.sh -c /home/jdoe/custom/pipeline.yml \
                                 -d /home/jdoe/custom/bin/ \
                                 -l /home/jdoe/data/test.log \
                                 < data/test.txt > data/test.naf


#### Filtering the pipeline
Suppose now that you would like to produce two intermediary files: one resulting from running the pipeline up to the `vua-wsd` component, and one with additional *srl* and *coreference* NAF layers. We will write the first file to `data/test.wsd`, and the second to `data/test.coref`, and use default file settings.

To run all components up to the `vua-wsd` component, do

    ./vu-rm-pip3/run-pipeline.sh -o terms -e vua-ontotagging < data/test.txt > data/test.wsd

This will run the components `ixa-pipe-tok`, `vua-alpino`, and `vua-wsd`, while excluding the `vua-ontotagging`, which modifies the *terms* layer.

The output file `data/test.wsd` contains *text*, *constituents*, *deps* and *terms* layers, but we need to run `vua-ontotagging` to complete the *terms* layer before we can produce the *srl* and *coreference* layers. We can do this as follows:

    ./vu-rm-pip3/run-pipeline.sh -i terms -e vua-alpino,vua-wsd -o srl,coreference \
                      < data/test.wsd > data/test.coref


Note that the `-i` option assumes that upstream NAF layers are present in the input file (the pipeline does not test this).  

The `-e` option can be used for filtering both *input* and *output* layers. Note however that excluded components can be added again during input-layer filtering, if they are downstream to some other component acting on the input layer. For instance, the *terms* layer has three acting components that follow each other: `vua-alpino`, `vua-wsd`, down to `vua-ontotagging`. Excluding `vua-wsd` during input-layer filtering would lead to a pipeline starting from `vua-alpino` and `vua-ontotagging`, and include `vua-wsd` again as it is downstream to `vua-alpino`.



#### Specifying component arguments
The following call sets the Alpino time out to 0.2 min per sentence, and the opinion miner's model to 'hotel':

    ./vu-rm-pip3/run-pipeline.sh -s 'vua-alpino:-t:0.2;opinion-miner:-d:hotel' < data/test.txt > data/test.out
