from wrapper.pipeline import Pipeline, create_pipeline, load_modules
import wrapper.dag as dag
import pytest

single_word='tests/data/single_word.txt'
cfg='example/pipeline.yml'


def test_pipeline_creation():
    p = create_pipeline(cfg)
    assert p.nb_modules() == 14  
    scheduled = p.topological_sort()
    assert len(scheduled) == 14


def test_create_pipeline_with_in_layers_and_goals():
    goal_layers = ['opinions','entities']
    in_layers=['text','terms','deps','constituents'] 
    p = create_pipeline(cfg)
    assert p.nb_modules() == 14
    p.filter_until(goal_layers, [])    
    assert p.nb_modules() == 5
    p.filter_from(in_layers, [])    
    assert p.nb_modules() == 5
    
    p = create_pipeline(cfg, in_layers=in_layers, goal_layers=goal_layers)
    assert p.nb_modules() == 5
    assert 'opinion-miner' in p.graph.get_keys()
    assert 'ixa-pipe-nerc' in p.graph.get_keys()
    assert 'ixa-pipe-ned' in p.graph.get_keys()


def test_goals():
    p = create_pipeline(cfg, goal_layers=['text'])
    assert p.nb_modules() == 1  
    p = create_pipeline(cfg, goal_layers=['deps'])
    assert p.nb_modules() == 2  
    p = create_pipeline(cfg, goal_layers=['terms'])
    assert p.nb_modules() == 4  
    p = create_pipeline(cfg, goal_layers=['srl'])
    assert p.nb_modules() == 8  


def test_create_pipeline_with_in_layers_and_modules():
    excepted_modules=['vua-wsd']
    in_layers=['entities','terms','deps','constituents'] 
    p = create_pipeline(cfg, in_layers=in_layers, excepted_modules=excepted_modules)
    assert p.nb_modules() == 13 # vua-wsd is added again after vua-alpino
    p = create_pipeline(cfg, in_layers=['terms'], excepted_modules=excepted_modules)
    assert p.nb_modules() == 13  
    p = create_pipeline(cfg, in_layers=['terms'], excepted_modules=['vua-alpino'])
    assert 'vua-wsd' in p.graph.get_keys()
    assert 'vua-ontotagging' in p.graph.get_keys()
    assert 'vua-nominal-event-detection' in p.graph.get_keys()
    assert 'vua-srl-dutch-nominal-events' in p.graph.get_keys()
    assert p.nb_modules() == 4 # wsd is there now


def test_zero_pipeline():
    goal_layers = ['terms']
    p = create_pipeline(cfg, in_layers=['srl'], goal_layers=goal_layers)
    assert p.nb_modules() == 0

def test_goal_modules_after_goal_layers():
    excepted = ['opinion-miner']
    p = create_pipeline(cfg, goal_layers=['entities'], excepted_modules=excepted)
    assert p.nb_modules() == 4


def test_loading_modules_with_non_default_options():
    modules = load_modules(cfg, {'vua-alpino': '-t 0.2'})
    assert len(modules) == 14
    alpino_cmd = [ m.cmd for m in modules if m.id == 'vua-alpino' ]
    assert alpino_cmd[0] == "vua-alpino.sh -t 0.2" 


