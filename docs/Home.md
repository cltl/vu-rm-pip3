The VU Reading Machine VU-RM-PIP3 builds on the Dutch NewsReader pipeline for syntactic and semantic document analysis.   

The NewsReader pipelines were developed as part of the [Newsreader project](http://www.newsreader-project.eu/), for advanced syntactic and semantic analysis of documents in Dutch, English, Italian and Spanish. These pipelines annotate documents following the [NAF annotation scheme](https://github.com/newsreader/NAF), which provides layers of annotations at the token, sentence and inter-document level.  
The pipeline we use here is a version of the [Dutch NewsReader pipeline](http://kyoto.let.vu.nl/newsreader_deliverables/NWR-D4-2-3.pdf), which defines specific components for creating or enriching the various NAF layers (see below for a graphical representation). 

VU-RM-PIP3 addresses the following needs:

- functionality: a python 3 wrapper allows for control of pipeline configuration and scheduling;
- robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
- clarity: the error output of components are logged, together with a report of completed/failed components.


## Installation and usage for Linux
The VU-RM-PIP3 pipeline repository contains the python 3 wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the VU-RM-PIP3 repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./install.sh

The [requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/requirements.md) lists requirements for installation and execution of the pipeline.

The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file `pipeline.log` in the directory from which it is called. 
You will find more information on running the pipeline on the [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md) page.

## Installation on Windows using WSL

The VU Reading Machine can be run on Windows using the Windows Subsystem for Linux (see [Microsoft reference](https://docs.microsoft.com/en-us/windows/wsl/install-win10)).

First, clone the Git repository, making sure to download the Shell files with Unix-style newlines (see [StackExchange](https://stackoverflow.com/questions/10418975/how-to-change-line-ending-settings)) using the following command.

    'git config --global core.autocrlf false'

Additionally, make sure the path of the repo does not contain any spaces (see [StackExchange](https://stackoverflow.com/questions/5163642/how-to-pass-directory-path-that-have-space-to-windows-shell)). For example, renames any directories using underscores.

Open the WSL Bash terminal and install [Timbl](https://languagemachines.github.io/timbl/). Also install Java8 and Maven3 on WSL via the Bash terminal (the Windows versions of Java and Maven will not work). 
Additionally, install 'unzip', 'libxss1', 'libxft2' and 'libtk8.5' (see [Alpino documentation](https://danieldk.eu/Posts/2017-01-10-Alpino-Windows.html)).

Possibly, both version 2 and version 3 of Python may be installed on the Linux system, and two versions of Pip. This can be checked using 'python --version'. Python3 is needed as the default Python version. This requires the creation of a new symbolic link (see see [AskUbuntu](https://askubuntu.com/questions/603949/python-2-7-is-still-default-though-alias-python-python3-4-is-set)).

Finally, install all Python requirements using 'pip install -r ./env/requirements.txt' and, additionally, install 2To3 using 'pip install 2to3'.

The pipeline may now be tested using the following command.

    ./run-pipeline.sh < example/test.txt > output.naf

However, there can still be problems related to 'setitimer' in Alpino. This can be avoided (though not solved) by removing '-t 0.2' from 'scripts/bin/vua-alpino.sh'.

## Docker
You can build a Docker image with:
```
docker build -t vu-rm-pip3 .
```
Or pull this image from Docker Hub:
```
docker pull vucltl/vu-rm-pip3
```

The image takes a raw text file (UTF-8) as argument, and accepts the following optional arguments:

- operation mode `-m`: can be set to `all` (default, runs the full pipeline); `opinions` (runs the pipeline up to the `opinion` layer); `srl` (runs the pipeline up to the `srl` layer);
- nominal events switch `-n`: per default (`-n` is False) all the components for the `srl` are run; with the nominal-events switch set to True, nominal-event detection and labelling components are *excluded*, and only the SRL components related to verbal predicates are run;
- alpino time out `-t`: defines the maximal per-sentence time budget for the Alpino parser (default is None);
- opinion-miner model data `-d`: defines the model data used by the opinion miner (default is 'news').

The output file is redirected to `stdout`, and the log file to `stderr`. To run the image on the example file `./example/test.txt` with the `opinions` mode, run:
```
docker run -v $(pwd)/example/:/work/ vu-rm-pip3 -m opinions /work/test.txt > test.out 2> test.log
```  


## Further reading
- [installation and execution requirements](https://github.com/cltl/vu-rm-pip3/blob/master/docs/requirements.md)
- [the Dutch NewsReader pipeline](https://github.com/cltl/vu-rm-pip3/blob/master/docs/newsreader.md): NAF layers and pipeline components
- [the pipeline wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md): pipeline configuration, filtering, execution and error handling 
- [pipeline interface](https://github.com/cltl/vu-rm-pip3/blob/master/docs/interface.md): input and output files
- [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md): pipeline argument and advanced usage examples


## Contact

Please submit issues to the [issue tracker](https://github.com/cltl/vu-rm-pip3/issues).
Questions can be addressed to Sophie Arnoult: sophie.arnoult@posteo.net


<img src=https://github.com/cltl/vu-rm-pip3/blob/master/docs/pipe-graph.png width="600" align="middle">

