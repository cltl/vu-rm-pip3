import wrapper.pipeline as pipeline
import wrapper.dag as dag

single_word='tests/data/single_word.txt'
cfg='example/pipeline.yml'
part1_out='tests/data/pipe_part1.txt'
fail_cfg='tests/data/fail.yml'
fail_alpino_cfg='tests/data/fail-alpino.yml'


"""
runs pipeline from intermediary output and config
"""
def test_finish_incomplete_pipeline():
    goal_layers = ['opinions','timex']
    p = pipeline.create_pipeline(cfg, in_layers=['opinions','timex'], goal_layers=goal_layers)
    print(p.graph)
    scheduled = p.topological_sort()
    assert len(scheduled) == 2
    with open(part1_out, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == len(goal_layers)


"""
after a module failure, runs modules that can still be executed
"""
def test_executable_modules_after_failure():
    p = pipeline.create_pipeline(fail_cfg)
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    failed = [v for v in summary.values() if v == 'failed']
    assert len(completed) == p.nb_modules() - 1
    assert len(failed) == 1

 
def test_rescheduling_after_alpino_failure():
    p = pipeline.create_pipeline(fail_alpino_cfg)
    print(p.graph)
    scheduled = p.topological_sort()
    assert len(scheduled) == 3
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    failed = [v for v in summary.values() if v == 'failed']
    not_run = [v for v in summary.values() if v == 'not_run']
    assert len(not_run) == 1
    assert len(completed) == 1
    assert len(failed) == 1

 
def test_intermediary_module():
    goal_layers = ['terms']
    p = pipeline.create_pipeline(cfg, in_layers=['terms'], goal_layers=goal_layers, excepted_modules = ['vua-alpino','vua-ontotagging'])

    scheduled = p.topological_sort()
    assert len(scheduled) == 1
    with open(part1_out, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == 1


def test_pipeline_with_modified_module_args():
    goal_layers = ['deps']
    subargs = {'vua-alpino': '-t 0.2'}
    p = pipeline.create_pipeline(cfg, goal_layers=goal_layers, subargs=subargs)
    assert p.nb_modules() == 2
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == 2


