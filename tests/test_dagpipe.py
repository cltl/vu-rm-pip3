from wrapper import pipeline, dag 

import pytest

tok = {'name': 'tok', 'output': ['text'], 'cmd': 'x'}
alpino = {'name': 'alpino', 'input': ['text'], 'output': ['terms', 'deps', 'constituents'], 'cmd': 'x'}
opin = {'name': 'opin', 'input': ['text', 'terms', 'entities', 'deps', 'constituents'],'output': ['opinions'], 'cmd': 'x'}
nerc = {'name': 'nerc', 'input': ['text', 'terms'], 'output': ['entities'], 'cmd': 'x'}
nom_ev = {'name': 'nom_ev', 'input': ['text', 'terms'], 'output': ['srl'], 'cmd': 'x'}
nom_pred = {'name': 'nom_pred', 'input': ['deps', 'terms', 'srl'], 'output': ['srl'], 'after': ['nom_ev'], 'cmd': 'x'}
coref = {'name': 'coref', 'input': ['srl'], 'output': ['coreferences'], 'after': ['nom_pred', 'srl'], 'cmd': 'x'}
srl = {'name': 'srl', 'input': ['deps', 'terms', 'constituents'], 'output': ['srl'], 'cmd': 'x'}
cycle_tok = {'name': 'tok', 'output': ['text'], 'after': ['srl'], 'cmd': 'x'}

modules = [tok, alpino, opin, nom_pred, nerc, nom_ev, coref, srl]
cyclic_modules = [cycle_tok, alpino, opin, nom_pred, nerc, nom_ev, coref, srl]
unconnected_modules = [tok, alpino, coref]

def test_pipeline_creation():
    ms = pipeline.create_modules(modules)
    pipe_graph = pipeline.build_pipeline(ms)
    assert len(pipe_graph.get_keys()) == len(modules) + 1 # with root

    p = pipeline.Pipeline(pipeline.create_modules(modules))
    assert p.nb_modules() == len(modules)
    assert p.graph.get_vertex('tok').children[0].node.id == 'alpino'

def test_topological_sort():
    p = pipeline.Pipeline(pipeline.create_modules([tok]))
    ptok = p.graph.get_vertex('tok').parents
    assert ptok[0].node.id == 'root'
    schedule = p.topological_sort()
    assert len(schedule) == 1

    p = pipeline.Pipeline(pipeline.create_modules([tok, alpino]))
    ctok = p.graph.get_vertex('tok').children
    assert ctok[0].node.id == 'alpino'
    palp = p.graph.get_vertex('alpino').parents
    assert palp[0].node.id == 'tok'
    schedule = p.topological_sort()
    assert len(schedule) == 2

    p = pipeline.Pipeline(pipeline.create_modules(modules))
    assert p.nb_modules() == len(modules) 

def test_filter_graph_by_modules():
    p = pipeline.Pipeline(pipeline.create_modules([tok, alpino]))
    path = p.graph.on_path_to('tok')
    assert len(path) == 2
    assert 'alpino' not in path

    p.filter_goals(['tok'])
    assert p.nb_modules() == 1
    assert 'alpino' not in p.graph.get_keys()
    assert 'tok' in p.graph.get_keys()

    p = pipeline.Pipeline(pipeline.create_modules(modules))
    p.filter_goals(['opin', 'coref'])
    assert p.nb_modules() == 8

def test_filter_graph_by_layers():
    p = pipeline.Pipeline(pipeline.create_modules(modules))
    p.filter_layers(['srl'])
    assert p.nb_modules() == 5
    p = pipeline.Pipeline(pipeline.create_modules(modules), goal_layers=['srl'])
    assert p.nb_modules() == 5

def test_filter_input_layers():
    p = pipeline.Pipeline(pipeline.create_modules(modules), in_layers=['text','terms','deps','constituents','srl'])
    assert p.nb_modules() == 3
    assert 'opin' in p.graph.get_keys()
    assert 'nerc' in p.graph.get_keys()
    assert 'coref' in p.graph.get_keys()

def test_unconnected_vertices():
    p = pipeline.Pipeline(pipeline.create_modules(unconnected_modules))
    with pytest.raises(ValueError) as e:
        p.topological_sort()
   
def test_cycle():
    p = pipeline.Pipeline(pipeline.create_modules(cyclic_modules))
    with pytest.raises(ValueError) as e:
        p.topological_sort()
       
def test_rescheduling():       
    p = pipeline.Pipeline(pipeline.create_modules(modules))
    schedule = p.topological_sort()
    assert schedule[1].node.id == 'alpino'
    rescheduled = pipeline.reschedule([schedule[0]], schedule[2:])
    assert len(rescheduled) == 0
