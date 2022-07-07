
@testset "neighbors_tests" begin
    #=
    p = generateRandomPartitions(10,5,1)[1]
    display(p)
    sample = getAdjacentSample(p, 10, 5, 10)
    display(sample)

    p2 = generateRandomPartitions(5,3,1)[1]
    display(p2)
    neighbors = getAdjacentPartitions(p2, 5, 3)
    display(neighbors)
    G = gnp_graph(5, p=.5)
    x = rand(5)
    p3 = iterativeImprovement(G, p2, 1, x, linear_model, 10, 0.1)
    display(p3)
    loss = getLoss(G, p3, x, linear_model, 10, 0.1)
    println("Iterative Loss: ", loss)
    =#
    p = generateRandomPartitions(5,3,1)[1]
    display([p])
    neighborhood = getNeighborhood(p, 5, 3, 3)
    display(neighborhood)
    space = kPartition(5,3)
    display(space)
end

#=
@testset "conversion_tests" begin
    p = generateRandomPartitions(10,5,1)[1]
    display(p)
    P = dict_to_matrix(p, 10, 5)
    display(P)
    p2 = matrix_to_dict(P, 10, 5)
    display(p2)
end
=#
#=
@testset "genetic_tests" begin
    #=
    p1 = generateRandomPartitions(10,5,1)[1]
    p2 = generateRandomPartitions(10,5,1)[1]
    pc = supernodeBucketCross(p1, p2, 10, 5)
    println("Parent 1: ", p1)
    println("Parent 2: ", p2)
    println("Child: ", pc)

    pcm = randomWalkMutate(pc, 10, 5, 0.75)
    println("Mutant Child: ", pcm)
    =#
    #=
    gen1 = generateRandomPartitions(100, 50, 512)
    x = rand(100)
    GNP = gnp_graph(100)
    f = 10
    agg1 = agglomerationReduction(GNP, 50)
    gen1[1] = agg1

    @time genf = geneticImprovement(GNP, gen1, f, 0.9, x, linear_model, 10, 0.1)
    gen1_loss = 0
    for i = 1:512
        gen1_loss += getLoss(GNP, gen1[i], x, linear_model, 10, 0.1)
    end
    genf_loss = 0
    for i = 1:512
        genf_loss += getLoss(GNP, genf[i], x, linear_model, 10, 0.1)
    end
    println("Avg Loss Gen1: ", gen1_loss/512)
    println("Avg Loss Gen$f: ", genf_loss/512)
    =#
    c = 100
    n = 5
    k = 3
    f0 = 10
    f1 = 100
    f2 = 500
    f3 = 1000
    gen1 = generateRandomPartitions(n, k, c)
    x = rand(n)
    G = gnp_graph(n, p=.5)
    genf0 = geneticImprovement(G, gen1, f0, 0.1, x, linear_model, 10, 0.1)
    genf1 = geneticImprovement(G, genf0, f1-f0, 0.1, x, linear_model, 10, 0.1)
    genf2 = geneticImprovement(G, genf1, f2-f1, 0.1, x, linear_model, 10, 0.1)
    genf3 = geneticImprovement(G, genf2, f3-f2, 0.1, x, linear_model, 10, 0.1)
    gen1_losses = getLossBatch(G, gen1, x, linear_model, 10, 0.1)
    gen1_avg = sum(gen1_losses/c)
    genf0_losses = getLossBatch(G, genf0, x, linear_model, 10, 0.1)
    genf0_avg = sum(genf0_losses/c)
    genf1_losses = getLossBatch(G, genf1, x, linear_model, 10, 0.1)
    genf1_avg = sum(genf1_losses/c)
    genf2_losses = getLossBatch(G, genf2, x, linear_model, 10, 0.1)
    genf2_avg = sum(genf2_losses/c)
    genf3_losses = getLossBatch(G, genf3, x, linear_model, 10, 0.1)
    genf3_avg = sum(genf3_losses/c)

    plt = violin(1:100, gen1_losses, label = "Gen 1, Avg = $gen1_avg")
    violin!(plt, 1:100, genf0_losses, label = "Gen $f0, Avg = $genf0_avg")
    violin!(plt, 1:100, genf1_losses, label = "Gen $f1, Avg = $genf1_avg")
    violin!(plt, 1:100, genf2_losses, label = "Gen $f2, Avg = $genf2_avg")
    violin!(plt, 1:100, genf3_losses, label = "Gen $f3, Avg = $genf3_avg")
    #=
    iter_partitions = pmap(part->iterativeImprovement(G, part, 1, x, linear_model, 10, 0.1), gen1)
    iter_losses = pmap(part->getLoss(G, part, x, linear_model, 10, 0.1), iter_partitions)
    iter_avg = sum(iter_losses)

    violin!(plt, 1:100, iter_losses, label = "Greedy, Avg = $iter_avg")
    =#
    display(plt)
end
=#
#=
@testset "iterative_tests" begin
    part = generateRandomPartitions(6,4,1)[1]
    G = gnp_graph(6, p=0.5)
    x = rand(6)
    part2 = iterativeImprovementDynamic(G, part, 1, x, linear_model, 10, 0.1)
end
=#
#=
@testset "findLocalMinimum test" begin
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 0.75))
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 0.75))
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 0.75))
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 0.75, startingPartition="Dict{Integer, Integer}(56 => 57, 35 => 55, 110 => 33, 60 => 83, 220 => 38, 30 => 34, 6 => 77, 67 => 13, 234 => 19, 215 => 88, 219 => 14, 73 => 1, 272 => 19, 182 => 89, 164 => 13, 115 => 33, 153 => 17, 112 => 49, 185 => 54, 64 => 55, 186 => 93, 251 => 81, 253 => 4, 267 => 42, 90 => 20, 139 => 5, 4 => 36, 13 => 89, 86 => 66, 168 => 62, 207 => 78, 263 => 32, 104 => 52, 242 => 63, 183 => 43, 224 => 89, 52 => 78, 177 => 82, 12 => 1, 179 => 95, 75 => 17, 23 => 74, 111 => 59, 264 => 63, 41 => 96, 43 => 59, 11 => 32, 68 => 62, 69 => 15, 171 => 25, 300 => 15, 82 => 32, 85 => 69, 130 => 24, 119 => 81, 125 => 22, 39 => 69, 77 => 45, 216 => 13, 126 => 79, 108 => 6, 71 => 87, 172 => 43, 66 => 19, 103 => 53, 156 => 72, 280 => 30, 59 => 2, 208 => 81, 2 => 90, 10 => 83, 27 => 8, 26 => 81, 124 => 69, 211 => 91, 261 => 25, 144 => 49, 127 => 38, 116 => 1, 100 => 77, 257 => 18, 273 => 92, 79 => 71, 200 => 98, 20 => 48, 81 => 57, 195 => 41, 230 => 29, 279 => 8, 290 => 38, 141 => 37, 278 => 82, 187 => 36, 213 => 58, 135 => 80, 9 => 1, 189 => 35, 227 => 100, 294 => 23, 138 => 63, 222 => 30, 109 => 71, 161 => 59, 107 => 86, 46 => 88, 276 => 2, 249 => 97, 295 => 19, 57 => 17, 152 => 8, 247 => 58, 241 => 53, 170 => 1, 88 => 91, 129 => 51, 209 => 88, 236 => 13, 120 => 39, 238 => 85, 250 => 29, 78 => 17, 260 => 62, 297 => 56, 133 => 56, 72 => 7, 258 => 22, 24 => 75, 8 => 77, 184 => 52, 37 => 8, 1 => 97, 137 => 2, 22 => 49, 83 => 94, 154 => 20, 190 => 48, 201 => 77, 252 => 6, 99 => 16, 121 => 74, 206 => 64, 237 => 61, 281 => 67, 14 => 47, 288 => 41, 270 => 54, 299 => 76, 33 => 31, 40 => 39, 113 => 25, 231 => 66, 245 => 40, 174 => 100, 254 => 4, 283 => 51, 165 => 69, 142 => 98, 269 => 85, 5 => 75, 55 => 4, 114 => 84, 123 => 59, 265 => 28, 268 => 70, 32 => 81, 136 => 50, 117 => 6, 45 => 11, 145 => 52, 197 => 39, 282 => 92, 233 => 68, 196 => 4, 262 => 70, 275 => 19, 210 => 21, 151 => 84, 239 => 6, 54 => 7, 63 => 30, 191 => 29, 91 => 7, 62 => 40, 205 => 55, 244 => 93, 158 => 9, 150 => 29, 176 => 9, 218 => 19, 122 => 51, 58 => 1, 199 => 52, 28 => 70, 173 => 49, 148 => 15, 256 => 20, 188 => 46, 92 => 92, 277 => 6, 36 => 30, 98 => 56, 235 => 12, 204 => 70, 118 => 25, 162 => 65, 84 => 98, 7 => 59, 25 => 29, 95 => 32, 203 => 35, 292 => 54, 76 => 82, 232 => 81, 34 => 19, 50 => 9, 93 => 11, 243 => 17, 296 => 40, 18 => 90, 194 => 66, 240 => 67, 147 => 71, 42 => 21, 87 => 29, 132 => 7, 140 => 64, 157 => 53, 167 => 88, 169 => 5, 202 => 20, 16 => 3, 248 => 100, 287 => 54, 180 => 61, 255 => 52, 160 => 85, 19 => 53, 289 => 30, 49 => 28, 291 => 13, 44 => 44, 266 => 99, 31 => 92, 217 => 27, 146 => 75, 74 => 68, 106 => 32, 61 => 38, 29 => 50, 94 => 22, 212 => 38, 225 => 10, 228 => 3, 102 => 59, 128 => 41, 159 => 49, 70 => 76, 259 => 6, 21 => 78, 193 => 33, 38 => 59, 163 => 70, 229 => 78, 131 => 46, 226 => 59, 192 => 58, 101 => 11, 105 => 27, 223 => 94, 221 => 63, 285 => 79, 17 => 62, 53 => 44, 271 => 73, 47 => 2, 175 => 8, 166 => 40, 89 => 80, 198 => 63, 214 => 71, 3 => 79, 80 => 86, 96 => 64, 51 => 24, 178 => 65, 286 => 39, 274 => 99, 149 => 54, 155 => 19, 181 => 52, 246 => 99, 143 => 79, 48 => 31, 15 => 60, 65 => 48, 97 => 77, 293 => 26, 284 => 45, 298 => 6, 134 => 47)"))
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 3, startingPartition="Dict{Integer, Integer}(56 => 57, 35 => 55, 110 => 33, 60 => 83, 220 => 38, 30 => 34, 6 => 77, 67 => 13, 234 => 19, 215 => 88, 219 => 14, 73 => 1, 272 => 19, 182 => 89, 164 => 13, 115 => 33, 153 => 17, 112 => 49, 185 => 54, 64 => 55, 186 => 93, 251 => 81, 253 => 4, 267 => 42, 90 => 20, 139 => 5, 4 => 36, 13 => 89, 86 => 66, 168 => 62, 207 => 78, 263 => 32, 104 => 52, 242 => 63, 183 => 43, 224 => 89, 52 => 78, 177 => 82, 12 => 1, 179 => 95, 75 => 17, 23 => 74, 111 => 59, 264 => 63, 41 => 96, 43 => 59, 11 => 32, 68 => 62, 69 => 15, 171 => 25, 300 => 15, 82 => 32, 85 => 69, 130 => 24, 119 => 81, 125 => 22, 39 => 69, 77 => 45, 216 => 13, 126 => 79, 108 => 6, 71 => 87, 172 => 43, 66 => 19, 103 => 53, 156 => 72, 280 => 30, 59 => 2, 208 => 81, 2 => 90, 10 => 83, 27 => 8, 26 => 81, 124 => 69, 211 => 91, 261 => 25, 144 => 49, 127 => 38, 116 => 1, 100 => 77, 257 => 18, 273 => 92, 79 => 71, 200 => 98, 20 => 48, 81 => 57, 195 => 41, 230 => 29, 279 => 8, 290 => 38, 141 => 37, 278 => 82, 187 => 36, 213 => 58, 135 => 80, 9 => 1, 189 => 35, 227 => 100, 294 => 23, 138 => 63, 222 => 30, 109 => 71, 161 => 59, 107 => 86, 46 => 88, 276 => 2, 249 => 97, 295 => 19, 57 => 17, 152 => 8, 247 => 58, 241 => 53, 170 => 1, 88 => 91, 129 => 51, 209 => 88, 236 => 13, 120 => 39, 238 => 85, 250 => 29, 78 => 17, 260 => 62, 297 => 56, 133 => 56, 72 => 7, 258 => 22, 24 => 75, 8 => 77, 184 => 52, 37 => 8, 1 => 97, 137 => 2, 22 => 49, 83 => 94, 154 => 20, 190 => 48, 201 => 77, 252 => 6, 99 => 16, 121 => 74, 206 => 64, 237 => 61, 281 => 67, 14 => 47, 288 => 41, 270 => 54, 299 => 76, 33 => 31, 40 => 39, 113 => 25, 231 => 66, 245 => 40, 174 => 100, 254 => 4, 283 => 51, 165 => 69, 142 => 98, 269 => 85, 5 => 75, 55 => 4, 114 => 84, 123 => 59, 265 => 28, 268 => 70, 32 => 81, 136 => 50, 117 => 6, 45 => 11, 145 => 52, 197 => 39, 282 => 92, 233 => 68, 196 => 4, 262 => 70, 275 => 19, 210 => 21, 151 => 84, 239 => 6, 54 => 7, 63 => 30, 191 => 29, 91 => 7, 62 => 40, 205 => 55, 244 => 93, 158 => 9, 150 => 29, 176 => 9, 218 => 19, 122 => 51, 58 => 1, 199 => 52, 28 => 70, 173 => 49, 148 => 15, 256 => 20, 188 => 46, 92 => 92, 277 => 6, 36 => 30, 98 => 56, 235 => 12, 204 => 70, 118 => 25, 162 => 65, 84 => 98, 7 => 59, 25 => 29, 95 => 32, 203 => 35, 292 => 54, 76 => 82, 232 => 81, 34 => 19, 50 => 9, 93 => 11, 243 => 17, 296 => 40, 18 => 90, 194 => 66, 240 => 67, 147 => 71, 42 => 21, 87 => 29, 132 => 7, 140 => 64, 157 => 53, 167 => 88, 169 => 5, 202 => 20, 16 => 3, 248 => 100, 287 => 54, 180 => 61, 255 => 52, 160 => 85, 19 => 53, 289 => 30, 49 => 28, 291 => 13, 44 => 44, 266 => 99, 31 => 92, 217 => 27, 146 => 75, 74 => 68, 106 => 32, 61 => 38, 29 => 50, 94 => 22, 212 => 38, 225 => 10, 228 => 3, 102 => 59, 128 => 41, 159 => 49, 70 => 76, 259 => 6, 21 => 78, 193 => 33, 38 => 59, 163 => 70, 229 => 78, 131 => 46, 226 => 59, 192 => 58, 101 => 11, 105 => 27, 223 => 94, 221 => 63, 285 => 79, 17 => 62, 53 => 44, 271 => 73, 47 => 2, 175 => 8, 166 => 40, 89 => 80, 198 => 63, 214 => 71, 3 => 79, 80 => 86, 96 => 64, 51 => 24, 178 => 65, 286 => 39, 274 => 99, 149 => 54, 155 => 19, 181 => 52, 246 => 99, 143 => 79, 48 => 31, 15 => 60, 65 => 48, 97 => 77, 293 => 26, 284 => 45, 298 => 6, 134 => 47)"))
    display(findLocalMinimum("data/visualization_data/PARTtest07-06_11-07-05.csv", 1, startingPartition="Dict{Integer, Integer}(56 => 37, 35 => 44, 110 => 11, 60 => 34, 220 => 20, 30 => 94, 6 => 63, 67 => 10, 234 => 90, 215 => 62, 219 => 13, 73 => 22, 272 => 10, 182 => 34, 164 => 43, 115 => 52, 153 => 5, 112 => 4, 185 => 57, 64 => 19, 186 => 93, 251 => 39, 253 => 29, 267 => 75, 90 => 11, 139 => 75, 4 => 58, 13 => 71, 86 => 57, 168 => 57, 207 => 82, 263 => 43, 104 => 17, 242 => 69, 183 => 36, 224 => 42, 52 => 46, 177 => 57, 12 => 37, 179 => 75, 75 => 31, 23 => 88, 111 => 4, 264 => 35, 41 => 43, 43 => 17, 11 => 3, 68 => 75, 69 => 51, 171 => 15, 300 => 17, 82 => 97, 85 => 86, 130 => 84, 119 => 33, 125 => 74, 39 => 93, 77 => 81, 216 => 50, 126 => 19, 108 => 43, 71 => 10, 172 => 63, 66 => 83, 103 => 92, 156 => 77, 280 => 33, 59 => 16, 208 => 45, 2 => 34, 10 => 76, 27 => 62, 26 => 58, 124 => 8, 211 => 46, 261 => 39, 144 => 11, 127 => 93, 116 => 92, 100 => 25, 257 => 50, 273 => 26, 79 => 72, 200 => 33, 20 => 4, 81 => 2, 195 => 20, 230 => 64, 279 => 57, 290 => 36, 141 => 34, 278 => 36, 187 => 54, 213 => 15, 135 => 7, 9 => 54, 189 => 53, 227 => 39, 294 => 56, 138 => 57, 222 => 4, 109 => 67, 161 => 10, 107 => 59, 46 => 81, 276 => 17, 249 => 15, 295 => 15, 57 => 8, 152 => 22, 247 => 59, 241 => 21, 170 => 47, 88 => 52, 129 => 14, 209 => 100, 236 => 90, 120 => 92, 238 => 64, 250 => 15, 78 => 88, 260 => 28, 297 => 9, 133 => 17, 72 => 84, 258 => 75, 24 => 22, 8 => 6, 184 => 90, 37 => 90, 1 => 100, 137 => 36, 22 => 21, 83 => 37, 154 => 57, 190 => 73, 201 => 32, 252 => 58, 99 => 49, 121 => 55, 206 => 95, 237 => 41, 281 => 83, 14 => 90, 288 => 81, 270 => 5, 299 => 23, 33 => 19, 40 => 65, 113 => 46, 231 => 16, 245 => 18, 174 => 44, 254 => 51, 283 => 11, 165 => 76, 142 => 63, 269 => 85, 5 => 51, 55 => 67, 114 => 61, 123 => 88, 265 => 23, 268 => 42, 32 => 99, 136 => 72, 117 => 30, 45 => 1, 145 => 29, 197 => 55, 282 => 79, 233 => 10, 196 => 9, 262 => 75, 275 => 70, 210 => 42, 151 => 83, 239 => 53, 54 => 75, 63 => 100, 191 => 58, 91 => 98, 62 => 4, 205 => 8, 244 => 22, 158 => 33, 150 => 44, 176 => 96, 218 => 84, 122 => 61, 58 => 55, 199 => 19, 28 => 25, 173 => 8, 148 => 29, 256 => 89, 188 => 12, 92 => 20, 277 => 98, 36 => 23, 98 => 79, 235 => 63, 204 => 99, 118 => 32, 162 => 27, 84 => 79, 7 => 50, 25 => 71, 95 => 76, 203 => 75, 292 => 100, 76 => 61, 232 => 15, 34 => 14, 50 => 29, 93 => 77, 243 => 1, 296 => 18, 18 => 17, 194 => 54, 240 => 61, 147 => 9, 42 => 11, 87 => 34, 132 => 14, 140 => 73, 157 => 48, 167 => 78, 169 => 35, 202 => 40, 16 => 89, 248 => 87, 287 => 29, 180 => 91, 255 => 83, 160 => 32, 19 => 59, 289 => 66, 49 => 3, 291 => 100, 44 => 20, 266 => 22, 31 => 7, 217 => 13, 146 => 54, 74 => 96, 106 => 32, 61 => 48, 29 => 52, 94 => 49, 212 => 68, 225 => 68, 228 => 88, 102 => 97, 128 => 1, 159 => 61, 70 => 79, 259 => 53, 21 => 66, 193 => 44, 38 => 76, 163 => 60, 229 => 85, 131 => 13, 226 => 41, 192 => 4, 101 => 24, 105 => 14, 223 => 36, 221 => 79, 285 => 26, 17 => 87, 53 => 34, 271 => 56, 47 => 5, 175 => 19, 166 => 40, 89 => 50, 198 => 60, 214 => 38, 3 => 56, 80 => 63, 96 => 2, 51 => 19, 178 => 70, 286 => 7, 274 => 25, 149 => 28, 155 => 91, 181 => 83, 246 => 24, 143 => 94, 48 => 63, 15 => 56, 65 => 48, 97 => 80, 293 => 32, 284 => 40, 298 => 10, 134 => 89)"))
end
=#
