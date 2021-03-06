#-*- coding: latin-1 -*-

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2010 Ifremer - Tous droits r�serv�s.
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

### File: arbres_regression_unitobs_generiques.R
### Time-stamp: <2012-01-10 18:12:14 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions de cr�ation de boxplots pour les m�triques agr�g�es / unit� d'observation.
####################################################################################################

########################################################################################################################
WP2MRT.unitobs.f <- function(metrique, factGraph, factGraphSel, listFact, listFactSel, tableMetrique,
                             dataEnv=dataEnv, baseEnv=.GlobalEnv)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factGraph : le facteur de s�lection des esp�ces.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ##            dataEnv : environnement de stockage des donn�es.
    ##            baseEnv : environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 10 mai 2011, 14:24

    pampaProfilingStart.f()

    ## Nettoyage des facteurs (l'interface de s�lection produit des valeurs vides) :
    listFactSel <- listFactSel[unlist(listFact) != ""]
    listFactSel <- listFactSel[length(listFactSel):1]

    listFact <- listFact[unlist(listFact) != ""]
    listFact <- listFact[length(listFact):1]

    ## Concat�nation
    facteurs <- c(factGraph, unlist(listFact)) # Concat�nation des facteurs

    selections <- c(list(factGraphSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es

    ## Donn�es pour la s�rie de MRT :
    if (tableMetrique == "unit")
    {
        ## Pour les indices de biodiversit�, il faut travailler sur les nombres... :
        tmpData <- subsetToutesTables.f(metrique="nombre", facteurs=facteurs,
                                        selections=selections, dataEnv=dataEnv, tableMetrique="unitSp",
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }else{
        ## ...sinon sur la m�trique choisie :
        tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=facteurs,
                                        selections=selections, dataEnv=dataEnv, tableMetrique=tableMetrique,
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }

    ## Formule du MRT :
    exprMRT <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" + "))))

    ## Identification des diff�rents modalit�s (esp�ces) du graphique � g�n�rer :
    if (factGraph == "")                # Pas de facteur de s�paration des graphiques.
    {
        iFactGraphSel <- ""
    }else{
        if (is.na(factGraphSel[1]))            # Toutes les modalit�s.
        {
            iFactGraphSel <- unique(as.character(sort(tmpData[ , factGraph])))
        }else{                              # Modalit�s s�lectionn�es (et pr�sentes parmi les donn�es retenues).
            iFactGraphSel <- factGraphSel[is.element(factGraphSel, tmpData[ , factGraph])]
        }
    }

    ## Agr�gation des observations / unit� d'observation :
    if (tableMetrique == "unitSpSz" && factGraph != "classe_taille")
    {
        tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                       metrique=metrique,
                                                       facteurs=c("unite_observation", "classe_taille"),
                                                       dataEnv=dataEnv,
                                                       listFact=listFact))
    }else{
        if (tableMetrique == "unit")
        {
            ## Calcul des indices de biodiversit� sur s�lection d'esp�ces :
            tmp <- do.call(rbind,
                           lapply(getOption("P.MPA"),
                                  function(MPA)
                              {
                                  calcBiodiv.f(Data=tmpData,
                                               refesp=get("refesp", envir=dataEnv),
                                               MPA=MPA,
                                               unitobs = "unite_observation", code.especes = "code_espece",
                                               nombres = "nombre",
                                               indices=metrique,
                                               dataEnv=dataEnv)
                              }))

            ## On rajoute les anciennes colonnes :
            tmpData <- cbind(tmp[ , colnames(tmp) != "nombre"], # Colonne "nombre" d�sormais inutile.
                             tmpData[match(tmp$unite_observation, tmpData$unite_observation),
                                     !is.element(colnames(tmpData),
                                                 c(colnames(tmp), "nombre", "code_espece")), drop=FALSE])
        }else{
            tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                           metrique=metrique,
                                                           facteurs=c("unite_observation"),
                                                           dataEnv=dataEnv,
                                                           listFact=listFact))
        }
    }

    ## Sauvegarde temporaire des donn�es utilis�es pour les graphiques (attention : �cras�e � chaque nouvelle s�rie de
    ## graphiques/analyses) :
    DataBackup <<- list(tmpData)

    ## Suppression des 'levels' non utilis�s :
    tmpData <- dropLevels.f(tmpData)

    ## Ouverture et configuration du p�riph�rique graphique :
    graphFile <- openDevice.f(noGraph=1,
                              metrique=metrique,
                              factGraph=factGraph,
                              modSel=iFactGraphSel,
                              listFact=listFact,
                              dataEnv=dataEnv,
                              type=ifelse(tableMetrique == "unitSpSz" && factGraph != "classe_taille",
                                          "CL_unitobs",
                                          "unitobs"),
                              typeGraph="MRT",
                              large=TRUE)

    par(mar=c(1.5, 7, 7, 7), mgp=c(3.5, 1, 0)) # param�tres graphiques.

    ## Titre (d'apr�s les m�triques, modalit� du facteur de s�paration et facteurs de regroupement) :
    mainTitle <- graphTitle.f(metrique=metrique,
                              modGraphSel=iFactGraphSel,
                              factGraph=factGraph,
                              listFact=listFact,
                              type=ifelse(tableMetrique == "unitSpSz" && factGraph != "classe_taille",
                                          "CL_unitobs",
                                          ifelse(tableMetrique == "unitSpSz",
                                                 "unitobs(CL)",
                                                 "unitobs")),
                              model="Arbre de r�gression multivari�e")

    tmpMRT <- rpart(exprMRT, data=tmpData)

    plot(tmpMRT, main=mainTitle)
    text.rpart.new(tmpMRT, use.n=TRUE, pretty=0, all=TRUE, xpd=NA)

    ## �criture des r�sultats format�s dans un fichier :
    tryCatch(sortiesMRT.f(objMRT=tmpMRT, formule=exprMRT,
                          metrique=metrique,
                          factAna=factGraph, modSel=iFactGraphSel,
                          listFact=listFact, listFactSel=listFactSel,
                          Data=tmpData, dataEnv=dataEnv,
                          type=ifelse(tableMetrique == "unitSpSz" && factGraph != "classe_taille",
                                      "CL_unitobs",
                                      "unitobs"),
                          baseEnv=baseEnv),
             error=errorLog.f)


    ## On ferme les p�riph�riques PDF :
    if (getOption("P.graphPDF") || isTRUE(getOption("P.graphPNG")))
    {
        dev.off()

        ## Inclusion des fontes dans le pdf si souhait� :
        if (getOption("P.graphPDF") && getOption("P.pdfEmbedFonts"))
        {
            tryCatch(embedFonts(file=graphFile),
                     error=function(e)
                 {
                     warning("Impossible d'inclure les fontes dans le PDF !")
                 })
        }else{}
    }else{
        if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")))
        {
            ## Sauvegarde en wmf si pertinent et souhait� :
            savePlot(graphFile, type="wmf", device=dev.cur())
        }else{}
    }

    pampaProfilingEnd.f()
}








### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
