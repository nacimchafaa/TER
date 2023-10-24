mutable struct edge 
   depart::Int64
   arrivee::Int64
   indice::Int64
end

mutable struct edgePoidsMono
   arete::edge
   poids::Int64
end

#mutable struct arbre
#   aretes::Vector{edge}
#   z1::Int64
#   z2::Int64
#end

nbSommets = 7

 
#Création du vecteur des arêtes
AB = edge(1, 2, 1) 
AD = edge(1, 4, 2)
BC = edge(2, 3, 3)
BD = edge(2, 4, 4)
BE = edge(2, 5, 5)
CE = edge(3, 5, 6)
DE = edge(4, 5, 7)
DF = edge(4, 6, 8)
EF = edge(5, 6, 9)
EG = edge(5, 7, 10)
FG = edge(6, 7, 11)
edges = [AB, AD, BC, BD, BE, CE, DE, DF, EF, EG, FG]
 
 
#Création du vecteur des arêtes de Z1
ABp1 = edgePoidsMono(AB, 7) 
ADp1 = edgePoidsMono(AD, 5)
BCp1 = edgePoidsMono(BC, 8)
BDp1 = edgePoidsMono(BD, 9)
BEp1 = edgePoidsMono(BE, 7)
CEp1 = edgePoidsMono(CE, 5)
DEp1 = edgePoidsMono(DE, 15)
DFp1 = edgePoidsMono(DF, 6)
EFp1 = edgePoidsMono(EF, 8)
EGp1 = edgePoidsMono(EG, 9)
FGp1 = edgePoidsMono(FG, 11)

edgesZ1 = [ABp1, ADp1, BCp1, BDp1, BEp1, CEp1, DEp1, DFp1, EFp1, EGp1, FGp1]
 
#Création du vecteur des arêtes de Z2
ABp2 = edgePoidsMono(AB, 2) 
ADp2 = edgePoidsMono(AD, 3)
BCp2 = edgePoidsMono(BC, 6)
BDp2 = edgePoidsMono(BD, 4)
BEp2 = edgePoidsMono(BE, 9)
CEp2 = edgePoidsMono(CE, 2)
DEp2 = edgePoidsMono(DE, 14)
DFp2 = edgePoidsMono(DF, 8)
EFp2 = edgePoidsMono(EF, 5)
EGp2 = edgePoidsMono(EG, 9)
FGp2 = edgePoidsMono(FG, 5)
 
edgesZ2 = [ABp2, ADp2, BCp2, BDp2, BEp2, CEp2, DEp2, DFp2, EFp2, EGp2, FGp2]


AB3 = edgePoidsMono(AB, 2) 
AD3 = edgePoidsMono(AD, 3)
BC3 = edgePoidsMono(BC, 6)
BD3 = edgePoidsMono(BD, 4)
BE3 = edgePoidsMono(BE, 9)
CE3 = edgePoidsMono(CE, 2)
DE3 = edgePoidsMono(DE, 14)
DF3 = edgePoidsMono(DF, 8)
EF3 = edgePoidsMono(EF, 5)
EG3 = edgePoidsMono(EG, 9)
FG3 = edgePoidsMono(FG, 5)
edgesλ = [AB3, AD3, BC3, BD3, BE3, CE3, DE3, DF3, EF3, EG3, FG3]


function CreationDict(edges::Vector{edge},edges1::Vector{edgePoidsMono}, edges2::Vector{edgePoidsMono})
   z::Dict{edge, Vector{Int64}} = Dict()
   for i in 1:length(edges)
      push!(z, edges[i] => [edges1[i].poids,edges2[i].poids])
   end
   return z
end 

nbAretes = 11
z = CreationDict(edges, edgesZ1, edgesZ2)