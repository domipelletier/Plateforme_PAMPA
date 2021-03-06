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

### File: Chargement_manuel_fichiers.R
### Time-stamp: <2012-02-24 20:23:01 Yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Scripts pour le chargement manuel des fichiers
####################################################################################################


########################################################################################################################
loadManual.f <- function(baseEnv, dataEnv)
{
    ## Purpose: Chargement des donn�es avec choix manuel des fichiers et
    ##          dossiers.
    ## ----------------------------------------------------------------------
    ## Arguments: baseEnv : environnement de l'interface principale.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:20

    ## Sauvegarde et suppression des noms de fichiers, options, etc. :
    dataEnvTmp <- backupEnv.f(dataEnv) # On sauvegarde temporairement l'environnement de donn�es.
    obsTypeTmp <- getOption("P.obsType") # ...et le type d'observations.

    ## Choix des fichiers et dossiers :
    fileNames <- chooseFiles.f(dataEnv = dataEnv)

    ## ...apr�s chooseFiles.f car utilise une �ventuelle valeur pr�alable de l'espace de travail.
    suppressWarnings(rm(list=ls(envir=dataEnv)[!is.element(ls(envir=dataEnv), "fileNames")],
                        envir=dataEnv)) # [!!!] revoir  [yr: 13/12/2011]


    ## V�rification de la configuration :
    filePathes <- testConfig.f(requiredVar=getOption("P.requiredVar"),
                               fileNames = fileNames,
                               dataEnv = dataEnv)

    ## chargement (conditionnel) des donn�es :
    if (! is.null(filePathes))
    {
        Data <- loadData.f(filePathes=filePathes, dataEnv=dataEnv, baseEnv = baseEnv)

        updateSummaryTable.f(get("tclarray", envir=baseEnv),
                             fileNames, Data,
                             get("table1", envir=baseEnv))
    }else{
        stop("Probl�me de configuration")
    }

    ## Calculs des poids (faits par AMP) :
    if ( ! is.benthos.f())
    {
        Data <- calcWeight.f(Data=Data)
    }else{}

    ## Assignement des donn�es dans l'environnement ad�quat :
    listInEnv.f(list=Data, env=dataEnv)

    ## assign("Data", Data, envir=.GlobalEnv) # [tmp]  [yr: 20/12/2011]

    ## Calcul des tables de m�triques :
    metrics <- calcTables.f(obs=Data$obs, unitobs=Data$unitobs, refesp=Data$refesp, dataEnv=dataEnv)

    stepInnerProgressBar.f(n=2, msg="Finalisation du calcul des tables de m�triques")

    ## Assignement des tables de m�triques dans l'environnement ad�quat :
    listInEnv.f(list=metrics, env=dataEnv)

    ## assign("metrics", metrics, envir=.GlobalEnv) # [tmp]  [yr: 20/12/2011]

    assign("backup", c(metrics,
                       list(obs=Data$obs),
                       tryCatch(list(".NombresSVR"=get(".NombresSVR", envir=dataEnv),
                                     ".DensitesSVR"=get(".DensitesSVR", envir=dataEnv)),
                                error=function(e){NULL})),
           envir=dataEnv)

    ## Export des tables de m�triques :
    stepInnerProgressBar.f(n=1, msg="Export des tables de m�triques dans des fichiers")

    exportMetrics.f(unitSpSz=metrics$unitSpSz, unitSp=metrics$unitSp, unit=metrics$unit,
                    obs=Data$obs, unitobs=Data$unitobs, refesp=Data$refesp,
                    filePathes=filePathes, baseEnv=baseEnv)

    ## Ajout des fichiers cr��s au log de chargement :
    add.logFrame.f(msgID="fichiers", env = baseEnv,
                   results=filePathes["results"],
                   has.SzCl=( ! is.null(metrics$unitSpSz) &&
                             prod(dim(metrics$unitSpSz))))

    ## Fin des informations de chargement (demande de confirmation utilisateur) :
    stepInnerProgressBar.f(n=2, msg="Fin de chargement !",
                           font=tkfont.create(weight="bold", size=9), foreground="darkred")

    updateInterface.load.f(baseEnv=baseEnv, tabObs=Data$obs)

    gestionMSGaide.f(namemsg="SelectionOuTraitement", env=baseEnv)

    infoLoading.f(button=TRUE, WinRaise=get("W.main", envir=baseEnv))

    ## [!!!] ajouter r�initialisation des menus si �chec  [yr: 14/12/2011]
    ## return(Data)
}

########################################################################################################################
chooseWS.f <- function(dir=getwd(), env=NULL)
{
    ## Purpose: Choix d'un r�pertoir de travail.
    ## ----------------------------------------------------------------------
    ## Arguments: dir : r�pertoir initial.
    ##            env : environnement de l'interface de choix de fichier
    ##                  (optionnel) pour la modification du r�sum�.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:45

    dir <- tclvalue(tkchooseDirectory(initialdir=ifelse(!is.na(dir),
                                                        dir, "")))

    if (!nchar(dir))
    {
        return(NULL)## Rien !
    }else{
        if (as.logical(length(grep("[dD]ata$", dir))) && !file.exists(paste(dir, "/Data", sep="")))
        {
            dir <- sub("/[dD]ata$", "", (oldDir <- dir))
            tkmessageBox(message=paste("\"", oldDir, "\" chang� en \"", dir, "\" !",
                         "\n\nLe dossier de donn�e est un sous-r�pertoire de l'espace de travail.", sep=""),
                         icon="warning")
        }else{}

        if (!is.null(env))
        {
            eval(substitute(evalq(tkconfigure(SummaryWS,
                                              text=dir,
                                              foreground="darkred"),
                                  envir=env),
                            list(dir=dir)))
        }else{}

        return(dir)
    }
}

########################################################################################################################
chooseUnitobs.f <- function(dir=getwd(), env=NULL)
{
    ## Purpose: Choix d'un fichier d'unit�s d'observation.
    ## ----------------------------------------------------------------------
    ## Arguments: dir : r�pertoir initial.
    ##            env : environnement de l'interface de choix de fichier
    ##                  (optionnel) pour la modification du r�sum�.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:45

    runLog.f(msg=c("Choix manuel du fichiers d'unit�s d'observations :"))

    nameUnitobs <- tclvalue(tkgetOpenFile(initialdir=paste(dir, "/Data/", sep="")))

    ## On enl�ve le nom de chemin pour ne conserver que le nom du fichier:
    nameUnitobs <- basename(nameUnitobs)

    if (!nchar(nameUnitobs))
    {
        return(NULL) ## Rien !
    }else{
        if (!is.null(env))
        {
            eval(substitute(evalq(tkconfigure(SummaryUnitobs,
                                              text=nameUnitobs,
                                              foreground="darkred"),
                                  envir=env),
                            list(nameUnitobs=nameUnitobs)))
        }else{}

        return(nameUnitobs)
    }
}

########################################################################################################################
chooseObservations.f <- function(dir=getwd(), env=NULL)
{
    ## Purpose: Choix d'un fichier d'observations
    ## ----------------------------------------------------------------------
    ## Arguments: dir : r�pertoir initial.
    ##            env : environnement de l'interface de choix de fichier
    ##                  (optionnel) pour la modification du r�sum�.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:45

    runLog.f(msg=c("Choix manuel du fichiers d'observations :"))

    namefileObs <- tclvalue(tkgetOpenFile(initialdir=paste(dir, "/Data/", sep="")))

    ## On enl�ve le nom de chemin pour ne conserver que le nom du fichier:
    namefileObs <- basename(namefileObs)

    if (!nchar(namefileObs))
    {
        return(NULL)
    }else{
        ## ici du coup, on peut y mettre un choix ou reconnaitre le r�f�rentiel automatiquement
        if (!is.null(env))
        {
            eval(substitute(evalq(tkconfigure(SummaryObs,
                                              text=namefileObs,
                                              foreground="darkred"),
                                  envir=env),
                            list(namefileObs=namefileObs)))
        }else{}

        return(namefileObs)
    }
}

########################################################################################################################
chooseRefesp.f <- function(dir=getwd(), env=NULL)
{
    ## Purpose: Choix d'un fichier de r�f�rentiel esp�ces
    ## ----------------------------------------------------------------------
    ## Arguments: dir : r�pertoir initial.
    ##            env : environnement de l'interface de choix de fichier
    ##                  (optionnel) pour la modification du r�sum�.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:50

    runLog.f(msg=c("Choix manuel du fichiers du r�f�rentiel esp�ces :"))

    namefileRef <- tclvalue(tkgetOpenFile(initialdir=paste(dir, "/Data/", sep="")))

    ## On enl�ve le nom de chemin pour ne conserver que le nom du fichier:
    namefileRef <- basename(namefileRef)

    if (!nchar(namefileRef))
    {
        return(NULL)
    }else{
        if (!is.null(env))
        {
            eval(substitute(evalq(tkconfigure(SummaryRefEsp,
                                              text=namefileRef,
                                              foreground="darkred"),
                                  envir=env),
                            list(namefileRef=namefileRef)))
        }else{}

        return(namefileRef)
    }
}

########################################################################################################################
chooseRefspa.f <- function(dir=getwd(), env=NULL)
{
    ## Purpose: Choix d'un fichier de r�f�rentiel spatial
    ## ----------------------------------------------------------------------
    ## Arguments: dir : r�pertoir initial.
    ##            env : environnement de l'interface de choix de fichier
    ##                  (optionnel) pour la modification du r�sum�.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:55

    runLog.f(msg=c("Choix manuel du fichiers du r�f�rentiel esp�ces :"))

    namefileRef <- tclvalue(tkgetOpenFile(initialdir=paste(dir, "/Data/", sep="")))

    ## On enl�ve le nom de chemin pour ne conserver que le nom du fichier:
    namefileRef <- basename(namefileRef)

    if (!nchar(namefileRef))
    {
        return(NULL)
    }else{
        if (!is.null(env))
        {
            eval(substitute(evalq(tkconfigure(SummaryRefSpa,
                                              text=namefileRef,
                                              foreground="darkred"),
                                  envir=env),
                            list(namefileRef=namefileRef)))
        }else{}

        return(namefileRef)
    }
}


########################################################################################################################
chooseFiles.f <- function(dataEnv)
{
    ## Purpose: Choix manuel des fichiers et dossiers.
    ## ----------------------------------------------------------------------
    ## Arguments: dataEnv : environnement des donn�es
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 14 d�c. 2011, 18:31

    runLog.f(msg=c("Interface de choix manuel des fichiers de donn�es."))


    ## ########################################################
    tt <- tktoplevel(height=50, width=300)
    tkwm.title(tt, "Choix des fichiers de donn�es � importer")

    ## Variables :
    Done <- tclVar(0)
    env <- environment()

    if (! missing(dataEnv) && is.environment(dataEnv) && exists("fileNames", envir=dataEnv))
    {
        fileNames <- get("fileNames", envir=dataEnv)
    }else{
        fileNames <- c(unitobs=NA,
                       obs=NA,
                       refesp=NA,
                       refspa=NA,
                       ws=getwd())
    }

    workSpaceTmp <- fileNames["ws"]
    unitobsTmp <- ifelse(is.na(fileNames["unitobs"]), character(), fileNames["unitobs"])
    obsTmp <- ifelse(is.na(fileNames["obs"]), character(), fileNames["obs"])
    refespTmp <- ifelse(is.na(fileNames["refesp"]), character(), fileNames["refesp"])
    refspaTmp <- ifelse(is.na(fileNames["refspa"]), character(), fileNames["refspa"])

    ## ########################################################

    ## Information importante :
    L.Info <-  tklabel(tt,
                       text=paste("L'espace de travail est le r�pertoire qui contient le dossier \"Data\".",
                                  "\nNe pas selectionner ce dernier !", sep=""),
                       bg="#FFFBCF", foreground="darkred",
                       font=tkfont.create(family="arial", ## weight="bold",
                                          size=9),#,
                       width=71, height=4, # taille.
                       relief="groove", borderwidth=2,
                       justify="left")

    button.widget0 <- tkbutton(tt, text="Espace de travail", ## width=45,
                               command=function()
                           {
                               if ( ! is.null(workSpaceTmp <- chooseWS.f(dir=workSpaceTmp, env=env)))
                               {
                                   assign("workSpaceTmp",
                                          workSpaceTmp,
                                          envir=env)
                               }
                           },
                               justify="left")

    button.widget1 <- tkbutton(tt, text="Table de donn�es d'unit�s d'observation",
                               command=function()
                           {
                               if ( ! is.null(unitobsTmp <- chooseUnitobs.f(dir=workSpaceTmp, env=env)))
                               {
                                   assign("unitobsTmp",
                                          unitobsTmp,
                                          envir=env)
                               }
                           },
                               justify="left")

    button.widget2 <- tkbutton(tt, text="Table de donn�es d'observations",
                               command=function()
                           {
                               if ( ! is.null(obsTmp <- chooseObservations.f(dir=workSpaceTmp, env=env)))
                               {
                                   assign("obsTmp",
                                          obsTmp,
                                          envir=env)
                               }
                           },
                               justify="left")

    button.widget3 <- tkbutton(tt, text="R�f�rentiel esp�ces",
                               command=function()
                           {
                               if ( ! is.null(refespTmp <- chooseRefesp.f(dir=workSpaceTmp, env=env)))
                               {
                                   assign("refespTmp",
                                          refespTmp,
                                          envir=env)
                               }
                           },
                               justify="left")

    button.widget4 <- tkbutton(tt, text="R�f�rentiel spatial (optionnel)",
                               command=function()
                           {
                               if ( ! is.null(refspaTmp <- chooseRefspa.f(dir=workSpaceTmp, env=env)))
                               {
                                   assign("refspaTmp",
                                          refspaTmp,
                                          envir=env)
                               }
                           },
                               justify="left")

    FrameBT <- tkframe(tt)

    OK.but <- tkbutton(FrameBT, text=" Valider ",
                       command=function(){tclvalue(Done) <- "1"})

    B.Cancel <- tkbutton(FrameBT, text="  Annuler  ",
                         command=function(){tclvalue(Done) <- "2"})

    tkgrid(L.Info,
           columnspan=2,
           pady=3, padx=5, sticky="ew")

    tkgrid(button.widget0,
           SummaryWS <- tklabel(tt, text=paste("non s�lectionn� - par d�faut :",
                                               ifelse(!is.na(workSpaceTmp),
                                                      workSpaceTmp, "RIEN !!!"))),
           pady=3, padx=5, sticky="w")

    tkgrid(button.widget1,
           SummaryUnitobs <- tklabel(tt, text=paste("non s�lectionn� - par d�faut :",
                                                    ifelse(!is.na(unitobsTmp),
                                                           unitobsTmp, "RIEN !!!"))),
           pady=3, padx=5, sticky="w")

    tkgrid(button.widget2,
           SummaryObs <- tklabel(tt, text=paste("non s�lectionn� - par d�faut :",
                                                ifelse(!is.na(obsTmp),
                                                       obsTmp, "RIEN !!!"))),
           pady=3, padx=5, sticky="w")

    tkgrid(button.widget3,
           SummaryRefEsp <- tklabel(tt, text=paste("non s�lectionn� - par d�faut :",
                                                   ifelse(!is.na(refespTmp),
                                                          refespTmp, "RIEN !!!"))),
           pady=3, padx=5, sticky="w")

    tkgrid(button.widget4,
           SummaryRefSpa <- tklabel(tt, text=paste("non s�lectionn� - par d�faut :",
                                                   ifelse(!is.na(refspaTmp),
                                                          refspaTmp, "RIEN !!!"))),
           pady=3, padx=5, sticky="w")

    tkgrid(OK.but, tklabel(FrameBT, text="            "), B.Cancel, pady=5, padx=5)

    tkgrid(FrameBT, pady=5, padx=5, columnspan=2)

    ## Informations sur l'espace de travail en gras au passage sur le bouton de choix de celui-ci :
    tkbind(button.widget0,
           "<Enter>", function(){tkconfigure(L.Info,
                                             font=tkfont.create(family="arial", weight="bold", size=9))})

    tkbind(SummaryWS,
           "<Enter>", function(){tkconfigure(L.Info,
                                             font=tkfont.create(family="arial", weight="bold", size=9))})

    tkbind(button.widget0,
           "<Leave>", function(){tkconfigure(L.Info,
                                             font=tkfont.create(family="arial", size=9))})

    tkbind(SummaryWS,
           "<Leave>", function(){tkconfigure(L.Info,
                                             font=tkfont.create(family="arial", size=9))})

    tkbind(tt, "<Destroy>", function(){tclvalue(Done) <- "2"})

    tkgrid.configure(button.widget0, button.widget1, button.widget2, button.widget3, button.widget4, sticky="ew")


    tkfocus(tt)
    tcl("update")
    winSmartPlace.f(tt)

    tkwait.variable(Done)

    if (tclvalue(Done) == "1")
    {
        tkdestroy(tt)

        fileNames <- c(unitobs=unname(unitobsTmp),
                       obs=unname(obsTmp),
                       refesp=unname(refespTmp),
                       refspa=unname(refspaTmp),
                       ws=unname(workSpaceTmp))

        ## Sauvegarde dans l'environnement des donn�es :
        if (! missing(dataEnv) && is.environment(dataEnv))
        {
            assign("fileNames", fileNames, envir=dataEnv)
        }else{}

        ## Retourne les noms de fichiers :
        return(fileNames)
    }else{
        tkdestroy(tt)

        return(NULL)
    }
}



### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:

