#-*- coding: latin-1 -*-

### File: arbres_regression_esp_generiques.R
### Time-stamp: <2011-05-17 14:50:40 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions de cr�ation de boxplots pour les m�triques agr�g�es / esp�ce / unit� d'observation.
####################################################################################################

########################################################################################################################
print.rpart.fr <- function (x, minlength = 0, spaces = 2, cp, digits = getOption("digits"),
                            ...)
{
    ## Purpose:Francisation de la fonction print.rpart() du package
    ##          "mvpart".
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de mvpart::print.rpart()
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 mai 2011, 15:17

    if (!inherits(x, "rpart"))
        stop("Not legitimate rpart object")
    if (!is.null(x$frame$splits))
        x <- rpconvert(x)
    if (!missing(cp))
        x <- prune.rpart(x, cp = cp)
    frame <- x$frame
    ylevel <- attr(x, "ylevels")
    node <- as.numeric(row.names(frame))
    depth <- tree.depth(node)
    indent <- paste(rep(" ", spaces * 32), collapse = "")
    if (length(node) > 1)
    {
        indent <- substring(indent, 1, spaces * seq(depth))
        indent <- paste(c("", indent[depth]), format(node), ")",
                        sep = "")
    }else{
        indent <- paste(format(node), ")", sep = "")
    }

    tfun <- (x$functions)$print
    if (!is.null(tfun)) {
        if (is.null(frame$yval2))
            yval <- tfun(frame$yval, ylevel, digits)
        else yval <- tfun(frame$yval2, ylevel, digits)
    }
    else yval <- format(signif(frame$yval, digits = digits))
    term <- rep(" ", length(depth))
    term[frame$var == "<leaf>"] <- "*"
    ## browser()
    z <- labels(x, digits = digits, minlength = minlength, ...)
    n <- frame$n
    z <- paste(indent, z, n, format(signif(frame$dev, digits = digits)),
               yval, term, sep="\t")
    omit <- x$na.action
    if (length(omit))
        cat("n=", n[1], " (", naprint(omit), ")\n\n", sep = "")
    else cat("n=", n[1], "\n\n")
    if (x$method == "class")
        cat(" noeud), partition, n, perte, yval, (yprob)\n")
    else cat(" noeud), partition, n, d�viance, yval\n")
    cat("\t\t\t\t* indique un noeud terminal\n\n")
    cat(z, sep = "\n")
    return(invisible(x))
}

########################################################################################################################
summary.rpart.fr <- function (object, cp = 0, digits = getOption("digits"), file,
                              ...)
{
    ## Purpose: Francisation de la fonction summary.rpart() du package
    ##          "mvpart".
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de summary.rpart()
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 mai 2011, 13:55

    if (!inherits(object, "rpart"))
    {
        stop("Not legitimate rpart object")
    }else{}

    if (!is.null(object$frame$splits))
    {
        x <- rpconvert(object)
    }else{
        x <- object
    }

    if (!missing(file))
    {
        sink(file)
        on.exit(sink())
    }else{}

    if (!is.null(x$call))
    {
        cat("Appel :\n")
        dput(x$call)
    }else{}

    omit <- x$na.action
    n <- x$frame$n
    if (length(omit))
    {
        cat("  n=", n[1], " (", naprint(omit), ")\n\n", sep = "")
    }else{
        cat("  n=", n[1], "\n\n")
    }

    print(x$cptable, digits = digits)
    ff <- x$frame
    ylevel <- attr(x, "ylevels")
    id <- as.integer(row.names(ff))
    parent.id <- ifelse(id == 1, 1, floor(id/2))
    parent.cp <- ff$complexity[match(parent.id, id)]
    rows <- (1:length(id))[parent.cp > cp]

    if (length(rows) > 0)
    {
        rows <- rows[order(id[rows])]
    }else{
        rows <- 1
    }

    is.leaf <- (ff$var == "<leaf>")
    index <- cumsum(c(1, ff$ncompete + ff$nsurrogate + 1 * (!is.leaf)))

    if (!all(is.leaf))
    {
        sname <- dimnames(x$splits)[[1]]
        cuts <- vector(mode = "character", length = nrow(x$splits))
        temp <- x$splits[, 2]
        for (i in 1:length(cuts))
        {
            if (temp[i] == -1)
            {
                cuts[i] <- paste("<", format(signif(x$splits[i, 4],
                                                    digits = digits)))
            }else{
                if (temp[i] == 1)
                {
                    cuts[i] <- paste("<", format(signif(x$splits[i, 4],
                                                        digits = digits)))
                }else{
                    cuts[i] <- paste("partitionn� en ",
                                     paste(c("G", "-", "D")[x$csplit[x$splits[i, 4], 1:temp[i]]],
                                           collapse = "", sep = ""),
                                     collapse = "")
                }
            }
        }

        if (any(temp < 2))
        {
            cuts[temp < 2] <- format(cuts[temp < 2], justify = "left")
        }else{}

        cuts <- paste(cuts, ifelse(temp >= 2,
                                   ",",
                                   ifelse(temp == 1,
                                          " vers la droite,",
                                          " vers la gauche, ")),
                      sep = "")
    }

    if (is.null(ff$yval2))
    {
        tprint <- x$functions$summary(ff$yval[rows], ff$dev[rows],
                                      ff$wt[rows], ylevel, digits)
    }else{
        tprint <- x$functions$summary(ff$yval2[rows, ], ff$dev[rows],
                                      ff$wt[rows], ylevel, digits)
    }

    for (ii in 1:length(rows))
    {
        i <- rows[ii]
        nn <- ff$n[i]
        twt <- ff$wt[i]
        cat("\nNoeud #", id[i], ": ", nn, " observations",
            sep = "")
        if (ff$complexity[i] < cp || is.leaf[i])
        {
            cat("\n")
        }else{
            cat(",    param de complexit�=", format(signif(ff$complexity[i],
                                                           digits)), "\n", sep = "")
        }

        cat(tprint[ii], "\n")
        if (ff$complexity[i] > cp && !is.leaf[i])
        {
            sons <- 2 * id[i] + c(0, 1)
            sons.n <- ff$n[match(sons, id)]
            cat("  fils Gauche=", sons[1], " (", sons.n[1], " obs)",
                " fils Droit=", sons[2], " (", sons.n[2], " obs)",
                sep = "")
            j <- nn - (sons.n[1] + sons.n[2])
            if (j > 1)
            {
                cat(", ", j, " observations restantes\n", sep = "")
            }else{
                if (j == 1)
                {
                    cat(", 1 observation restante\n")
                }else{
                    cat("\n")
                }
            }
            cat("  Partition initiale :\n")
            j <- seq(index[i], length = 1 + ff$ncompete[i])
            if (all(nchar(cuts[j]) < 25))
            {
                temp <- format(cuts[j], justify = "left")
            }else{
                temp <- cuts[j]
            }

            cat(paste("      ", format(sname[j], justify = "left"),
                " ", temp, " improve=", format(signif(x$splits[j,
                  3], digits)), ", (", nn - x$splits[j, 1], " manquant)",
                sep = ""), sep = "\n")

            if (ff$nsurrogate[i] > 0)
            {
                cat("  Partition alternative :\n")
                j <- seq(1 + index[i] + ff$ncompete[i], length = ff$nsurrogate[i])
                agree <- x$splits[j, 3]
                if (all(nchar(cuts[j]) < 25))
                {
                    temp <- format(cuts[j], justify = "left")
                }else{
                    temp <- cuts[j]
                }

                if (ncol(x$splits) == 5)
                {
                  adj <- x$splits[j, 5]
                  cat(paste("      ", format(sname[j], justify = "left"),
                            " ", temp, " agree=", format(round(agree, 3)),
                            ", adj=", format(round(adj, 3)), ", (",
                            x$splits[j, 1], " split)", sep = ""), sep = "\n")
                }else{
                  cat(paste("      ", format(sname[j], justify = "left"),
                            " ", temp, " agree=", format(round(agree, 3)),
                            ", (", x$splits[j, 1], " split)",
                            sep = ""), sep = "\n")
                }
            }
        }
    }

    cat("\n")
    invisible(x)
}

########################################################################################################################
text.rpart.new <- function (x, splits = TRUE, which = 4, label = "yval", FUN = text,
                            all.leaves = FALSE, pretty = NULL, digits = getOption("digits") -
                            2, tadj = 0.65, stats = TRUE, use.n = FALSE, bars = TRUE,
                            legend = FALSE, xadj = 1, yadj = 1, bord = FALSE, big.pts = FALSE,
                            ...)
{
    ## Purpose: Remplace la fonction text.rpart() du package "mvpart"
    ##          (correction de l'alignement vertical)
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de mvpart::text.rpart
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 mai 2011, 11:17

    if (!inherits(x, "rpart"))
    {
        stop("Not legitimate rpart")
    }else{}

    if (!is.null(x$frame$splits))
    {
        x <- rpconvert(x)
    }else{}

    frame <- x$frame
    col <- names(frame)
    method <- x$method
    ylevels <- attr(x, "ylevels")

    if (!is.null(ylevels <- attr(x, "ylevels")))
    {
        col <- c(col, ylevels)
    }else{}

    if (is.na(match(label, col)))
    {
        stop("Label must be a column label of the frame component of the tree")
    }else{}

    cxy <- par("cxy")
    if (!is.null(srt <- list(...)$srt) && srt == 90)
    {
        cxy <- rev(cxy)
    }else{}

    xy <- rpartco(x)
    node <- as.numeric(row.names(x$frame))
    is.left <- (node%%2 == 0)
    node.left <- node[is.left]
    parent <- match(node.left/2, node)
    bars <- bars & is.matrix(frame$yval2)
    text.adj <- ifelse(bars, yadj * diff(range(xy$y))/12, 0)

    if (splits)
    {
        left.child <- match(2 * node, node)
        right.child <- match(node * 2 + 1, node)
        rows <- labels(x, pretty = pretty)
        if (which == 1)
        {
            FUN(xy$x, xy$y + tadj * cxy[2], rows[left.child],
                ...)
        }else{
            if (which == 2 | which == 4)
                FUN(xy$x, xy$y + tadj * cxy[2], rows[left.child],
                    pos = 2, ...)
            if (which == 3 | which == 4)
                FUN(xy$x, xy$y + tadj * cxy[2], rows[right.child],
                    pos = 4, ...)
        }
    }else{}

    leaves <- if (all.leaves)
    {
        rep(TRUE, nrow(frame))
    }else{
        frame$var == "<leaf>"
    }
    if (stats)
    {
        if (is.null(frame$yval2))
        {
            stat <- x$functions$text(yval = frame$yval[leaves],
                dev = frame$dev[leaves], wt = frame$wt[leaves],
                ylevel = ylevels, digits = digits, n = frame$n[leaves],
                use.n = use.n)
        }else{
            stat <- x$functions$text(yval = frame$yval2[leaves,
                                     ], dev = frame$dev[leaves], wt = frame$wt[leaves],
                                     ylevel = ylevels, digits = digits, n = frame$n[leaves],
                                     use.n = use.n)
        }

        ## Ajout d'une constante lorsque les effectifs sont �galement ajout�s (labels sur deux lignes) :
        FUN(xy$x[leaves], xy$y[leaves] - ifelse(use.n, tadj + 0.3, tadj) * cxy[2] - text.adj,
            stat, adj = 0.5, ...)
    }

    if (bars)
    {
        bar.vals <- x$functions$bar(yval2 = frame$yval2)
        sub.barplot(xy$x, xy$y, bar.vals, leaves, xadj = xadj,
                    yadj = yadj, bord = bord, line = TRUE, col = c("lightblue",
                                                           "blue", "darkblue"))
        rx <- range(xy$x)
        ry <- range(xy$y)
        if (!is.null(ylevels))
        {
            bar.labs <- ylevels
        }else{
            bar.labs <- dimnames(x$y)[[2]]
        }
        if (legend & !is.null(bar.labs))
        {
            legend(min(xy$x) - 0.1 * rx, max(xy$y) + 0.05 * ry,
                   bar.labs, col = c("lightblue", "blue", "darkblue"),
                   pch = 15, bty = "n", ...)
        }else{}
    }
    if (big.pts)
    {
        points(xy$x[leaves], xy$y[leaves], pch = 16, cex = 3 *
               par()$cex, col = 2:(sum(leaves) + 1))
    }else{}

    invisible()
}

########################################################################################################################
resFileMRT.f <- function(metrique, factAna, modSel, listFact,
                         prefix=NULL, ext="txt", sufixe=NULL, type="espece")
{
    ## Purpose: D�finit les noms du fichiers pour les r�sultats des arbres
    ##          de r�gression multivari�e.
    ##          L'extension et un prefixe peuvent �tres pr�cis�s,
    ##          mais par d�faut, c'est le fichier de sorties texte qui est
    ##          cr��.
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : nom de la m�trique analys�e.
    ##            factAna : nom du facteur de s�prataion des analyses.
    ##            modSel : modalit� de factAna s�lectionn�e.
    ##            listFact : vecteur des noms de facteurs de l'analyse.
    ##            prefix : pr�fixe du nom de fichier.
    ##            sufixe : un sufixe pour le nom de fichier.
    ##            ext : extension du fichier.
    ##            type : type de mod�le (traitement conditionnel).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  8 sept. 2010, 15:48

    ## si pas de pr�fix fourni :
    if (is.null(prefix))
    {
        prefix <- "MRT"
    }else{}

    ## Nom de fichier :
    filename <- paste(nameWorkspace, "/FichiersSortie/", prefix, "_",
                      ## M�trique analys�e :
                      metrique, "_",
                      ## si facteur de s�paration des analyses :
                      "Agr-",
                      switch(type,
                             "espece"="espece+unitobs_",
                             "CL_espece"="CL+espece+unitobs_",
                             "unitobs"="unitobs_",
                             "CL_unitobs"="CL+unitobs_",
                             ""),
                      switch(type,
                             "espece"={
                                 ifelse(factAna == "",
                                        "",
                                        paste(factAna, "(",
                                              ifelse(modSel[1] != "", modSel, "toutes"),
                                              ")_", sep=""))
                             },
                             "CL_espece"={
                                 ifelse(factAna == "",
                                        "",
                                        paste(factAna, "(", ifelse(modSel[1] != "",
                                                                   paste(modSel, collapse="+"),
                                                                   "toutes"), ")_", sep=""))
                             },
                             "unitobs"={
                                 ifelse(factAna == "",
                                        "(toutes esp�ces)_",
                                        paste(factAna, "(", ifelse(modSel[1] != "",
                                                                   paste(modSel, collapse="+"),
                                                                   "toutes"), ")_", sep=""))
                             },
                             "CL_unitobs"={
                                 ifelse(factAna == "",
                                        "(toutes esp�ces)_",
                                        paste(factAna, "(", ifelse(modSel[1] != "",
                                                                   paste(modSel, collapse="+"),
                                                                   "toutes"), ")_", sep=""))
                             },
                             ""),
                      ## liste des facteurs de l'analyse
                      paste(listFact, collapse="-"),
                      ## sufixe :
                      ifelse(is.null(sufixe), "", paste("_", sufixe, sep="")),
                      ## Extension du fichier :
                      ".", gsub("^\\.([^.]*)", "\\1", ext[1], perl=TRUE), # nettoyage de l'extension si besoin.
                      sep="")

    ## Ouverture de la connection (retourne l'objet de type 'connection') si pas un fichier avec extension graphique,
    ## retourne le nom de fichier sinon :
    if (!is.element(gsub("^\\.([^.]*)", "\\1", ext[1], perl=TRUE),
                    c("pdf", "PDF", "png", "PNG", "jpg", "JPG")))
    {
        return(resFile <- file(filename, open="w"))
    }else{
        return(filename)
    }
}

########################################################################################################################
sortiesMRT.f <- function(objMRT, formule, metrique, factAna, modSel, listFact, Data,
                         sufixe=NULL, type="espece")
{
    ## Purpose: Formater les r�sultats des MRT et les �crire dans un fichier
    ## ----------------------------------------------------------------------
    ## Arguments: objMRT : un objet de classe 'rpart'.
    ##            formule : la formule utilis�e (pas lisible dans le call).
    ##            metrique : la m�trique choisie.
    ##            factAna : le facteur de s�paration des analyses.
    ##            modSel : la modalit� courante.
    ##            listFact : liste du (des) facteur(s) de regroupement.
    ##            Data : les donn�es utilis�es.
    ##            sufixe : un sufixe pour le nom de fichier.
    ##            type : type d'analyse, pour traitement conditionnel des
    ##                   titres et noms de fichiers.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 25 ao�t 2010, 16:19

    ## longueur des lignes pour les sorties textes :
    oOpt <- options()
    on.exit(options(oOpt))

    options(width=120)

    ## Formule de mod�le lisible:
    objMRT$call$formula <- formule
    formule <<- formule
    resMRT <<- objMRT

    ## Chemin et nom de fichier :
    resFile <- resFileMRT.f(metrique=metrique, factAna=factAna,
                            modSel=modSel, listFact=listFact,
                            sufixe=sufixe, type=type)
    on.exit(close(resFile), add=TRUE)

    ## �criture des r�sultats :

    cat("Appel :\n", file=resFile, append=FALSE)
    dput(objMRT$call, file=resFile)

    cat("\n\n----------------------------------------------------------------------------------------------------",
        file=resFile, append=TRUE)

    cat("\nR�sultat g�n�ral :\n\n", file=resFile, append=TRUE)

    capture.output(print.rpart.fr(objMRT), file=resFile, append=TRUE)

    cat("\n\n----------------------------------------------------------------------------------------------------",
        file=resFile, append=TRUE)

    cat("\nD�tails :\n\n", file=resFile, append=TRUE)

    capture.output(summary.rpart.fr(objMRT), file=resFile, append=TRUE)
}

########################################################################################################################
WP2MRT.esp.f <- function(metrique, factGraph, factGraphSel, listFact, listFactSel, tableMetrique)
{
    ## Purpose: Produire des arbres de r�gression multivari�e en tenant
    ##          compte des options graphiques + Sorties texte.
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factGraph : le facteur de s�paration des graphiques.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 11 mai 2011, 10:09

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
                                    tableMetrique=tableMetrique, exclude = NULL)

    ## Formule du boxplot
    exprMRT <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" + "))))

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
        openDevice.f(noGraph=which(modGraphSel == iFactGraphSel),
                     metrique=metrique,
                     factGraph=factGraph,
                     modSel=if (getOption("P.plusieursGraphPage"))
                 {
                     iFactGraphSel      # toutes les modalit�s.
                 }else{
                     modGraphSel        # la modalit� courante uniquement.
                 },
                     listFact=listFact,
                     type=switch(tableMetrique, # diff�rents types de graphs en fonction de la table de
                                        # donn�es.
                                 "listespunit"={"espece"},
                                 "unitespta"={"CL_espece"},
                                 "espece"),
                     typeGraph="MRT")

        par(mar=c(2, 5, 8, 5), mgp=c(3.5, 1, 0)) # param�tres graphiques.

        ## Titre (d'apr�s les m�triques, modalit� du facteur de s�paration et facteurs de regroupement) :
        mainTitle <- graphTitle.f(metrique=metrique,
                                  modGraphSel=modGraphSel, factGraph=factGraph,
                                  listFact=listFact,
                                  type=switch(tableMetrique, # diff�rents types de graphs en fonction de la table de
                                        # donn�es.
                                              "listespunit"={"espece"},
                                              "unitespta"={"CL_espece"},
                                              "TableBiodiv"={"biodiv"},
                                              "espece"),
                                  model="Arbre de r�gression multivari�e")

        ## Boxplot !
        tmpMRT <- rpart(exprMRT, data=tmpDataMod)

        plot(tmpMRT, main=mainTitle)
        text(tmpMRT, use.n=TRUE, pretty=1, all=TRUE, xpd=NA, bars=TRUE)

        plot(tmpMRT, main=mainTitle)
        text.rpart.new(tmpMRT, use.n=TRUE, pretty=0, all=TRUE, xpd=NA)

        ## �criture des r�sultats format�s dans un fichier :
        tryCatch(sortiesMRT.f(objMRT=tmpMRT, formule=exprMRT,
                              metrique=metrique,
                              factAna=factGraph, modSel=modGraphSel, listFact=listFact,
                              Data=tmpDataMod,
                              type=ifelse(tableMetrique == "unitespta",
                                          "CL_espece",
                                          "espece")),
                 error=errorLog.f)

        ## On ferme les p�riph�riques PNG en mode fichier individuel :
        if (isTRUE(getOption("P.graphPNG")) &&
            (! getOption("P.plusieursGraphPage") || length(iFactGraphSel) <= 1))
        {
            dev.off()
        }else{}

    }

    ## On ferme les p�riph�riques PDF ou PNG restants :
    if (getOption("P.graphPDF") ||
        (isTRUE(getOption("P.graphPNG")) &&
         getOption("P.plusieursGraphPage") &&
         length(iFactGraphSel) > 1))
    {
        dev.off()
    }else{}

    pampaProfilingEnd.f()
}








### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
