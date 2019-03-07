# Installation

## Requirements

### Operating System
The VU Reading Machine can be run on Linux and Windows using WSL; for Mac, you will need to adapt the installation of some component dependencies, notably the Alpino parser.

### Component dependencies
Not all component dependencies are installed by `install.sh`. Dependencies include: java (jdk8), maven3, python3, pip3, lib2to3, timbl, libtcl, libtk, libxslt, libxss1, libxft2, unzip, gawk, gcc, git, bash and lsof.

### Python components and environment
The pipeline is written for python 3, and was tested with python 3.5 and 3.6. The wrapper is not compatible with python 2. Required python packages for the pipeline are recorded under `./requirements.txt`.

Within the python environment of your choice, do:
```
pip install -r ./requirements.txt
```

### Java components 
The pipeline also depends on a number of java components, most of which must be compiled with Maven. We tested the compilation of these components with Maven 3.5.4 and Java 1.8.

You should set `$MAVEN_HOME`, `$JAVA_HOME` and `$PATH` in, e.g., `~/.bash_profile`:
```shell
export JAVA_HOME=<path-to-jdk>/jdk1.8.0_x
export MAVEN_HOME=<path-to-maven>/apache-maven-3.5.4
export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}
``` 

## Installation and usage for Linux
The VU-RM-PIP3 pipeline repository contains the python 3 wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the VU-RM-PIP3 repository:
   
    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script `install.sh` to install the components of the Dutch NewsReader pipeline: 

    ./scripts/install.sh

The script `run-pipeline.sh` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
    ./scripts/run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file `pipeline.log` in the directory from which it is called. 
See the [advanced usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md) page for more information on running the pipeline.

## Installation on Windows using WSL

The VU Reading Machine can be run on Windows using the Windows Subsystem for Linux (see [Microsoft reference](https://docs.microsoft.com/en-us/windows/wsl/install-win10)).

First, clone the Git repository, making sure to download the Shell files with Unix-style newlines (see [StackExchange](https://stackoverflow.com/questions/10418975/how-to-change-line-ending-settings)) using the following command.

    'git config --global core.autocrlf false'

Additionally, make sure the path of the repo does not contain any spaces (see [StackExchange](https://stackoverflow.com/questions/5163642/how-to-pass-directory-path-that-have-space-to-windows-shell)). For example, rename any directories using underscores.

Open the WSL Bash terminal and install [Timbl](https://languagemachines.github.io/timbl/). Also install Java8 and Maven3 on WSL via the Bash terminal (the Windows versions of Java and Maven will not work). 
Additionally, install 'unzip', 'libxss1', 'libxft2' and 'libtk8.5' (see [Alpino documentation](https://danieldk.eu/Posts/2017-01-10-Alpino-Windows.html)).

Possibly, both version 2 and version 3 of Python may be installed on the Linux system, and two versions of Pip. This can be checked using 'python --version'. Python3 is needed as the default Python version. This requires the creation of a new symbolic link (see see [AskUbuntu](https://askubuntu.com/questions/603949/python-2-7-is-still-default-though-alias-python-python3-4-is-set)).

Finally, install all Python requirements using 'pip install -r ./requirements.txt' and, additionally, install 2To3 using 'pip install 2to3'.

The pipeline may now be tested using the following command.

    ./scripts/run-pipeline.sh < tests/data/test.txt > output.naf

However, there can still be problems related to 'setitimer' in Alpino. This can be avoided (though not solved) as long as one does *not* set a time limit for the Alpino parser (that is the default for the pipeline). 
