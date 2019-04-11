.. _installation:

*********************************
Installation
*********************************

Requirements
================================================

Operating System
------------------------------------------------
The VU Reading Machine can be run on Linux and Windows using WSL; for Mac, you will need to adapt the installation of some component dependencies, notably the Alpino parser.

Component dependencies
------------------------------------------------
Not all component dependencies are installed by ``install.sh``. 
For Ubuntu 18.04, run:

.. code-block:: console

    sudo apt-get install g++ gawk git libxslt-dev make maven tcl timbl tk unzip python3-pip python3-venv

Python components and environment
------------------------------------------------
The pipeline is written for python 3, and was tested with python 3.5 and 3.6. The wrapper is not compatible with python 2. Required python packages for the pipeline are recorded under ``./cfg/requirements.txt``.

You can define python 3 as your default python through:

.. code-block:: console

    echo "alias python='python3'" >> ~/.bash_aliases
    source ~/.bash_aliases

Next, create a virtual environment, and install ``wheel`` and ``python-pytest``:

.. code-block:: console

    python -m venv venv3
    source venv3/bin/activate
    pip install wheel python-pytest 

Java components 
------------------------------------------------
The pipeline also depends on a number of java components, most of which must be compiled with Maven. We tested the compilation of these components with Maven 3.5.4 and Java 1.8.

You should set ``$MAVEN_HOME``, ``$JAVA_HOME`` and ``$PATH`` in, e.g., ``~/.bash_profile``:

.. code-block:: bash

   export JAVA_HOME=<path-to-jdk>/jdk1.8.0_x
   export MAVEN_HOME=<path-to-maven>/apache-maven-3.5.4
   export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}

Installation and usage for Linux
================================================
The vu-rm-pip3 pipeline repository contains the python 3 wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the vu-rm-pip3 repository:
   
.. code-block:: console

    git clone https://github.com/cltl/vu-rm-pip3.git
    cd vu-rm-pip3

Install Python dependencies from within the Python environment of your choice:

.. code-block:: console

    pip install -r cfg/requirements.txt

Run the script ``install.sh`` to install the components of the Dutch NewsReader pipeline:

.. code-block:: console

    ./scripts/install.sh

The installation script loads a file ``./cfg/component_versions`` that records the versions of the pipeline components (either GitHub commit numbers or version tags). Installed components, models and resources are stored in ``./lib/`` per default.
The installation script accepts two arguments:

* ``-c``: clean install; removes the components library
* ``-l``: allows to set a different path for the components library

The script ``run-pipeline.sh`` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
.. code-block:: console

    ./scripts/run-pipeline.sh < input.txt > output.naf

The script additionally produces a log file ``pipeline.log`` in the directory from which it is called. 
See :ref:`usage` for more information on running the pipeline.

Installation on Windows using WSL
================================================

The VU Reading Machine can be run on Windows using the Windows Subsystem for Linux (see `Microsoft reference <https://docs.microsoft.com/en-us/windows/wsl/install-win10>`_).

First, clone the Git repository, making sure to `download the shell files with Unix-style newlines <https://stackoverflow.com/questions/10418975/how-to-change-line-ending-settings>`_ using the following command:

.. code-block:: console

    git config --global core.autocrlf false

Additionally, make sure the path of the repo does not contain any spaces (see `StackExchange <https://stackoverflow.com/questions/5163642/how-to-pass-directory-path-that-have-space-to-windows-shell>`_). For example, rename any directories using underscores.

Open the WSL Bash terminal and install `Timbl <https://languagemachines.github.io/timbl/>`_. Also install Java8 and Maven3 on WSL via the Bash terminal (the Windows versions of Java and Maven will not work). 
Additionally, install 'unzip', 'libxss1', 'libxft2' and 'libtk8.5' (see `Alpino documentation <https://danieldk.eu/Posts/2017-01-10-Alpino-Windows.html>`_).

Possibly, both version 2 and version 3 of Python may be installed on the Linux system, and two versions of Pip. This can be checked using 'python --version'. Python3 is needed as the default Python version. This requires the creation of a new symbolic link (see see `AskUbuntu <https://askubuntu.com/questions/603949/python-2-7-is-still-default-though-alias-python-python3-4-is-set>`_).

Finally, install all Python requirements:

.. code-block:: console

    pip install -r ./cfg/requirements.txt 

The pipeline may now be tested using the following command:

.. code-block:: console

    ./scripts/run-pipeline.sh < tests/data/test.txt > output.naf

However, there can still be problems related to 'setitimer' in Alpino. This can be avoided (though not solved) as long as one does *not* set a time limit for the Alpino parser (that is the default for the pipeline). 
