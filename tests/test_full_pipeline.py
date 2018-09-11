from wrapper import pipeline, module
import sys
import io
from wrapper.module import ixa_tok, ixa_nerc, ixa_ned, alpino_naf, svm_wsd, opin, fact, f_net, pm_tagger, ixa_time, sonar_srl, nom_event, nom_pred, coref
from wrapper.pipeline import Pipeline
from wrapper.module import Module
single_sentence='tests/data/pytests/test.raw'
components = [ixa_tok, alpino_naf, ixa_nerc, svm_wsd, pm_tagger, sonar_srl, f_net, nom_event, nom_pred, coref, opin, fact, ixa_time]



def test_pipeline_output_has_exact_size():
    p = Pipeline(components)    
    result = p.run_pipeline_from_file(single_sentence)
    print(result)
    assert len(result.split('\n')) == 358 

def test_pipeline_with_intermediary_files():
    p = Pipeline(components)    
    infile = open(single_sentence, 'r')
    result = p.run(infile, 'tests/data/pytests/', 'test')  
    assert len(result.split('\n')) == 358 

    
