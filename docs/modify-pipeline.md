# Modifying the pipeline

Adding or replacing pipeline components involves three steps:

- adding installation instructions to the installation script `./scripts/install.sh`
- adding the component to the pipeline configuration file: see [pipeline configuration](https://github.com/cltl/vu-rm-pip3/blob/master/docs/configuration.md)
- adding an executable script for the component: see [pipeline configuration](https://github.com/cltl/vu-rm-pip3/blob/master/docs/configuration.md)  

## Running the pipeline with alternative components

To have two pipelines differ by a single component, the simplest method is to use two pipeline configuration files, one for each alternative component (this because the pipeline configuration file is intended to run a full pipeline).

The steps to follow are then:

- modifying the install script to install both components
- creating two pipeline configuration files, that differ only in the specification of the alternative components. See [usage](https://github.com/cltl/vu-rm-pip3/blob/master/docs/usage.md) for specifying non-default configuration files.
- add executable scripts for each alternative component 


