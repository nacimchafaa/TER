#for i in 50:50:500
#    for j in 1:10
#        run(`./graph_ge $i 0.5 100 MST$i-$j.dat`)
#        AddSecondObj("MST$i-$j.dat","BiMST$i-$j.dat")
#    end
#end
using Random

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
        s = s * " " * string(rand(1:10000))
        write(fecrit,s * "\n")
    end
    
    # Fermeture des fichiers
    close(flu)
    close(fecrit)
end


for i in 50:50:500
    run(`./graph_ge $i 0.1 10000 MST$i.dat`)
    AddSecondObj("MST$i.dat","BiMST$i.dat")
    rm("MST$i.dat") 
end
