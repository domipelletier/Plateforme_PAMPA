################################################################################
## Nom                  : Global.r
## Objet                : Programme de calcul des m�triques biodiversit� et ressources
## Input                : TXT
## Output               : CSV
## R version            : 2.10.1
## Date de cr�ation     : F�vrier 2008
## Date de modification : Janvier 2011
################################################################################

## ** Version **
options(versionPAMPA = "1.0-alpha-7")

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

## ! -> ajouter un fichier "test des champs"
## ! -> un fichier stats de v�rification des donn�es
## ! -> un fichier avec les diff�rents modes de calcul des classes de taille (cf WP2/CalculClassesDeTaille.doc)

## !am�lioration des commentaires : en ent�te de chaque fichier, un plan du contenu
## !am�liorer les messages d'alerte, en mettre d�s qu'il y a des saisies et apr�s contr�le de saisie
## !cr�ation automatique des dossiers et appel de l'ensemble des fichiers une fois l'espace de travail choisi

## ! difficult� possible : appel de fonctions graphiques dans les fonctions de calcul pour extraire les fonctions graph...
## ! les tests de variables "par valeur" (classetaille, nom d'amp...) ne doivent pas �tre dans les fonctions g�n�riques

## ######################### Chargement des librairies ############################
## ! conseill� : que la version de R et les packages soient fournis avec toute mise � jour


## !Messages d'avis :

                                                           # Mise en forme du code :
                                                           # -----------------------
source("./Exec/load_packages.R", encoding="latin1")        # OK
source("./Exec/fonctions_base.R", encoding="latin1")       # OK
source("./Exec/config.r", encoding="latin1")               # faite
source("./Exec/gestionmessages.r", encoding="latin1")      # faite
source("./Exec/nombres_SVR.R", encoding="latin1")          # OK
source("./Exec/mkfilegroupe.r", encoding="latin1")         # faite

source("./Exec/calcul_simple.r", encoding="latin1")        # faite
source("./Exec/arbre_regression.r", encoding="latin1")     # faite


source("./Exec/requetes.r", encoding="latin1")             # faite
source("./Exec/modifinterface.r", encoding="latin1")       # faite
source("./Exec/command.r", encoding="latin1")              # faite


source("./Exec/testfichier.r", encoding="latin1")          # faite
source("./Exec/view.r", encoding="latin1")                 # faite
source("./Exec/import.r", encoding="latin1")               # faite
source("./Exec/importdefaut.r", encoding="latin1")         # faite

##################################################
## Nouvelle interface de s�lection des variables :
source("./Exec/selection_variables_fonctions.R", encoding="latin1")        # OK
source("./Exec/selection_variables_interface.R", encoding="latin1")        # OK

##################################################
## Nouveaux boxplots :
source("./Exec/fonctions_graphiques.R", encoding="latin1")                 # OK
source("./Exec/boxplots_esp_generiques.R", encoding="latin1")              # OK
source("./Exec/boxplots_unitobs_generiques.R", encoding="latin1")          # OK

##################################################
## Analyses statistiques :
source("./Exec/modeles_lineaires_interface.R", encoding="latin1")          # OK
source("./Exec/modeles_lineaires_esp_generiques.R", encoding="latin1")     # OK
source("./Exec/modeles_lineaires_unitobs_generiques.R", encoding="latin1") # OK

##################################################
## Barplots sur les fr�quences d'occurrence :
source("./Exec/barplots_occurrence.R", encoding="latin1")                  # OK
source("./Exec/barplots_occurrence_unitobs.R", encoding="latin1")          # OK

## On lance l'interface :
source("./Exec/interface_fonctions.R", encoding="latin1")  # OK
source("./Exec/interface.r", encoding="latin1")            # faite

tkfocus(tm)

#################### Tags de d�veloppement ####################
## [!!!] : construction dangereuse, capilo-tract�e ou erreur possible.
## [imb] : fonctions imbriqu�es dans d'autres fonctions (� corriger)
## [sll] : sans longueur des lignes (mise en forme du code pas termin�e)
## [inc] : expression/fonction incompl�te.
## [OK]  : probl�me corrig�.
## [???] : comprend pas !
## [sup] : supprim�.
## [dep] : d�plac� (menu).
