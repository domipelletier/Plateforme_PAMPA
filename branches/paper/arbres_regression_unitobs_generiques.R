#-*- coding: latin-1 -*-

### File: arbres_regression_unitobs_generiques.R
### Time-stamp: <2011-05-12 16:26:49 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions de cr�ation de boxplots pour les m�triques agr�g�es / unit� d'observation.
####################################################################################################

########################################################################################################################
WP2MRT.unitobs.f <- function(metrique, factGraph, factGraphSel, listFact, listFactSel, tableMetrique)
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
    if (tableMetrique == "TableBiodiv")
    {
        ## Pour les indices de biodiversit�, il faut travailler sur les nombres... :
        tmpData <- subsetToutesTables.f(metrique="nombre", facteurs=facteurs,
                                        selections=selections, tableMetrique="listespunit",
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }else{
        ## ...sinon sur la m�trique choisie :
        tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=facteurs,
                                        selections=selections, tableMetrique=tableMetrique,
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
    if (tableMetrique == "unitespta" && factGraph != "classe_taille")
    {
        tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                       metrique=metrique,
                                                       facteurs=c("unite_observation", "classe_taille"),
                                                       listFact=listFact))
    }else{
        if (tableMetrique == "TableBiodiv")
        {
            ## Calcul des indices de biodiversit� sur s�lection d'esp�ces :
            tmp <- calcBiodiv.f(Data=tmpData,
                                unitobs = "unite_observation", code.especes = "code_espece",
                                nombres = "nombre",
                                indices=metrique)

            ## On rajoute les anciennes colonnes :
            tmpData <- cbind(tmp,
                             tmpData[match(tmp$unite_observation, tmpData$unite_observation),
                                     !is.element(colnames(tmpData), colnames(tmp))])
        }else{
            tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                           metrique=metrique,
                                                           facteurs=c("unite_observation"),
                                                           listFact=listFact))
        }
    }

    ## Sauvegarde temporaire des donn�es utilis�es pour les graphiques (attention : �cras�e � chaque nouvelle s�rie de
    ## graphiques/analyses) :
    DataBackup <<- list(tmpData)

    ## Suppression des 'levels' non utilis�s :
    tmpData <- dropLevels.f(tmpData)

    ## Ouverture et configuration du p�riph�rique graphique :
    openDevice.f(noGraph=1,
                 metrique=metrique,
                 factGraph=factGraph,
                 modSel=iFactGraphSel,
                 listFact=listFact,
                 type=ifelse(tableMetrique == "unitespta" && factGraph != "classe_taille",
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
                              type=ifelse(tableMetrique == "unitespta" && factGraph != "classe_taille",
                                          "CL_unitobs",
                                          ifelse(tableMetrique == "unitespta",
                                                 "unitobs(CL)",
                                                 "unitobs")),
                              model="Arbre de r�gression multivari�e")

    tmpMRT <- rpart(exprMRT, data=tmpData)

    plot(tmpMRT, main=mainTitle)
    text.rpart.new(tmpMRT, use.n=TRUE, pretty=0, all=TRUE, xpd=NA)

    ## �criture des r�sultats format�s dans un fichier :
    tryCatch(sortiesMRT.f(objMRT=tmpMRT, formule=exprMRT,
                          metrique=metrique,
                          factAna=factGraph, modSel=iFactGraphSel, listFact=listFact,
                          Data=tmpData,
                          type=ifelse(tableMetrique == "unitespta" && factGraph != "classe_taille",
                                      "CL_unitobs",
                                      "unitobs")),
             error=errorLog.f)


    ## On ferme les p�riph�riques PDF :
    if (getOption("P.graphPDF") || isTRUE(getOption("P.graphPNG")))
    {
        dev.off()
    }else{}

    pampaProfilingEnd.f()
}








### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
