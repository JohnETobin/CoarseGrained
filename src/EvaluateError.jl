include("ReduceNetwork.jl")
include("SimulateDynamics.jl")

# Given how the original nodes are mapped to the supernodes with partitions, returns the aggregated error

function aggregateTimeSeries(originalTimeSeries, partition, type="average")
    if type == "average"
        supernodeSizes = ReduceNetwork.getSupernodeSizes(partition)
        reducedSize = len(supernodeSizes)
        originalSize = np.size(originalTimeSeries, axis=0)
        numTimeSteps = np.size(originalTimeSeries, axis=1)
        aggregatedTimeSeries = np.zeros((reducedSize, numTimeSteps))

        for node in range(originalSize)
        aggregatedTimeSeries[partition[node], :] += originalTimeSeries[node, :]/supernodeSizes[partition[node]]
        end
    end
    return aggregatedTimeSeries
end

function computeDynamicalError(originalTimeSeries, reducedTimeSeries, partition)
  reducedSize = size(reducedTimeSeries.y, 1)
  originalSize = size(reducedTimeSeries.y, 1)
  numTimeSteps = size(reducedTimeSeries.y, 2)

  aggregatedTimeSeries = aggregateTimeSeries(originalTimeSeries.y, partition)
  return np.sum(np.sum(np.power(reducedTimeSeries.y - aggregatedTimeSeries, 2)))/numTimeSteps
end

function computeIndividualError(originalTimeSeries, reducedTimeSeries, partition)
  reducedSize = size(reducedTimeSeries.y, 1)
  originalSize = size(reducedTimeSeries.y, 1)
  numTimeSteps = size(reducedTimeSeries.y, 2)
  loss = 0
  for node in range(originalSize)
    loss += lossFunction(originalTimeSeries.y[node, :], reducedTimeSeries.y[partition[node], :])
  end
  return loss
end

function lossFunction(timeseries1, timeseries2, type="L2")
  if type == "L2"
    return np.sum(np.power(timeseries1 - timeseries2, 2))/np.size(timeseries1)
  end
end

function getLoss(A, partition, initial_condition, dynamical_function, tmax, dt, function_args)
  #These functions are in the parallelized function to hopefully reduce the amount of single threaded tasks
  try
    compressed_initial_condition = ReduceNetwork.compressInitialCondition(initial_condition, partition)
    reducedA = ReduceNetwork.compressAdjacencyMatrix(A, partition)
  catch
    return np.nan
  end
  
  originalTimeSeries = SimulateDynamics.simulateODEonGraph(A, initial_condition, dynamical_function=dynamical_function, tmax=tmax, dt=dt, function_args...)
  reducedTimeSeries = SimulateDynamics.simulateODEonGraph(reducedA, compressed_initial_condition, dynamical_function=dynamical_function, tmax=tmax, dt=dt, function_args...)

  loss = computeIndividualError(originalTimeSeries, reducedTimeSeries, partition)
  #loss = computeDynamicalError(originalTimeSeries, reducedTimeSeries, partition)
  print(loss, flush=True)
  return loss
