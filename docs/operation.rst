.. _wrapper:

*********************************
Pipeline operation
*********************************
The NewsReader pipeline can advantageously be represented as a directed acyclic graph, where vertices correspond to components, and edges to components dependencies.

The pipeline is created from a list of component specifications, as explained next. Given a directed graph, it is straightforward to subset part of the pipeline graph by :ref:`filtering <filtering>`. Finally, :ref:`topological sorting <sorting>` of the graph provides a list of components in order of execution.

If errors are detected in the execution of components, the component execution list is modified to allow for maximum processing of the input, as explained :ref:`below <error-handling>`.

Pipeline configuration and creation
================================================
The pipeline graph is created from a list of components, where each component provides the following information:

* component identifier
* input layers
* output layers
* prerequired components
* execution script name *(execution only)*


Each component is represented as a vertex in the graph. There is a one-to-one relation between components and vertices, and we may use the terms interchangeably for brevity.

For each distinct component pair :math:`(m_1, m_2)` we add an edge from their respective vertices :math:`v_1` to :math:`v_2` if and only if:

* :math:`m_1` is prerequired by :math:`m_2`
* or :math:`v_1` outputs a NAF layer that is input to :math:`v_2` and :math:`m_1` and :math:`m_2` are not both modifying that layer.

The last provision prevents cyclic dependencies: components that modify a same layer will appear as siblings in the graph. 

Vertices with no incoming edges are connected to a root vertex.

Input and output layers are regarded as the prime source of information for building the graph, and the prerequired components as a mean to specify dependencies between components that operate on a same NAF layer.

Overspecifying component dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The graph may contain redundant edges as a result of overspecified dependencies in the configuration components list (redundancies between the preceding components and input/output layer specifications, or between input layers and layers obtainable by transitivity). 
While it would be possible to reduce the graph (transitive reduction), the pipeline is not affected by such redundancies.

Underspecifying dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Unconnected vertices in the graph are detected when sorting the graph for execution.

Cyclic dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The graph should be acyclic. Cyclic dependencies are detected when :ref:`sorting <sorting>` the graph for execution.

.. _filtering: 

Component filtering
================================================
The components configuration list allows to specify a maximal pipeline.
Components can be excluded from this list prior to building the pipeline; one must ensure in this case that dependencies of downstream components are still satisfied. 
The graph created from this list can be refined to include only specific goal layers or input layers. 

Filtering by goal layers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Given a list of goal layers, the graph is filtered to keep only the components (vertices) that allow to produce these layers (keeping vertices on the path between root and these components). By default, all components with a goal layer are kept, including components that only modify that layer. 

Filtering by input layers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The pipeline normally expects a raw input file, and at least one component operating on an empty input-layer list. One can however filter the graph with a list of input layers. In that case, vertices that produce these layers are kept together with their children vertices. Other vertices are filtered out. Vertices with no incoming edges after this filtering are reconnected to the root vertex. The resulting pipeline is intended to operate on a NAF file that contains these input layers.
As with goal-layer filtering, all components acting on the input layers are kept, except otherwise specified by an exclusion filter.

Combined filtering
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
On can combine input-layer filtering with goal-layer filtering. In that case, input-layer filtering is performed first. 

.. _sorting:

Topological sorting and pipeline execution
================================================
The graph can be sorted into an executable list of components, where all component dependencies are satisfied when any given component is called. Sorting proceeds by visiting the graph from the root depth first and keeping track of the visited vertices; if one encounters a vertex with incoming edges from non-visited vertices, this vertex is put in a waiting queue; otherwise, the vertex is added to a stack. Sorting continues on the waiting queue, until it is empty or stops changing (because of a cycle).

Upon normal termination, sorting returns a stack of ordered vertices, which can then be visited sequentially to execute each pipeline component. Note that sorting may return different topological orderings for a same graph, depending on the freedom allowed by component dependencies.

.. _error-handling:

Error handling and rescheduling
================================================
If an error is detected during the execution of a component, the remaining components are filtered to keep those that do not depend on the failing one. Pipeline execution then proceeds with the filtered components (on the same input file as to the failing component), allowing for maximal processing of the input.

Errors are detected by searching for keywords in the ``stderr`` stream of each component; we are considering the following keywords: 'error', 'Error', 'Exception' and ' fault'.
Component failures leading to an empty stdout stream are also detected, and handled in the same way.

This process is repeated as often as a component fails and an alternative component schedule can be produced.

Further reading
================================================
See the :ref:`configuration` for more information on configuring the pipeline, and :ref:`usage` for pipeline arguments and advanced usage examples.
