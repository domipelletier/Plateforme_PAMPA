#-*- coding: latin-1 -*-
# Time-stamp: <2013-02-15 17:10:30 yves>

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

### File: Chargement_shapefile.R
### Created: <2012-11-19 14:58:51 yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Chargement et traitement du shapefile de r�f�rentiel spatial (optionel).
####################################################################################################

########################################################################################################################
loadShapefile.f <- function(directory, layer)
{
    ## Purpose: chargement du r�f�rentiel spatial sous forme de shapefile.
    ## ----------------------------------------------------------------------
    ## Arguments: directory : r�pertoire o� se trouve le shapefile.
    ##            layer : nom de la couche (nom de fichiers sans extension).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 nov. 2012, 17:12

    ## Lecture du shapefile :
    refspa <- readOGR(dsn=directory, layer=layer,
                      input_field_name_encoding=getOption("P.shapefileEncoding"), verbose=FALSE)

    colnames(refspa@data) <- gsub("_", ".", colnames(refspa@data), fixed=TRUE)
    colnames(refspa@data)[1] <- "OBJECTID"

    ## D�finition du syst�me de coordonn�es (sans projection) pour les calculs de surface :
    crsArea <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

    refspa <- spCbind(refspa,
                      data.frame("SITE.SURFACE"=areaPolygon(spTransform(x=refspa,
                                                                        CRSobj=crsArea)) / (10^6), # en km� !
                                 row.names=row.names(refspa@data)))

    ## Ajout des centro�des :
    tmpCentr <- as.data.frame(coordinates(refspa),
                              row.names=row.names(refspa@data))

    colnames(tmpCentr) <- paste("SITE.centr", c("X", "Y"), sep="")

    refspa <- spCbind(refspa,
                      tmpCentr)

}

########################################################################################################################
overlayUnitobs.f <- function(unitobs, refspa)
{
    ## Purpose: Attribution des unit�s d'observation � des zones du
    ##          r�f�rentiel spatial
    ## ----------------------------------------------------------------------
    ## Arguments: unitobs : table des unit�s d'observation.
    ##            refspa : r�f�rentiel spatial ("SpatialPolygonsDataFrame").
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 nov. 2012, 17:35

    ## Spatialisation des unitobs :
    spaUnitobs <- SpatialPointsDataFrame(coords=cbind(x=unitobs$longitude,
                                                      y=unitobs$latitude),
                                         data=unitobs,
                                         proj4string=refspa@proj4string,
                                         match.ID=TRUE)

    ## Correspondance avec les zones :
    unitobs <- cbind(unitobs,
                     "OBJECTID"=overlay(x=spaUnitobs, y=refspa))

    return(unitobs)
}






### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
