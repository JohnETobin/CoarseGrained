include("ReduceNetwork.jl")
include("SimulateDynamics.jl")

# Given how the original nodes are mapped to the supernodes with partitions, returns the aggregated error
function aggregateTimeSeries(originalTimeSeries::ODESolution, partition::Dict{Integer,Integer}, type="average")
    if type == "average"
        supernodeSizes = ReduceNetwork.getSupernodeSizes(partition)
        reducedSize = length(supernodeSizes)
        originalSize = size(originalTimeSeries,1)
        numTimeSteps = size(originalTimeSeries,2)
        aggregatedTimeSeries = zeros((reducedSize, numTimeSteps))

        for node in range(originalSize)
        aggregatedTimeSeries[partition[node], :] .+= originalTimeSeries[node, :]./supernodeSizes[partition[node]]
        end
    end
    return aggregatedTimeSeries
end

function computeDynamicalError(originalTimeSeries::ODESolution, reducedTimeSeries::ODESolution, partition::Dict{Integer,Integer})
  numTimeSteps = size(reducedTimeSeries, 2)
  aggregatedTimeSeries = aggregateTimeSeries(originalTimeSeries, partition)
  return sum(sum((reducedTimeSeries - aggregatedTimeSeries).^2))/numTimeSteps
end

function computeIndividualError(originalTimeSeries::ODESolution, reducedTimeSeries::ODESolution, partition::Dict{Integer,Integer})
  originalSize = size(reducedTimeSeries, 1)
  loss = 0
  for node in 1:originalSize
    loss += lossFunction(originalTimeSeries[node, :], reducedTimeSeries[partition[node], :])
  end
  return loss
end

function lossFunction(timeseries1::, timeseries2, type="L2")
  if type == "L2"
    return sum((timeseries1 - timeseries2)^2)/size(timeseries1, 1)
  end
end

function getLoss(A::MatrixNetwork, partition::Dict{Integer, Integer}, initial_condition::Vector, dynamical_function::Function, tmax::Number, dt::Number; function_args...)
  #These functions are in the parallelized function to hopefully reduce the amount of single threaded tasks
  try
    compressed_initial_condition = ReduceNetwork.compressInitialCondition(initial_condition, partition)
    reducedA = ReduceNetwork.compressAdjacencyMatrix(A, partition)
  catch
    return NaN
  end
  originalTimeSeries = SimulateDynamics.simulateODEonGraph(A, initial_condition; dynamical_function=dynamical_function, tmax=tmax, dt=dt, function_args...)
  reducedTimeSeries = SimulateDynamics.simulateODEonGraph(reducedA, compressed_initial_condition; dynamical_function=dynamical_function, tmax=tmax, dt=dt, function_args...)

  loss = computeIndividualError(originalTimeSeries, reducedTimeSeries, partition)
  #loss = computeDynamicalError(originalTimeSeries, reducedTimeSeries, partition)
  println(loss)
  flush(stdout)
  return loss
end
