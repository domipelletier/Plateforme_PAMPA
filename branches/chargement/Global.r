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
options(versionPAMPA = "1.1-7")

## R�glage de l'encodage des caract�res :
## options(encoding="latin1")

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
## !cr�ation automatique des dossiers et appel de l'ensemble des fichiers une fois l'espace de travail choisi

## ! les tests de variables "par valeur" (classetaille, nom d'amp...) ne doivent pas �tre dans les fonctions g�n�riques

## ######################### Chargement des librairies ############################
## ! conseill� : que la version de R et les packages soient fournis avec toute mise � jour


## !Messages d'avis :

                                                           # Mise en forme du code :
                                                           # -----------------------
source("./Scripts_Biodiv/load_packages.R", encoding="latin1")        # OK
source("./Scripts_Biodiv/fonctions_base.R", encoding="latin1")       # OK
source("./Scripts_Biodiv/gestionmessages.r", encoding="latin1")      # faite
source("./Scripts_Biodiv/nombres_SVR.R", encoding="latin1")          # OK
source("./Scripts_Biodiv/mkfilegroupe.r", encoding="latin1")         # faite

source("./Scripts_Biodiv/calcul_simple.r", encoding="latin1")        # faite

source("./Scripts_Biodiv/requetes.r", encoding="latin1")             # faite
source("./Scripts_Biodiv/modifinterface.r", encoding="latin1")       # faite
source("./Scripts_Biodiv/command.r", encoding="latin1")              # faite


source("./Scripts_Biodiv/testfichier.r", encoding="latin1")          # faite
source("./Scripts_Biodiv/view.r", encoding="latin1")                 # faite
source("./Scripts_Biodiv/import.r", encoding="latin1")               # faite
source("./Scripts_Biodiv/importdefaut.r", encoding="latin1")         # faite

##################################################
## Nouvelle interface de s�lection des variables :
source("./Scripts_Biodiv/selection_variables_fonctions.R", encoding="latin1")        # OK
source("./Scripts_Biodiv/selection_variables_interface.R", encoding="latin1")        # OK

##################################################
## Nouveaux boxplots :
source("./Scripts_Biodiv/fonctions_graphiques.R", encoding="latin1")                 # OK
source("./Scripts_Biodiv/boxplots_esp_generiques.R", encoding="latin1")              # OK
source("./Scripts_Biodiv/boxplots_unitobs_generiques.R", encoding="latin1")          # OK

source("./Scripts_Biodiv/demo_cartes.R", encoding="latin1")          # OK

##################################################
## Analyses statistiques :
source("./Scripts_Biodiv/modeles_lineaires_interface.R", encoding="latin1")          # OK
source("./Scripts_Biodiv/modeles_lineaires_esp_generiques.R", encoding="latin1")     # OK
source("./Scripts_Biodiv/modeles_lineaires_unitobs_generiques.R", encoding="latin1") # OK
source("./Scripts_Biodiv/arbres_regression_unitobs_generiques.R", encoding="latin1") # OK
source("./Scripts_Biodiv/arbres_regression_esp_generiques.R", encoding="latin1")     # OK

##################################################
## Barplots sur les fr�quences d'occurrence :
source("./Scripts_Biodiv/barplots_occurrence.R", encoding="latin1")                  # OK
source("./Scripts_Biodiv/barplots_occurrence_unitobs.R", encoding="latin1")          # OK


########################################################################################################################
## Configuration :

source("./Scripts_Biodiv/Initialisation.R", encoding="latin1")

## Initialisation des options graphiques (nouveau syst�me) :
if (is.null(getOption("GraphPAMPA")))   # uniquement si pas d�j� initialis�es (cas de lancement multiple)
{
    initialiseGraphOptions.f()
}

## Chargement de la configuration apr�s l'initialisation des options => permet d'avoir des options personnalis�es dans
## la configuration.
## source("./Scripts_Biodiv/config.r", encoding="latin1")               # faite
                                        # supprim� et remplac� par un script d'initialisation pour �viter la demande de
                                        # configuration au premier lancement (pas utile en cas de chargement manuel).
                                        # [yr: 17/11/2011]


## On lance l'interface :
source("./Scripts_Biodiv/interface_fonctions.R", encoding="latin1")  # OK
source("./Scripts_Biodiv/interface.r", encoding="latin1")            # faite

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
