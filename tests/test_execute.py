import wrapper.pipeline as pipeline

single_word = 'tests/data/single_word.txt'
four_words = 'tests/data/four_words.txt'
cfg = 'cfg/pipeline.yml'
part1_out = 'tests/data/pipe_part1.txt'
fail_cfg = 'tests/data/fail.yml'
fail_alpino_cfg = 'tests/data/fail-alpino.yml'
fail_empty_cfg = 'tests/data/empty-out.yml'
NB_COMPS = 15


def test_finish_incomplete_pipeline():
    goal_layers = ['opinions', 'timex']
    p = pipeline.create_pipeline(cfg, in_layers=['opinions', 'timex'], goal_layers=goal_layers)
    scheduled = p.topological_sort()
    assert len(scheduled) == 2
    with open(part1_out, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == len(goal_layers)


def test_executable_components_after_failure():
    p = pipeline.create_pipeline(fail_cfg)
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    failed = [v for v in summary.values() if v == 'failed']
    assert len(completed) == p.nb_components() - 1
    assert len(failed) == 1

 
def test_rescheduling_after_alpino_failure():
    p = pipeline.create_pipeline(fail_alpino_cfg)
    scheduled = p.topological_sort()
    assert len(scheduled) == 4
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    failed = [v for v in summary.values() if v == 'failed']
    not_run = [v for v in summary.values() if v == 'not_run']
    assert len(not_run) == 1
    assert len(completed) == 2
    assert len(failed) == 1

 
def test_component_fails_in_partially_generated_layer():
    goal_layers = ['terms']
    p = pipeline.create_pipeline(cfg, in_layers=['terms'], goal_layers=goal_layers)
    scheduled = p.topological_sort()
    assert len(scheduled) == 3
    with open(part1_out, 'r') as f:
        summary = p.execute(f)
    failed = [v for v in summary.values() if v == 'failed']
    assert len(failed) == 1


def test_pipeline_with_modified_component_args():
    goal_layers = ['deps']
    subargs = {'vua-alpino': '-t 0.2'}
    p = pipeline.create_pipeline(cfg, goal_layers=goal_layers, subargs=subargs)
    assert p.nb_components() == 3
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == 3


def test_pipeline_detects_empty_output():
    goal_layers = ['deps']
    p = pipeline.create_pipeline(fail_empty_cfg, goal_layers=goal_layers)
    assert p.nb_components() == 3
    with open(single_word, 'r') as f:
        summary = p.execute(f)
    not_run = [v for v in summary.values() if v == 'not_run']
    assert len(not_run) == 1


def test_full_pipeline():
    p = pipeline.create_pipeline(cfg)
    assert p.nb_components() == NB_COMPS
    with open(four_words, 'r') as f:
        summary = p.execute(f)
    completed = [v for v in summary.values() if v == 'completed']
    assert len(completed) == NB_COMPS

