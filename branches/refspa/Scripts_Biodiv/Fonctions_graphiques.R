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

### File: fonctions_graphiques.R
### Time-stamp: <2012-01-10 18:24:33 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions communes pour les graphiques.
####################################################################################################

makeColorPalettes.f <- function()
{
    ## Purpose: Cr�er les palettes de couleurs pour les graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: aucun !
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 oct. 2012, 17:19

    ## default:
    assign(".ColorPaletteDefault",
           colorRampPalette(c("#66FFFF", "#9966FF", "#009999", "#CC3399", "#FFCC99",
                              "#FFFF99", "#CCFF99", "#CC9900", "#C0504D", "#FF99CC")),
           envir=.GlobalEnv)

    ## blue:
    assign(".ColorPaletteBlue",
           colorRampPalette(c("#66FFFF", "#215968", "#33CCCC", "#003366", "#CCFFFF",
                              "#009999", "#99CCFF", "#66FFFF", "#215968", "#33CCCC")),
           envir=.GlobalEnv)

    ## heat:
    assign(".ColorPaletteHeat",
           colorRampPalette(heat.colors(5)),
           envir=.GlobalEnv)

    ## gray:
    assign(".ColorPaletteGray",
           colorRampPalette(c("#787878", "#dddddd")),
           envir=.GlobalEnv)
}


PAMPAcolors.f <- function(n=1, palette=getOption("P.colPalette"), list=FALSE)
{
    ## Purpose: retourner n couleurs de la palette "palette".
    ## ----------------------------------------------------------------------
    ## Arguments: n : nombre de couleurs.
    ##            palette : une des palettes de couleurs pr�d�finies
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 oct. 2012, 17:08

    if (list)
    {
        return(c("d�faut", "bleu", "chaud", "gris"))
    }else{}

    if (is.element(palette,
                   c("default", "d�faut", "defaut", "blue", "bleu",
                     "heat", "chaud", "gray", "grey", "gris")) &&
        ! exists(palette, envir=.GlobalEnv))
    {
        makeColorPalettes.f()
    }else{}

    res <- switch(palette,
                  "default"=,
                  "defaut"=,
                  "d�faut"={
                      if (n <= 10)
                      {
                          .ColorPaletteDefault(10)[1:n]
                      }else{
                          .ColorPaletteDefault(n)
                      }
                  },
                  "bleu"=,
                  "blue"={
                      if (n <= 10)
                      {
                          .ColorPaletteBlue(10)[1:n]
                      }else{
                          .ColorPaletteBlue(n)
                      }
                  },
                  "chaud"=,
                  "heat"={
                      .ColorPaletteHeat(n)
                  },
                  "grey"=,
                  "gris"=,
                  "gray"={
                      .ColorPaletteGray(n)
                  })

    return(res)
}


########################################################################################################################
resFileGraph.f <- function(metrique, factGraph, modSel, listFact, ext, dataEnv,
                           prefix="boxplot", sufixe=NULL, type="espece")
{
    ## Purpose: D�finit les noms du fichiers pour les r�sultats des mod�les
    ##          lin�aires. L'extension et un prefixe peuvent �tres pr�cis�s,
    ##          mais par d�faut, c'est le fichier de sorties texte qui est
    ##          cr��.
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : nom de la m�trique analys�e.
    ##            factGraph : nom du facteur de s�prataion des analyses/
    ##                        de selection d'esp�ce(s).
    ##            modSel : modalit�(s) de factGraph s�lectionn�e(s).
    ##            listFact : vecteur des noms de facteurs de l'analyse.
    ##            prefix : pr�fixe du nom de fichier.
    ##            sufixe : un sufixe pour le nom de fichier.
    ##            ext : extension du fichier.
    ##            type : type de mod�le (traitement conditionnel).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 janv. 2011, 10:38

    ## Nom de fichier :
    filename <- paste(get("filePathes", envir=dataEnv)["results"], prefix, "_",
                      ## M�trique analys�e :
                      metrique,
                      ifelse(getOption("P.maxExclu") && getOption("P.GraphPartMax") < 1,
                             paste("(", round(100 * getOption("P.GraphPartMax")),"pc-max)", sep=""),
                             ""),
                      "_",
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
                                 ifelse(factGraph == "",
                                        "",
                                        paste(factGraph, "(", ifelse(modSel[1] != "",
                                                                     paste(modSel, collapse="+"),
                                                                     "toutes"), ")_", sep=""))
                             },
                             "CL_espece"={
                                 ifelse(factGraph == "",
                                        "",
                                        paste(factGraph, "(", ifelse(modSel[1] != "",
                                                                     paste(modSel, collapse="+"),
                                                                     "toutes"), ")_", sep=""))
                             },
                             "unitobs"={
                                 ifelse(factGraph == "",
                                        "(toutes_esp�ces)_",
                                        paste(factGraph, "(", ifelse(modSel[1] != "",
                                                                     paste(modSel, collapse="+"),
                                                                     "toutes"), ")_", sep=""))
                             },
                             "CL_unitobs"={
                                 ifelse(factGraph == "",
                                        "(toutes_esp�ces)_",
                                        paste(factGraph, "(", ifelse(modSel[1] != "",
                                                                     paste(modSel, collapse="+"),
                                                                     "toutes"), ")_", sep=""))
                             },
                             ""),
                      ## liste des facteurs de l'analyse
                      paste(listFact, collapse="-"),
                      ## sufixe :
                      ifelse(is.null(sufixe) || sufixe == "",
                             "",
                             paste("_", sufixe, sep="")),
                      ## Extension du fichier :
                      ".", gsub("^\\.([^.]*)", "\\1", ext[1], perl=TRUE), # nettoyage de l'extension si besoin.
                      sep="")

    ## Retourne le nom de fichier :
    return(filename)
}


########################################################################################################################
openDevice.f <- function(noGraph, metrique, factGraph, modSel, listFact, dataEnv,
                         type="espece", typeGraph="boxplot", large=FALSE)
{
    ## Purpose: Ouvrir les p�riph�riques graphiques avec les bonnes options
    ## ----------------------------------------------------------------------
    ## Arguments: noGraph : le num�ro de graphique (integer)
    ##            metrique : la m�trique choisie.
    ##            factGraph : le facteur de s�paration des graphiques.
    ##            modSel :  modalit�(s) de factGraph s�lectionn�e(s).
    ##            listFact : liste du (des) facteur(s) de regroupement.
    ##            type : type de donn�es (traitement conditionnel).
    ##            typeGraph : type de graphique.
    ##            large : pour des traitements particuliers (e.g. MRT)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 ao�t 2010, 14:54

    fileName <- NULL

    if (!getOption("P.graphPDF")) # sorties graphiques � l'�cran ou PNG.
    {
        if (isTRUE(getOption("P.graphPNG")))
        {
            if (noGraph == 1 || ! getOption("P.plusieursGraphPage"))
            {
                pngFileName <- resFileGraph.f(metrique=metrique, factGraph=factGraph, modSel=modSel, listFact=listFact,
                                              dataEnv=dataEnv, ext="png", prefix = typeGraph,
                                              sufixe = ifelse(getOption("P.plusieursGraphPage") &&
                                                                (length(modSel) > 1 || modSel[1] == ""),
                                                              "%03d",
                                                              ""),
                                              type = type)

                ## Si plusieurs graphiques par page :
                if (getOption("P.plusieursGraphPage") && length(modSel) > 1 & # Regrouper dans une fonction de test
                    !is.element(type, c("unitobs")))                          # (mutualiser le code). [!!!]
                {
                    png(pngFileName,
                        width=ifelse(large, 120, 90) * 15,
                        height=ifelse(large, 75, 55) * 15,
                        pointsize=14)
                    par(mfrow=c(getOption("P.nrowGraph"), getOption("P.ncolGraph")))
                }else{
                    png(pngFileName,
                        width=ifelse(large, 100,
                                     ifelse(isTRUE(getOption("P.graphPaper")), 50, 75)) * 15,
                        height=ifelse(large, 55,
                                      ifelse(isTRUE(getOption("P.graphPaper")), 30, 40)) * 15, pointsize=14)
                }

                ## Pour retourner le nom de fichier malgr� tout :
                fileName <- pngFileName
            }else{}

        }else{   ## Graphiques � l'�cran :
            ## Des fonctions diff�rentes pour l'affichage � l'�cran, selon la plateforme :
            if (.Platform$OS.type == "windows")
            {
                winFUN <- "windows"
            }else{
                winFUN <- "X11"
            }

            if (getOption("P.plusieursGraphPage") && # Plusieurs graphs par page...
                    length(modSel) > 1 &&            # ...plus d'un facteur s�lectionn�...
                    !is.element(type, c("unitobs"))) # ...et pas d'agr�gation.
            {
                if ((noGraph %% # ...et page remplie.
                     (getOption("P.nrowGraph") * getOption("P.ncolGraph"))) == 1)
                {
                    ## [!!!] Limiter aux cas n�cessaires... (cf. plus haut).
                    eval(call(winFUN,
                              width=ifelse(large, 40, 30),  # 80, 60
                              height=ifelse(large, 26, 20), # 45, 35
                              pointsize=ifelse(isTRUE(getOption("P.graphPaper")), 14, 10)))

                    par(mfrow=c(getOption("P.nrowGraph"), getOption("P.ncolGraph")))
                }else{                  # Pas plusieurs graphs par page.
                }
            }else{                      # Pas plusieurs graphs par page.
                eval(call(winFUN,
                          width=ifelse(large, 35,
                                       ifelse(isTRUE(getOption("P.graphPaper")), 10, 25)), # 10, 50
                          height=ifelse(large, 15,
                                        ifelse(isTRUE(getOption("P.graphPaper")), 6, 12)), # 6, 20
                          pointsize=ifelse(isTRUE(getOption("P.graphPaper")), 14, 10)))
            }

            fileName <- resFileGraph.f(metrique=metrique, factGraph=factGraph, modSel=modSel, listFact=listFact,
                                       dataEnv=dataEnv, ext="wmf", prefix = typeGraph,
                                       sufixe = ifelse(getOption("P.plusieursGraphPage") &&
                                                        (length(modSel) > 1 || modSel[1] == ""),
                                                       "%03d",
                                                       ""),
                                       type=type)
        }
    }else{ ## Sorties graphiques en pdf :
        if (noGraph == 1)
        {
            ## Nom de fichier de fichier :
            if (getOption("P.PDFunFichierPage")) # Un fichier par graphique avec num�ro.
            {
                pdfFileName <- paste(get("filePathes", envir=dataEnv)["results"],
                                     metrique, "_", factGraph, "_", paste(listFact, collapse="-"), "-%03d.pdf", sep="")
                onefile <- FALSE

            }else{                          # Tous les graphiques dans des pages s�par�es d'un m�me fichier.
                pdfFileName <- paste(get("filePathes", envir=dataEnv)["results"],
                                     metrique, "_", factGraph, "_", paste(listFact, collapse="-"), ".pdf", sep="")
                onefile <- TRUE
            }
            ## Ouverture de fichier :
            pdf(pdfFileName, encoding="ISOLatin1", family="URWHelvetica", onefile=onefile,
                width=ifelse(large, 30,
                             ifelse(isTRUE(getOption("P.graphPaper")), 12, 20)),
                height=ifelse(large, 20,
                             ifelse(isTRUE(getOption("P.graphPaper")), 8, 12)),
                pointsize=14)

            ## Si plusieurs graphiques par page :
            if (getOption("P.plusieursGraphPage") &&
                length(modSel) > 1 &&            # Plus d'un facteur s�lectionn�.
                !is.element(type, c("unitobs"))) # Pas d'agr�gation.
            {
                par(mfrow=c(getOption("P.nrowGraph"), getOption("P.ncolGraph")))
            }else{}

            ## Pour retourner le nom de fichier �galement :
            fileName <- pdfFileName
        }else{}
    }

    par(cex=getOption("P.cex"))
    return(fileName)
}


########################################################################################################################
boxplotPAMPA.f <- function(exprBP, data, main=NULL, cex=getOption("P.cex"),...)
{
    ## Purpose: Boxplot avec un formatage pour pampa
    ## ----------------------------------------------------------------------
    ## Arguments: exprBP : expression d�crivant le mod�le du boxplot.
    ##            data : les donn�es � utiliser.
    ##            main : titre du graphique.
    ##            cex : taille des caract�res.
    ##            ... : arguments optionnels (pass�s � la fonction boxplot).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 10 f�vr. 2011, 17:05

    ## Extraction du nom de la m�trique :
    metrique <- deparse(exprBP[[2]])

    ## Les couleurs pour l'identification des modalit�s du facteur de second niveau :
    colors <- colBoxplot.f(terms=attr(terms(exprBP), "term.labels"), data=data)

    ## Suppression des valeurs infinies (plante ylims les graphiques) :
    tmpMetric <- replace(data[ , metrique], is.infinite(data[ , metrique]), NA)

    ## ylims :
    ylim <- c(min(tmpMetric, na.rm=TRUE),
              ifelse(getOption("P.maxExclu") && getOption("P.GraphPartMax") < 1,
                     getOption("P.GraphPartMax") * max(tmpMetric, na.rm=TRUE),
                     max(tmpMetric, na.rm=TRUE) +
                     0.1*(max(tmpMetric, na.rm=TRUE) -
                          min(tmpMetric, na.rm=TRUE))))

    ## Plot sans affichage pour r�cup�rer l'objet :
    tmpBP <- boxplot(exprBP, data=data,
                     varwidth = TRUE, las=2,
                     col=colors,
                     ylim=ylim,
                     cex.lab=cex,
                     cex.axis=cex,
                     plot=FALSE,
                     ...)

    ## Marge dynamiques (adaptation � la longueur des labels) :
    optim(par=unlist(par("mai")),       # Le rapport inch/ligne est modifi� en changeant les marges => besoin
                                        # de l'optimiser.
          fn=function(x)
      {
          par(mai=c(
              ## Marge du bas dynamique :
              ifelse((tmp <- lineInchConvert.f()$V * cex * unlist(par("lheight")) * (0.2 + 0.9) + # marge
                                        # suppl�mentaire.
                      max(strDimRotation.f(tmpBP$names,
                                           srt=45,
                                           unit="inches",
                                           cex=cex)$height, na.rm=TRUE)) > 0.65 * unlist(par("pin"))[2],
                     0.65 * unlist(par("pin"))[2],
                     tmp),
              ## Marge de gauche dynamique :
              tmp2 <- ifelse((tmp <- lineInchConvert.f()$H * cex * unlist(par("lheight")) * (1.4 +0.4 + 0.9) + # marge
                                        # suppl�mentaire.
                              max(strDimRotation.f(as.graphicsAnnot(pretty(range(if(getOption("P.maxExclu")
                                                                                    && getOption("P.GraphPartMax") < 1)
                                                                             {
                                                                                 data[data[ ,metrique] <
                                                                                      getOption("P.GraphPartMax") *
                                                                                      max(data[ ,metrique], na.rm=TRUE) ,
                                                                                      metrique]
                                                                             }else{
                                                                                 data[ , metrique]
                                                                             }, na.rm=TRUE))),
                                                   srt=0,
                                                   unit="inches",
                                                   cex=cex)$width, na.rm=TRUE)) > 0.7 * unlist(par("pin"))[1],
                             0.7 * unlist(par("pin"))[1],
                             tmp),
              ## Marge sup�rieure augment�e s'il y a un titre :
              ifelse(isTRUE(getOption("P.graphPaper")),
                     2 * lineInchConvert.f()$V,
                     8 * lineInchConvert.f()$V),
              ## Marge de droite :
              lineInchConvert.f()$H * cex * unlist(par("lheight")) * 0.5) +
                  lineInchConvert.f()$H * cex * unlist(par("lheight")) * 0.1,
              ## Distance du nom d'axe d�pendante de la taille de marge gauche :
              mgp=c(tmp2 / lineInchConvert.f()$H - 1.4, 0.9, 0))

          ## Valeur � minimiser :
          return(sum(abs(x - unlist(par("mai")))))
      },
          control=list(abstol=0.01))    # Tol�rance.

    ## Plot avec affichage cette fois :
    tmpBP <- boxplot(exprBP, data=data,
                     varwidth = TRUE, las=2,
                     col=colors,
                     ylim=ylim,
                     xaxt="n",
                     main=if (! isTRUE(getOption("P.graphPaper")))
                 {
                     main
                 }else{NULL},
                     cex.lab=cex,
                     cex.axis=cex,
                     ...)

    ## Ajout de l'axe des abscices :
    axis(side=1, at = seq_along(tmpBP$names), labels = FALSE, tick = TRUE)

    ## Ajout des labels :
    text(x = seq_along(tmpBP$names),
         y = par("usr")[3] -
             ifelse(isTRUE(getOption("P.graphPDF")), # Coef diff�rent pour les PDFs.
                    0.020,
                    0.030) * cex *
             diff(range(par("usr")[3:4])),
         labels = tmpBP$names,
         xpd = TRUE, srt = 45, adj = c(1, 1),
         cex = cex)

    ## Stockage des ylim pour les traitements ult�rieurs :
    tmpBP$ylim <- ylim

    return(tmpBP)
}


########################################################################################################################
strDimRotation.f <- function(x, srt=0, unit="user", cex=getOption("P.cex"),...)
{
    ## Purpose: Calcul des dimensions d'une cha�ne de caract�re � laquelle
    ##          on applique une rotation
    ## ----------------------------------------------------------------------
    ## Arguments: x : vecteur de classe 'character'.
    ##            srt : angle de rotation en degr�s.
    ##            unit : unit� de sortie.
    ##            ... : arguments suppl�mentaires pass�s � str(height|width).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 f�vr. 2011, 16:15

    ## browser()

    ## Dimensions en pouces :
    W.inches <- strwidth(x, unit="inches", cex=cex,...)
    H.inches <- strheight(x, unit="inches", cex=cex,...)

    ## Facteur de conversion avec l'unit� souhait�e :
    X.inchesVSunit <- W.inches / strwidth(x, unit=unit, cex=cex,...)
    Y.inchesVSunit <- H.inches / strheight(x, unit=unit, cex=cex,...)

    ## Calcul des largeurs et hauteurs en rotations :
    X.calc <- abs(W.inches * cos(srt * base:::pi / 180)) + abs(H.inches * sin(srt * base:::pi / 180))
    Y.calc <- abs(W.inches * sin(srt * base:::pi / 180)) + abs(H.inches * cos(srt * base:::pi / 180))

    ## Conversion dans l'unit� souhait�e :
    return(list(width = X.calc / X.inchesVSunit,
                height = Y.calc / Y.inchesVSunit))
}

########################################################################################################################

lineInchConvert.f <- function()
{
    ## Purpose: Calcul du facteur de conversion inch/ligne.
    ## ----------------------------------------------------------------------
    ## Arguments: Aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 ao�t 2011, 13:07

    pars <- par(c("mai", "mar"))

    return(list(H=(pars$mai/pars$mar)[2],
                V=(pars$mai/pars$mar)[1]))
}

########################################################################################################################

unitConvY.f <- function(x=NULL, from="user", to="user")
{
    ## Purpose: Conversion verticale des unit�s entre diff�rents syst�mes de
    ##          coordonn�es
    ## ----------------------------------------------------------------------
    ## Arguments: x : valeur � convertir. Si NULL, retourne le rapport
    ##                unit�2/unit�1 (to/from).
    ##            from : unit� de d�part.
    ##            to : unit� vers laquelle convertir.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 ao�t 2011, 14:21

    Y1 <- strheight("X", unit=from, cex=10)
    Y2 <- strheight("X", unit=to, cex=10)

    if (is.null(x))
    {
        return(Y2/Y1)                   # Rapport uniquement.
    }else{
        return(x * Y2/Y1)               # Valeur convertie.
    }
}

########################################################################################################################

unitConvX.f <- function(x=NULL, from="user", to="user")
{
    ## Purpose: Conversion horizontale des unit�s entre diff�rents syst�mes
    ##          de coordonn�es
    ## ----------------------------------------------------------------------
    ## Arguments: x : valeur � convertir. Si NULL, retourne le rapport
    ##                unit�2/unit�1 (to/from).
    ##            from : unit� de d�part.
    ##            to : unit� vers laquelle convertir.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 ao�t 2011, 14:21

    X1 <- strwidth("XXXXXX", unit=from, cex=10)
    X2 <- strwidth("XXXXXX", unit=to, cex=10)

    if (is.null(x))
    {
        return(X2/X1)                   # Rapport uniquement.
    }else{
        return(x * X2/X1)               # Valeur convertie.
    }
}




### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
