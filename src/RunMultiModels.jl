using Pickle
include("ReduceNetwork.jl")
include("SimulateDynamics.jl")
include("EvaluateError.jl")
include("GenerateGraphs.jl")

###### PARAMETERS TO TWEAK ######
numProcesses = 4 # len(os.sched_getaffinity(0)) # sched_getaffinity doesn't work on Macs

# network parameters
originalSize = 10
reducedSize  = 2
#=
options for graphType, graphArgs
    'random', {'p': p} --> generates G = GenerateGraphs.gnp_graph(originalSize, p)
    "cycle", {}:       --> generates G = GenerateGraphs.cycle_graph(originalSize, directed=False)
    "line", {}:        --> generates G = GenerateGraphs.line_graph(originalSize, directed=False)
=#
# graphType, graphArgs = "random", {'p': 0.4}
# graphType, graphArgs = "cycle", {}
graphType, graphArgs = "line", {}

# model parameters
#=
options for modelType, modelArgs
    "linear_model", {"epsilon": epsilon}        --> runs SimulateDynamics.linear_model
    "SIS_model", {"gamma": gamma, "beta": beta} --> runs SimulateDynamics.SIS
    "SI_model", {beta': beta}                   --> runs SimulateDynamics.SI
    "kuramoto_model", {"omega": omega, 'K': K}  --> runs SimulateDynamics.kuramoto_model
=#
# all models
# listModelType   = ["linear_model", "kuramoto_model", "SIS_model", "SI_model", "linear_opinions","nonlinear_opinions"]
# listModelAbbrev = ["Lin", "Kur", "SIS", "SI", "LinOp","NLOp"]
# listModelArgs   = [{"epsilon":-3/originalSize}, {"omega":1, "K":1}, {"beta":1, "gamma":1}, {"beta":1}, {"c":1}, {"d":0.1, "u":1, "b":0}]

# select models
listModelType   = ["linear_model"]
listModelAbbrev = ["Lin"]
listModelArgs   = [{ϵ:-3/originalSize}]

# simulation parameters
tmax    = 10
tinc    = 0.1
numRuns = 100 # number of initial conditions to simulate

###### NO NEED TO TOUCH BELOW ######
# Generate a list of partitions to test
listOfPartitions  = ReduceNetwork.kPartition(originalSize, reducedSize)

# Generate a list of initial conditions
listOfICs = [rand(originalSize) for run in range(numRuns)]

for id in range(length(listModelType))
    # specify model parameters
    modelType = listModelType[id]
    modelAbbrev, modelArgs = listModelAbbrev[id], listModelArgs[id]

    # store parameters
    parameters = {"originalSize": originalSize, "reducedSize": reducedSize, "graphType": graphType, "graphArgs": graphArgs,
    "modelType": modelType, "modelArgs": modelArgs, "modelAbbrev": modelAbbrev, "tmax": tmax, "tinc": tinc}

    # select model
    if modelType == "linear_model" 
        modelFunc = SimulateDynamics.linear_model
    elseif modelType == "SIS_model"
        modelFunc = SimulateDynamics.SIS_model
    elseif modelType == "SI_model"
        modelFunc = SimulateDynamics.SI_model
    elseif modelType == "kuramoto_model"
        modelFunc = SimulateDynamics.kuramoto_model
    elseif modelType == "linear_opinions"
        modelFunc = SimulateDynamics.linear_opinions
    elseif modelType == "nonlinear_opinions"
        modelFunc = SimulateDynamics.nonlinear_opinions
    end

    # Construct network
    isAccepted = False
    while !isAccepted
        if graphType == "random"
            G = GenerateGraphs.gnp_graph(originalSize, graphArgs["p"])
        elseif graphType == "cycle"
            G = GenerateGraphs.cycle_graph(originalSize, directed=False)
        elseif graphType == "line"
            G = GenerateGraphs.line_graph(originalSize, directed=False)
        end
        if nx.is_connected(G)
            isAccepted = True
        end
    end

    # Run simulations numRuns times with different initial conditions
    for run in range(numRuns)

        # initial_condition = np.random.rand(originalSize)
        # initial_condition = np.concatenate((np.ones(1),np.zeros(originalSize-1)))
        initial_condition = listOfICs[run]

        argList = list()
        for partition in listOfPartitions
            argList.append(A, partition, initial_condition, modelFunc, tmax, tinc, modelArgs)
        end

        mp.Pool(processes=numProcesses) do pool
            losses = pool.starmap(EvaluateError.getLoss, argList)
        end

        # specify folder and check if it already exists
        foldername = SimulateDynamics.foldername(modelType, modelArgs, graphType, graphArgs)
        if !isdir(foldername)
             mkdir(foldername) # make folder if it doesn't exist
        end

        # prep filename and data
        filename = foldername * "/" * string(originalSize) * "_" * string(reducedSize) * "_run" * string(run)

        data = {}
        data["A"] = A
        data["partitions"] = listOfPartitions
        data["losses"] = losses
        data["parameters"] = parameters
        data["initial_condition"] = initial_condition

        open(filename, "wb") do file
            pickle.dump(data, file)
        end
    end
end


