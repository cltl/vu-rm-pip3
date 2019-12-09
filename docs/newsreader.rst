.. _newsreader-pipeline:

*********************************
The Dutch NewsReader pipeline
*********************************

NAF layers
================================================
NAF annotations in the Dutch pipeline consist of the following layers:

* raw: raw text 
* text: tokenized words
* terms: word senses combined with morphosyntactic information
* deps: dependency parses
* constituents: phrase-structure parses
* entities: people, locations, organizations and numeric expressions
* srl: semantic-role labels
* opinions: opinion triplets (holder, target, expression)
* factualities: annotates veracity or factuality of relevant expressions
* coreferences: marks coreferent term spans
* timeExpressions: standardized time expressions


Components
================================================
Our version of the Dutch NewsReader pipeline uses the following components:

* NAF formatting: `text2naf <https://github.com/cltl/text2naf>`_
* tokenizing: `ixa-pipe-tok <https://github.com/ixa-ehu/ixa-pipe-tok>`_
* POS tagging, lemmatization and parsing: `vua-alpino <https://github.com/cltl/morphosyntactic_parser_nl>`_
* named entity recognition: `ixa-pipe-nerc <https://github.com/ixa-ehu/ixa-pipe-nerc/blob/master/README.md>`_
* named entity disambiguation: `ixa-pipe-ned <https://github.com/ixa-ehu/ixa-pipe-ned/blob/master/README.md>`_
* word sense disambiguation: `vua-wsd <https://github.com/cltl/svm_wsd>`_
* time/date standardisation: `vuheideltimewrapper <https://github.com/cltl/vuheideltimewrapper>`_
* predicate-matrix tagging: `vua-ontotagging <https://github.com/cltl/OntoTagger>`_
* semantic role labelling: `vua-srl-nl <https://github.com/sarnoult/vua-srl-nl>`_
* factuality: `multilingual_factuality <https://github.com/cltl/multilingual_factuality>`_
* opinion mining: `opinion_miner_deluxePP <https://github.com/rubenIzquierdo/opinion_miner_deluxePP>`_
* event coreference: `EventCoreference <https://github.com/cltl/EventCoreference>`_
* nominal event detection: `vua-nominal-event-detection <https://github.com/cltl/OntoTagger>`_
* nominal event srl labelling:  `vua-srl-dutch-nominal-events <https://github.com/sarnoult>`_
* FrameNet labelling: `vua-framenet-classifier <https://github.com/cltl/OntoTagger>`_

Component versions
================================================
The versions of the components used by the pipeline are stored in ``./cfg/component_versions``. This file is loaded by the installation script.

Component dependencies
================================================
Components either generate one or more layers or modify a layer. They depend on one or more input layers, and may also require specific components to be executed first, besides the components required to produce their input layers. The following table summarizes the dependencies of the Dutch NewsReader pipeline:


============================  ========================================== =============================== ===========================
component                     input layers                                *required components*            output layers 
============================  ========================================== =============================== ===========================
text2naf                      ..                                          ..                               raw
ixa-pipe-tok                  raw                                         ..                               text   
vua-alpino                    text                                        ..                               terms, deps, constituents 
ixa-pipe-nerc                 text, terms                                 ..                               entities      
ixa-pipe-ned                  entities                                    ..                               entities      
vuheideltimewrapper           text, terms                                 ..                               timeExpressions 
vua-wsd                       text, terms                                 ..                               terms 
vua-ontotagging               terms                                       *+vua-wsd*                       terms 
vua-srl-nl                    terms, deps, constituents                   ..                               srl         
vua-framenet-classifier       terms, srl                                  *+vua-srl-nl, vua-ontotagging*   srl    
vua-nominal-event-detection   srl, terms                                  ..                               srl 
vua-srl-dutch-nominal-events  terms, dependencies, srl                    *+vua-nominal-event-detection*   srl 
vua-eventcoreference          srl, terms                                  ..                               coreferences  
opinion-miner                 text, terms, deps, constituents, entities   ..                               opinions 
multilingual-factuality       terms, coreferences, opinions               ..                               factualities 
============================  ========================================== =============================== ===========================

Pipeline graph
=============================

These dependencies result in the following execution graph:

.. image:: images/pipe-graph.png

The pipeline :ref:`wrapper <wrapper>` instantiates this graph as a directed acyclic graph, allowing for its filtering, execution and rescheduling.
