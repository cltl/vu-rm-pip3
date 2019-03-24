class Vertex:
    """stores a component and its links to children and parent vertices"""
    def __init__(self, node):
        self.node = node
        self.children = []
        self.parents = []

    def __str__(self):
        return str(self.node) + ' children: ' + str([x.node.id for x in self.children]) + '; parents: ' + str([x.node.id for x in self.parents])

    def add_child(self, child):
        self.children.append(child)

    def add_parent(self, parent):
        self.parents.append(parent)

    def remove_child(self, child):
        self.children.remove(child)

    def remove_parent(self, parent):
        self.parents.remove(parent)


def create_graph(node_id, node):
    g = Graph(node_id)
    g.add_vertex(node_id, node)
    return g


class Graph:
    """stores component vertices"""
    def __init__(self, root):
        self.graph = {}
        self.root = root

    def __str__(self):
        return '\n'.join(str(x) for x in self.graph.values())

    def items(self):
        return self.graph.items()        

    def add_vertex(self, node_id, node):
        new_vertex = Vertex(node)
        self.graph[node_id] = new_vertex
        return new_vertex

    def get_vertex(self, n):
        if n in self.graph:
            return self.graph[n]
        else:
            return None

    def remove_key(self, n):
        if n == self.root:
            raise ValueError('refusing to remove graph root')
        return self.graph.pop(n)

    def add_edge(self, frm, to):
        self.graph[frm].add_child(self.graph[to])
        self.graph[to].add_parent(self.graph[frm])

    def keys(self):
        return self.graph.keys()

    def vertices(self):
        return self.graph.values()

    def topological_sort_loop(self, n, stack, visited, waiting):
        if any(p.node.id not in visited for p in self.graph[n].parents):
            waiting.add(n)
        else: 
            if n in waiting:
                waiting.remove(n)
            if n not in visited:
                stack.append(self.graph[n])
            visited.add(n)
            for c in self.graph[n].children:
                self.topological_sort_loop(c.node.id, stack, visited, waiting)

    def topological_sort(self):
        visited = set()
        waiting = set()
        stack = []
        self.topological_sort_loop('root', stack, visited, waiting)
        while waiting: 
            cp_waiting = set([e for e in waiting])
            for n in waiting:
                self.topological_sort_loop(n, stack, visited, waiting)
            if waiting == cp_waiting:
                missing_parents = set()
                for n in waiting:
                    missing_parents.update(set(p.node.id not in visited for p in self.graph[n].parents))
                if missing_parents - cp_waiting:
                    raise ValueError("Sorting cannot proceed without the components {}".format(missing_parents - cp_waiting))
                else:
                    raise ValueError('Found possible cycle while sorting: check the component definitions for {}'.format(', '.join(v for v in missing_parents)))
        if len(visited) < len(self.keys()):
            unconnected = self.keys() - visited
            raise ValueError('Unconnected vertices: {}'.format(', '.join(v for v in unconnected)))
        return stack

    def on_path_loop(self, goal, on_path):
        on_path.add(goal)
        if goal not in self.graph:
            raise KeyError('could not find vertex {} in graph:\n{}'.format(goal, str(self.graph)))
        for p in self.graph[goal].parents:
            self.on_path_loop(p.node.id, on_path)

    def on_path_to(self, goal):
        on_path = set()
        try:
            self.on_path_loop(goal, on_path)
        except KeyError as e:
            logger.error(e)
            raise
        return on_path

    def on_path_from_loop(self, frm, on_path):
        on_path.add(frm)
        if frm not in self.graph:
            raise KeyError('could not find vertex {} in graph:\n{}'.format(frm, str(self.graph)))
        for p in self.graph[frm].children:
            self.on_path_from_loop(p.node.id, on_path)

    def on_path_from(self, frm):
        on_path = set()
        try:
            self.on_path_from_loop(frm, on_path)
        except KeyError as e:
            logger.error(e)
            raise
        return on_path
      
    def find_keys(self, matching):
        return [k for k, v in self.graph.items() if matching(v)]

    def prune(self, keys):
        """removes corresponding vertices, edges and disconnected children vertices"""
        prune_keys = keys
        while prune_keys:
            to_remove = [self.remove_key(k) for k in prune_keys]
            prune_keys = []
            for key in self.graph:
                for v in to_remove:
                    if v in self.graph[key].parents:
                        self.graph[key].remove_parent(v)
                    if v in self.graph[key].children:
                        self.graph[key].remove_child(v)
                if not self.graph[key].parents and key != self.root:
                    prune_keys.append(key)

    def detach(self, keys):
        """removes corresponding vertices and edges allowing for disconnected vertices

        This operation does not guarantee that dependency requirements between vertices
        are still satisfied after edges are removed
        """
        to_remove = [self.remove_key(k) for k in keys]
        for key in self.graph:
            for v in to_remove:
                if v in self.graph[key].parents:
                    self.graph[key].remove_parent(v)
                if v in self.graph[key].children:
                    self.graph[key].remove_child(v)

