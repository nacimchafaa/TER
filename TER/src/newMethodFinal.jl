


################################################ Version ou on trie les poids critiques dans des vecteurs et on permute directement sans Kruskal ##################################################


include("functions_newmethod.jl")
#include("data.jl")
using Plots

function main()
    target = "../data"
    fnames = getfname(target)
    for instance in eachindex(fnames)
        beginTime = time()
        lesArbres::Vector{Vector{edge}} = []
        nbSommets::Int64, nbAretes::Int64, edges::Vector{edge}, z::Dict{edge,Vector{Int64}}, edgesZ1::Vector{edgePoidsMono}, edgesZ2::Vector{edgePoidsMono}, edgesλ::Vector{edgePoidsMono} = parseFileBiObj(string(target,"/",fnames[instance]))
        println("\nInstance : ", fnames[instance], ", Nombre de sommets : $nbSommets", ", Nombre d'arêtes : $nbAretes")
        
        # Tri des poids avant Kruskal
        sortedDict::Vector{Pair{edge,Vector{Int64}}} = []
        sortedDict = sort(collect(z), by=x->x[2])

        # Construction d'un vecteur contenant les arêtes triées seulement (sans les poids)
        sortedEdges::Vector{edge} = []
        for i in eachindex(sortedDict)
            push!(sortedEdges,sortedDict[i][1])
        end

        # Initialisation des vecteurs de coordonnées pour le plot
        X::Vector{Int64} = []
        Y::Vector{Int64} = []

        # Initialisation d'un vecteur contenant les ensembles d'arêtes de chaque arbre
        arbres::Vector{Set{edge}} = []

        # Vecteur contenant les indices de chaque arête dans le vecteur sortedEdges
        sortedEdgesIndex::Dict{edge, Int64} = Dict()
        for i in eachindex(sortedEdges)
           push!(sortedEdgesIndex, sortedEdges[i] => i)
        end
        
        # Initialisation d'un vecteur de booléens pour les lesArbres
        arbreBool::Vector{Bool} = falses(nbAretes) 

        # Calcul des poids critiques
        TabCrit::Vector{PoidsCrit} = calculPoidsCritiques(sortedEdges,z)
        nTab::Int64 = length(TabCrit)

        # Résolution léxicographique du 1er arbre couvrant par rapport au tri initial (λ = 1)
        arbre::Vector{edge} = kruskalBis(sortedEdges,nbSommets)
        push!(lesArbres, arbre)

        # Mise à jour du vecteur de booléens en mettant à 1 les arêtes dans l'arbre
        for edge in arbre
            arbreBool[edge.indice] = true
        end
    
        #display(scatter(X, Y, markersize = 1 ,label=#=$(fnames[instance])_=#"newMethod"))
        i::Int64 = 1

        while i <= nTab
            # partie création du vecteur des permutations
            samePoidsCrit::Vector{Vector{edge}} = []
            push!(samePoidsCrit, [TabCrit[i].edge1, TabCrit[i].edge2]) 
            if i == nTab
                i +=1
            end   
            if i < nTab 
                j::Int64 = i+1
                while j <= nTab && TabCrit[j].poids == TabCrit[i].poids
                    k::Int64 = 1
                    arret::Bool = false
                    while k <= length(samePoidsCrit) && arret == false
                        if TabCrit[j].edge1 ∈ samePoidsCrit[k] && TabCrit[j].edge2 ∉ samePoidsCrit[k]
                            push!(samePoidsCrit[k], TabCrit[j].edge2)
                            arret = true
                        elseif TabCrit[j].edge2 ∈ samePoidsCrit[k] && TabCrit[j].edge1 ∉ samePoidsCrit[k]
                            push!(samePoidsCrit[k], TabCrit[j].edge1)
                            arret = true
                        end
                        k += 1
                    end
                    if arret == false
                        push!(samePoidsCrit, [TabCrit[j].edge1, TabCrit[j].edge2])
                        arret = true
                    end
                    j += 1
                end
                i = j
            end
                # partie des permutations
                for vecteur in samePoidsCrit
                    # Initialisation d'un vecteur contenant les indices des éléments à inverser dans sortedEdges
                    indexes::Vector{Int64} = []

                    inTree::Int64 = 0
                    notInTree::Int64 = 0

                    for edge in vecteur
                        push!(indexes, sortedEdgesIndex[edge])
                        if edge ∈ arbre
                            inTree +=1
                        else
                            notInTree +=1
                        end
                    end
                    # tri des indices par ordre croissant car il peut y avoir des inversions
                    sort!(indexes)

                        # Cas où il y a 2 arêtes seulement à swapper 
                        if length(vecteur) == 2 
                            # inversion des arêtes successives
                            sortedEdges[indexes] = reverse(sortedEdges[indexes])
                            # remise du vecteur des indices dans l'ordre
                            for edge in sortedEdges[indexes]
                                index = findfirst(x -> x == edge, sortedEdges)
                                sortedEdgesIndex[edge] = index
                            end
                            if inTree == 2
                                nothing
                            elseif notInTree == 2
                                nothing
                            elseif arbreBool[sortedEdges[indexes[2]].indice] == false && arbreBool[sortedEdges[indexes[1]].indice] == true 
                                nothing
                            elseif createCycle(arbre, sortedEdges[indexes[2]], sortedEdges[indexes[1]]) == false
                                indiceArbre::Int64 = findfirst(x -> x == sortedEdges[indexes[2]], arbre)
                                arbre[indiceArbre] = sortedEdges[indexes[1]]
                                arbreBool[sortedEdges[indexes[1]].indice] == true
                                arbreBool[sortedEdges[indexes[2]].indice] == false
                                push!(lesArbres, copy(arbre))
                                #display(scatter(X, Y, markersize = 1 ,label=#=$(fnames[instance])_=#"newMethod"))  
                            end
                        
                    # cas ou il y a 3 aretes ou plus à swapper 
                        else 
                            for i = 0:length(vecteur)-1
                                m::Int64 = length(vecteur) - i
                                j = 1
                                while j < m
                                    vecteur[j], vecteur[j+1] = vecteur[j+1], vecteur[j]  
                                    if arbreBool[vecteur[j].indice] == false && arbreBool[vecteur[j+1].indice] == false
                                        nothing
                                    elseif arbreBool[vecteur[j].indice] == true && arbreBool[vecteur[j+1].indice] == true
                                        nothing
                                    elseif arbreBool[vecteur[j].indice] == false && arbreBool[vecteur[j+1].indice] == true
                                        nothing
                                    elseif createCycle(arbre, vecteur[j], vecteur[j+1]) == false
                                        indiceArbre = findfirst(x -> x == vecteur[j], arbre)
                                        arbre[indiceArbre] = vecteur[j]
                                        arbreBool[vecteur[j].indice] == false
                                        arbreBool[vecteur[j+1].indice] == true
                                        push!(lesArbres, copy(arbre))
                                        #display(scatter(X, Y, markersize = 1 ,label=#=$(fnames[instance])_=#"newMethod"))                                    
                                    end
                                    j += 1                              
                                end
                            end      
                        end
                end
        end
        nbSol::Int64 = length(lesArbres)
        #println("Solutions : $lesArbres")
        #println("aretes : $aretes")
        println("Nombre de solutions supportées : $nbSol")
        #println(lesArbres)
        timespent = time() - beginTime
        println("\tTemps d'exécution :", timespent) 
        return lesArbres
    end
end
main()