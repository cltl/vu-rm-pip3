from wrapper import pipeline

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

components = [tok, alpino, opin, nom_pred, nerc, nom_ev, coref, srl]
cyclic_components = [cycle_tok, alpino, opin, nom_pred, nerc, nom_ev, coref, srl]
unconnected_components = [tok, alpino, coref]


def test_pipeline_creation():
    ms = pipeline.create_components(components)
    pipe_graph = pipeline.build_pipeline(ms)
    assert len(pipe_graph.keys()) == len(components) + 1 # with root

    p = pipeline.Pipeline(pipeline.create_components(components))
    assert p.nb_components() == len(components)
    assert p.graph.get_vertex('tok').children[0].node.id == 'alpino'


def test_topological_sort():
    p = pipeline.Pipeline(pipeline.create_components([tok]))
    ptok = p.graph.get_vertex('tok').parents
    assert ptok[0].node.id == 'root'
    schedule = p.topological_sort()
    assert len(schedule) == 1

    p = pipeline.Pipeline(pipeline.create_components([tok, alpino]))
    ctok = p.graph.get_vertex('tok').children
    assert ctok[0].node.id == 'alpino'
    palp = p.graph.get_vertex('alpino').parents
    assert palp[0].node.id == 'tok'
    schedule = p.topological_sort()
    assert len(schedule) == 2

    p = pipeline.Pipeline(pipeline.create_components(components))
    assert p.nb_components() == len(components) 


def test_filter_graph_by_layers():
    p = pipeline.Pipeline(pipeline.create_components(components))
    p.keep_until(['srl'])
    assert p.nb_components() == 5
    p = pipeline.Pipeline(pipeline.create_components(components), goal_layers=['srl'])
    assert p.nb_components() == 5


def test_filter_input_layers():
    p = pipeline.Pipeline(pipeline.create_components(components), in_layers=['entities', 'coreferences'])
    assert p.nb_components() == 3
    assert 'opin' in p.graph.keys()
    assert 'nerc' in p.graph.keys()
    assert 'coref' in p.graph.keys()


def test_unconnected_vertices():
    with pytest.raises(ValueError):
        pipeline.Pipeline(pipeline.create_components(unconnected_components))

   
def test_cycle():
    p = pipeline.Pipeline(pipeline.create_components(cyclic_components))
    with pytest.raises(ValueError):
        p.topological_sort()

       
def test_rescheduling():       
    p = pipeline.Pipeline(pipeline.create_components(components))
    schedule = p.topological_sort()
    assert schedule[1].node.id == 'alpino'
    rescheduled = pipeline.reschedule([schedule[0]], schedule[2:])
    assert len(rescheduled) == 0

