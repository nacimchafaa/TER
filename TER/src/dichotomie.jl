include("functions_dichotomy.jl")
#include("data.jl")
using Plots

function main()
    target = "../data"
    fnames = getfname(target)
    for instance in eachindex(fnames)
        beginTime = time()
        lesArbres::Vector{Vector{edgePoidsMono}} = []            
        nbSommets::Int64, nbAretes::Int64, edges::Vector{edge}, z::Dict{edge,Vector{Int64}}, edgesZ1::Vector{edgePoidsMono}, edgesZ2::Vector{edgePoidsMono}, edgesλ::Vector{edgePoidsMono} = parseFileBiObj(string(target,"/",fnames[instance]))

        nbSolSupportees::Int64 = 0

        println("\nInstance : ", fnames[instance], ", Nombre de sommets : $nbSommets", ", Nombre d'arêtes : $nbAretes")
        ############################
        arbre1, y1 = kruskal(edgesZ1, nbSommets)
        arbre2, y2 = kruskal(edgesZ2, nbSommets)

        #coordonnées de y1 (arbre A) dans l'espace des critères
        y1x, y1y = coordonnees(arbre1, z)
        
        #coordonnées de y2 (arbre B) dans l'espace des critères
        y2x, y2y = coordonnees(arbre2, z)
    
        #Vérification que la solution trouvée est la meilleure pour Z1 dans l'espace des critères
        arbre1, y1 = verifOptimum1(y1x,y1y,z, edgesλ, nbSommets)

        #coordonnées de y1 (arbre A) dans l'espace des critères
        y1x, y1y = coordonnees(arbre1, z)
        push!(lesArbres,arbre1)
    
        #Vérification que la solution trouvée est la meilleure pour Z2 dans l'espace des critères
        arbre2, y2 = verifOptimum2(y2x, y2y,z, edgesλ, nbSommets)

        #coordonnées de y2 (arbre B) dans l'espace des critères
        y2x, y2y = coordonnees(arbre2, z)
        push!(lesArbres,arbre2)
        
        ######################################### Dichotomie  ##################################################
        arbres = dichotomie(lesArbres,y1x, y1y, y2x, y2y, z, edgesλ, nbSommets)
        nbSolSupportees = length(arbres)
        println("Le nombre de solutions supportées est : $nbSolSupportees")
        #X::Vector{Int64} = []
        #Y::Vector{Int64} = []
        #for arbre in lesArbres
            #x, y = coordonnees(arbre, z)
            #push!(X, x)
            #push!(Y, y)
        #end
        #display(scatter!(X, Y, label="$(fnames[instance])_Dichotomie"))
        timespent = time() - beginTime
        println("\tTemps d'exécution :", timespent)
    end
 end
 main()