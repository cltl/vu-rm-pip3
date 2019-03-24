from wrapper.pipeline import create_pipeline, load_components
import pytest


single_word = 'tests/data/single_word.txt'
cfg = 'cfg/pipeline.yml'
NB_COMPS = 15


def test_pipeline_creation():
    p = create_pipeline(cfg)
    assert p.nb_components() == NB_COMPS
    scheduled = p.topological_sort()
    assert len(scheduled) == NB_COMPS


def test_create_pipeline_with_in_layers_and_goals():
    goal_layers = ['opinions', 'entities']
    in_layers = ['terms', 'deps', 'constituents']
    p = create_pipeline(cfg)
    assert p.nb_components() == NB_COMPS
    p.keep_from(in_layers)
    assert p.nb_components() == NB_COMPS - 2
    p.keep_until(goal_layers)
    assert p.nb_components() == 6

    p = create_pipeline(cfg, in_layers=in_layers, goal_layers=goal_layers)
    assert p.nb_components() == 6
    assert 'opinion-miner' in p.graph.keys()
    assert 'ixa-pipe-nerc' in p.graph.keys()
    assert 'ixa-pipe-ned' in p.graph.keys()
    assert 'vua-ontotagging' in p.graph.keys()


def test_goals():
    p = create_pipeline(cfg, goal_layers=['text'])
    assert p.nb_components() == 2  
    p = create_pipeline(cfg, goal_layers=['deps'])
    assert p.nb_components() == 3  
    p = create_pipeline(cfg, goal_layers=['terms'])
    assert p.nb_components() == 5  
    p = create_pipeline(cfg, goal_layers=['srl'])
    assert p.nb_components() == 9  


def test_create_pipeline_without_layer_modifying_component():
    excepted_components = ['ixa-pipe-ned']
    p = create_pipeline(cfg, excepted_components=excepted_components)
    assert p.nb_components() == NB_COMPS - 1


def test_create_pipeline_without_component_with_children_edges():
    p = create_pipeline(cfg, excepted_components=['vua-nominal-event-detection', 'vua-srl-dutch-nominal-events'])
    assert p.nb_components() == NB_COMPS - 2


def test_create_pipeline_without_component_with_dependents():
    with pytest.raises(ValueError):
        create_pipeline(cfg, excepted_components=['vua-wsd'])


def test_filtering_with_goal_layers_before_in_layers_has_no_effect():
    p = create_pipeline(cfg, in_layers=['srl'])
    nb_comps_in_filtered = p.nb_components()
    goal_layers = ['terms']
    p = create_pipeline(cfg, in_layers=['srl'], goal_layers=goal_layers)
    assert p.nb_components() == nb_comps_in_filtered


def test_loading_components_with_non_default_options():
    components = load_components(cfg, {'vua-alpino': '-t 0.2'})
    assert len(components) == NB_COMPS
    alpino_cmd = [ m.cmd for m in components if m.id == 'vua-alpino' ]
    assert alpino_cmd[0] == "vua-alpino.sh -t 0.2" 

