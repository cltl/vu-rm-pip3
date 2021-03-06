.. _configuration:

*********************************
Configuration
*********************************
Executing the pipeline requires two types of files: 

* a yaml configuration file, declaring the pipeline components and their dependencies; 
* individual executable scripts, for the execution of each pipeline component. 

The configuration file defines a maximal pipeline with all available components; components can be filtered out by specifying input layers, goal layers or goal modules, as explained in :ref:`wrapper` and :ref:`usage`. 

The default configuration file for the Dutch NewsReader pipeline is provided under ``./cfg/pipeline.yml``, and execution scripts are provided in ``./scripts/bin``, which is also the default location for such scripts. A different configuration file, and different scripts location can be specified as explained in :ref:`usage`.

Input/Output files
================================================
The pipeline reads input text documents from ``stdin`` and writes the result NAF files to ``stdout``. Besides, the ``stderr`` stream of each component and an execution summary are :ref:`logged <logging>`.


Configuration file
================================================
The components used to create the pipeline are listed in a yaml configuration file. Each component specification defines a name, a shell-script name ('cmd'), output layers, and optionally, input layers and prerequisite modules ('after').
For example, the predicate-matrix tagger is identified as 'vua-ontotagging', it inputs and outputs a *terms* NAF layer, runs with the shell script 'vua-ontotagging.sh', and it runs after the 'vua-wsd' component.

.. code-block:: yaml

    - name: vua-ontotagging
      input:
      - terms
      output:
      - terms
      cmd: vua-ontotagging.sh
      after:
      - vua-wsd

Execution scripts
================================================
The pipeline defines a common location for the executable scripts of its components. The name of that directory is prepended to the shell-script name of each component (defined through the 'cmd' spec in the configuration file) for execution. 

Each executable script defines where a given component is installed, as well as most arguments for the execution of that component. 
Current exceptions are the time-out for the Alpino wrapper, and the model data for the opinion miner. When arguments to these components are modified (``-s`` option in the execution script), they are appended to the 'cmd' spec of the relevant component. For other cases, one can modify a component shell script to set arguments externally, and let the pipeline execution script set this argument through ``-s``. 

.. _logging:

Logging
================================================
A log file is used to record the following information:

* whether components were called with non-default arguments;
* the ``stderr`` stream of each executed module;
* identified errors in the execution of a module if any, and the rescheduled pipeline;
* a summary upon completion, listing the scheduled modules, as well as the completed, failed and non-executed modules. 

The log file is written by default to ``./pipeline.log``, but a different path can be specified as explained in :ref:`usage`. 

Configuring the installation
================================================
The installation script currently hard-codes the sources of the pipeline components and models. The versions of the pipeline components are stored separately however (in ``./cfg/component_versions``) and are loaded at the beginning of the installation.  

Modifying the pipeline
================================================

To add or replace pipeline components involves three steps:

* add installation instructions to the installation script ``./scripts/install.sh``, and specify the component version in ``./cfg/component_versions``. The latter is loaded by the installation script, and provides a quick overview of the versions of the components used by the pipeline.
* add the component to the pipeline yaml configuration file ``./cfg/pipeline.yml``. You should specify the NAF input/output layers for that component, the name of its execution script, and possible dependencies with regard to other pipeline components.
* add an executable script for the component in ``./scripts/bin``.

Running the pipeline with alternative components
-------------------------------------------------

To have two pipelines differ by a single component, one can specify two pipeline configuration files (``./cfg/pipeline1.yml`` and ``./cfg/pipeline2.yml``) that differ by that component. 

Modifying the settings or arguments for a given component
----------------------------------------------------------

One can modify component shell scripts to set arguments externally. These arguments can be input to the wrapper at runtime (through the wrapper argument ``-s``, see :ref:`usage`).


