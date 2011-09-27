################################################################################
## Nom     : critereespref.f
## Objet   : choix d'un Facteur dans le r�f�rentiel esp�ce par l'utilisateur
## Input   : especes
## Output  : champ s�lectionn�
################################################################################

critereespref.f <- function ()
{
    runLog.f(msg=c("Choix d'un Facteur dans le r�f�rentiel esp�ces :"))

    Done <- tclVar("0")                 # Variable de statut d'ex�cussion.

    aa <- tktoplevel()
    tkwm.title(aa, "Selection du facteur du r�f�rentiel des esp�ces")

    ## Ascenceur :
    scr <- tkscrollbar(aa, repeatinterval=5, command=function(...)tkyview(tl, ...))

    tl <- tklistbox(aa, height=20, width=50, selectmode="single",
                    yscrollcommand=function(...)tkset(scr, ...),
                    background="white")

    ## Placement des �l�ments :
    tkgrid(tklabel(aa, text="Liste des facteurs du r�f�rentiel des esp�ces"))

    tkgrid(tl, scr)
    tkgrid.configure(scr, rowspan=4, sticky="ensw")
    tkgrid.configure(tl, rowspan=4, sticky="ensw")

    ## R�duction aux facteurs contenant de l'information : [yr: 30/09/2010]
    esptmp <- especes[is.element(especes$code_espece, obs$code_espece), ] # s�lection des lignes correspondant aux
                                        # obs.
    esptmp <- esptmp[ , sapply(esptmp, function(x){!all(is.na(x))})] # s�lection des champs qui contiennent autre
                                        # chose qu'uniquement des NAs.

    facts <- sort(names(esptmp))

    ## ici, on liste les AMP qui ne correspondent pas au jeu de donn�es :
    listeSite <- c("RUN" , "MAY" , "BA" , "BO" , "CB" , "CR" , "STM" , "NC")
    listeSiteExclus <- subset(listeSite, listeSite!=SiteEtudie)

    ## On retire les champs contenant les lettres des sites exclus :
    for (k in (seq(along=listeSiteExclus)))
    { # On peut faire plus simple [yr: 03/08/2010]
        facts <- facts[ ! grepl(paste(listeSiteExclus[k], "$", sep=""),
                                facts)]
    }

    ## Ajout des facteur dans la liste :
    for (i in seq(along=facts))
    {
        tkinsert(tl, "end", facts[i])
    }

    ## Frame pour les boutons :
    F.button <- tkframe(aa)

    ## Bouton OK :
    B.OK <- tkbutton(F.button, text="  OK  ",
                       command=function()
                   {
                       assign("factesp",
                              facts[as.numeric(tkcurselection(tl))+1],
                              parent.env(environment()))

                       tclvalue(Done) <- 1
                   })

    ## Bouton d'annulation :
    B.Cancel <- tkbutton(F.button, text=" Annuler ",
                         command=function(){tclvalue(Done) <- 2})

    tkgrid(B.OK, tklabel(F.button, text="\t"), B.Cancel, padx=10)
    tkgrid(F.button, pady=5, ## sticky="we",
           columnspan=2)

    tkbind(aa, "<Destroy>", function(){tclvalue(Done) <- 2})

    winSmartPlace.f(aa)
    tkfocus(tl)

    ## Attente d'une action de l'utilisateur :
    tkwait.variable(Done)

    ## On retourne la s�lection :
    if (tclvalue(Done) == 1)
    {
        tkdestroy(aa)
        return(factesp)
    }else{
        tkdestroy(aa)
        return(NULL)
    }
} # fin critereespref.f

################################################################################
## Nom     : ChoixFacteurSelect.f
## Objet   : choix d'un Facteur de s�lection par l'utilisateur
## Input   : table, nom de table, nom de champ, un nombre de s�lection ("single" ou "multiple"
## Output  : valeur(s) du champ s�lectionn�
################################################################################

ChoixFacteurSelect.f <- function (tableselect, monchamp, Nbselectmax, ordre)
{
    winfac <- tktoplevel(width = 80)
    tkwm.title(winfac, paste("Selection des valeurs de ", monchamp, sep=""))

    scr <- tkscrollbar(winfac, repeatinterval=5, command=function(...)tkyview(tl, ...))

    if (Nbselectmax=="single"||Nbselectmax=="multiple") # [???] � quoi �a sert de faire �a, puisque la fonction ne g�re
                                        # pas les erreurs ! [yr: 30/09/2010]
    {
        tl <- tklistbox(winfac, height=20, width=50, selectmode=Nbselectmax,
                        yscrollcommand=function(...)tkset(scr, ...), background="white")
    }
    tkgrid(tklabel(winfac, text=paste("Liste des valeurs de ", monchamp,
                           " presents\n Plusieurs s�lections POSSIBLES", sep="")))

    tkgrid(tl, scr)
    tkgrid.configure(scr, rowspan=4, sticky="ensw")
    tkgrid.configure(tl, rowspan=4, sticky="ensw")

    if (ordre==1)
    {
        maliste <- sort(as.character(unique(tableselect)))
    }

    ## On remplit la liste de choix :
    for (i in seq(along=maliste))
    {
        tkinsert(tl, "end", maliste[i])
    }

    OnOK <- function ()
    {
        assign("selectfact",
               eval(maliste[as.numeric(tkcurselection(tl))+1], envir=parent.env(environment())),
               envir=parent.env(environment()))

        tkdestroy(winfac)
    }

    OK.but <-tkbutton(winfac, text="OK", command=OnOK)
    tkgrid(OK.but, pady=5)

    winSmartPlace.f(winfac)
    tkfocus(tl)

    tkwait.window(winfac)

    if (exists("selectfact") && length(selectfact))
    {
        return(selectfact)
    }else{
        return(NULL)
    }

    ## !am�liorations possibles
    ## a utiliser si concat�nation de monchamp et matable
    ## mavar=paste(matable, "$", monchamp, sep="")
    ## mavar=unique(eval(parse(text=mavar)))
    ## ssi return possible,
    ## as character sinon, la variable retourn�e est de mode "externalptr"
}


################################################################################
## Nom    : choixunfacteurUnitobs.f()
## Objet  : choix du facteur de groupement des unit�s d'observations
## Input  : tables "unit" et "unitobs"
## Output : table "unit" + le facteur de la table unitobs choisi
################################################################################

choixunfacteurUnitobs.f <- function ()
{
    runLog.f(msg=c("Choix d'un Facteur dans le r�f�rentiel des unit�s d'observation :"))

    Done <- tclVar("0")                 # Variable de statut d'ex�cussion.

    aa <- tktoplevel()
    tkwm.title(aa, "Selection du facteur de groupement des unites d'observation")

    scr <- tkscrollbar(aa, repeatinterval=5,
                       command=function(...)tkyview(tl, ...))

    tl <- tklistbox(aa, height=20, width=50, selectmode="single",
                    yscrollcommand=function(...)tkset(scr, ...),
                    background="white")

    tkgrid(tklabel(aa, text="Liste des facteurs de groupement"))
    tkgrid(tl, scr)
    tkgrid.configure(scr, rowspan=4, sticky="ensw")
    tkgrid.configure(tl, rowspan=4, sticky="ensw")

    ## R�duction aux facteurs contenant de l'information : [yr: 30/09/2010]
    uobstmp <- unitobs[is.element(unitobs$unite_observation, obs$unite_observation), ] # s�lection des lignes
                                        # correspondant aux obs.
    uobstmp <- uobstmp[ , sapply(uobstmp, function(x){!all(is.na(x))})] # s�lection des champs qui contiennent autre
                                        # chose qu'uniquement des NAs.

    facts <- sort(names(uobstmp))

    ## On remplit la liste de choix :
    for (i in (seq(along=facts)))
    {
        tkinsert(tl, "end", facts[i])
    }

    ## Frame pour les boutons :
    F.button <- tkframe(aa)

    ## Bouton OK :
    B.OK <- tkbutton(F.button, text="  OK  ",
                       command=function()
                   {
                       assign("factunitobs",
                              facts[as.numeric(tkcurselection(tl))+1],
                              parent.env(environment()))

                       tclvalue(Done) <- 1
                   })

    ## Bouton d'annulation :
    B.Cancel <- tkbutton(F.button, text=" Annuler ",
                         command=function(){tclvalue(Done) <- 2})

    tkgrid(B.OK, tklabel(F.button, text="\t"), B.Cancel, padx=10)
    tkgrid(F.button, pady=5, ## sticky="we",
           columnspan=2)

    tkbind(aa, "<Destroy>", function(){tclvalue(Done) <- 2})

    winSmartPlace.f(aa)
    tkfocus(tl)

    ## Attente d'une action de l'utilisateur :
    tkwait.variable(Done)

    ## On retourne la s�lection :
    if (tclvalue(Done) == 1)
    {
        tkdestroy(aa)
        return(factunitobs)
    }else{
        tkdestroy(aa)
        return(NULL)
    }
} # fin choixunfacteurUnitobs

################################################################################
## Nom     : choixespeces.f
## Objet   : s�lection d'un fichier esp�ces par l'utilisateur
## Input   : fichier "especes" au m�me format que le r�f�rentiel
## Output  : table "especes" modifi�e
################################################################################

choixespeces.f <- function()
{
    runLog.f(msg=c("Chargement d'une liste d'esp�ces � conserver (fichier) :"))

    ## fenetre de chargement du fichier des especes � analyser
    nameFichierEspecesAnalyser <- tclvalue(tkgetOpenFile())
    if (!nchar(nameFichierEspecesAnalyser))
    {
        tkmessageBox(message="Aucun fichier n'a ete selectionne!")
    }else{
        assign("fileNameRefEsp", nameFichierEspecesAnalyser, envir=.GlobalEnv)
        lectureFichierEspeces.f()
    }

    ## filtre de la table observations
    obs <- subset(obs, obs$code_espece %in% especes$code_espece)
    obs.genre <- subset(obs, obs$Genre %in% especes$Genre)
    obs.espece <- subset(obs, obs$espece %in% especes$espece)

    assign("obs", obs, envir=.GlobalEnv)

    ## filtre de la table unite d'observations
    listeEspecesUnitobsAnalyse <- unique(obs$unite_observation)
    unitobs <- subset(unitobs, unitobs$unite_observation %in% listeEspecesUnitobsAnalyse)
    assign("unitobs", unitobs, envir=.GlobalEnv)

    ## on refait la table de contingence
    contingence <- tapply(obs$nombre,
                          list(obs$unite_observation, obs$code_espece),
                          sum, na.rm=TRUE)

    contingence[is.na(contingence)] <- 0
    ## Suppression des especes qui ne sont jamais vues
    ## Sinon problemes pour les calculs d'indices de diversit�.
    a <- which(apply(contingence, 2, sum, na.rm=TRUE) == 0)

    if (length(a) != 0)
    {
        contingence <- contingence[, -a, drop=FALSE]
    }
    rm(a)

    ## idem
    b <- which(apply(contingence, 1, sum, na.rm=TRUE) == 0)
    if (length(b) != 0)
    {
        contingence <- contingence[-b, , drop=FALSE]
    }
    rm(b)
    assign("contingence", contingence, envir=.GlobalEnv)

    write.csv2(contingence,
               file=paste(nameWorkspace, "/FichiersSortie/ContingenceUnitObsEspeces",
                          ifelse(Jeuxdonnescoupe, "_selection", ""),
                          ".csv", sep=""))

    ## on recr�e les tables de base
    creationTablesBase.f()
    Jeuxdonnescoupe <- 1

    tkmessageBox(message=paste("ATTENTION, les tables 'Observations' et 'Unites observations'",
                               " ont ete reduites aux especes selectionnees .", sep=""),
                 icon="warning", type="ok")
} # fin choixespeces.f()


################################################################################
## Nom    : UnCritereEspDansObs.f
## Objet  : Restreindre le fichier obs � uniquement un critere du referentiel sp�cifique
## Input  : table "obs"
## Output : table obs pour une valeur d'un champ du referentiel sp�cifique
################################################################################

UnCritereEspDansObs.f <- function ()
{
    runLog.f(msg=c("S�lection sur un crit�re du r�f�rentiel esp�ces :"))

    factesp <- critereespref.f()

    if (length(factesp) == 0 || is.null(factesp))
    {
        selectfactesp <- NULL
    }else{
        obs[, factesp] <- especes[, factesp][match(obs$code_espece, especes$code_espece)]

        levelsTmp <- levels(obs$code_espece)

        selectfactesp <- selectModWindow.f(factesp, obs, selectmode="extended")
        assign("selectfactesp", selectfactesp, envir=.GlobalEnv)
    }

    if (!is.null(selectfactesp))
    {
        obs <- dropLevels.f(subset(obs, is.element(obs[, factesp], selectfactesp)), which="code_espece")

        ## R�int�gration des niveaux s�lectionn�s mais plus pr�sents dans les donn�es :
        levelsTmp <- levelsTmp[is.element(levelsTmp,
                                          especes$code_espece[is.element(especes[ , factesp],
                                                                         selectfactesp)])]

        obs$code_espece <- factor(obs$code_espece, levels=levelsTmp)

        gestionMSGaide.f("etapeselected")

        ## On d�finit globalement que l'on travaille sur une s�lection :
        assign("Jeuxdonnescoupe", 1, envir=.GlobalEnv)

        return(list(facteur=factesp,
                    selection=selectfactesp,
                    obs=obs))
    }else{}
}



################################################################################
## Nom    : UnCritereUnitobsDansObs.f
## Objet  : Restreindre le fichier obs � uniquement un critere du referentiel sp�cifique
## Input  : table "obs"
## Output : table obs pour une valeur d'un champ du referentiel sp�cifique
################################################################################

UnCritereUnitobsDansObs.f <- function ()
{
    runLog.f(msg=c("S�lection sur un crit�re du r�f�rentiel des unit�s d'observation :"))

    factunitobs <- choixunfacteurUnitobs.f()

    if (length(factunitobs) == 0 || is.null(factunitobs))
    {
        selectfactunitobs <- NULL
    }else{
        obs[, factunitobs] <- unitobs[, factunitobs][match(obs$unite_observation, unitobs$unite_observation)]

        levelsTmp <- levels(obs$unite_observation)

        selectfactunitobs <- selectModWindow.f(factunitobs, obs, selectmode="extended")
        assign("selectfactunitobs", selectfactunitobs, envir=.GlobalEnv)
    }

    if (!is.null(selectfactunitobs))
    {
        obs <- dropLevels.f(subset(obs, is.element(obs[, factunitobs], selectfactunitobs)),
                            which="unite_observation") # V�rifier si c'est correct [!!!]

        ## R�int�gration des niveaux s�lectionn�s mais plus pr�sents dans les donn�es :
        levelsTmp <- levelsTmp[is.element(levelsTmp,
                                          unitobs$unite_observation[is.element(unitobs[ , factunitobs],
                                                                               selectfactunitobs)])]

        obs$unite_observation <- factor(obs$unite_observation, levels=levelsTmp)

        gestionMSGaide.f("etapeselected")

        ## On d�finit globalement que l'on travaille sur une s�lection :
        assign("Jeuxdonnescoupe", 1, envir=.GlobalEnv)

        return(list(facteur=factunitobs,
                    selection=selectfactunitobs,
                    obs=obs))
    }else{}
}
