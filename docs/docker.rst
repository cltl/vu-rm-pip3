.. _docker:

*********************************
Docker image
*********************************

The vu-rm-pip3 docker image allows to run the pipeline in a self-contained environment.

Obtaining the image 
================================================
You can pull the image from Docker Hub:

.. code-block:: console

    docker pull vucltl/vu-rm-pip3

Or build your own Docker image with:

.. code-block:: console

    docker build -t vu-rm-pip3 .

Usage
================================================
Running the pipeline
------------------------------------------------
The image takes a raw text file (UTF-8) as argument, and returns a processed NAF file (to ``stdout``) and a log file (through ``stderr``). The image accepts the following optional arguments:

* operation mode ``-m``: can be set to

    * ``all`` -- default, runs the full pipeline; 
    * ``opinions`` -- runs the pipeline up to the *opinion* layer; 
    * ``srl`` -- runs the pipeline up to the *srl* layer; 
    * ``entities`` -- runs the pipeline up to the *entities* layer, including named entity linking;

* nominal events switch ``-n``: per default, all the components for the ``srl`` are run; with the nominal-events switched on, nominal-event detection and labelling components are *excluded*, and only the SRL components related to verbal predicates are run;
* alpino time out ``-t``: defines the maximal per-sentence time budget for the Alpino parser (default is None);
* opinion-miner model data ``-d``: defines the model data used by the opinion miner (default is 'news').

Alternatively, the flag ``-w`` allows to directly specify a string of wrapper arguments, as documented in :ref:`usage`.

RDF conversion
------------------------------------------------
The image can also be used to extract an RDF representation of a NAF file, using the flag ``-r``.

Examples
================================================

To run the image ``vucltl/vu-rm-pip3`` on an example file ``./example/test.txt`` with the ``opinions`` mode, and write the output and log files back into ``./example/``, run:

.. code-block:: console

    docker run -v $(pwd)/example/:/wrk/ \
               vucltl/vu-rm-pip3 -m opinions /wrk/test.txt \
               > example/test.out 2> example/test.log

Alternatively, you can call the pipeline with its wrapper arguments:

.. code-block:: console

    docker run -v $(pwd)/example/:/wrk/ \
               vucltl/vu-rm-pip3 -w "-o opinions" /wrk/test.txt \
               > example/test.out 2> example/test.log


To run the full pipeline, and extract RDF from its output, run:

.. code-block:: console

    docker run -v $(pwd)/example/:/wrk/ \
               vucltl/vu-rm-pip3 /wrk/test.txt 
               > example/test.naf 2> example/test.log
    docker run -v $(pwd)/example/:/wrk/ \
               vucltl/vu-rm-pip3 -r /wrk/test.naf > example/test.rdf

