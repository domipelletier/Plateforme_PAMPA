#-*- coding: latin-1 -*-

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2012 Ifremer - Tous droits r�serv�s.
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

### File: Barplots_esp_generiques.R
### Time-stamp: <2012-08-22 16:25:03 yves>
###
### Author: Yves Reecht (auto-entrepreneur)
###
####################################################################################################
### Description:
###
###
####################################################################################################

########################################################################################################################
pointsSmallSample.f <- function(objBaP, nbmin=20)
{
    ## Purpose: Afficher des points pour les petits effectifs
    ## ----------------------------------------------------------------------
    ## Arguments: objBaP : objet retourn� par barplotPAMPA.f().
    ##            nbmin: nombre mini au dessous duquel afficher un warning.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  5 sept. 2012, 16:49

    if (any(objBaP$n < nbmin & objBaP$n > 0, na.rm=TRUE))
    {
        msg <- paste("petit effectif (< ", nbmin, ")", sep="")

        ## "L�gende" :
        legend("top",
               msg,
               cex =0.9, text.col="red", merge=FALSE, adj=c(0, 0.2),
               pch=rev(c(24, NA)[seq_along(msg)]),
               col="red3", pt.bg="gold", pt.cex=1.2)

        ## Index des petits effectifs :
        idx <- which(objBaP$n < nbmin & objBaP$n > 0)

        ## Points :
        points(x=objBaP$x[idx],
               y=rep((max(objBaP$ylims) / 1.1) * 0.97, length=length(idx)),
               pch=24, col = "red3", bg = "gold", cex=1.2)
    }else{}
}


########################################################################################################################
errbar <- function(x, y, yplus, yminus, cap = 0.015, main = NULL, sub = NULL,
                   xlab = as.character(substitute(x)),
                   ylab = if (is.factor(x) || is.character(x)) "" else as.character(substitute(y)),
                   add = TRUE, lty = 1, type = "p", ylim = NULL, lwd = 1, pch = NA,
                   errbar.col = par("fg"), Type = rep(1, length(y)), ...)
{
    ## Purpose: Tracer les barres d'erreur sur des barplots.
    ## ----------------------------------------------------------------------
    ## Arguments: Ceux de la fonction du package Hmisc.
    ## ----------------------------------------------------------------------
    ## Author: Copi� de la fonction du m�me nom du package Hmisc.

    if (is.null(ylim))
        ylim <- range(y[Type == 1], yplus[Type == 1], yminus[Type ==
            1], na.rm = TRUE)
    if (is.factor(x) || is.character(x)) {
        x <- as.character(x)
        n <- length(x)
        t1 <- Type == 1
        t2 <- Type == 2
        n1 <- sum(t1)
        n2 <- sum(t2)
        omai <- par("mai")
        mai <- omai
        mai[2] <- max(strwidth(x, "inches")) + 0.25 * .R.
        par(mai = mai)
        on.exit(par(mai = omai))
        plot(NA, NA, xlab = ylab, ylab = "", xlim = ylim, ylim = c(1,
            n + 1), axes = FALSE, ...)
        axis(1)
        w <- if (any(t2))
            n1 + (1:n2) + 1
        else numeric(0)
        axis(2, at = c(seq.int(length.out = n1), w), labels = c(x[t1],
            x[t2]), las = 1, adj = 1)
        points(y[t1], seq.int(length.out = n1), pch = pch, type = type,
            ...)
        segments(yplus[t1], seq.int(length.out = n1), yminus[t1],
            seq.int(length.out = n1), lwd = lwd, lty = lty, col = errbar.col)
        if (any(Type == 2)) {
            abline(h = n1 + 1, lty = 2, ...)
            offset <- mean(y[t1]) - mean(y[t2])
            if (min(yminus[t2]) < 0 & max(yplus[t2]) > 0)
                lines(c(0, 0) + offset, c(n1 + 1, par("usr")[4]),
                  lty = 2, ...)
            points(y[t2] + offset, w, pch = pch, type = type,
                ...)
            segments(yminus[t2] + offset, w, yplus[t2] + offset,
                w, lwd = lwd, lty = lty, col = errbar.col)
            at <- pretty(range(y[t2], yplus[t2], yminus[t2]))
            axis(side = 3, at = at + offset, labels = format(round(at,
                6)))
        }
        return(invisible())
    }
    if (add)
        points(x, y, pch = pch, type = type, ...)
    else plot(x, y, ylim = ylim, xlab = xlab, ylab = ylab, pch = pch,
        type = type, ...)
    xcoord <- par()$usr[1:2]
    smidge <- cap * (xcoord[2] - xcoord[1])/2
    segments(x, yminus, x, yplus, lty = lty, lwd = lwd, col = errbar.col)
    if (par()$xlog) {
        xstart <- x * 10^(-smidge)
        xend <- x * 10^(smidge)
    }
    else {
        xstart <- x - smidge
        xend <- x + smidge
    }
    segments(xstart, yminus, xend, yminus, lwd = lwd, lty = lty,
        col = errbar.col)
    segments(xstart, yplus, xend, yplus, lwd = lwd, lty = lty,
        col = errbar.col)
    return(invisible())
}


########################################################################################################################
barplotPAMPA.f <- function(metrique, listFact, Data, main=NULL, cex=getOption("P.cex"),...)
{
    ## Purpose: Barplots avec formatage pour PAMPA
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique � repr�senter.
    ##            listFact : liste des facteurs de regroupement.
    ##            Data : les donn�es � utiliser.
    ##            main : titre du graphique.
    ##            cex : taille des caract�res.
    ##            ... : arguments optionnels (pass�s � la fonction boxplot).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 ao�t 2012, 17:32

    ## Calcul des moyennes/m�dianes :

    heights <- switch(getOption("P.barplotStat"),
                      "moyenne"=,
                      "mean"={
                          with(Data,
                               tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                                      mean, na.rm=TRUE))
                      },
                      "m�diane"=,
                      "median"={
                           with(Data,
                               tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                                      median, na.rm=TRUE))
                      })

    ## Calcul des �carts types (pour IC param�triques) :
    if (is.element(getOption("P.barplotStat"), c("mean", "moyenne")))
    {
        SD <- with(Data,
                   tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                          sd, na.rm=TRUE))
    }else{}
    ## ... ou des quantiles :
    if (is.element(getOption("P.barplotStat"), c("median", "m�diane")))
    {
        ## Lower:
        quantL <- with(Data,
                         tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                                quantile, probs=c(0.25), na.rm=TRUE))
        ## Higher:
        quantH <- with(Data,
                         tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                                quantile, probs=c(0.75), na.rm=TRUE))
    }else{}

    ## Nombre d'observation par croisement de facteur :
    N <- with(Data,
              tapply(eval(parse(text=metrique)), lapply(listFact, function(y)eval(parse(text=y))),
                     function(x)
                 {
                     sum( ! is.na(x))
                 }))

    ## Intervalle de confiance :
    CIplus <- switch(getOption("P.barplotStat"),
                     "moyenne"=,
                     "mean"={
                          SD * qt(0.975, df=N-1) / sqrt(N)
                     },
                     "m�diane"=,
                     "median"={
                          quantH - heights
                     })
    CIminus <- switch(getOption("P.barplotStat"),
                      "moyenne"=,
                      "mean"={
                          SD * qt(0.975, df=N-1) / sqrt(N)
                      },
                      "m�diane"=,
                      "median"={
                           heights - quantL
                      })

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
              tmp2 <- ifelse((tmp <- lineInchConvert.f()$H * cex * unlist(par("lheight")) *
                                      (ifelse(isTRUE(getOption("P.graphPaper")), 1.4, 2.4)
                                       + 0.4 + 0.9) + # marge# suppl�mentaire.
                          max(strDimRotation.f(as.graphicsAnnot(pretty(range(heights, na.rm=TRUE))),
                                               srt=0,
                                               unit="inches",
                                               cex=cex)$width, na.rm=TRUE)) > 0.7 * unlist(par("pin"))[1],
                             0.7 * unlist(par("pin"))[1],
                             tmp),
              ## Marge sup�rieure augment�e s'il y a un titre :
              ifelse(isTRUE(getOption("P.graphPaper")) || (! isTRUE(getOption("P.title"))),
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


    ## Suppression des valeurs infinies (plante ylims les graphiques) :
    tmpHeights <- replace(heights, is.infinite(heights), NA)
    tmpCIplus <- replace(CIplus, is.infinite(CIplus), NA)

    ylims <- c(0,
               1.13 * max(tmpHeights +
                          replace(tmpCIplus, is.na(tmpCIplus), 0), # �viter d'avoir NA si IC non calculable.
                          na.rm=TRUE)) # max des ordonn�es tenant compte de l'intervalle de confiance
                                        # param�trique.

    barPlotTmp <- barplot(heights,
                          beside=TRUE,
                          main=if ((! isTRUE(getOption("P.graphPaper"))) && isTRUE(getOption("P.title"))){main}else{NULL},
                          xlab="",
                          ylim=ylims,
                          las=1,
                          col=PAMPAcolors.f(n=nrow(heights)),
                          cex.lab=cex,
                          cex.axis=cex,
                          legend.text=ifelse(length(listFact) > 1, TRUE, FALSE),
                          args.legend=list("x"="topright", "inset"=-0.08, "xpd"=NA,
                                           "title"=Capitalize.f(varNames[listFact[1], "nom"])),
                          ...)

    errbar(x=barPlotTmp, y=heights, yplus=heights + CIplus, yminus=heights - CIminus,
           add=TRUE, pch=NA)

    if (getOption("P.axesLabels"))
    {
        mtext(Capitalize.f(varNames[tail(listFact, 1), "nom"]),
              side=1, line=2.3, cex=cex)


        ## Pr�cision du type de statistique :
        if ( ! isTRUE(getOption("P.graphPaper")))
        {
            mtext(switch(paste(getOption("P.lang"), getOption("P.barplotStat"), sep="-"),
                         "fr-moyenne"=,
                         "fr-mean"={
                             expression((italic("moyenne")~+~italic("intervalle de confiance � 95%")))
                         },
                         "fr-m�diane"=,
                         "fr-median"={
                             expression((italic("m�diane")~+~italic("�cart interquartile")))
                         },
                         "en-moyenne"=,
                         "en-mean"={
                             expression((italic("mean")~+~italic("95% confidence interval")))
                         },
                         "en-m�diane"=,
                         "en-median"={
                             expression((italic("median")~+~italic("interquartile range")))
                         }),
                  side=2, line=par("mgp")[1]-1.1, cex=0.9 * getOption("P.cex"), font=2)
        }else{}
    }else{}

    ## R�sultats :
    return(list(x=barPlotTmp,
                n=N,
                ylims=ylims))
}


########################################################################################################################
WP2barplot.esp.f <- function(metrique,
                             factGraph, factGraphSel,
                             listFact, listFactSel,
                             tableMetrique,
                             dataEnv, baseEnv=.GlobalEnv)
{
    ## Purpose: Produire des barplots g�n�riques par esp�ce en tenant compte
    ##          des options graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factGraph : le facteur de s�paration des graphiques.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ##            dataEnv : environnement de stockage des donn�es.
    ##            baseEnv : environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 23 ao�t 2012, 10:39

    pampaProfilingStart.f()

    ## Nettoyage des facteurs (l'interface de s�lection produit des valeurs vides) :
    listFactSel <- listFactSel[unlist(listFact) != ""]
    listFactSel <- listFactSel[length(listFactSel):1]

    listFact <- listFact[unlist(listFact) != ""]
    listFact <- listFact[length(listFact):1]

    ## Concat�nation
    facteurs <- c(factGraph, unlist(listFact)) # Concat�nation des facteurs

    selections <- c(list(factGraphSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es.

    ## Donn�es pour la s�rie de boxplots :
    tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=facteurs, selections=selections,
                                    dataEnv=dataEnv, tableMetrique=tableMetrique, exclude = NULL)

    ## ## Construction de la formule du boxplot :
    ## exprBP <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" + "))))
    ## [!!!]

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
    ## ###############################################################
    ## Boucle de cr�ation des graphiques (par facteur de s�paration) :
    for (modGraphSel in iFactGraphSel)
    {
        ## Pr�paration des donn�es pour un graphique :
        if (modGraphSel == "")          # ...si pas de facteur de s�paration des graphiques
        {
            tmpDataMod <- tmpData
        }else{                          # ...sinon.
            tmpDataMod <- subset(tmpData, tmpData[ , factGraph] == modGraphSel) # Subset des donn�es pour la modalit�.
        }

        ## Passage au graphique suivant si le nombre d'observations  < au minimum d�fini dans les options.
        if (nrow(tmpDataMod) < getOption("P.MinNbObs"))
        {
            warning("Nombre d'observations pour ", modGraphSel, " < ", getOption("P.MinNbObs"),
                    " : Graphique non cr�� !\n")

            plotted <- FALSE
            next()
        }else{
            plotted <- TRUE
        }

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
                                     type=switch(tableMetrique, # diff�rents types de graphs en fonction de la table de
                                        # donn�es.
                                                 "unitSp"={"espece"},
                                                 "unitSpSz"={"CL_espece"},
                                                 "unit"={"unitobs"},
                                                 "espece"),
                                     typeGraph=paste("barplot", getOption("P.barplotStat"), sep="-")) # moyenne/m�diane !?

        ## graphFile uniquement si nouveau fichier :
        if (!is.null(graphFileTmp)) graphFile <- graphFileTmp

        par(mar=c(9, 5, 8, 1), mgp=c(3.5, 1, 0)) # param�tres graphiques.

        ## Titre (d'apr�s les m�triques, modalit� du facteur de s�paration et facteurs de regroupement) :

        mainTitle <- graphTitle.f(metrique=metrique,
                                  modGraphSel=modGraphSel, factGraph=factGraph,
                                  listFact=listFact,
                                  type=switch(tableMetrique, # diff�rents types de graphs en fonction de la table de
                                        # donn�es.
                                              "unitSp"={"espece"},
                                              "unitSpSz"={"CL_espece"},
                                              "espece"))

        ## Label axe y :
        ylab <- ifelse(getOption("P.axesLabels"),
                       parse(text=paste("'", Capitalize.f(varNames[metrique, "nom"]), "'",
                             ifelse(varNames[metrique, "unite"] != "",
                                    paste("~~(", varNames[metrique, "unite"], ")", sep=""),
                                    ""),
                             sep="")),
                       "")

        ## Barplot !
        tmpBaP <- barplotPAMPA.f(metrique=metrique, listFact=listFact, Data=tmpDataMod,
                                 main=mainTitle, ylab=ylab)


        ## #################### Informations suppl�mentaires sur les graphiques ####################

        ## Affichage des warnings (petits effectifs) :
        if (isTRUE(getOption("P.warnings")))
        {
            ## Avertissement pour les petits effectifs :
            pointsSmallSample.f(objBaP=tmpBaP, nbmin=5)
        }else{}

        ## Nombres d'observations :
        if (getOption("P.NbObs"))
        {
            nbObs <- tmpBaP$n # Retourn� par la fonction 'barplot'

            ## Nombres sur l'axe sup�rieur :
            axis(3, as.vector(nbObs), at=as.vector(tmpBaP$x),
                 col.ticks=getOption("P.NbObsCol"), col.axis = getOption("P.NbObsCol"),
                 lty = 2, lwd = 0.5,
                 mgp=c(2, 0.5, 0))

            legend("topleft", "Nombre d'enregistrements par barre",
                   cex =0.9, col=getOption("P.NbObsCol"), text.col=getOption("P.NbObsCol"), merge=FALSE)
        }else{}

        ## ###################################################
        ## Fermeture de graphiques et sauvegarde de fichiers :

        ## On ferme les p�riph�riques PNG en mode fichier individuel :
        if (isTRUE(getOption("P.graphPNG")))
        {
            if ((! getOption("P.plusieursGraphPage") || length(iFactGraphSel) <= 1) && plotted)
            {
                dev.off()

                ## Sauvegarde des donn�es :
                if (getOption("P.saveData"))
                {
                    writeData.f(filename=graphFile, Data=tmpData,
                                cols=NULL)
                }else{}

                ## Sauvegarde des statistiques :
                if (getOption("P.saveStats"))
                {
                    infoStats.f(filename=graphFile, Data=tmpData, agregLevel="species", type="graph",
                                metrique=metrique, factGraph=factGraph, factGraphSel=modGraphSel,
                                listFact=rev(listFact), listFactSel=rev(listFactSel), # On les remets dans un ordre
                                        # intuitif.
                                dataEnv=dataEnv, baseEnv=baseEnv)
                }else{}
            }
        }else{
            ## Sauvegarde en wmf si pertinent et souhait� :
            if (( ! getOption("P.plusieursGraphPage") || length(iFactGraphSel) <= 1) &&
                plotted && ! getOption("P.graphPDF"))
            {
                if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")))
                {
                    savePlot(graphFile, type="wmf", device=dev.cur())
                }else{}

                ## Sauvegarde des donn�es :
                if (getOption("P.saveData"))
                {
                    writeData.f(filename=graphFile, Data=tmpData,
                                cols=NULL)
                }else{}

                ## Sauvegarde des statistiques :
                if (getOption("P.saveStats"))
                {
                    infoStats.f(filename=graphFile, Data=tmpData, agregLevel="species", type="graph",
                                metrique=metrique, factGraph=factGraph, factGraphSel=modGraphSel,
                                listFact=rev(listFact), listFactSel=rev(listFactSel), # On les remets dans un ordre
                                        # intuitif.
                                dataEnv=dataEnv, baseEnv=baseEnv)
                }else{}
            }else{}
        }

    }  ## Fin de boucle graphique.

    ## On ferme les p�riph�riques PDF ou PNG restants :
    if (getOption("P.graphPDF") ||
        (isTRUE(getOption("P.graphPNG")) && getOption("P.plusieursGraphPage") && length(iFactGraphSel) > 1)
        && plotted)
    {
        dev.off()

        ## Sauvegarde des donn�es :
        if (getOption("P.saveData"))
        {
            writeData.f(filename=sub("\\%03d", "00X", graphFile),
                        Data=DataBackup, cols=NULL)
        }else{}

        ## Sauvegarde des statistiques :
        if (getOption("P.saveStats"))
        {
            infoStats.f(filename=sub("\\%03d", "00X", graphFile), Data=DataBackup,
                        agregLevel="species", type="graph",
                        metrique=metrique, factGraph=factGraph, factGraphSel=factGraphSel,
                        listFact=rev(listFact), listFactSel=rev(listFactSel), # On les remets dans un ordre intuitif.
                        dataEnv=dataEnv, baseEnv=baseEnv)
        }else{}

        ## Inclusion des fontes dans le pdf si souhait� :
        if (getOption("P.graphPDF") && getOption("P.pdfEmbedFonts"))
        {
            i <- 1

            ## On parcours tous les fichiers qui correspondent au motif :
            while (is.element(basename(tmpFile <- sub("\\%03d", formatC(i, width=3, flag="0"), graphFile)),
                              dir(dirname(graphFile))))
            {
                tryCatch(embedFonts(file=tmpFile),
                         error=function(e)
                     {
                         warning("Impossible d'inclure les fontes dans le PDF !")
                     })

                i <- i + 1
            }
        }else{}
    }else{}

    ## Sauvegarde en wmf + donn�es restants si pertinent et souhait� :
    if ( ! (getOption("P.graphPNG") || getOption("P.graphPDF")) && # Si pas d'autre sortie fichier.
        getOption("P.plusieursGraphPage") && length(iFactGraphSel) > 1
        && plotted)
    {
        if (.Platform$OS.type == "windows" && isTRUE(getOption("P.graphWMF")))
        {
            savePlot(graphFile, type="wmf", device=dev.cur())
        }else{}

        ## Sauvegarde des donn�es :
        if (getOption("P.saveData"))
        {
            writeData.f(filename=sub("\\%03d", "00X", graphFile),
                        Data=DataBackup, cols=NULL)
        }else{}

        ## Sauvegarde des statistiques :
        if (getOption("P.saveStats"))
        {
            infoStats.f(filename=sub("\\%03d", "00X", graphFile), Data=DataBackup,
                        agregLevel="species", type="graph",
                        metrique=metrique, factGraph=factGraph, factGraphSel=factGraphSel,
                        listFact=rev(listFact), listFactSel=rev(listFactSel), # On les remets dans un ordre intuitif.
                        dataEnv=dataEnv, baseEnv=baseEnv)
        }else{}
    }else{}

    pampaProfilingEnd.f()
}







### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
