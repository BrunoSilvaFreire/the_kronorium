import 'dart:collection';

class AdjacencyList<TVertex, TEdge> {
  final List<AdjacencyNode<TVertex, TEdge>> _nodes = [];
  final Queue<int> _freeIndices = Queue<int>();
  final Set<int> _freeIndicesSet = <int>{};

  void clear() {
    _nodes.clear();
    _freeIndices.clear();
    _freeIndicesSet.clear();
  }

  void remove(int index) {
    _nodes[index].clear();
    _freeIndices.add(index);
    _freeIndicesSet.add(index);
  }

  int push(TVertex vertex) {
    int index;
    if (_freeIndices.isNotEmpty) {
      index = _freeIndices.first;
      _freeIndices.removeFirst();
      _freeIndicesSet.remove(index);
      _nodes[index].data = vertex;
    } else {
      index = _nodes.length;
      _nodes.add(AdjacencyNode(vertex));
    }
    return index;
  }

  int get size => _nodes.length - _freeIndices.length;

  bool get isEmpty => size == 0;

  Iterable<TVertex> get allVertices sync* {
    for (int i = 0; i < size; i++) {
      yield _nodes[i].data;
    }
  }

  TVertex? vertex(int index) => _nodes[index].data;

  TEdge? edge(int from, int to) => _nodes[from].edge(to);

  void connect(int from, int to, TEdge edgeData) {
    _nodes[from].connect(to, edgeData);
  }

  bool disconnect(int from, int to) => _nodes[from].disconnect(to);

  Iterable<(int, TEdge)> edgesFrom(int index) sync* {
    for (var node in _nodes[index].connections.entries) {
      yield (node.key, node.value);
    }
  }

// Additional methods like edgesFrom can be implemented as needed,
// following the structure and functionality of the original C++ code.
}

class AdjacencyNode<TVertex, TEdge> {
  Map<int, TEdge> _map = {};
  TVertex data;

  AdjacencyNode(this.data);

  Map<int, TEdge> get connections => _map;

  TEdge? edge(int to) => _map[to];

  void connect(int index, TEdge edgeData) {
    _map[index] = edgeData;
  }

  bool disconnect(int index) => _map.remove(index) != null;

  void clear() {
    _map.clear();
    data = null as TVertex;
  }
}
