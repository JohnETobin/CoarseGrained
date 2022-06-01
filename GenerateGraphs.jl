using LinearAlgebra
using MatrixNetworks
using LoopVectorization
using BenchmarkTools

# example graphs (non random)
function line_graph(n; edge_weight=1.0, directed=True)
  G = zeros(n, n)
  if directed
    # Create a directed path from the first node to the last node
    @simd G[i,i+1 for i in 1:n-1] = edge_weight
  else
    # Create an undirected path from the first node to the last node
    @simd G[i,i+1 for i in 1:n-1] = edge_weight
    @simd G[i+1,i for i in 1:n-1] = edge_weight
  end
  return G
end


function cycle_graph(n, edge_weight=1.0, directed=True)
  G = zeros(n, n)
  if directed
    # Create a directed cycle from the first node to the last node
    @simd G[i, i+1 for i in 1:n-1] = edge_weight
    @simd G[n, 1] = edge_weight
  else
    # Create an undirected cycle from the first node to the last node
    @simd G[i,i+1 for i in 1:n-1] = edge_weight
    @simd G[i+1,i for i in 1:n-1] = edge_weight
    G[n, 1] = edge_weight
    G[1, n] = edge_weight
  end
  return G
end

function grid_graph(n, edge_weight=1.0, directed=False)
  #=A square (or close to square) 2d lattice with a number of nodes close to `n`. The
  directed version of the grid graph has a source and a sink node (e.g., everything
  flows from top left to bottom right on the grid).=#

  m = sqrt(n)
  mint = round(Int, m)
  if m == mint
    m1, m2 = mint, mint
  else
    m1, m2 = mint+1, mint
  end
  G = zeros(n, n)

  if directed
    for i, j in m1, m2
      if i%m1 != 0
        G[i+j]
      end
    end
  else
    nx.set_edge_attributes(G, edge_weight, "weight")
  end
  return G
end


# random graphs

function gnp_graph(n; p=0.1, directed=True, edge_weight=1.0)
  G = zeros(n, n)
  P = rand(Float64, (n, n))
  if directed
    for i,j in 1:n, 1:n
      if P[i, j] < p
        @simd G[i, j] = edge_weight
      end
    end
  else
    for i in 1:n
      for j in i:n
        if P[i, j] < p
          @simd G[i, j] = edge_weight
          @simd G[j,i] = edge_weight
        end
      end
    end
  end
  return G
end

def sbm_graph(n, communities=4, p_within=0.2, p_between=0.05, seed=None, edge_weight=1.0, directed=True):

  # make array of block probabilities
  p = (p_within*np.eye(communities)
       +p_between*(np.ones(communities)-np.eye(communities)))

  # make list of community sizes
  size = int(n/communities)
  sizes = size*np.ones(communities, dtype=int)
  for s in sizes:
    if sum(sizes) < n:
      s += 1
    else:
      break

  # make graph
  G = nx.stochastic_block_model(sizes, p, nodelist=None, seed=seed,
                                directed=directed, selfloops=False, sparse=False)
  nx.set_edge_attributes(G, edge_weight, "weight")

  return G


def cm_graph(n, max_degree=5, directed=True, seed=None):
  '''(Directed) configuration model where there is roughly the same number of
  nodes with (in-)degree 1 as with (in-)degree 2 ... as with (in-)degree
  `max_degree`. For directed networks, the out-degree distribution is the same
  as the in-degree distribution but the in-degree and out-degree of a node are u
  ncorrelated.'''

  # make list of community sizes
  size = int(n/max_degree)
  sizes = size*np.ones(max_degree, dtype=int)
  for s in sizes:
    if sum(sizes) < n:
      s += 1
    else:
      break

  # make degree sequence
  indegrees = np.concatenate([(i+1)*np.ones(s, dtype=int) for i, s in enumerate(sizes)])
  if directed:
    outdegrees = np.copy(indegrees)
    np.random.shuffle(outdegrees)

    # make graph
    G = nx.directed_configuration_model(indegrees, outdegrees, create_using=nx.DiGraph(), seed=seed)

  else:
    # make graph
    G = nx.configuration_model(indegrees, seed=seed)

  return G

# TODO: add something like a feed-forward neural-network graph?
# or something else with hierarchical or layered structure?
