#-*- coding: latin-1 -*-

### File: barplots_occurrence.R
### Time-stamp: <2012-01-10 18:12:45 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions pour cr�er des repr�sentations (barplots) des fr�quences d'occurrences relatives (%)
### (utilise certaines fonctions de ./boxplot_generique_calc.R)
####################################################################################################

barplotOccurrence.f <- function(factGraph, factGraphSel, listFact, listFactSel, dataEnv)
{
    ## Purpose: cr�ation des barplots d'apr�s les s�lections de facteurs et
    ##          modalit�s.
    ## ----------------------------------------------------------------------
    ## Arguments: factGraph : le facteur de s�paration des graphiques.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 oct. 2010, 10:51

    metrique <- "freq.occurrence"

    ## Nettoyage des facteurs (l'interface de s�lection produit des valeurs vides) :
    listFactSel <- listFactSel[unlist(listFact) != ""]
    listFactSel <- listFactSel[length(listFactSel):1]

    listFact <- listFact[unlist(listFact) != ""]
    listFact <- listFact[length(listFact):1]

    ## Concat�nation
    facteurs <- c(factGraph, unlist(listFact)) # Concat�nation des facteurs

    selections <- c(list(factGraphSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es

    ## Donn�es pour la s�rie de boxplots :
    tmpData <- subsetToutesTables.f(metrique="pres_abs", facteurs=facteurs, selections=selections,
                                    dataEnv=dataEnv, tableMetrique="TablePresAbs", exclude = NULL)

    ## Identification des diff�rents graphiques � g�n�rer:
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


    ## Sauvegarde temporaire des donn�es utilis�es pour les graphiques (attention : �cras�e � chaque nouvelle s�rie de
    ## graphiques) :
    DataBackup <<- list()

    ## ###############################################################
    ## Boucle de cr�ation des graphiques (par facteur de s�paration) :
    for (modGraphSel in iFactGraphSel)
    {
        ## Option graphique :
        cex <- getOption("P.cex")

        ## Pr�paration des donn�es pour un graphique :
        if (modGraphSel == "")          # ...si pas de facteur de s�paration des graphiques
        {
            tmpDataMod <- tmpData
        }else{                          # ...sinon.
            tmpDataMod <- subset(tmpData, tmpData[ , factGraph] == modGraphSel) # Subset des donn�es pour la modalit�.
        }

        ## Passage au graphique suivant si le nombre d'observations  < au minimum d�fini dans les options.
        if (dim(tmpDataMod)[1] < getOption("P.MinNbObs"))
        {
            warning("Nombre d'observations pour ", modGraphSel, " < ", getOption("P.MinNbObs"),
                    " : Graphique non cr�� !\n")
            next()
        }else{}

        ## Suppression des 'levels' non utilis�s :
        tmpDataMod <- dropLevels.f(tmpDataMod)

        ## Sauvegarde temporaire des donn�es :
        DataBackup[[modGraphSel]] <<- tmpDataMod

        ## Ouverture et configuration du p�riph�rique graphique :
        graphFileTmp <- openDevice.f(noGraph=which(modGraphSel == iFactGraphSel),
                                     metrique=metrique,
                                     factGraph=factGraph,
                                     modSel=if (getOption("P.plusieursGraphPage"))
                                 {
                                     iFactGraphSel      # toutes les modalit�s.
                                 }else{
                                     modGraphSel        # la modalit� courante uniquement.
                                 },
                                     listFact=listFact,
                                     dataEnv=dataEnv,
                                     type="espece",
                                     typeGraph="barplot")

        ## graphFile uniquement si nouveau fichier :
        if (!is.null(graphFileTmp)) graphFile <- graphFileTmp

        ## Titre (d'apr�s les m�triques, modalit� du facteur de s�paration et facteurs de regroupement) :
        if (! isTRUE(getOption("P.graphPaper")))
        {
            mainTitle <- graphTitle.f(metrique=metrique,
                                      modGraphSel=modGraphSel,
                                      factGraph=factGraph,
                                      listFact=listFact,
                                      type="espece")
        }else{
            mainTitle <- NULL
        }

        ## Calcul des fr�quences :
        heights <- with(tmpDataMod,
                        tapply(pres_abs, lapply(listFact, function(y)eval(parse(text=y))),
                               function(x)
                           {
                               100 * sum(x, na.rm=TRUE) / length(na.omit(x))
                           }))

        ## Param�tres graphiques :
        ## Marge dynamiques (adaptation � la longueur des labels) :
        optim(par=unlist(par("mai")),   # Le rapport inch/ligne est modifi� en changeant les marges => besoin
                                        # de l'optimiser.
              fn=function(x)
          {
              par(mai=c(
                  ## Marge du bas :
                  lineInchConvert.f()$V * cex * unlist(par("lheight")) * 4.5,
                  ## Marge de gauche dynamique :
                  tmp2 <- ifelse((tmp <- lineInchConvert.f()$H * cex * unlist(par("lheight")) * (1.4 +0.4 + 0.9) + # marge
                                        # suppl�mentaire.
                              max(strDimRotation.f(as.graphicsAnnot(pretty(range(heights, na.rm=TRUE))),
                                                   srt=0,
                                                   unit="inches",
                                                   cex=cex)$width, na.rm=TRUE)) > 0.7 * unlist(par("pin"))[1],
                                 0.7 * unlist(par("pin"))[1],
                                 tmp),
                  ## Marge sup�rieure augment�e s'il y a un titre :
                  ifelse(isTRUE(getOption("P.graphPaper")) ,
                         3 * lineInchConvert.f()$V,
                         8 * lineInchConvert.f()$V),
                  ## Marge de droite :
                  lineInchConvert.f()$H * cex * unlist(par("lheight")) * 7) +
                  lineInchConvert.f()$H * cex * unlist(par("lheight")) * 0.1,
                  ## Distance du nom d'axe d�pendante de la taille de marge gauche :
                  mgp=c(tmp2 / lineInchConvert.f()$H - 1.4, 0.9, 0))

              ## Valeur � minimiser :
              return(sum(abs(x - unlist(par("mai")))))
          },
              control=list(abstol=0.01))    # Tol�rance.

        ## Label axe y :
        ylab <- parse(text=paste("'", Capitalize.f(varNames[metrique, "nom"]), "'",
                      ifelse(varNames[metrique, "unite"] != "",
                             paste("~~(", varNames[metrique, "unite"], ")", sep=""),
                             ""),
                      sep=""))

        barPlotTmp <- barplot(heights,
                              beside=TRUE,
                              main=mainTitle,
                              xlab="",
                              ylab=ylab,
                              ylim=c(0, 1.1 * max(heights, na.rm=TRUE)),
                              las=1,
                              col=.ColorPalette(nrow(heights)),
                              cex.lab=cex,
                              cex.axis=cex,
                              legend.text=ifelse(length(listFact) > 1, TRUE, FALSE),
                              args.legend=list("x"="topright", "inset"=-0.08, "xpd"=NA,
                                               "title"=Capitalize.f(varNames[listFact[1], "nom"])))

        mtext(Capitalize.f(varNames[tail(listFact, 1), "nom"]),
              side=1, line=2.3, cex=cex)

        if (getOption("P.NbObs"))
        {
            ## Nombre d'"observations" :
            nbObs <- with(tmpDataMod,
                          tapply(pres_abs,
                                 lapply(listFact, function(y)eval(parse(text=y))),
                                 function(x)
                             {
                                 length(na.omit(x))
                             }))

            ## Nombres sur l'axe sup�rieur :
            mtext(nbObs, side=3, at=barPlotTmp, las=2, col=getOption("P.NbObsCol"),
                  adj=-0.2)

            legend(x="topleft",
                   legend=expression("Nombre d'observations ("=="nb unit�s d'observation x nb esp�ces)"),
                   cex =0.9, col=getOption("P.NbObsCol"), text.col="orange", merge=FALSE)

        }else{}

        ## On ferme les p�riph�riques PNG en mode fichier individuel :
        if (isTRUE(getOption("P.graphPNG")))
        {
            if ((! getOption("P.plusieursGraphPage") || length(iFactGraphSel) <= 1))
                dev.off()
        }else{
            ## Sauvegarde en wmf si pertinent et souhait� :
            if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")) &&
                (! getOption("P.plusieursGraphPage") || length(iFactGraphSel) <= 1) &&
                !getOption("P.graphPDF"))
            {
                savePlot(graphFile, type="wmf", device=dev.cur())
            }else{}
        }
    }                                   # Fin de boucle graphique


    ## On ferme les p�riph�riques PDF ou PNG restants :
    if (getOption("P.graphPDF") ||
        (isTRUE(getOption("P.graphPNG")) && getOption("P.plusieursGraphPage") && length(iFactGraphSel) > 1))
    {
            dev.off()

            ## Inclusion des fontes dans le pdf si souhait� :
            if (getOption("P.graphPDF") && getOption("P.pdfEmbedFonts"))
            {
                embedFonts(file=graphFile)
            }else{}
    }else{}

    ## Sauvegarde en wmf restants si pertinent et souhait� :
    if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")) &&
        !(getOption("P.graphPNG") || getOption("P.graphPDF")) &&
        getOption("P.plusieursGraphPage") && length(iFactGraphSel) > 1)
    {
        savePlot(graphFile, type="wmf", device=dev.cur())
    }else{}
}








### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End: