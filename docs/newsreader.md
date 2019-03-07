# The Dutch NewsReader pipeline

## NAF layers
NAF annotations in the Dutch pipeline consist of the following layers:

- text: tokenized words
- terms: word senses combined with morphosyntactic information
- deps: dependency parses
- constituents: phrase-structure parses
- entities: people, locations, organizations and numeric expressions
- srl: semantic-role labels
- opinions: opinion triplets (holder, target, expression)
- factualities: annotates veracity or factuality of relevant expressions
- coreferences: marks coreferent term spans
- timeExpressions: standardized time expressions


## Components
Our version of the Dutch NewsReader pipeline uses the following components:

- tokenizing: [ixa-pipe-tok](https://github.com/ixa-ehu/ixa-pipe-tok)
- POS tagging, lemmatization and parsing: [vua-alpino](https://github.com/cltl/morphosyntactic\_parser\_nl)
- named entity recognition: [ixa-pipe-nerc](https://github.com/ixa-ehu/ixa-pipe-nerc/blob/master/README.md)
- named entity disambiguation: [ixa-pipe-ned](https://github.com/ixa-ehu/ixa-pipe-ned/blob/master/README.md)
- word sense disambiguation: [vua-wsd](https://github.com/cltl/svm\_wsd)
- time/date standardisation: [vuheideltimewrapper](https://github.com/cltl/vuheideltimewrapper)
- predicate-matrix tagging: [vua-ontotagging](https://github.com/cltl/OntoTagger)
- semantic role labelling: [vua-srl](https://github.com/newsreader/vua-srl-nl)
- factuality: [multilingual\_factuality](https://github.com/cltl/multilingual\_factuality)
- opinion mining: [opinion\_miner\_deluxePP](https://github.com/rubenIzquierdo/opinion_miner_deluxePP)
- event coreference: [EventCoreference](https://github.com/cltl/EventCoreference)
- nominal event detection: [vua-nominal-event-detection](https://github.com/cltl/OntoTagger)
- nominal event srl labelling:  [vua-srl-dutch-nominal-events](https://github.com/newsreader/vua-srl-dutch-nominal-events)
- FrameNet labelling: [vua-framenet-classifier](https://github.com/cltl/OntoTagger)


## Component dependencies
Components either generate one or more layers or modify a layer. They depend on one or more input layers, and may also require specific components to be executed first, besides the components required to produce their input layers. The following table summarizes the dependencies of the Dutch NewsReader pipeline:

component | input layers | *required components* | output layers 
:---------|:--------------------------|:-------------|:-------
ixa-pipe-tok | raw      | | text   
vua-alpino | text       | | terms, deps, constituents 
ixa-pipe-nerc | text, terms |     | entities      
ixa-pipe-ned | entities |     | entities      
vuheideltimewrapper | text, terms |   | timeExpressions 
vua-wsd | text, terms  |  | terms 
vua-ontotagging | terms | *+vua-wsd*         | terms 
vua-srl |       terms, deps, constituents | | srl         
vua-framenet-classifier | terms, srl    | *+vua-wsd, vua-srl, vua-ontotagging* | srl    
vua-nominal-event-detection | text, terms | *+vua-wsd, vua-ontotagging* |  srl 
vua-srl-dutch-nominal-events | terms, dependencies, srl  | *+vua-nominal-event-detection* | srl 
vua-eventcoreference |  srl      | *+vua-srl, vua-srl-dutch-nominal-events* | coreferences  
opinion-miner | text, terms, deps, constituents, entities | | opinions 
multilingual-factuality | terms, coreferences, opinions    |     | factualities 

These dependencies result in the following execution graph:

<img src=https://github.com/cltl/vu-rm-pip3/blob/master/docs/pipe-graph.png width="400" align="middle">

The pipeline [wrapper](https://github.com/cltl/vu-rm-pip3/blob/master/docs/operation.md) instantiates this graph as a directed acyclic graph, allowing for its filtering, execution and rescheduling.
