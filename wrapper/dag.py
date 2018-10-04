import sys

"""
stores module information, and links to children and parent vertices
"""
class Vertex:
    def __init__(self, node):
        self._node = node
        self._children = []
        self._parents = []

    def __str__(self):
        return str(self._node) + ' children: ' + str([x.node.id for x in self._children])+ '; parents: ' + str([x.node.id for x in self._parents])

    def add_child(self, child):
        self._children.append(child)

    @property
    def children(self):
        return self._children

    @children.setter
    def children(self, val):
        self._children = val

    def add_parent(self, parent):
        self._parents.append(parent)

    @property
    def parents(self):
        return self._parents

    @parents.setter
    def parents(self, val):
        self._parents = val

    @property
    def node(self):
        return self._node

    @node.setter
    def node(self, val):
        self._node = val


"""
maps module ids to module vertices 
"""
class Graph:
    def __init__(self):
        self.graph = {}

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
        self.graph.pop(n)

    def add_edge(self, frm, to):
        self.graph[frm].add_child(self.graph[to])
        self.graph[to].add_parent(self.graph[frm])

    def get_keys(self):
        return self.graph.keys()

    def get_vertices(self):
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
                raise ValueError('found cycle while sorting: check the module definitions for {}'.format(', '.join(v for v in waiting)))
        if len(visited) < len(self.get_keys()):
            unconnected = self.get_keys() - visited
            raise ValueError('Unconnected vertices: {}'.format(', '.join(v for v in unconnected)))
        return stack

    def on_path_loop(self, goal, on_path):
        on_path.add(goal)
        if goal not in self.graph:
            raise KeyError('could not find module {} in graph:\n{}'.format(goal, str(self.graph)))
        for p in self.graph[goal].parents:
            self.on_path_loop(p.node.id, on_path)

    def on_path_to(self, goal):
        on_path = set()
        self.on_path_loop(goal, on_path)
        return on_path

    def on_path_from_loop(self, frm, on_path):
        on_path.add(frm)
        if frm not in self.graph:
            raise KeyError('could not find module {} in graph:\n{}'.format(frm, str(self.graph)))
        for p in self.graph[frm].children:
            self.on_path_from_loop(p.node.id, on_path)

    def on_path_from(self, frm):
        on_path = set()
        self.on_path_from_loop(frm, on_path)
        return on_path
       
    def find_keys(self, matching):
        return [k for k, v in self.graph.items() if matching(v)]

