#-*- coding: latin-1 -*-
# Time-stamp: <2013-04-25 18:23:28 yves>

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2013 Ifremer - Tous droits r�serv�s.
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

### File: Chargement_OBSIND.R
### Created: <2013-04-25 12:12:23 yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Chargement des donn�es de type OBSIND (observation ponctuelle et g�olocalis�e d'individus).
####################################################################################################


unitobsNew.OBSIND.create.f <- function(unitobs, refspa, dataEnv)
{
    ## Purpose: Cr�ation d'une nouvelle table d'unit�s d'observations pour
    ##          les observations ponctuelles g�or�f�renc�es (OBSIND).
    ## ----------------------------------------------------------------------
    ## Arguments: unitobs : table des unit�s d'observations
    ##                      (r�duite � ce stade).
    ##            refspa : r�f�rentiel spatial sous forme de shapefile.
    ##            dataEnv : environnmeent des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 25 avril 2013, 16:04

    ## lien entre les unitobs "individuelles" et le r�f�rentiel spatial :
    unitobsTmp <- overlayUnitobs.f(unitobs=unitobs, refspa=refspa)

    ## Construction d'un nouvel indice d'unit�s d'observations (intersection zone - jour
    ## d'observation ; dites "regroup�es") :
    unitobsTmp$unitobsNew <- paste("Z", unitobsTmp$OBJECTID, "-J", unitobsTmp$jour, "-",
                                   unitobsTmp$mois, "-", unitobsTmp$an, sep="")

    ## Sauvegarde d'une table de correspondance entre unit�s d'observations "individuelles" et
    ## "regroup�es" dans l'environnement des donn�es :
    assign(x=".unitobsCorresp",
           value=unitobsTmp[ , c("unite_observation", "unitobsNew")],
           envir=dataEnv)

    ## Suppression des unit�s d'observation hors polygones :
    unitobsTmp <- unitobsTmp[ ! is.na(unitobsTmp$OBJECTID), ]

    ## R�organisation des colonnes :
    unitobsTmp <- unitobsTmp[ , c("cas.etude", "unitobsNew",
                                 "type", "site", "station", "caracteristique_1",
                                  "caracteristique_2", "fraction_echantillonnee", "jour", "mois",
                                  "an", "heure", "nebulosite", "direction_vent", "force_vent",
                                  "etat_mer", "courant", "maree", "phase_lunaire", "latitude",
                                  "longitude", "statut_protection", "avant_apres", "biotope",
                                  "biotope_2", "habitat1", "habitat2", "habitat3", "visibilite",
                                  "prof_min", "prof_max", "DimObs1", "DimObs2", "nb_plong",
                                  "plongeur", "OBJECTID")]

    colnames(unitobsTmp)[2] <- "unite_observation"

    ## Agr�gations (une ligne par unit� d'observation) :
    unitobsNew <- do.call(rbind,
                          lapply(split(unitobsTmp, unitobsTmp[ , "unite_observation"]),
                                 aggreg.unitobsNew.f,
                                 refspa=refspa))

    return(unitobsNew)
}


########################################################################################################################
aggreg.unitobsNew.f <- function(x, refspa)
{
    ## Purpose: Agr�ger des parties de la nouvelle table des unitobs pour
    ##          n'avoir plus qu'une ligne par unitobs.
    ## ----------------------------------------------------------------------
    ## Arguments: x : sous-table des unitobs avec les donn�es d'une unitobs.
    ##            refspa : le r�f�rentiel spatial sous forme de shapefile.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 25 avril 2013, 17:04

    ## Colonnes ne b�n�ficiant pas d'un traitement sp�cial :
    idx <- which(! is.element(colnames(x),
                              c("latitude", "longitude", "visibilite", "prof_min", "prof_max",
                                "DimObs1", "DimObs2", "plongeur")))

    ## On conserve la valeur si c'est la m�me partout dans la colonne :
    x[ , idx] <- sapply(x[ , idx],
                        function(y)
                    {
                        if (length(unique(y)) == 1)
                        {
                            return(y)
                        }else{
                            return(rep(NA, length(y)))
                        }
                    }, simplify=FALSE)

    ## Longitude/latitude = barycentre du polygone :
    x[ , c("latitude", "longitude")] <- refspa@data[x[ , "OBJECTID"],
                                                    c("SITE.centrY", "SITE.centrX")]

    ## Colonnes pour lesquelles on prend le minimum :
    x[ , c("visibilite", "prof_min")] <- sapply(x[ , c("visibilite", "prof_min")],
                                                function(x)
                                            {
                                                if (all(is.na(x)))
                                                {
                                                    NA
                                                }else{
                                                    min(x, na.rm=TRUE)
                                                }
                                            },
                                                simplify=FALSE)

    ## Colonne pour laquelle on prend le maximum :
    x[ , "prof_max"] <- if (all(is.na(x[ , "prof_max"])))
      {
          NA
      }else{
          max(x[ , "prof_max"], na.rm=TRUE)
      }

    ## Dimobs en km� :
    x[ , "DimObs1"] <- refspa@data[x[ , "OBJECTID"],
                                   c("SITE.SURFACE")]

    x[ , "DimObs2"] <- 1

    ## Plusieurs observateurs possibles :
    x[ , "nb_plong"] <- length(unique(x[ , "plongeur"]))
    x[ , "plongeur"] <- paste(unique(x[ , "plongeur"]), collapse=", ")

    return(x[1, !is.element(colnames(x), "OBJECTID"), drop=FALSE])
}





### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 100
### End:
