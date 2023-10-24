using Random

mutable struct edge 
   depart::Int64
   arrivee::Int64
   indice::Int64
end
   
mutable struct edgePoidsMono
   arete::edge
   poids::Int64
end
  
mutable struct arbre
   aretes::Vector{edge}
   z1::Int64
   z2::Int64
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

function AddSecondObj(nomFichier::String,nomFichier2::String)
   # Ouverture d'un fichier en lecture
   flu = open(nomFichier,"r")
   fecrit = open(nomFichier2,"w")

   # Lecture de la première ligne et recopie de la première ligne
   s::String = readline(flu) # lecture d'une ligne et stockage dans une chaîne de caractères
   ligne::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau
   nbSommets::Int64 = ligne[1]
   nbAretes::Int64 = ligne[2]
   write(fecrit,s * "\n")

   # Lecture de chaque ligne pour ajouter un second objectif
   for i in 1:nbAretes
       s = readline(flu)
       s = s * " " * string(rand(1:100))
       write(fecrit,s * "\n")
   end
    
   # Fermeture des fichiers
   close(flu)
   close(fecrit)
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

# Fonction pour trouver le parent d'un sommet
function find_parent(parent, sommet)
   while parent[sommet] != sommet
       sommet = parent[sommet]
   end
   return sommet
end

# Fonction pour unir deux ensembles
function union_sets(parent, rank, x, y)
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


#Algorithme de Kruskal pour trouver le MST
function kruskal(edges::Vector{edgePoidsMono}, nbSommets::Int64)
   #Initialisation de l'arbre couvrant
   MST::Vector{edgePoidsMono} = [] 
   poidsTotal::Int64 = 0
   #Tri des arêtes par ordre croissant de leurs poids respectifs
   sortedWeights::Vector{edgePoidsMono} = []
   sortedWeights = sort!(edges, by = x -> x.poids)
   
   # initialiser les parents et les rangs pour chaque nœud
   parent = [i for i in 1:length(edges)]
   rank = zeros(Int, length(edges))
   e = 1
   while length(MST) < nbSommets -1
      edgeActual::edgePoidsMono = sortedWeights[e]
      u, v = edgeActual.arete.depart, edgeActual.arete.arrivee
      # si ajouter cette arête ne forme pas de cycle, l'ajouter dans le MST
      if find_parent(parent, u) != find_parent(parent, v)
         push!(MST, edgeActual)    
         union_sets(parent, rank, u, v)
         poidsTotal += edgeActual.poids
      end
      e += 1
   end
   return MST, poidsTotal
end



#Fonction qui retourne un vecteur d'arêtes avec la somme ponderée des poids dans chaque fonction objectif
function CalculCoutsPonderes(edgesλ::Vector{edgePoidsMono}, z::Dict{edge, Vector{Int64}}, λ1::Int64, λ2::Int64) 
   for i in edgesλ
      i.poids = λ1 * z[(i.arete)][1] + λ2 * z[(i.arete)][2]
      #println("$(z[(i.arete)][1]),$(z[(i.arete)][2]) -> $(i.poids)")
   end
end



#Fonction qui retourne les coordonnées d'une solution sur l'espace des critères par rapport aux deux fonctions objectifs
function coordonnees(arbre, z::Dict{edge, Vector{Int64}})
   y1x = 0
   y1y = 0
   for i in arbre
         y1x += (z[(i.arete)][1])
         y1y += (z[(i.arete)][2])
   end
   return y1x, y1y
end




#Fonction pour vérifier que le MST trouvé pour la première fonction objectif est optimal
function verifOptimum1(y1x::Int64, y1y::Int64, z::Dict{edge, Vector{Int64}}, edgesλ::Vector{edgePoidsMono}, nbSommets::Int64)
   λ1 = 0; λ2 = 0

   λ1 = y1y + 1
   λ2 = 1 
   CalculCoutsPonderes(edgesλ, z, λ1, λ2)
   arbre, y = kruskal(edgesλ, nbSommets)

   y1, y2 = coordonnees(arbre,z)
   return arbre, y1
end


#Fonction pour vérifier que le MST trouvé pour la seconde fonction objectif est optimal
function verifOptimum2(y2x::Int64, y2y::Int64, z::Dict{edge, Vector{Int64}}, edgesλ::Vector{edgePoidsMono}, nbSommets::Int64)
   λ1 = 0; λ2 = 0

   λ1 = 1
   λ2 = y2x+1

   CalculCoutsPonderes(edgesλ, z, λ1, λ2)
   arbre, y = kruskal(edgesλ, nbSommets)
   
   y1, y2 = coordonnees(arbre,z)  
   return arbre, y2
end

#Fonction dichotomique
function dichotomie(lesArbres, y1x, y1y, y2x, y2y, z, edgesλ, nbSommets)
   #Calcul des λ
   λ1 = y1y - y2y
   λ2 = y2x - y1x
   #Calcul de la somme ponderée des deux fonctions objectif
   CalculCoutsPonderes(edgesλ, z, λ1, λ2)
   #Calcul du MST avec l'algorithme de Kruskal
   arbre, y = kruskal(edgesλ, nbSommets)
   #Coordonnées des points de la solution obtenue dans l'espace des critères
   y1, y2 = coordonnees(arbre,z)
   #Calcul du poids total du chemin
   poidsInit = λ1 * y1x + λ2 * y1y
   if y < poidsInit
      push!(lesArbres, arbre)
      dichotomie(lesArbres,y1x,y1y,y1,y2,z, edgesλ, nbSommets)
      dichotomie(lesArbres,y1,y2,y2x,y2y,z, edgesλ, nbSommets)
   end
   return lesArbres
end

