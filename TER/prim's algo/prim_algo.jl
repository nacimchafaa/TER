V = Array{Vector}(undef, 7) #Vecteur des successeur des sommets
V[1] = [2,4]
V[2] = [1,3,4,5]
V[3] = [2,5]
V[4] = [1,2,5,6]
V[5] = [2,3,4,6,7]
V[6] = [4,5,7]
V[7] = [5,6]

P = Array{Vector}(undef, 7)   #Vecteur des poids sur les arêtes
P[1] = [7,5]
P[2] = [7,8,9,7]
P[3] = [8,5]
P[4] = [5,9,15,6]
P[5] = [7,5,15,8,9]
P[6] = [6,8,11]
P[7] = [9,11]



function prim(V,P)
    n = length(V)           #Nombre de sommets
    selectedNode = falses(n)  #Sommets selectionnés 
    poidsTotal = 0  #Poids Total du MST
    selectedNode[1] = true    #On selectionne le premier sommet
    MST = 1         #Nombre d'aretes dans le MST
    while MST < n
        minW = typemax(Float64)
        a = 1
        b = 1
        for i in 1:n
            if selectedNode[i] == true
                for j in 1:length(V[i])
                    if selectedNode[V[i][j]] == false
                       if P[i][j] < minW
                           minW = P[i][j]
                           a = i
                           b = j
                       end
                    end
                end
            end
        end
        println(a, " - ", V[a][b], " : ", P[a][b])
        poidsTotal += P[a][b]
        selectedNode[V[a][b]] = true
        MST += 1
    end
    println("Poids total du chemin : ", poidsTotal)
end

 