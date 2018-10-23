# Pipeline operation
The NewsReader pipeline can advantageously be represented as a directed acyclic graph, where vertices correspond to components, and edges to components dependencies.

The pipeline is created from a list of component specifications, as explained next. Given a directed graph, it is straightforward to subset part of the pipeline graph by [filtering input layers, goal layers or goal components](#component-filtering). Finally, [topological sorting](#topological-sorting-and-pipeline-execution) of the graph provides a list of components in order of execution.

If errors are detected in the execution of components, the component execution list is modified to allow for maximum processing of the input, as explained [below](#error-handling).

## Pipeline configuration and creation
The pipeline graph is created from a list of components, where each component provides the following information:

- component identifier
- input layers
- output layers
- prerequired components
- execution script name *(execution only)*


Each component is represented as a vertex in the graph. There is a one-to-one relation between components and vertices, and we may use the terms interchangeably for brevity.

For each distinct component pair `(m_1, m_2)`, we add an edge from their respective vertices `v_1` to `v_2` if and only if:

- `v_1` outputs a NAF layer that is input to `v_2`
- *or* `m1` is prerequired by `m_2`

Vertices with no incoming edges are connected to a root vertex.

#### Overspecifying component dependencies
The graph may contain redundant edges as a result of overspecified dependencies in the configuration components list (redundancies between the preceding components and input/output layer specifications, or between input layers and layers obtainable by transitivity). 
While it would be possible to reduce the graph (transitive reduction), the pipeline is not affected by such redundancies.

#### Underspecifying dependencies
Unconnected vertices in the graph are detected when sorting the graph for execution.

#### Cyclic dependencies
The graph should be acyclic. Cyclic dependencies are detected when [sorting](#topological-sorting-and-pipeline-execution) the graph for execution.

## Component filtering
The components configuration list allows to specify a maximal pipeline.
The graph created from this list can be refined to include only specific goal layers or components, or input layers.

#### Filtering by goal layers
Given a list of goal layers, the graph is filtered to keep only the components (vertices) that allow to produce these layers (keeping vertices on the path between root and these components). All components with a goal layer are kept, including components that only modify that layer.

#### Filtering by goal components
Given a list of goal components, the graph is filtered to keep these components, and the components they depend on (keeping vertices on the path between root and goal components).

#### Filtering by input layers
The pipeline normally expects a raw input file, and at least one component operating on an empty (or null) input layer list. One can however filter the graph with a list of input layers. In that case, vertices that produce these layers are filtered out, keeping only components that input these layers and their children vertices. Vertices with no incoming edges after this filtering are reconnected to the root vertex. The resulting pipeline is intended to operate on a NAF file that contains these input layers.

#### Combined filtering
On can combine input filtering with either goal-component or goal-layer filtering.
 One can however not combine goal-layer with goal-component filtering, for instance to select all components outputting some layer and only part of the components outputting another layer; one needs to provide all goal components and use goal-component filtering in that case (see the [usage](docs/usage.md) page for examples).


## Topological sorting and pipeline execution
The graph can be sorted into an executable list of components, where all component dependencies are satisfied when any given component is called. Sorting proceeds by visiting the graph from the root depth first and keeping track of the visited vertices; if one encounters a vertex with incoming edges from non-visited vertices, this vertex is put in a waiting queue; otherwise, the vertex is added to a stack. Sorting continues on the waiting queue, until it is empty or stops changing (because of a cycle).

Upon normal termination, sorting returns a stack of ordered vertices, which can then be visited sequentially to execute each pipeline component. Note that sorting may return different topological orderings for a same graph, depending on the freedom allowed by component dependencies.

## Error handling and rescheduling
If an error is detected during the execution of a component, the remaining components are filtered to keep those that do not depend on the failing one. Pipeline execution then proceeds with the filtered components (on the same input file as to the failing component), allowing for maximal processing of the input.

Errors are detected by searching for keywords in the `stderr` stream of each component; we are considering the following keywords: 'error', 'Error', 'Exception' and ' fault'.

This process is repeated as often as a component fails and an alternative component schedule can be produced.

## Further reading
Input and output files are described on the [interface](docs/interface.md); the [usage](docs/usage.md) lists arguments to the pipeline and provides advanced usage examples.
