*******************************************************
Welcome to the VU Reading Machine!
*******************************************************
The VU Reading Machine (vu-rm-pip3: VU Reading Machine PIPeline with NAF v3) processes Dutch texts and generates high-level semantic interpretations: annotated concepts, entities (people, organisations, places), events and roles, time expressions and opinions. The interpretations are interesting for humanities researchers and social scientists that want to investigate the content of large text collections. 

The VU Reading Machine is based on the Dutch NLP pipeline developed at the VU in the `NewsReader <http://www.newsreader-project.eu/>`_ and `BiographyNet <http://www.biographynet.nl>`_ projects. The pipeline uses a text streaming architecture in which modules take a text stream as input and generate a text stream as output in a predefined format: the Natural Language Annotation Format (`NAF <https://github.com/newsreader/NAF>`_). NAF uses a layered stand-off representation based on LAF and various other ISO proposals for NLP output representation.

The code for the VU Reading Machine consists of a flexible, language-independent python 3 pipeline wrapper as well as installation and execution scripts for the Dutch NewsReader pipeline on Linux. 

The pipeline wrapper addresses the following needs:

* functionality: the pipeline is modelled as a graph, allowing for flexible scheduling; pipeline components are configured separately;
* robustness: errors in components are detected and used to reschedule the pipeline components, allowing for maximum processing of the input;
* clarity: the error outputs of individual components are logged, together with a report of completed/failed components.

The Dutch pipeline can easily be modified both at installation and execution:

* installation is performed through a shell script; versions of the pipeline components are recorded separately and can be updated very simply (see :ref:`configuration <configuration>`); 
* the pipeline components and their execution details are recorded in a yaml configuration file. Besides, the wrapper arguments allow for fine-grained control of the pipeline execution (see :ref:`Usage <usage>`). 



Quick start
============ 
Linux
------------
The vu-rm-pip3 repository contains the wrapper as well as code to install and run components of the Dutch NewsReader pipeline. To clone the repository:
   
.. code-block:: console

    git clone https://github.com/cltl/vu-rm-pip3.git

Run the script ``install.sh`` to install the components of the Dutch NewsReader pipeline: 

.. code-block:: console

    ./scripts/install.sh

See :ref:`installation` for a list of requirements and for installing the VU Reading Machine on Windows.
 
The script ``run-pipeline.sh`` allows to run the pipeline on a raw text document to produce a fully annotated NAF document:
    
.. code-block:: console

    ./scripts/run-pipeline.sh < input.txt > output.naf

See :ref:`usage` for more options.

Docker 
------
You can also pull and run a Docker image from DockerHub: 

.. code-block:: console

    docker pull vucltl/vu-rm-pip3

To run the image on an input file `./example/test.txt`: 

.. code-block:: console

    docker run -v $(pwd)/example/:/wrk/ vucltl/vu-rm-pip3 /wrk/test.txt > example/test.out 2> example/test.log

See :ref:`docker` for more information.

RDF
--------
The script ``scripts/bin/naf2sem-grasp.sh`` allows to extract an RDF file from pipeline output NAF files. See :ref:`rdf` for more information.

Further reading
================

* :ref:`newsreader-pipeline` lists the pipeline components used by the pipeline, as well as the dependencies between them.
* :ref:`wrapper` provides information on the pipeline-wrapper operation, detailing configuration, filtering, execution and error handling.
* :ref:`installation` contains requirements and installation instructions for Linux and Windows.
* :ref:`configuration` provides information on pipeline configuration, input/output files and instructions to modify the pipeline or its components.
* :ref:`usage` lists pipeline arguments and advanced usage examples.
* :ref:`docker` provides information on getting and running the docker image.


