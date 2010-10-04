################################################################################
## Nom                  : Global.r
## Objet                : Programme de calcul des m�triques biodiversit� et ressources
## Input                : TXT
## Output               : CSV
## R version            : 2.10.1
## Date de cr�ation     : F�vrier 2008
## Date de modification : Avril 2010
################################################################################

## R�glage de l'encodage des caract�res :
options(encoding="latin1")

## Platform-specific treatment:
if (.Platform$OS.type == "windows")
{
    setwd("C:/PAMPA/")
}else{
    setwd("/media/ifremer/PAMPA/Scripts/latest/")
}
basePath <- getwd()

## R�pertoire de travail par d�faut (si pas configur� par ailleurs) :
nameWorkspace <- basePath

## ! suggestions concernant la r�organisation :

## ! -> un fichier global (executable du programme, appelle chaque fonction)
## ! -> ajouter un fichier "test des champs"
## ! -> rajouter un message signalant que l'import des donn�es a r�ussi pour chaque fichier
## ! -> un fichier stats de v�rification des donn�es
## ! -> un fichier avec les diff�rents modes de calcul des classes de taille (cf WP2/CalculClassesDeTaille.doc)
## ! -> Un fichier calcul metrique base, un autre pour les m�triques avanc�es, avec pour chaque, les noms de variable = contenu menu
## ! -> un fichier analyses ou un fichier par type d'analyse
## ! -> un fichier pour les groupements par classe et pr�paration de calculs (tri, cr�ation d'objets pour les calculs)
## ! -> un fichier data_temp pour ne pas �craser les fichiers charg�s � la base
## ! -> un fichier interface
## ! -> un fichier affichage graphique,

## !am�lioration des commentaires : en ent�te de chaque fichier, un plan du contenu
## !am�liorer les messages d'alerte, en mettre d�s qu'il y a des saisies et apr�s contr�le de saisie
## !cr�ation automatique des dossiers et appel de l'ensemble des fichiers une fois l'espace de travail choisi

## ! difficult� possible : appel de fonctions graphiques dans les fonctions de calcul pour extraire les fonctions graph...
## ! les tests de variables "par valeur" (classetaille, nom d'amp...) ne doivent pas �tre dans les fonctions g�n�riques

## ######################### Chargement des librairies ############################
## ! conseill� : que la version de R et les packages soient fournis avec toute mise � jour


## !Messages d'avis :
## !1: le package 'vegan' a �t� compil� sous R version 2.7.2 et l'aide ne fonctionnera pas correctement
## !Veuillez le r�installer, s'il-vous-plait
## !2: le package 'maptools' a �t� compil� sous R version 2.7.2 et l'aide ne fonctionnera pas correctement
## !Veuillez le r�installer, s'il-vous-plait
## !3: le package 'sp' a �t� compil� sous R version 2.7.2 et l'aide ne fonctionnera pas correctement
## !Veuillez le r�installer, s'il-vous-plait

                                                           # Mise en forme du code :
                                                           # -----------------------
source("./Exec/load_packages.R", encoding="latin1")
source("./Exec/config.r", encoding="latin1")               # faite
source("./Exec/gestionmessages.r", encoding="latin1")      # faite
source("./Exec/mkfilegroupe.r", encoding="latin1")         # faite

source("./Exec/graphique.r", encoding="latin1")            # faite [sll]
source("./Exec/graphique_benthos.r", encoding="latin1")
source("./Exec/calcul_simple.r", encoding="latin1")        # faite [sll]
source("./Exec/arbre_regression.r", encoding="latin1")     # fai.. [sll]
source("./Exec/anova.r", encoding="latin1")


source("./Exec/requetes.r", encoding="latin1")
source("./Exec/modifinterface.r", encoding="latin1")
source("./Exec/command.r", encoding="latin1")              # faite


source("./Exec/testfichier.r", encoding="latin1")
source("./Exec/view.r", encoding="latin1")                 # faite
source("./Exec/import.r", encoding="latin1")
source("./Exec/importdefaut.r", encoding="latin1")         # faite [sll]

source("./Exec/interface_fonctions.R", encoding="latin1")
source("./Exec/interface.r", encoding="latin1")

##################################################
## Nouvelle interface de s�lection des variables :
source("./Exec/selection_variables_fonctions.R", encoding="latin1")
source("./Exec/selection_variables_interface.R", encoding="latin1")

##################################################
## Nouveaux boxplots :
source("./Exec/boxplot_generique_calc.R", encoding="latin1")

##################################################
## Analyses statistiques :
source("./Exec/modeles_lineaires_interface.R", encoding="latin1")
source("./Exec/modeles_lineaires_generique.R", encoding="latin1")


tkfocus(tm)

#################### Tags de d�veloppement ####################
## [!!!] : construction dangereuse, capilo-tract�e ou erreur possible.
## [imb] : fonctions imbriqu�es dans d'autres fonctions (� corriger)
## [sll] : sans longueur des lignes (mise en forme du code pas termin�e)
## [inc] : expression/fonction incompl�te.
## [OK]  : probl�me corrig�.
## [???] : comprend pas !
