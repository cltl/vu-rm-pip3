import sys
import io
import subprocess
import pytest
from wrapper import pipeline, module
from wrapper.module import ixa_tok, ixa_nerc, ixa_ned, alpino_naf, svm_wsd, opin, fact, f_net, pm_tagger, ixa_time, sonar_srl, nom_event, nom_pred, coref
from wrapper.pipeline import Pipeline
from wrapper.module import Module
single_sentence='tests/data/pytests/test.raw'
components = [ixa_tok, alpino_naf, ixa_nerc, svm_wsd, pm_tagger, sonar_srl, f_net, nom_event, nom_pred, coref, opin, fact, ixa_time]




def test_pipeline_with_module_without_run_script():
    p = Pipeline([Module([],[],'foo')])
    with pytest.raises(AttributeError) as e:
        p.run(single_sentence, 'tests/data/pytests/', 'test')  

def test_pipeline_is_valid():
    p = Pipeline(components)    
    b = p.is_valid()
    print(b)
    assert p.is_valid()
