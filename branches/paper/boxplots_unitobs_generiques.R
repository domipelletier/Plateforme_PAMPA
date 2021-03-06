#-*- coding: latin-1 -*-

### File: boxplots_ttesp_generic.R
### Time-stamp: <2011-06-23 10:25:14 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
###
####################################################################################################


########################################################################################################################
graphTitle.unitobs.f <- function(metrique, modGraphSel, factGraph, listFact, model=NULL)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 oct. 2010, 15:44

    return(paste(ifelse(is.null(model),
                        "valeurs de ",
                        paste(model, " pour ", varNames[metrique, "article"], sep="")),
                 varNames[metrique, "nom"], " agr�g�",
                 switch(varNames[metrique, "genre"], # Accord de "agr�g�".
                        f="e", fp="es", mp="s", ""),
                 " par unit� d'observation",
                 ifelse(modGraphSel[1] == "", # Facteur de s�paration uniquement si d�fini.
                        "\npour toutes les esp�ces",
                        paste(switch(factGraph,
                                     "classe_taille"="\npour les individus correspondant � '", # Cas des classes de
                                        # tailles.
                                     "\npour les esp�ces correspondant � '"),
                              factGraph, "' = (",
                              paste(modGraphSel, collapse=", "), ")", sep="")),
                 "\n selon ",
                 paste(sapply(listFact[length(listFact):1],
                              function(x)paste(varNames[x, c("article", "nom")], collapse="")),
                       collapse=" et "),
                 "\n", sep=""))
}


########################################################################################################################
WP2boxplot.unitobs.f <- function(metrique, factGraph, factGraphSel, listFact, listFactSel, tableMetrique)
{
    ## Purpose: Produire les boxplots en tenant compte des options graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factGraph : le facteur s�lection des esp�ces.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  6 ao�t 2010, 16:34

    pampaProfilingStart.f()

    ## Nettoyage des facteurs (l'interface de s�lection produit des valeurs vides) :
    listFactSel <- listFactSel[unlist(listFact) != ""]
    listFactSel <- listFactSel[length(listFactSel):1]

    listFact <- listFact[unlist(listFact) != ""]
    listFact <- listFact[length(listFact):1]

    ## Concat�nation
    facteurs <- c(factGraph, unlist(listFact)) # Concat�nation des facteurs

    selections <- c(list(factGraphSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es

    ## Donn�es pour la s�rie de boxplots :
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

    ## Formule du boxplot
    exprBP <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" + "))))

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
    ## graphiques) :
    DataBackup <<- list(tmpData)

    ## Cr�ation du graphique si le nombre d'observations  < au minimum d�fini dans les options :
    if (nrow(tmpData) < getOption("P.MinNbObs"))
    {
        warning("Nombre d'observations pour (", paste(iFactGraphSel, collapse=", "), ") < ", getOption("P.MinNbObs"),
                " : Graphique non cr�� !\n")
    }else{

        ## ## Suppression des valeurs sup�rieures � X% du maximum (pour plus de lisibilit�) :
        ## if (getOption("P.maxExclu"))
        ## {
        ##     tmpData <- tmpData[which(tmpData[, metrique] <=
        ##                                 getOption("P.GraphPartMax") * max(tmpData[, metrique],
        ##                                                                   na.rm=TRUE)), ]
        ## }else{}

        ## Suppression des 'levels' non utilis�s :
        tmpData <- dropLevels.f(tmpData)

        ## Ouverture et configuration du p�riph�rique graphique :
        wmfFile <- openDevice.f(noGraph=1,
                                metrique=metrique,
                                factGraph=factGraph,
                                modSel=iFactGraphSel,
                                listFact=listFact,
                                type=ifelse(tableMetrique == "unitespta" && factGraph != "classe_taille",
                                            "CL_unitobs",
                                            "unitobs"),
                                typeGraph="boxplot")

        par(mar=c(9, 5, 8, 1), mgp=c(3.5, 1, 0)) # param�tres graphiques.

        ## Titre (d'apr�s les m�triques, modalit� du facteur de s�paration et facteurs de regroupement) :
        mainTitle <- graphTitle.f(metrique=metrique,
                                  modGraphSel=iFactGraphSel,
                                  factGraph=factGraph,
                                  listFact=listFact,
                                  type=ifelse(tableMetrique == "unitespta" && factGraph != "classe_taille",
                                              "CL_unitobs",
                                              ifelse(tableMetrique == "unitespta",
                                                     "unitobs(CL)",
                                                     "unitobs")))

        ## Label axe y :
        ylab <- parse(text=paste("'", Capitalize.f(varNames[metrique, "nom"]), "'",
                      ifelse(varNames[metrique, "unite"] != "",
                             paste("~~(", varNames[metrique, "unite"], ")", sep=""),
                             ""),
                      sep=""))

        ## Boxplot !
        tmpBP <- boxplotPAMPA.f(exprBP, data=tmpData,
                                main=mainTitle, ylab=ylab)  ## Capitalize.f(varNames[metrique, "nom"]),


        ## #################### Informations suppl�mentaires sur les graphiques ####################

        ## Label si un seul groupe :
        if (length(tmpBP$names) == 1)
        {
            axis(1, at=1, labels=tmpBP$names)
        }else{}

        ## S�parateurs de facteur de premier niveau :
        if (getOption("P.sepGroupes"))
        {
            sepBoxplot.f(terms=attr(terms(exprBP), "term.labels"), data=tmpData)
        }

        ## S�parateurs par d�faut :
        abline(v = 0.5+(0:length(tmpBP$names)) , col = "lightgray", lty = "dotted") # S�parations.

        ## L�gende des couleurs (facteur de second niveau) :
        if (getOption("P.legendeCouleurs"))
        {
            legendBoxplot.f(terms=attr(terms(exprBP), "term.labels"), data=tmpData)
        }else{}

        ## Moyennes :
        Moyenne <- as.vector(tapply(X=tmpData[, metrique], # moyenne par groupe.
                                    INDEX=as.list(tmpData[ , attr(terms(exprBP),
                                                                     "term.labels"), drop=FALSE]),
                                    FUN=mean, na.rm=TRUE))

        ## ... points :
        if (getOption("P.pointMoyenne"))
        {
            points(Moyenne,
                   pch=getOption("P.pointMoyennePch"),
                   col=getOption("P.pointMoyenneCol"), lwd=2.5,
                   cex=getOption("P.pointMoyenneCex"))
        }else{}

        ## ... valeurs :
        if (getOption("P.valMoyenne"))
        {
            plotValMoyennes.f(moyennes=Moyenne, objBP=tmpBP)
        }else{}

        if (isTRUE(getOption("P.warnings")))
        {
            ## Avertissement pour les petits effectifs :
            plotPetitsEffectifs.f(objBP=tmpBP, nbmin=5)
        }else{}

        ## Nombres d'observations :
        if (getOption("P.NbObs"))
        {
            nbObs <- tmpBP$n # Retourn� par la fonction 'boxplot'

            ## Nombres sur l'axe sup�rieur :
            axis(3, as.vector(nbObs), at=1:length(as.vector(nbObs)),
                 col.ticks="orange", col.axis = "orange", lty = 2, lwd = 0.5,
                 mgp=c(2, 0.5, 0))

            legend("topleft", "Nombre d'enregistrements par boite � moustache",
                   cex =0.9, col=getOption("P.NbObsCol"), text.col="orange", merge=FALSE)
        }else{}

    }  ## Fin de graphique.

    ## On ferme les p�riph�riques PDF :
    if (getOption("P.graphPDF") || isTRUE(getOption("P.graphPNG")))
    {
        dev.off()
    }else{
        if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")))
        {
            ## Sauvegarde en wmf si pertinent et souhait� :
            savePlot(wmfFile, type="wmf", device=dev.cur())
        }else{}
    }

    pampaProfilingEnd.f()
}






### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
