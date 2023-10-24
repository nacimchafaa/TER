import Base.union

mutable struct edge
    depart::Int64
    arrivee::Int64
    indice::Int64
end
mutable struct edgePoidsMono
    arete::edge
    poids::Int64
end

mutable struct PoidsCrit
    edge1::edge
    edge2::edge
    poids::Rational{Int64}
end


function getfname(pathtofolder)

    # recupere tous les fichiers se trouvant dans le repertoire cible
    allfiles = readdir(pathtofolder)
 
    # vecteur booleen qui marque les noms de fichiers valides
    flag = trues(size(allfiles))
 
    k=1
    for f in allfiles
        # traite chaque fichier du repertoire
        if f[1] != '.'
            # pas un fichier cache => conserver
            println("fname = ", f)
        else
            # fichier cache => supprimer
            flag[k] = false
        end
        k = k+1
    end
 
    # extrait les noms valides et retourne le vecteur correspondant
    finstances = allfiles[flag]
    return finstances
end

function parseFileBiObj(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f = open(nomFichier,"r")
 
    # Lecture de la première ligne 
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    ligne::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau
    nbSommets = ligne[1]
    nbAretes = ligne[2]
 
    # Lecture de chaque ligne
    edges::Vector{edge} = Vector{edge}(undef,nbAretes)
    e::edge = edge(0,0,0)
    ePoids1::edgePoidsMono = edgePoidsMono(e, 0)
    edgesZ1::Vector{edgePoidsMono} = []
    edgesZ2::Vector{edgePoidsMono} = []
    edgesλ::Vector{edgePoidsMono} = []
    z::Dict{edge,Vector{Int64}} = Dict()
    for i in 1:nbAretes
       s = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
       ligne = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau
       e = edge(ligne[1],ligne[2],i)
       edges[i] = e
       push!(z, e => [ligne[3],ligne[4]])
       ePoids1 = edgePoidsMono(e,ligne[3])
       ePoids2 = edgePoidsMono(e,ligne[4])
       push!(edgesZ1,ePoids1)
       push!(edgesZ2,ePoids2)
       push!(edgesλ,ePoids1)
    end
    # Fermeture du fichier
    close(f)
 
    # Retourner les infos utiles
    return nbSommets, nbAretes, edges, z, edgesZ1, edgesZ2, edgesλ
end

function calculPoidsCritiques(E::Vector{edge},z::Dict{edge,Vector{Int64}})
    n::Int64 = length(E)
    den::Int64 = 0
    num::Int64 = 0
    ci::Vector{Int64} = zeros(2)
    cj::Vector{Int64} = zeros(2)
    crit::Rational{Int64} = 0//1
    TabCrit::Vector{PoidsCrit} = []
    for i in 1:n
        ci = z[E[i]]
        for j in (i+1):n
            cj = z[E[j]]
            #println("pour les arêtes ($(E[i].depart),$(E[i].arrivee)) et ($(E[j].depart),$(E[j].arrivee)), dont les coûts sont $ci et $cj,")
            den = ci[1] - ci[2] - cj[1] + cj[2]
            if (den != 0)
                num = cj[2] - ci[2]
                crit = num // den
                #println("nous trouvons le poids critique suivant : $crit")
                if (crit > 0) && (crit < 1)
                    push!(TabCrit,PoidsCrit(E[i],E[j],crit))
                end
            else
                #println("Il n'y a pas de poids critique")
            end
        end
    end
    sort!(TabCrit, by = x -> x.poids, rev = true) 
    return TabCrit
end


# Fonction pour trouver le parent d'un sommet
function find_parent(parent::Vector{Int64}, sommet::Int64)
    while parent[sommet] != sommet
        sommet = parent[sommet]
    end
    return sommet
end

# Fonction pour unir deux composantes connexes
function union_sets(parent::Vector{Int64}, rank::Vector{Int64}, x::Int64, y::Int64)
    x_root = find_parent(parent, x)
    y_root = find_parent(parent, y)
    
    if rank[x_root] < rank[y_root]
        parent[x_root] = y_root
    elseif rank[x_root] > rank[y_root]
        parent[y_root] = x_root
    else
        parent[y_root] = x_root
        rank[x_root] += 1
    end
end


function kruskalBis(sortedEdges::Vector{edge}, nbSommets::Int64)
    MST::Vector{edge} = []

    # Initialiser les parents et les rangs pour chaque sommet
    parent = [i for i in 1:length(sortedEdges)]
    rank = zeros(Int, length(sortedEdges))
    e = 1
    while length(MST) < nbSommets -1
        edgeActual::edge = sortedEdges[e]
        u, v = edgeActual.depart, edgeActual.arrivee
        # si ajouter cette arête ne forme pas de cycle, l'ajouter dans le MST
        if find_parent(parent, u) != find_parent(parent, v)
            push!(MST, edgeActual)
            union_sets(parent, rank, u, v)
        end
       e += 1
    end
    return MST
end


# Fonction qui retourne les coordonnées d'une solution sur l'espace des critères par rapport aux deux fonctions objectifs
function coordonnees(arbre, z::Dict{edge, Vector{Int64}})
    x = 0
    y = 0
    for i in arbre
          x+= (z[(i)][1])
          y += (z[(i)][2])
    end
    return x,y
end

    

# Fonction pour inverser un vecteur
function inverseVecteur(vecteur::Vector)
    n::Int64 = length(vecteur)
    for i = 0:n-1
        m::Int64 = length(vecteur) - i
        j = 1
        while j < m
            vecteur[j], vecteur[j+1] = vecteur[j+1], vecteur[j]
            j += 1
        end
    end
    return vecteur
end


#Retourne false si les arêtes A et B sont dans le même cycle, sinon true
function createCycle(tree::Vector{edge}, A::edge, B::edge)
    n = 0
    for edge in tree
        n = max(n, edge.depart, edge.arrivee)
    end
    parent::Vector{Int64} = collect(1:n)
    rank = zeros(Int64, n)

    for edge in tree
        if edge != A
            Union(parent, rank, edge.depart, edge.arrivee)
        end
    end
    return !Union(parent, rank, B.depart, B.arrivee)
end

function find(parent::Vector{Int64}, x::Int64)
    if parent[x] != x
        parent[x] = find(parent, parent[x])  # Compression de chemin
    end
    return parent[x]
end

function Union(parent::Vector{Int64}, rank::Vector{Int64}, x::Int64, y::Int64)
    x_root = find(parent, x)
    y_root = find(parent, y)

    if x_root == y_root
        return false
    end
    if rank[x_root] < rank[y_root]
        parent[x_root] = y_root
    elseif rank[x_root] > rank[y_root]
        parent[y_root] = x_root
    else
        parent[y_root] = x_root
        rank[x_root] += 1
    end
    return true
end

