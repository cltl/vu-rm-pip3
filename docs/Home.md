The VU Reading Machine VU-RM-PIP3 builds on the Dutch NewsReader pipeline for syntactic and semantic document analysis.   

The NewsReader pipelines were developed as part of the [Newsreader project](http://www.newsreader-project.eu/), for advanced syntactic and semantic analysis of documents in Dutch, English, Italian and Spanish. These pipelines annotate documents following the [NAF annotation scheme](https://github.com/newsreader/NAF), which provides layers of annotations at the token, sentence and inter-document level.  
The pipeline we use here is a version of the [Dutch NewsReader pipeline](http://kyoto.let.vu.nl/newsreader_deliverables/NWR-D4-2-3.pdf), which defines specific components for creating or enriching the various NAF layers (see below for a graphical representation). 

VU-RM-PIP3 addresses the following needs:

- functionality: a python 3 wrapper allows for control of pipeline configuration and scheduling;
- robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
- clarity: the error output of components are logged, together with a report of completed/failed components.


## Installation and requirements
See [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md) for installing the VU Reading Machine on Linux or Windows.

## Running the pipeline
You can run the pipeline using Docker or a shell script (see [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md)).

You can build a Docker image with:
```
docker build -t vu-rm-pip3 .
```
Or pull this image from Docker Hub:
```
docker pull vucltl/vu-rm-pip3
```

The image takes a raw text file (UTF-8) as argument, and accepts the following optional arguments:

- operation mode `-m`: can be set to `all` (default, runs the full pipeline); `opinions` (runs the pipeline up to the *opinion* layer); `srl` (runs the pipeline up to the *srl* layer); `entities` (runs the pipeline up to the *entities* layer, including named entity linking);
- nominal events switch `-n`: per default, all the components for the `srl` are run; with the nominal-events switched on, nominal-event detection and labelling components are *excluded*, and only the SRL components related to verbal predicates are run;
- alpino time out `-t`: defines the maximal per-sentence time budget for the Alpino parser (default is None);
- opinion-miner model data `-d`: defines the model data used by the opinion miner (default is 'news').

The output file is redirected to `stdout`, and the log file to `stderr`. To run the image on the example file `./example/test.txt` with the `opinions` mode, run:
```
docker run -v $(pwd)/example/:/work/ vu-rm-pip3 -m opinions /work/test.txt > test.out 2> test.log
```  


## Further reading
- [installation and requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/installation.md)
- [the Dutch NewsReader pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md): NAF layers and pipeline components
- [the pipeline wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md): pipeline configuration, filtering, execution and error handling 
- [pipeline interface](https://github.com/cltl/vu-rm-pip3/blob/master/docs/interface.md): input and output files
- [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md): pipeline argument and advanced usage examples


## Contact

Please submit issues to the [issue tracker](https://github.com/cltl/vu-rm-pip3/issues).
Questions can be addressed to Sophie Arnoult: sophie.arnoult@posteo.net


<img src=https://github.com/cltl/vu-rm-pip3/blob/master/docs/pipe-graph.png width="600" align="middle">

