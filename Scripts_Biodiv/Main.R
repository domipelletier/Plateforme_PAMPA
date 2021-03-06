#-*- coding: latin-1 -*-
# Time-stamp: <2018-01-11 13:07:23 yreecht>

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2017 Ifremer - Tous droits r�serv�s.
##
##   Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
##   modifier suivant les termes de la "GNU General Public License" telle que
##   publi�e par la Free Software Foundation : soit la version 2 de cette
##   licence, soit (� votre gr�) toute version ult�rieure.
##
##   Ce programme est distribu� dans l'espoir qu'il vous sera utile, mais SANS
##   AUCUNE GARANTIE : sans m�me la garantie implicite de COMMERCIALISABILIT�
##   ni d'AD�QUATION � UN OBJECTIF PARTICULIER. Consultez la Licence G�n�rale
##   Publique GNU pour plus de d�tails.
##
##   Vous devriez avoir re�u une copie de la Licence G�n�rale Publique GNU avec
##   ce programme ; si ce n'est pas le cas, consultez :
##   <http://www.gnu.org/licenses/>.

### File: Main.R
### Created: <2012-02-24 20:36:47 Yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Objet            : Programme de calcul des m�triques "ressources & biodiversit�".
### Date de cr�ation : F�vrier 2008
###
####################################################################################################

## ** Version **
options(versionPAMPA = "2.8-beta3")

## Platform-specific treatment:
## Identification du dossier parent (d'installation) :
fileCall <- sub("source\\([[:blank:]]*(file[[:blank:]]*=[[:blank:]]*)?(\"|\')([^\"\']*)(\"|\')[[:blank:]]*(,.*\\)|\\))",
                "\\3",
                paste(deparse(tryCatch(sys.call(-2),
                                       error=function(e) {NULL})),
                      collapse=""))

## R�glage du dossier de travail de R :
if(basename(fileCall) == "Main.R")
{
    setwd(paste(dirname(fileCall), "/../", sep=""))
}else{
    ## message("Dossier non-trouv�")
    if (.Platform$OS.type == "windows")
    {
        setwd("C:/PAMPA/")
    }else{}                             # Rien !
}

## R�cup�r� dans une variable globale (beurk !) :
basePath <- getwd()

## R�pertoire de travail par d�faut (si pas configur� par ailleurs) :
nameWorkspace <- basePath

########################################################################################################################
## Chargement des fonctions de la plateforme pour :
                                                                                       # Mise en forme du code :
## ...les fonctions communes de base :                                                 # -----------------------
source("./Scripts_Biodiv/Load_packages.R", encoding="latin1")                          # OK
source("./Scripts_Biodiv/Fonctions_base.R", encoding="latin1")                         # OK

## ...la cr�ation de l'interface :
source("./Scripts_Biodiv/Interface_fonctions.R", encoding="latin1")                    # OK
source("./Scripts_Biodiv/Interface_principale.R", encoding="latin1")                   # OK

## anciennes fonctions annexes de visualisation des donn�es (corrig�es) :
source("./Scripts_Biodiv/Gestionmessages.R", encoding="latin1")                        # faite
source("./Scripts_Biodiv/Testfichier.R", encoding="latin1")                            # faite
source("./Scripts_Biodiv/View.R", encoding="latin1")                                   # faite

## ...le chargement des donn�es :
source("./Scripts_Biodiv/Chargement_fichiers.R", encoding="latin1")                    # OK
source("./Scripts_Biodiv/Chargement_manuel_fichiers.R", encoding="latin1")             # OK
source("./Scripts_Biodiv/Calcul_poids.R", encoding="latin1")                           # OK
source("./Scripts_Biodiv/Lien_unitobs-refspa.R", encoding="latin1")                    # OK
source("./Scripts_Biodiv/Chargement_shapefile.R", encoding="latin1")                   # OK
source("./Scripts_Biodiv/Chargement_OBSIND.R", encoding="latin1")                      # OK

## ...les calculs de tables de m�triques :
source("./Scripts_Biodiv/Agregations_generiques.R", encoding="latin1")                 # OK
source("./Scripts_Biodiv/Calcul_tables_metriques.R", encoding="latin1")                # OK
source("./Scripts_Biodiv/Calcul_tables_metriques_LIT.R", encoding="latin1")            # OK
source("./Scripts_Biodiv/Calcul_tables_metriques_SVR.R", encoding="latin1")            # OK
source("./Scripts_Biodiv/Traces_tortues.R", encoding="latin1")                         # OK

## ...la s�lection des donn�es :
source("./Scripts_Biodiv/Selection_donnees.R", encoding="latin1")                      # OK

## ...options graphiques et g�n�rales :
source("./Scripts_Biodiv/Options.R", encoding="latin1")                                # OK

##################################################
## Analyses et graphiques :

## ...l'interface de s�lection des variables :
source("./Scripts_Biodiv/Selection_variables_fonctions.R", encoding="latin1")          # OK
source("./Scripts_Biodiv/Selection_variables_interface.R", encoding="latin1")          # OK

## ...la cr�ation de boxplots (...) :
source("./Scripts_Biodiv/Fonctions_graphiques.R", encoding="latin1")                   # OK
source("./Scripts_Biodiv/Boxplots_esp_generiques.R", encoding="latin1")                # OK
source("./Scripts_Biodiv/Boxplots_unitobs_generiques.R", encoding="latin1")            # OK
## ...dont cartes :
source("./Scripts_Biodiv/Graphiques_carto.R", encoding="latin1")                       #
source("./Scripts_Biodiv/Variables_carto.R", encoding="latin1")                        #

## ...les analyses statistiques :
source("./Scripts_Biodiv/Modeles_lineaires_interface.R", encoding="latin1")            # OK
source("./Scripts_Biodiv/Modeles_lineaires_esp_generiques.R", encoding="latin1")       # OK
source("./Scripts_Biodiv/Modeles_lineaires_unitobs_generiques.R", encoding="latin1")   # OK
source("./Scripts_Biodiv/Arbres_regression_unitobs_generiques.R", encoding="latin1")   # OK
source("./Scripts_Biodiv/Arbres_regression_esp_generiques.R", encoding="latin1")       # OK

## ...les barplots sur les fr�quences d'occurrence :
source("./Scripts_Biodiv/Barplots_occurrence.R", encoding="latin1")                    # OK
source("./Scripts_Biodiv/Barplots_occurrence_unitobs.R", encoding="latin1")            # OK

## ...barplots g�n�riques :
source("./Scripts_Biodiv/Barplots_esp_generiques.R", encoding="latin1")                # OK
source("./Scripts_Biodiv/Barplots_unitobs_generiques.R", encoding="latin1")            # OK

########################################################################################################################
## Configuration :
source("./Scripts_Biodiv/Initialisation.R", encoding="latin1")

## Initialisation des options graphiques (nouveau syst�me) :
if (is.null(getOption("GraphPAMPA")))   # uniquement si pas d�j� initialis�es (cas de lancement multiple)
{
    initialiseOptions.f()
}

## On lance l'interface :
mainInterface.create.f()

#################### Tags de d�veloppement ####################
## [!!!] : construction dangereuse, capilo-tract�e ou erreur possible.
## [imb] : fonctions imbriqu�es dans d'autres fonctions (� corriger)
## [sll] : sans longueur des lignes (mise en forme du code pas termin�e)
## [inc] : expression/fonction incompl�te.
## [OK]  : probl�me corrig�.
## [???] : comprend pas !
## [sup] : supprim�.
## [dep] : d�plac� (menu).


### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
