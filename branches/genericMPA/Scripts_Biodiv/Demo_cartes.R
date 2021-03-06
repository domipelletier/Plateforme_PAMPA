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

### File: demo_cartes.R
### Time-stamp: <2012-01-10 15:17:13 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Scripts de d�monstartion de ce qui pourra �tre fait avec des carte.
### Pour l'instant uniquement pour la Nouvelle-Cal�donie.
####################################################################################################

########################################################################################################################
selectionVariablesCarte.f <- function(dataEnv)
{
    ## Purpose: S�lection d'un variable pour d�mo de repr�sentation
    ##          sur une carte (NC).
    ## ----------------------------------------------------------------------
    ## Arguments: dataEnv : l'environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 25 mai 2011, 14:29

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution

    nextStep <- "boxplot.unitobs"       # N�cessaire pour la mise � jour des listes de m�triques.

    ## Liste des m�triques :
    metriques <- champsMetriques.f(nomTable="unitSp", nextStep=nextStep, dataEnv=dataEnv)

    TableMetrique <- tclVar("unitSp")  # Table des m�triques.
    MetriqueChoisie <- tclVar("")           # M�trique choisie


    ## ########################
    ## �l�ments graphiques :
    WinSelection <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinSelection, paste("S�lection de m�trique pour carte", sep=""))

    ## M�triques :
    FrameMetrique <- tkframe(WinSelection, borderwidth=2, relief="groove")

    CB.metrique <- ttkcombobox(FrameMetrique, value=metriques, textvariable=MetriqueChoisie,
                               state="readonly")

    RB.unitSp <- tkradiobutton(FrameMetrique, variable=TableMetrique,
                               value="unitSp", text="... / unit� d'observation")
    RB.unit <- tkradiobutton(FrameMetrique, variable=TableMetrique,
                             value="unit", text="...de biodiversit� ( / unit� d'observation)")

    FrameBT <- tkframe(WinSelection)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})

    ## ############
    ## �v�nements :
    tkbind(RB.unitSp, "<Leave>", function(){updateMetrique.f(nomTable=tclvalue(TableMetrique), env=env)})
    tkbind(RB.unit, "<Leave>", function(){updateMetrique.f(nomTable=tclvalue(TableMetrique), env=env)})

    tkbind(WinSelection, "<Destroy>", function(){tclvalue(Done) <- 2})

    ## #############################
    ## Positionnement des �l�ments :
    tkgrid(tklabel(FrameMetrique, text="M�trique � repr�senter : "), sticky="w")

    tkgrid(RB.unitSp, sticky="w")
    tkgrid(RB.unit, CB.metrique, tklabel(FrameMetrique, text=" \n"), sticky="w")

    tkgrid(FrameMetrique, column=1, columnspan=3, sticky="w", padx=7, pady=7)

    tkgrid(FrameBT, column=1, columnspan=3, padx=7, pady=7)

    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
           tklabel(FrameBT, text="\n"))

    ## Update des fen�tres :
    tcl("update")

    ## tkfocus(WinSelection)
    winSmartPlace.f(WinSelection)

    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        if (tclvalue(Done) == "1")      # statut ex�cution OK.
        {
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- ifelse(tclvalue(MetriqueChoisie) == "", "0", "1")

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.

            boxplotCarte.f(metrique=tclvalue(MetriqueChoisie),
                           tableMetrique=tclvalue(TableMetrique),
                           dataEnv=dataEnv)
        }else{}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }

    tkdestroy(WinSelection)             # destruction de la fen�tre.
}

########################################################################################################################
boxplotCarte.f <- function(metrique, tableMetrique, dataEnv)
{
    ## Purpose: Cr�er la carte avec des boxplots sur les sites
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            tableMetrique : nom de la table de m�triques.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 25 mai 2011, 16:10

    pampaProfilingStart.f()

    ## Donn�es pour la s�rie de boxplots :
    if (tableMetrique == "unit")
    {
        ## Pour les indices de biodiversit�, il faut travailler sur les nombres... :
        tmpData <- subsetToutesTables.f(metrique="nombre", facteurs=c("site", "statut_protection"),
                                        selections=list(NA, NA), dataEnv=dataEnv, tableMetrique="unitSp",
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }else{
        tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=c("site", "statut_protection"),
                                        selections=list(NA, NA), dataEnv=dataEnv, tableMetrique="unitSp",
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }

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
        tmpData <- cbind(tmp,
                         tmpData[match(tmp$unite_observation, tmpData$unite_observation),
                                 !is.element(colnames(tmpData), colnames(tmp))])
    }else{
        tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                       metrique=metrique,
                                                       facteurs=c("unite_observation"),
                                                       dataEnv=dataEnv,
                                                       listFact=c("site", "statut_protection")))
    }

    tmpData <- cbind(tmpData,
                     unitobs[match(tmpData$unite_observation, unitobs$unite_observation) ,
                             c("longitude", "latitude", "unite_observation")])

    tmpData <- dropLevels.f(tmpData)

    ## fond de carte NC :
    MapNC <- readShapePoly(paste(basePath, "/shapefiles/NewCaledonia_v7", sep=""),
                           verbose=TRUE, repair=FALSE, delete_null_obj=TRUE)

    ## P�riph�rique graphique :
    x11(width=50, height=30, pointsize=10)

    par(mgp=c(2, 1, 0))

    plot(MapNC,
         xlim=range(tmpData$longitude, na.rm=TRUE) + 0.05 * c(-1, 1) * diff(range(tmpData$longitude, na.rm=TRUE)),
         ylim=range(tmpData$latitude, na.rm=TRUE) + 0.05 * c(-1, 1) * diff(range(tmpData$latitude, na.rm=TRUE)),
         ## col=ifelse(MapNC$L1_ATTRIB == "oceanic", "lightblue", "lightyellow"),
         col=ifelse(!MapNC$LAND, "lightblue1", "lightyellow"),
         density=NA,
         xaxs="i", yaxs="i", axes=TRUE, bg=c("lightblue"),
         lwd=0.1)

    title(paste(Capitalize.f(varNames[metrique, "nom"]),
                " par statut de protection et par site", sep=""))
    mtext("longitude", side=1, line=3)
    mtext("Lattitude", side=2, line=3)

    X <- tapply(tmpData$longitude, tmpData$site, mean, na.rm=TRUE)
    Y <- tapply(tmpData$latitude, tmpData$site, mean, na.rm=TRUE)

    y <- tapply(tmpData[ , metrique], tmpData$site, function(x)x)
    x <- tapply(tmpData$statut_protection, tmpData$site, function(x)x)

    ## Rectangles pour avoir un fond (transparent) aux subplots.
    for (i in seq_along(X))
    {
        subplot({plot(0:1, 0:1, xaxt="n", yaxt="n", type="n", xlab="", ylab="", bty="n") ;
                 rect(0, 0, 1, 1, col=rgb(1, 1, 1, 0.4))},
                X[i], Y[i], size=c(1.2, 1.12), type="plt")
    }

    ## Barplots :
    for (i in seq_along(X))
    {
        subplot(boxplot(y[[i]] ~ x[[i]],
                        ylim=c(0, max(tmpData[ , metrique], na.rm=TRUE)),
                        col=PAMPAcolors.f(n=nlevels(tmpData$statut_protection)),
                        main=paste("", names(x)[i], sep=""),
                        las=1),
                X[i], Y[i], size=c(1.2, 1.12),  type="fig",
                pars=list(bg="white", fg="black", cex=0.6, xpd=NA, mgp=c(1.5, 0.5, 0),
                          tcl=-0.3, mar=c(2.5, 4, 2, 1) + 0.1))
    }
}






### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
