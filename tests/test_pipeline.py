from wrapper import pipeline
from wrapper.pipeline import Pipeline

single_word='tests/data/pytests/single_word.txt'
yml_cfg='tests/data/pytests/pipeline.yml'
part2_cfg='tests/data/pytests/pipe_part2.yml'
part1_out='tests/data/pytests/pipe_part1.out'
part2_out='tests/data/pytests/pipe_part2.out'
fail_cfg='tests/data/pytests/fail.yml'
fail_out='tests/data/pytests/fail.out'

"""
loads config file for full pipeline
"""
def test_modules_loaded_from_yaml_config():
    p = Pipeline(yml_cfg)
    assert len(p.modules) == 13

"""
takes a list of modules and assembles them into valid pipeline
"""
def test_pipeline_assembly_from_modules():
    p = Pipeline(yml_cfg)
    assert len(p.modules) == 13
    assert p.modules[0]['name'] == 'ixa_tok'
    assert p.modules[1]['name'] == 'alpino'

    p.build_random_pipeline()
    assert len(p.modules) == 13
    assert p.modules[0]['name'] == 'ixa_tok'
    assert p.modules[1]['name'] == 'alpino'

"""
runs pipeline from intermediary output and config
"""
def test_finish_incomplete_pipeline():
    p = Pipeline(part2_cfg)
    assert len(p.completed()) == len(p.modules) - 2
    assert len(p.failed()) == 1
    assert len(p.not_run()) == 1
    
    with open(part1_out, 'r') as f:
        p.run(f, part2_out)

    assert len(p.completed()) == len(p.modules)
    assert len(p.failed()) == 0
    assert len(p.not_run()) == 0

"""
after a module failure, runs modules that can still be executed
"""
def test_executable_modules_after_failure():
    p = Pipeline(fail_cfg)
    assert len(p.not_run()) == len(p.modules) 

    with open(single_word, 'r') as f:
        p.run(f, fail_out)

    assert len(p.completed()) == len(p.modules) - 1
    assert len(p.failed()) == 1
    assert len(p.not_run()) == 0

