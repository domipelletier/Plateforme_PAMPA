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

### File: Boxplot_generique_calc.R
### Time-stamp: <2012-01-19 17:11:27 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions de traitement des donn�es et des graphiques pour la cr�ation de boxplots "� la carte".
####################################################################################################

########################################################################################################################
sepBoxplot.f <- function(terms, data)
{
    ## Purpose: Calculer les positions des s�parateurs (facteur de premier
    ##          niveau).
    ## ----------------------------------------------------------------------
    ## Arguments: terms : les termes de l'expression (facteurs ; cha�ne de
    ##                    caract�res)
    ##            data : le jeu de donn�es (data.frame)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 10 ao�t 2010, 14:11

    if (length(terms) < 2)
    {
    }else{
        n <- length(terms)
        ## Positions :
        pos <- seq(from=0.5,
                   by=prod(sapply(data[ , terms[1:(n-1)], drop=FALSE],
                                  function(x){length(unique(na.omit(x)))})),
                   length.out=length(unique(na.omit(data[ , terms[n]]))) + 1)
        ## Lignes verticales :
        abline(v=pos,
               col=rep(getOption("P.sepGroupesCol"), length(pos)),
               lty=rep(1, length(pos)))
    }
}


########################################################################################################################
colBoxplot.f <- function(terms, data)
{
    ## Purpose: D�finitions des couleurs pour le facteur de second
    ##          niveau
    ## ----------------------------------------------------------------------
    ## Arguments: terms : les termes de l'expression (facteurs ; cha�ne de
    ##                    caract�res)
    ##            data : le jeu de donn�es (data.frame)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 10 ao�t 2010, 15:05

    if (length(terms) < 2)
    {
        return(NULL)
    }else{
        n <- length(terms)

        ## D�finition des couleurs :
        col <- rep(PAMPAcolors.f(n=length(unique(na.omit(data[ , terms[n - 1]])))),
                   each=ifelse(n == 2,
                               1,            # Pas de facteur imbriqu�.
                               prod(sapply(data[ , terms[1:(n-2)], drop=FALSE], # nombres de niveaux du (des) facteur(s)
                                           function(x){length(unique(na.omit(x)))})))) # imbriqu�s.
        return(col)
    }
}


########################################################################################################################
legendBoxplot.f <- function(terms, data)
{
    ## Purpose: Afficher la l�gende des couleurs (facteur de second
    ##          niveau)
    ## ----------------------------------------------------------------------
    ## Arguments: terms : les termes de l'expression (facteurs ; cha�ne de
    ##                    caract�res)
    ##            data : le jeu de donn�es (data.frame)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 10 ao�t 2010, 16:42
    if (length(terms) < 2)
    {
    }else{
        n <- length(terms)

        ## Couleurs :
        colors <- unique(colBoxplot.f(terms=terms, data=data))

        ## Noms :
        names <- levels(as.factor(data[ , terms[n - 1]]))

        ## L�gende :
        legend("topright", names, col=colors,
               pch = 15, pt.cex=1.2,
               cex =0.9, title=varNames[terms[n - 1], "nom"])
    }
}

########################################################################################################################
graphTitle.f <- function(metrique, modGraphSel, factGraph, listFact, model=NULL, type="espece")
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 oct. 2010, 15:44

    return(paste(ifelse(is.null(model),
                        "valeurs de ",
                        paste(model, " pour ", varNames[metrique, "article"], sep="")),
                 varNames[metrique, "nom"],
                 ifelse(is.element(type, c("espece", "unitobs", "CL_espece", "unitobs(CL)")),
                        paste(" agr�g�",
                              switch(varNames[metrique, "genre"], # Accord de "agr�g�".
                                     f="e", fp="es", mp="s", ""), sep=""),
                        ""),
                 switch(type,
                        "espece"=" par esp�ce et unit� d'observation",
                        "CL_espece"=" par classe de tailles, esp�ce et unit� d'observation",
                        "unitobs"=" par unit� d'observation",
                        "unitobs(CL)"=" par unit� d'observation",
                        "CL_unitobs"=" par classe de tailles et unit� d'observation",
                        "biodiv"=" par unit� d'observation",
                        ""),
                 switch(type,
                        "espece"={
                            ifelse(modGraphSel == "", # Facteur de s�paration uniquement si d�fini.
                                   "",
                                   paste("\npour le champ '", factGraph, "' = ", modGraphSel, sep=""))
                        },
                        "CL_espece"={
                            ifelse(modGraphSel == "", # Facteur de s�paration uniquement si d�fini.
                                   "",
                                   paste("\npour le champ '", factGraph, "' = ", modGraphSel, sep=""))
                        },
                        "unitobs"={
                            ifelse(modGraphSel[1] == "", # Facteur de s�paration uniquement si d�fini.
                                   "\npour toutes les esp�ces",
                                   paste("\npour les esp�ces correspondant � '", factGraph, "' = (",
                                         paste(modGraphSel, collapse=", "), ")", sep=""))
                        },
                        "unitobs(CL)"={
                            ifelse(modGraphSel[1] == "", # Facteur de s�paration uniquement si d�fini.
                                   "\npour toutes les classes de taille",
                                   paste("\npour les classes de tailles correspondant � '", factGraph, "' = (",
                                         paste(modGraphSel, collapse=", "), ")", sep=""))
                        },
                        "CL_unitobs"={
                            ifelse(modGraphSel[1] == "", # Facteur de s�paration uniquement si d�fini.
                                   "\npour toutes les esp�ces",
                                   paste("\npour les esp�ces correspondant � '", factGraph, "' = (",
                                         paste(modGraphSel, collapse=", "), ")", sep=""))
                        },
                        "biodiv"={
                            ifelse(modGraphSel[1] == "", # Facteur de s�paration uniquement si d�fini.
                                   "",
                                   paste("\npour les unit�s d'observation correspondant � '", factGraph, "' = (",
                                         paste(modGraphSel, collapse=", "), ")", sep=""))
                        },
                        ""),
                 "\n selon ",
                 paste(sapply(listFact[length(listFact):1],
                              function(x)paste(varNames[x, c("article", "nom")], collapse="")),
                       collapse=" et "),
                 "\n", sep=""))
}


########################################################################################################################
plotValMoyennes.f <- function(moyennes, objBP,
                              adj=c(0.5, -0.4), cex=0.9,...)
{
    ## Purpose: Affichage des moyennes sur les boxplots en �vitant le
    ##          recouvrement avec les lignes des bo�tes.
    ## ----------------------------------------------------------------------
    ## Arguments: moyennes : les valeurs de moyennes.
    ##            objBP : un objet retourn� par la fonction "boxplot".
    ##            adj : justification.
    ##            cex : taille de la police.
    ##            ... : param�tres optionnels suppl�mentaires pass�s � text()
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 oct. 2010, 15:43

    ## Propri�t�s des bo�tes � moustaches + points hors bo�tes + maximum du graphique :
    pointsOut <- as.list(tapply(objBP$out, objBP$group, function(x)x))
    pointsOut[as.character(which(!is.element(seq(length.out=ncol(objBP$stats)),
                                             as.numeric(names(pointsOut)))))] <- NA

    x <- rbind(objBP$stats,
               matrix(sapply(pointsOut,
                             function(x)
                         {
                             c(sort(x, na.last=TRUE),
                               rep(NA, max(sapply(pointsOut, length)) - length(x)))
                         }),
                      ncol=length(pointsOut))[ , order(as.numeric(names(pointsOut))), drop=FALSE],
               if (getOption("P.maxExclu") && getOption("P.GraphPartMax") < 1)
                   {
                       objBP$ylim[2]
                   }else{
                       max(c(objBP$out, objBP$stats), na.rm=TRUE)
                   })

    x[x > objBP$ylim[2] | x < objBP$ylim[1]] <- NA

    x <- apply(x, 2, sort, na.last=TRUE)

    ## Proportions occup�es par les diff�rentes parties des boites � moustaches :
    xprop <- apply(x, 2,
                   function(cln)
               {
                   res <- (tail(cln, -1) - head(cln, -1))/max(cln, na.rm=TRUE)
                   if (all(na.omit(res) <= 0))
                   {
                       res[3] <- 1
                   }else{}

                   return(res)
               })

    ## Ordre de priorit� d�croissante des positions o� �crire :
    ord <- c(3, 4, 2, seq(from=5, to=nrow(xprop)), 1)

    ## Premi�re position (dans l'ordre d�croissant de priorit�) remplissant le crit�re (> 5.5% de la zone graphique) :
    xi <- sapply(seq(length.out=ncol(xprop)), function(i)which(xprop[ord , i] > 0.055)[1])

    ## �criture des valeurs de moyennes sur le graphique :
    text(x=seq_along(xi), y=sapply(seq_along(xi), function(i)x[ord[xi][i], i]),
         labels=as.character(round(moyennes, digits=unlist(options("P.NbDecimal")))),
         col=getOption("P.valMoyenneCol"), adj=adj,
         cex=cex,...)

}

########################################################################################################################
plotPetitsEffectifs.f <- function(objBP, nbmin=20)
{
    ## Purpose: Affichage des warnings sur les graphiques
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 27 oct. 2010, 10:39

    if (any(objBP$n < nbmin & objBP$n > 0, na.rm=TRUE))
    {
        msg <- c(
                 ## Affichage d'avertissement pour  > X% du max retir� :
                 if (getOption("P.maxExclu") &&  getOption("P.GraphPartMax") < 1)
                 {
                     paste("Enregistrements > ", 100 * getOption("P.GraphPartMax"),
                           "% du maximum non affich�s\n", sep="")
                 }else{},
                 paste("petit effectif (< ", nbmin, ")", sep=""))

        ## "L�gende" :
        legend("top",
               msg,
               cex =0.9, text.col="red", merge=FALSE, adj=c(0, 0.2),
               pch=rev(c(24, NA)[seq_along(msg)]),
               col="red3", pt.bg="gold", pt.cex=1.2)


        ## Propri�t�s des bo�tes � moustaches + points hors bo�tes + maximum du graphique :
        pointsOut <- as.list(tapply(objBP$out, objBP$group, function(x)x))
        pointsOut[as.character(which(!is.element(seq(length.out=ncol(objBP$stats)),
                                                 as.numeric(names(pointsOut)))))] <- NA

        x <- rbind(min(c(objBP$out, objBP$stats), na.rm=TRUE),
                   objBP$stats,
                   matrix(sapply(pointsOut,
                                 function(x)
                             {
                                 c(sort(x, na.last=TRUE),
                                   rep(NA, max(sapply(pointsOut, length)) - length(x)))
                             }),
                          ncol=length(pointsOut))[ , order(as.numeric(names(pointsOut))), drop=FALSE],
                   if (getOption("P.maxExclu") && getOption("P.GraphPartMax") < 1)
                   {
                       objBP$ylim[2]
                   }else{
                       max(c(objBP$out, objBP$stats), na.rm=TRUE)
                   })

        x[x > objBP$ylim[2] | x < objBP$ylim[1]] <- NA

        x <- apply(x, 2, sort, na.last=TRUE)

        ## Proportions occup�es par les diff�rentes parties des boites � moustaches :
        xprop <- apply(x, 2, function(cln)(tail(cln, -1) - head(cln, -1))/max(cln, na.rm=TRUE))

        ord <- c(seq(from=nrow(xprop), to=6), 1, 5, 2, 4, 3) # Ordre de priorit� des positions o� �crire.

        ## Premi�re position (ordre d�croissant de priorit�) remplissant le crit�re (> 8% de la zone graphique) :
        xi <- sapply(seq(length.out=ncol(xprop)), function(i){which(xprop[ord , i] > 0.08)[1]})

        idx <- which(objBP$n < nbmin & objBP$n > 0)

        ampli <- max(c(objBP$out, objBP$stats), na.rm=TRUE) - min(c(objBP$out, objBP$stats), na.rm=TRUE)

        invisible(sapply(seq_along(xi)[idx],
                         function(i)
                     {
                         points(x=i,
                                y=x[ifelse(ord[xi][i] == 1, 1, ord[xi][i] + 1), i] +
                                  ifelse(ord[xi][i] == 1, # Ajustement vertical si en bas.
                                         0.04 * ampli,
                                         ifelse(ord[xi][i] == nrow(xprop), #... si tout en haut.
                                                -0.04 * ampli,
                                                -0.04 * ampli)),
                                pch=24, col = "red3", bg = "gold", cex=1.2)

                     }))

    }else{
        ## Affichage d'avertissement pour  > X% du max retir� :
        if (getOption("P.maxExclu"))
        {
            legend("top",
                   paste("Enregistrements > ", 100 * getOption("P.GraphPartMax"),
                         "% du maximum non affich�s\n", sep=""),
                   cex =0.9, col="red", text.col="red", merge=FALSE)
        }else{}
    }
}


########################################################################################################################
WP2boxplot.f <- function(metrique, factGraph, factGraphSel, listFact, listFactSel, tableMetrique, dataEnv,
                         baseEnv=.GlobalEnv)
{
    ## Purpose: Produire les boxplots en tenant compte des options graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factGraph : le facteur de s�paration des graphiques.
    ##            factGraphSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ##            dataEnv : environnement de stockage des donn�es.
    ##            baseEnv : environnement de l'interface principale.
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

    selections <- c(list(factGraphSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es.

    ## Donn�es pour la s�rie de boxplots :
    tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=facteurs, selections=selections,
                                    dataEnv=dataEnv, tableMetrique=tableMetrique, exclude = NULL)

    ## Formule du boxplot
    exprBP <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" + "))))

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
                                     typeGraph="boxplot")

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

        ## Boxplot !
        tmpBP <- boxplotPAMPA.f(exprBP, data=tmpDataMod,
                                main=mainTitle, ylab=ylab)


        ## #################### Informations suppl�mentaires sur les graphiques ####################

        ## S�parateurs de facteur de premier niveau :
        if (getOption("P.sepGroupes"))
        {
            sepBoxplot.f(terms=attr(terms(exprBP), "term.labels"), data=tmpDataMod)
        }

        ## S�parateurs par d�faut :
        abline(v = 0.5+(0:length(tmpBP$names)) , col = "lightgray", lty = "dotted") # S�parations.

        ## L�gende des couleurs (facteur de second niveau) :
        if (getOption("P.legendeCouleurs"))
        {
            legendBoxplot.f(terms=attr(terms(exprBP), "term.labels"), data=tmpDataMod)
        }else{}

        ## Moyennes :
        Moyenne <- as.vector(tapply(X=tmpDataMod[, metrique], # moyenne par groupe.
                                    INDEX=as.list(tmpDataMod[ , attr(terms(exprBP),
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
                 col.ticks=getOption("P.NbObsCol"), col.axis = getOption("P.NbObsCol"),
                 lty = 2, lwd = 0.5,
                 mgp=c(2, 0.5, 0))

            legend("topleft", "Nombre d'enregistrements par bo�te � moustache",
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
