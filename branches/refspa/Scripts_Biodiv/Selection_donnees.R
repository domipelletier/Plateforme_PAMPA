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

### File: selection_donnees.R
### Time-stamp: <2012-01-17 15:27:21 yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions de s�lection des donn�es selon les champs d'un des r�f�rentiels.
####################################################################################################

chooseRefespField.f <- function(refesp, obs)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments: refesp : r�f�rentiel esp�ces.
    ##            obs : la table des observations.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  4 janv. 2012, 17:47

    runLog.f(msg=c("Choix d'un Facteur dans le r�f�rentiel esp�ces :"))

    Done <- tclVar("0")                 # Variable de statut d'ex�cussion.

    W.selRef <- tktoplevel()
    tkwm.title(W.selRef, "Selection du facteur du r�f�rentiel des esp�ces")

    ## Ascenceur :
    SCR <- tkscrollbar(W.selRef, repeatinterval=5,
                       command=function(...)tkyview(LI.fields, ...))

    LI.fields <- tklistbox(W.selRef, height=20, width=50, selectmode="single",
                           yscrollcommand=function(...)tkset(SCR, ...),
                           background="white")

    ## Placement des �l�ments :
    tkgrid(tklabel(W.selRef, text="Liste des facteurs du r�f�rentiel des esp�ces"))

    tkgrid(LI.fields, SCR)
    tkgrid.configure(SCR, rowspan=4, sticky="ensw")
    tkgrid.configure(LI.fields, rowspan=4, sticky="ensw")

    ## R�duction aux facteurs contenant de l'information : [yr: 30/09/2010]
    esptmp <- refesp[is.element(refesp[ , "code_espece"],
                                obs[ , "code_espece"]), ] # s�lection des lignes correspondant aux
                                        # obs.
    esptmp <- esptmp[ , sapply(esptmp, function(x){!all(is.na(x))})] # s�lection des champs qui contiennent autre
                                        # chose qu'uniquement des NAs.

    facts <- sort(names(esptmp))

    ## ici, on liste les AMP qui ne correspondent pas au jeu de donn�es :
    listeSite <- c("RUN" , "MAY" , "BA" , "BO" , "CB" , "CR" , "STM" , "NC")
    listeSiteExclus <- subset(listeSite,
                              ! is.element(listeSite, getOption("P.MPA")))

    ## On retire les champs contenant les lettres des sites exclus :
    for (k in (seq(along=listeSiteExclus)))
    { # On peut faire plus simple [yr: 03/08/2010]
        facts <- facts[ ! grepl(paste(listeSiteExclus[k], "$", sep=""),
                                facts)]
    }

    ## Ajout des facteur dans la liste :
    for (i in seq(along=facts))
    {
        tkinsert(LI.fields, "end", facts[i])
    }

    ## Frame pour les boutons :
    F.button <- tkframe(W.selRef)

    ## Bouton OK :
    B.OK <- tkbutton(F.button, text="  OK  ",
                       command=function()
                   {
                       assign("factesp",
                              facts[as.numeric(tkcurselection(LI.fields))+1],
                              parent.env(environment()))

                       tclvalue(Done) <- 1
                   })

    ## Bouton d'annulation :
    B.Cancel <- tkbutton(F.button, text=" Annuler ",
                         command=function(){tclvalue(Done) <- 2})

    tkgrid(B.OK, tklabel(F.button, text="\t"), B.Cancel, padx=10)
    tkgrid(F.button, pady=5, ## sticky="we",
           columnspan=2)

    tkbind(W.selRef, "<Destroy>", function(){tclvalue(Done) <- 2})

    winSmartPlace.f(W.selRef)
    tkfocus(LI.fields)

    ## Attente d'une action de l'utilisateur :
    tkwait.variable(Done)

    ## On retourne la s�lection :
    if (tclvalue(Done) == 1)
    {
        tkdestroy(W.selRef)
        return(factesp)
    }else{
        tkdestroy(W.selRef)
        return(NULL)
    }
}

########################################################################################################################
selectionEsp.f <- function(refesp, obs)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  4 janv. 2012, 17:38

    runLog.f(msg=c("S�lection sur un crit�re du r�f�rentiel esp�ces :"))

    factSp <- chooseRefespField.f(refesp=refesp, obs=obs)

    if (length(factSp) == 0 || is.null(factSp))
    {
        selectfactSp <- NULL
    }else{
        obs[, factSp] <- refesp[match(obs[ , "code_espece"],
                                      refesp[ , "code_espece"]),
                                factSp]

        levelsTmp <- levels(obs[ , "code_espece"])

        selectfactSp <- selectModWindow.f(factSp, obs, selectmode="extended")
        ## assign("selectfactSp", selectfactSp, envir=.GlobalEnv)
    }

    if (!is.null(selectfactSp))
    {
        obs <- dropLevels.f(subset(obs, is.element(obs[, factSp], selectfactSp)),
                            which="code_espece")

        ## R�int�gration des niveaux s�lectionn�s mais plus pr�sents dans les donn�es :
        levelsTmp <- levelsTmp[is.element(levelsTmp,
                                          refesp[is.element(refesp[ , factSp],
                                                            selectfactSp) ,
                                                 "code_espece"])]

        obs[ , "code_espece"] <- factor(obs[ , "code_espece"], levels=levelsTmp)



        ## On d�finit globalement que l'on travaille sur une s�lection :
        options(P.selection=TRUE)

        return(list(facteur=factSp,
                    selection=selectfactSp,
                    obs=obs))
    }else{}
}


########################################################################################################################
selectionOnRefesp.f <- function(dataEnv, baseEnv)
{
    ## Purpose: S�lection des donn�es (dans les observations) selon un
    ##          crit�re du r�f�rentiel esp�ces.
    ## ----------------------------------------------------------------------
    ## Arguments: baseEnv : environnement de l'interface principale.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  4 janv. 2012, 14:54

    on.exit(winRaise.f(get("W.main", envir=baseEnv)))

    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel esp�ces :"))

    ## R�cup�ration des donn�es :
    obs <- get("obs", envir=dataEnv)
    unitobs <- get("unitobs", envir=dataEnv)
    refesp <- get("refesp", envir=dataEnv)

    if (exists(".NombresSVR", envir=dataEnv)) # SVR !
    {
        .NombresSVR <- get(".NombresSVR", envir=dataEnv)

        .DensitesSVR <- get(".DensitesSVR", envir=dataEnv)
    }

    if (exists("unitSpSz", envir=dataEnv))
    {
        unitSpSz <- get("unitSpSz", envir=dataEnv)
    }

    unitSp <- get("unitSp", envir=dataEnv)

    filePathes <- get("filePathes", envir=dataEnv)

    ## Objets tcltk :
    W.main <- get("W.main", envir=baseEnv)

    ## S�lection des observations :
    selection <- selectionEsp.f(refesp=refesp, obs=obs)

    infoGeneral.f(msg="S�lection et recalcul selon un crit�re du r�f�rentiel esp�ces :",
                  waitCursor=TRUE,
                  font=tkfont.create(weight="bold", size=9), foreground="darkred")

    if (!is.null(selection))
    {
        ## assign("obs", obs <- selection[["obs"]], envir=.GlobalEnv)
        obs <- selection[["obs"]]

        keptEspeces <- as.character(refesp[is.element(refesp[ , selection[["facteur"]]],
                                                      selection[["selection"]]),
                                           "code_espece"])

        ## R�duction des tables de donn�es (au esp�ces s�lectionn�es) :
        if (exists(".NombresSVR"))
        {
            species <- dimnames(.NombresSVR)[["code_espece"]]

            .NombresSVR <- extract(.NombresSVR,
                                   indices=list(species[is.element(species, keptEspeces)]),
                                   dims=which(is.element(names(dimnames(.NombresSVR)), "code_espece")))

            .DensitesSVR <- extract(.DensitesSVR,
                                    indices=list(species[is.element(species, keptEspeces)]),
                                    dims=which(is.element(names(dimnames(.DensitesSVR)), "code_espece")))
        }else{}

        if (exists("unitSpSz") && ncol(unitSpSz)) # [!!!]  [yr: 4/1/2012]
        {
            unitSpSz <- dropLevels.f(unitSpSz[is.element(unitSpSz[ , "code_espece"],
                                                         keptEspeces), , drop=FALSE],
                                     which="code_espece")

        }else{
            if ( ! exists("unitSpSz")) unitSpSz <- NULL
        }

        unitSp <- dropLevels.f(unitSp[is.element(unitSp[ , "code_espece"],
                                                 keptEspeces), , drop=FALSE],
                               which="code_espece")

        ## Recalcul des indices de biodiversit� :
        unit <- calc.unit.f(unitSp=unitSp, obs=obs, refesp=refesp,
                            unitobs=unitobs, dataEnv=dataEnv)

        ## Sauvegarde des donn�es recalcul�es dans l'environnement ad�quat :
        if (exists(".NombresSVR"))
        {
            listInEnv.f(list("obs"=obs,
                             "unitSpSz"=unitSpSz,
                             "unitSp"=unitSp,
                             "unit"=unit,
                             ".NombresSVR"=.NombresSVR,
                             ".DensitesSVR"=.DensitesSVR),
                        env=dataEnv)
        }else{
            listInEnv.f(list("obs"=obs,
                             "unitSpSz"=unitSpSz,
                             "unitSp"=unitSp,
                             "unit"=unit),
                        env=dataEnv)
        }

        ## Plan d'�chantillonnage basic :
        PlanEchantillonnageBasic.f(tabUnitobs=unitobs, tabObs=obs, filePathes=filePathes)

        ## Export des tables (.GlobalEnv & fichiers):
        exportMetrics.f(unitSpSz=unitSpSz, unitSp=unitSp, unit=unit,
                        obs=obs, unitobs=unitobs, refesp=refesp,
                        filePathes=filePathes, baseEnv=baseEnv)

        ## Information de l'utilisateur :
        infoLoading.f(msg=paste("Les m�triques ont �t�",
                                " recalcul�es pour la s�lection d'esp�ces.",
                      sep=""),
                      icon="info",
                      font=tkfont.create(weight="bold", size=9))


        ## Recr�ation des tables de calcul :
        ## creationTablesCalcul.f()

        updateInterface.select.f(criterion=paste(selection[["facteur"]], ":",
                                                 paste(selection[["selection"]], collapse=", ")),
                                 tabObs=obs,
                                 baseEnv=baseEnv)

        ## Ajout d'info dans le log de s�lection :
        add.logFrame.f(msgID="selection", env = baseEnv,
                       facteur=selection[["facteur"]], selection=selection[["selection"]],
                       results=filePathes["results"], referentiel="unitobs",
                       has.SzCl=( ! is.null(unitSpSz) && prod(dim(unitSpSz))))

        gestionMSGaide.f("etapeselected", env=baseEnv)

        infoLoading.f(button=TRUE, WinRaise=W.main)
    }else{
        infoLoading.f(msg="Abandon !")
        infoLoading.f(button=TRUE, WinRaise=W.main)
    }
}

########################################################################################################################
########################################################################################################################
chooseUnitobsField.f <- function(unitobs, obs)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  5 janv. 2012, 21:26

    runLog.f(msg=c("Choix d'un Facteur dans le r�f�rentiel des unit�s d'observation :"))

    Done <- tclVar("0")                 # Variable de statut d'ex�cussion.

    W.select <- tktoplevel()
    tkwm.title(W.select, "Selection du facteur de groupement des unites d'observation")

    SCR <- tkscrollbar(W.select, repeatinterval=5,
                       command=function(...)tkyview(LI.fields, ...))

    LI.fields <- tklistbox(W.select, height=20, width=50, selectmode="single",
                           yscrollcommand=function(...)tkset(SCR, ...),
                           background="white")

    tkgrid(tklabel(W.select, text="Liste des facteurs de groupement"))
    tkgrid(LI.fields, SCR)
    tkgrid.configure(SCR, rowspan=4, sticky="ensw")
    tkgrid.configure(LI.fields, rowspan=4, sticky="ensw")

    ## R�duction aux facteurs contenant de l'information : [yr: 30/09/2010]
    uobstmp <- unitobs[is.element(unitobs$unite_observation, obs$unite_observation), ] # s�lection des lignes
                                        # correspondant aux obs.
    uobstmp <- uobstmp[ , sapply(uobstmp, function(x){!all(is.na(x))})] # s�lection des champs qui contiennent autre
                                        # chose qu'uniquement des NAs.

    facts <- sort(names(uobstmp))

    ## On remplit la liste de choix :
    for (i in (seq(along=facts)))
    {
        tkinsert(LI.fields, "end", facts[i])
    }

    ## Frame pour les boutons :
    F.button <- tkframe(W.select)

    ## Bouton OK :
    B.OK <- tkbutton(F.button, text="  OK  ",
                       command=function()
                   {
                       assign("factunitobs",
                              facts[as.numeric(tkcurselection(LI.fields))+1],
                              parent.env(environment()))

                       tclvalue(Done) <- 1
                   })

    ## Bouton d'annulation :
    B.Cancel <- tkbutton(F.button, text=" Annuler ",
                         command=function(){tclvalue(Done) <- 2})

    tkgrid(B.OK, tklabel(F.button, text="\t"), B.Cancel, padx=10)
    tkgrid(F.button, pady=5, ## sticky="we",
           columnspan=2)

    tkbind(W.select, "<Destroy>", function(){tclvalue(Done) <- 2})

    winSmartPlace.f(W.select)
    tkfocus(LI.fields)

    ## Attente d'une action de l'utilisateur :
    tkwait.variable(Done)

    ## On retourne la s�lection :
    if (tclvalue(Done) == 1)
    {
        tkdestroy(W.select)
        return(factunitobs)
    }else{
        tkdestroy(W.select)
        return(NULL)
    }
}

########################################################################################################################
selectionUnitobs.f <- function(unitobs, obs)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  5 janv. 2012, 21:11

    runLog.f(msg=c("S�lection sur un crit�re du r�f�rentiel des unit�s d'observation :"))

    factunitobs <- chooseUnitobsField.f(unitobs=unitobs, obs=obs)

    if (length(factunitobs) == 0 || is.null(factunitobs))
    {
        selectfactunitobs <- NULL
    }else{
        obs[, factunitobs] <- unitobs[match(obs[ , "unite_observation"],
                                            unitobs[ , "unite_observation"]),
                                      factunitobs]

        levelsTmp <- levels(obs[ , "unite_observation"])

        selectfactunitobs <- selectModWindow.f(factunitobs, obs, selectmode="extended")
    }

    if ( ! is.null(selectfactunitobs))
    {
        obs <- dropLevels.f(subset(obs,
                                   is.element(obs[, factunitobs],
                                              selectfactunitobs)),
                            which="unite_observation") # V�rifier si c'est correct [!!!]

        ## R�int�gration des niveaux s�lectionn�s mais plus pr�sents dans les donn�es :
        levelsTmp <- levelsTmp[is.element(levelsTmp,
                                          unitobs[is.element(unitobs[ , factunitobs],
                                                             selectfactunitobs),
                                                  "unite_observation"])]

        obs[ , "unite_observation"] <- factor(obs[ , "unite_observation"],
                                              levels=levelsTmp)

        ## On d�finit globalement que l'on travaille sur une s�lection :
        options(P.selection=TRUE)

        return(list(facteur=factunitobs,
                    selection=selectfactunitobs,
                    obs=obs))
    }else{}
}

########################################################################################################################
selectionOnUnitobs.f <- function(dataEnv, baseEnv)
{
    ## Purpose: S�lection des donn�es (dans les observations) selon un
    ##          crit�re du r�f�rentiel d'unit�s d'observation.
    ## ----------------------------------------------------------------------
    ## Arguments: baseEnv : environnement de l'interface principale.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  5 janv. 2012, 21:02

    on.exit(winRaise.f(get("W.main", envir=baseEnv)))

    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel des unit�s d'observation :"))

    ## R�cup�ration des donn�es :
    obs <- get("obs", envir=dataEnv)
    unitobs <- get("unitobs", envir=dataEnv)
    refesp <- get("refesp", envir=dataEnv)

    filePathes <- get("filePathes", envir=dataEnv)

    if (exists(".NombresSVR", envir=dataEnv)) # SVR !
    {
        .NombresSVR <- get(".NombresSVR", envir=dataEnv)

         .DensitesSVR <- get(".DensitesSVR", envir=dataEnv)
    }

    ## ...et des tables de m�triques :
    if (exists("unitSpSz", envir=dataEnv))
    {
        unitSpSz <- get("unitSpSz", envir=dataEnv)
    }

    unitSp <- get("unitSp", envir=dataEnv)
    unit <- get("unit", envir=dataEnv)

    ## Objets tcltk :
    W.main <- get("W.main", envir=baseEnv)

    selection <- selectionUnitobs.f(unitobs=unitobs, obs=obs)

    infoGeneral.f(msg="S�lection et recalcul selon un crit�re du r�f�rentiel d'unit�s d'observation :",
                  waitCursor=TRUE,
                  font=tkfont.create(weight="bold", size=9), foreground="darkred")

    if (!is.null(selection))
    {
        obs <- selection[["obs"]]

        keptUnitobs <- as.character(unitobs[is.element(unitobs[ , selection[["facteur"]]],
                                                       selection[["selection"]]),
                                            "unite_observation"])

        ## R�duction des tables de donn�es (aux unitobs s�lectionn�es) :
        if (exists(".NombresSVR"))
        {
            unitObs <- dimnames(.NombresSVR)[["unite_observation"]]

            .NombresSVR <- extract(.NombresSVR,
                                   indices=list(unitObs[is.element(unitObs, keptUnitobs)]),
                                   dims=which(is.element(names(dimnames(.NombresSVR)), "unite_observation")))

            .DensitesSVR <- extract(.DensitesSVR,
                                    indices=list(unitObs[is.element(unitObs, keptUnitobs)]),
                                    dims=which(is.element(names(dimnames(.DensitesSVR)), "unite_observation")))
        }else{}

        if (exists("unitSpSz") && ncol(unitSpSz))
        {
            unitSpSz <- dropLevels.f(unitSpSz[is.element(unitSpSz[ , "unite_observation"],
                                                         keptUnitobs),
                                              , drop=FALSE],
                                     which="unite_observation")
        }else{}

        unitSp <- dropLevels.f(unitSp[is.element(unitSp[ , "unite_observation"],
                                                 keptUnitobs),
                                      , drop=FALSE],
                               which="unite_observation")

        unit <- dropLevels.f(unit[is.element(unit[ , "unite_observation"],
                                             keptUnitobs),
                                  , drop=FALSE],
                             which="unite_observation")

        ## Sauvegarde des donn�es recalcul�es dans l'environnement ad�quat :
        if (exists(".NombresSVR"))
        {
            listInEnv.f(list("obs"=obs,
                             "unitSpSz"=unitSpSz,
                             "unitSp"=unitSp,
                             "unit"=unit,
                             ".NombresSVR"=.NombresSVR,
                             ".DensitesSVR"=.DensitesSVR),
                        env=dataEnv)
        }else{
            listInEnv.f(list("obs"=obs,
                             "unitSpSz"=unitSpSz,
                             "unitSp"=unitSp,
                             "unit"=unit),
                        env=dataEnv)
        }

        ## Plan d'�chantillonnage basic :
        PlanEchantillonnageBasic.f(tabUnitobs=unitobs, tabObs=obs, filePathes=filePathes)

        ## Export des tables (.GlobalEnv & fichiers):
        exportMetrics.f(unitSpSz=unitSpSz, unitSp=unitSp, unit=unit,
                        obs=obs, unitobs=unitobs, refesp=refesp,
                        filePathes=filePathes, baseEnv=baseEnv)

        ## Information de l'utilisateur :
        infoLoading.f(msg=paste("Les m�triques ont �t�",
                      " recalcul�es sur la s�lection d'unit�s d'observation.",
                      sep=""),
                      icon="info",
                      font=tkfont.create(weight="bold", size=9))

        updateInterface.select.f(criterion=paste(selection[["facteur"]], ":",
                                                 paste(selection[["selection"]], collapse=", ")),
                                 tabObs=obs, baseEnv=baseEnv)

        ## Ajout d'info dans le log de s�lection :
        add.logFrame.f(msgID="selection", env = baseEnv,
                       facteur=selection[["facteur"]], selection=selection[["selection"]],
                       results=filePathes["results"], referentiel="unitobs",
                       has.SzCl=( ! is.null(unitSpSz) && prod(dim(unitSpSz))))

        gestionMSGaide.f("etapeselected", env=baseEnv)

        infoLoading.f(button=TRUE, WinRaise=W.main)
    }else{
        infoLoading.f(msg="Abandon !")
        infoLoading.f(button=TRUE, WinRaise=W.main)
    }
}

########################################################################################################################
restoreData.f <- function(baseEnv, dataEnv)
{
    ## Purpose: Restauration des donn�es originales (avant s�lection selon un
    ##          ou plusieurs crit�res).
    ## ----------------------------------------------------------------------
    ## Arguments: baseEnv : environnement de l'interface principale.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  6 janv. 2012, 15:44

    listInEnv.f(list=get("backup", envir=dataEnv), env=dataEnv)

    updateInterface.restore.f(criterion = "Tout",
                              tabObs=get("obs", envir=dataEnv),
                              baseEnv=baseEnv)

    options(P.selection=FALSE)

    add.logFrame.f(msgID="restauration", env = baseEnv)

    tkmessageBox(message=paste("Donn�es originales restaur�e."## , dim(obs)[1],
                 ## "enregistrements dans la table des observations"
                 ))

    gestionMSGaide.f("SelectionOuTraitement", env=baseEnv)
}









### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
