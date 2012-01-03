
########################################################################################################################
reorderStatus.f <- function(Data, which="statut_protection")
{
    ## Purpose: R�ordonner les nivaux du status de protection
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de donn�es.
    ##            which : l'indice de la colonne (de pr�f�rence un nom).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  1 juin 2011, 14:10

    if (is.factor(Data[ , which]))
    {
        Data[ , which] <- factor(Data[ , which],
                                 levels=c(getOption("P.statusOrder")[is.element(getOption("P.statusOrder"),
                                                                                levels(Data[ , which]))],
                                          levels(Data[ , which])[!is.element(levels(Data[ , which]),
                                                                             getOption("P.statusOrder"))]))

        return(Data)
    }else{
        stop("Pas un facteur !")
    }
}

########################################################################################################################
PlanEchantillonnageBasic.f <- function(tabUnitobs, tabObs)
{
    ## Purpose: �crire le plan d'�chantillonnage basic dans un fichier.
    ## ----------------------------------------------------------------------
    ## Arguments: tabUnitobs : table des unit�s d'observation (data.frame).
    ##            tabObs : table des observations (data.frame).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 sept. 2011, 13:53

    PlanEchantillonnage <- with(dropLevels.f(tabUnitobs[is.element(tabUnitobs$unite_observation,
                                                                   levels(tabObs$unite_observation)), ]),
                                table(an, statut_protection, exclude = NA))

    attr(PlanEchantillonnage, "class") <- "array" # Pour un affichage en "tableau".

    write.csv2(PlanEchantillonnage,
               file=paste(NomDossierTravail, "PlanEchantillonnage_basique",
                          ifelse(Jeuxdonnescoupe, "_selection", ""),
                          ".csv", sep=""), row.names=TRUE)
}


########################################################################################################################
selectionObs.SVR.f <- function()
{
    ## Purpose: D�finir le seuil de Dmin (en m) au-dessus duquel les
    ##          observations ne sont pas prises en compte.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  8 nov. 2010, 10:29

    onOK.selectionObs.SVR.f <- function()
    {
        ## Purpose: Action lorsque le bouton de choix de seuil pour les SVR est
        ##          cliqu�.
        ## ----------------------------------------------------------------------
        ## Arguments: aucun
        ## ----------------------------------------------------------------------
        ## Author: Yves Reecht, Date:  8 nov. 2010, 12:01

        if (tclvalue(Suppr) == "1")
        {
            if (!is.na(as.numeric(tclvalue(Level))))
            {
                tclvalue(Done) <- "1"
            }else{
                tclvalue(Done) <- "2"
            }
        }else{
            tclvalue(Level) <- Inf
            tclvalue(Done) <- "1"
        }
    }

    dminDefault <- 5                    # 5m par d�faut.

    Done <- tclVar("0")
    Suppr <- tclVar("1")                # Seuil utilis� par d�faut.
    Level <- tclVar(dminDefault)        # tclVar pour le seuil (initialis�e au d�faut).

    WinSVR <- tktoplevel()
    tkwm.title(WinSVR, "S�lection des observations")

    FrameInfo <- tkframe(WinSVR, borderwidth=2, relief="groove")

    CB.supprObs <- tkcheckbutton(WinSVR, variable=Suppr)
    E.supprLevel <- tkentry(WinSVR, width=3, textvariable=Level)

    FrameBT <- tkframe(WinSVR)
    BT.OK <- tkbutton(FrameBT, text="   OK   ",
                      command=onOK.selectionObs.SVR.f)

    tkbind(WinSVR, "<Destroy>", function(){tclvalue(Done) <- "3"}) # En cas de destruction de fen�tre.
    tkbind(E.supprLevel, "<Return>", onOK.selectionObs.SVR.f)

    ## Placement des �l�ments graphiques :
    tkgrid(tklabel(WinSVR, text=""))

    tkgrid(FrameInfo, column=2, columnspan=2, sticky="we")
    tkgrid(tklabel(FrameInfo,
                   text=paste("Information\n\n Types d'interpolations : ",
                   ifelse(getOption("PAMPA.SVR.interp") == "extended",
                          "�tendues !",
                          "simples !"), "\n", sep=""), justify="left"), sticky="w")

    tkgrid(tklabel(WinSVR, text=""))

    tkgrid(tklabel(WinSVR, text="\t"),
           CB.supprObs,
           tklabel(WinSVR, text="  Ne conserver que les observations pour lesquelles Dmin =< "),
           E.supprLevel,
           tklabel(WinSVR, text="m ?\t "))

    tkgrid(tklabel(FrameBT, text="\n\t"),
           BT.OK,
           tklabel(FrameBT, text="\t\n"))
    tkgrid(FrameBT, column=0, columnspan=5)

    tkfocus(E.supprLevel)

    winSmartPlace.f(WinSVR, xoffset=-200, yoffset=-50)

    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        switch(tclvalue(Done),
               "1"={                    # Statut OK :
                   tkdestroy(WinSVR)
                   return(as.numeric(tclvalue(Level)))
               },
               "2"={                    # Le seuil n'est pas num�rique :
                   tkmessageBox(message="Vous devez choisir un seuil num�rique (s�parateur '.')",
                                icon="error")
                   tclvalue(Done) <- "0"
                   tkfocus(E.supprLevel)
                   winRaise.f(WinSVR)
                   next()
               },
               "3"={                    # Destruction de la fen�tre :
                   return(NULL)
               })
    }

    tkdestroy(WinSVR)
}


################################################################################
## Nom    : lectureFichierEspeces.f()
## Objet  : lecture du r�f�rentiel esp�ces
## Input  : fichier esp�ces
## Output : table esp�ces
## Modif 02/12/09 lecture d'un fichier CSV (DP)
################################################################################

lectureFichierEspeces.f <- function ()
{
    ## rm(especes)
    runLog.f(msg=c("Chargement du r�f�rentiel esp�ces :"))

    ## Importation des caracteristiques des especes
    especes <- read.table(pathRefesp, sep="\t", dec=".", quote="", header=TRUE, encoding="latin1")
    names(especes) <- c("code_espece", "GrSIH", "CodeSIH", "IssCaap", "TaxoCode", "CodeFAO", "CodeFB", "Phylum",
                        "Cat_benthique", "Classe", "Ordre", "Famille", "Genre", "espece", "Identifiant", "ObsNC",
                        "ObsRUN", "ObsMAY", "ObsSTM", "ObsCB", "ObsBA", "ObsBO", "ObsCR", "taillemax", "L50",
                        "cryptique", "mobilite", "territorial", "nocturne", "comportement.grp", "agreg.saison",
                        "position.col.eau", "strategie.demo", "Type.ponte", "Habitat.Prefere", "Changement.sexe",
                        "regim.alim", "interet.chasseNC", "interet.chasseRUN", "interet.chasseMAY", "interet.chasseSTM",
                        "interet.chasseCB", "interet.chasseBA", "interet.chasseBO", "interet.chasseCR",
                        "interet.ligneNC", "interet.ligneRUN", "interet.ligneMAY", "interet.ligneSTM",
                        "interet.ligneCB", "interet.ligneBA", "interet.ligneBO", "interet.ligneCR", "interet.filetNC",
                        "interet.filetRUN", "interet.filetMAY", "interet.filetSTM", "interet.filetCB",
                        "interet.filetBA", "interet.filetBO", "interet.filetCR", "interet.casierNC",
                        "interet.casierRUN", "interet.casierMAY", "interet.casierSTM", "interet.casierCB",
                        "interet.casierBA", "interet.casierBO", "interet.casierCR", "interet.piedNC", "interet.piedRUN",
                        "interet.piedMAY", "interet.piedSTM", "interet.piedCB", "interet.piedBA", "interet.piedBO",
                        "interet.piedCR", "interetComMAY", "Coeff.a.Med", "Coeff.b.Med", "Coeff.a.NC", "Coeff.a.MAY",
                        "Coeff.b.NC", "Coeff.b.MAY", "poids.moyen.petits", "poids.moyen.moyens", "poids.moyen.gros",
                        "taille_max_petits", "taille_max_moyens", "niveau.a.et.b.MED", "niveau.a.et.b.NC",
                        "niveau.a.et.b.MAY", "emblematiqueNC", "emblematiqueRUN", "emblematiqueMAY", "emblematiqueSTM",
                        "emblematiqueCB", "emblematiqueBA", "emblematiqueBO", "emblematiqueCR", "stat.IUCN",
                        "autre.statutNC", "autre.statutRUN", "autre.statutMAY", "autre.statutSTM", "autre.statutCB",
                        "autre.statutBA", "autre.statutBO", "autre.statutCR", "etat.pop.localNC", "etat.pop.localRUN",
                        "etat.pop.localMAY", "etat.pop.localSTM", "etat.pop.localCB", "etat.pop.localBA",
                        "etat.pop.localBO", "etat.pop.localCR", "endemiqueNC", "endemiqueRUN", "endemiqueMAY",
                        "endemiqueSTM", "endemiqueCB", "endemiqueBA", "endemiqueBO", "endemiqueCR")


    ## Verification du nombre de colonnes:
    if (ncol(especes) != 125)
    {
        rm(especes)
        gestionMSGerreur.f("nbChampEsp")
    }
    if (nrow(especes)!=0)
    {
        especes[especes=="-999"] <- NA
    }

    ## Ajout de cath�gories benthiques suppl�mentaires lues dans un fichier de correspondance :
    correspCatBenthique <- read.csv(paste(basePath,
                                          "/Scripts_Biodiv/corresp-cat-benth.csv", sep=""),
                                    row.names=1)

    especes <- cbind(especes, correspCatBenthique[as.character(especes$Cat_benthique), , drop=FALSE])

    ## Pour v�rif :
    ## na.omit(especes[as.integer(runif(50,min=1, max=3553)), c("Cat_benthique", "CategB_general", "CategB_groupe")])

    ## Suppression de la ligne en NA
    especes <- subset(especes, !is.na(especes$code_espece))
    ## assign("especes", especes, envir=.GlobalEnv)
    return(especes)
}

################################################################################
## Nom    : opendefault.f()
## Objet  : choix de l'espace de travail par defaut C:/PAMPA
##          si pas fait, cr�e le dossier,
##          teste la pr�sence de Fichiersortie/ si pas fait, cr�e le dossier,
##          cr�ation de la table des observations,
##          cr�ation de la table des unit�s d'observations,
##          cr�ation du r�f�rentiel esp�ces
##          cr�ation d'une table de contingence
##          cr�ation d'un r�capitulatif du plan d'�chantillonnage
## A FINIR
## Input  : fichier esp�ces
##          fichier observations
##          fichier unit� d'observations
## Output : table esp�ces
##          table observations
##          table unit� d'observations
##          fichier et table de contingence
##          fichier et table plan d'�chantillonnage
################################################################################

## Creation de l'environnement par defaut
environnementdefault.f <- function (nameWorkspace)
{
    runLog.f(msg=c("V�rification de l'environnement de travail :"))

    if (!missing(nameWorkspace))
    {
        if (file.access(nameWorkspace, mode = 0)== 0)
        {
            if (file.access(paste(nameWorkspace, "/FichiersSortie", sep=""), mode = 0)==-1)
            {
                dir.create(paste(nameWorkspace, "/FichiersSortie", sep=""),
                           showWarnings = TRUE, recursive = FALSE, mode = "0777")
            }
        }else{
            dir.create(nameWorkspace, showWarnings = TRUE, recursive = FALSE, mode = "0777")
            dir.create(paste(nameWorkspace, "/FichiersSortie", sep=""),
                       showWarnings = TRUE, recursive = FALSE, mode = "0777")
        }
        return(nameWorkspace)

    }else{
        gestionMSGerreur.f("noWorkspace")
    }
}

## Choix par defauts de C:/PAMPA
opendefault.f <- function ()
{

    pampaProfilingStart.f()

    runLog.f(msg=c("--------------------------------------------------------------------------------",
                   "Nouveau chargement des donn�es :"))

    pathMaker.f(nameWorkspace=nameWorkspace,
                fileNameUnitobs=fileNameUnitobs,
                fileNameObs=fileNameObs,
                fileNameRefesp=fileNameRefesp)
                                        # M�J des variables "pathUnitobs", "pathObs", "pathRefesp". Pour les
                                        # cas o� les variables fileNameUnitobs-Refesp auraient chang�.

    add.logFrame.f(msgID="dataLoading", env = .GlobalEnv,
                   workSpace=nameWorkspace, fileObs=pathObs,
                   fileEsp=pathRefesp, fileUnitobs=pathUnitobs)

    assign("Jeuxdonnescoupe", 0, envir=.GlobalEnv)

    ## Informations de chargement (initialisation) :
    infoGeneral.f(msg="      Chargement des donn�es      ",
                  font=tkfont.create(weight="bold", size=9), foreground="darkred")

    initInnerTkProgressBar.f(initial=0, max=24, width=450)
    stepInnerProgressBar.f(n=0, msg="Chargement du r�f�rentiel d'unit�s d'observation")


    tkconfigure(ResumerEspaceTravail, text=paste("Espace de travail : ", nameWorkspace))

    environnementdefault.f(nameWorkspace)

    ## ################################################################################

    unitobs <- read.table(pathUnitobs, sep="\t", dec=".", header=TRUE, encoding="latin1")
    colnames(unitobs) <- c("AMP", "unite_observation", "type", "site", "station", "caracteristique_1", "caracteristique_2",
         "fraction_echantillonnee", "jour", "mois", "an", "heure", "nebulosite", "direction_vent", "force_vent",
         "etat_mer", "courant", "maree", "phase_lunaire", "latitude", "longitude", "statut_protection", "avant_apres",
         "biotope", "biotope_2", "habitat1", "habitat2", "habitat3", "visibilite", "prof_min", "prof_max", "DimObs1",
         "DimObs2", "nb_plong", "plongeur")

    ## �ventuelle reconfiguration de la barre de progression du chargement :
    switch(as.character(unique(unitobs$type)[1]),
           "SVR"={},                    # rien � faire.
           "LIT"={
               reconfigureInnerProgressBar.f(max=9)
           },                           # Pour le benthos on ne calcule pas les m�triques / classe de taille.
           {
               reconfigureInnerProgressBar.f(max=12) # Dans tous les autres cas : 8
           })

    levels(unitobs$caracteristique_1) <- c(levels(unitobs$caracteristique_1), "NA") # bon �a corrige l'erreur ci-dessous
                                        # mais est-ce bien n�cessaire ? [yr: 23/08/2010]
    unitobs$caracteristique_1[is.na(unitobs$caracteristique_1)] <- "NA" # [!!!]

    ## Si les unit�s d'observation sont ne sont pas des facteurs :
    if (!is.factor(unitobs$unite_observation))
    {
        unitobs$unite_observation <- factor(as.character(unitobs$unite_observation))
    }

    ## Si caracteristique_2 est au format ann�e de campagne, renommer la colonne :
    if (is.temporal.f("caracteristique_2", unitobs))
    {
        colnames(unitobs)[colnames(unitobs) == "caracteristique_2"] <- "annee.campagne"
    }

    if (unique(unitobs$type)[1]=="PecRec")
    {
        x.lt <- as.POSIXlt(as.character(unitobs$heure), format="%Hh%M")
        unitobs$heureEnq <- x.lt$hour + x.lt$min/60 + x.lt$sec/3600
        x.lt <- as.POSIXlt(as.character(unitobs$DimObs1), format="%Hh%M")
        unitobs$heureDeb <- x.lt$hour + x.lt$min/60 + x.lt$sec/3600


        unitobs$DimObs1 <- sapply(seq(length.out=nrow(unitobs)),
                                  function(i)
                              {
                                  switch(as.character(unitobs$heureEnq[i] < unitobs$heureDeb[i]),
                                         "TRUE"=(24 - unitobs$heureDeb[i]) + unitobs$heureEnq[i],
                                         "FALSE"=unitobs$heureEnq[i] - unitobs$heureDeb[i],
                                         "NA"=NA)
                              })

        unitobs$DimObs1[unitobs$DimObs1 == 0] <- NA
    }

    if (nrow(unitobs)!=0)
    {
        unitobs[unitobs=="-999"] <- NA
    }

    ## Reorganisation des niveaux de protection :
    unitobs <- reorderStatus.f(Data=unitobs, which="statut_protection")

    ## Ann�es : integer -> factor (n�cessaire pour les analyses stats):
    unitobs$an <- factor(unitobs$an)

    assign("unitobs", unitobs, envir=.GlobalEnv)
    assign("siteEtudie", unique(unitobs$AMP), envir=.GlobalEnv)

    ## Chargement des observations :
    stepInnerProgressBar.f(n=1, msg="Chargement du fichier d'observations")

    obs <- read.table(pathObs, sep="\t", dec=".", header=TRUE, encoding="latin1")

    if (unique(unitobs$type)[1] != "SVR")
    {
        colnames(obs) <- c("unite_observation", "secteur", "code_espece", "sexe", "taille", "classe_taille", "poids",
                           "nombre", "dmin", "dmax")
    }else{
        ## On renomme les colonnes + identification du type d'interpolation :
        switch(as.character(ncol(obs)),
               "11"={
                   colnames(obs) <- c("unite_observation", "rotation", "secteur", "code_espece", "sexe", "taille",
                                      "classe_taille", "poids", "nombre", "dmin", "dmax")

                   options(PAMPA.SVR.interp="extended")
               },
               "14"={
                   colnames(obs) <- c("unite_observation", "rotation", "sec.valides", "sec.ciel", "sec.sol",
                                      "sec.obstrue", "code_espece", "sexe", "taille",
                                      "classe_taille", "poids", "nombre", "dmin", "dmax")

                   options(PAMPA.SVR.interp="basic")
               },
               stop("Le fichier d'observations ne contient pas le bon nombre de colonnes"))

        obs$rotation <- as.numeric(obs$rotation)

        dminMax <- NULL
        while (is.null(dminMax))
        {
            dminMax <- selectionObs.SVR.f()
        }

        ## On ne tient pas compte des observations � une distance > dminMax
        ## (pas de subset car tendance � faire dispara�tre des unitobs des analyses) :
        idxSupr <- obs$dmin > dminMax

        obs$nombre[idxSupr] <- 0
        obs$poids[idxSupr] <- NA
        obs$taille[idxSupr] <- NA

        ## obs <- subset(obs, dmin <= dminMax)
    }

    ## remplacement des -999 en NA
    if (as.logical(nrow(obs)))                      # !=0
    {
        obs[obs == "-999"] <- NA
    }

    ## nombre : numeric -> factor (n�cessaire pour une bonne prise en compte dans les analyses stat) :
    obs$nombre <- as.integer(obs$nombre)

    ## Si les unit�s d'observation sont ne sont pas des facteurs :
    if (!is.factor(obs$unite_observation))
    {
        obs$unite_observation <- factor(as.character(obs$unite_observation))
    }

    if (!all(is.element(obs$unite_observation, unitobs$unite_observation))) # �a devrait �tre mieux
                                        # comme �a !
    {
        ## cas ou obs contient des unites d'obs absentes dans unitobs
        warning("La table observations contient des unit�s d'observation absentes dans la table unitobs.")

        ## Ajout du message pour le chargement :
        infoLoading.f(msg=paste("Attention, la Table obs contient ",
                                sum(!is.element(obs$unite_observation, unitobs$unite_observation)),
                                " (sur ",
                                nrow(obs),
                                ") enregistrements ",
                                "\navec des unit�s d'observation absentes dans la table unitobs.",
                                sep=""),
                     icon="warning")
    }

    ## Chargement du r�f�rentiel esp�ces :
    stepInnerProgressBar.f(n=1, msg="Chargement du r�f�rentiel esp�ces")

    ## R�f�rentiel esp�ces :
    assign("especes", lectureFichierEspeces.f(), envir=.GlobalEnv)

    #####################################################
    ## Plan d'�chantillonnage (� refaire compl�tement) :
    stepInnerProgressBar.f(n=1, msg="Plan d'�chantillonnage")

    ## ############# R�capitulatif du plan d'�chantillonnage #############
    PlanEchantillonnageBasic.f(tabUnitobs=unitobs, tabObs=obs)


    ## ################
    assign("obs", obs, envir=.GlobalEnv)

    ## Information sur l'AMP s�lectionn�e et le type d'observations analys�es :
    tkconfigure(ResumerAMPetType,
                text=paste("Aire Marine Prot�g�e : ", unique(unitobs$AMP), " ; type d'observation : ",
                           unique(unitobs$type), sep=""))

    ## Conversion des dates (tester si meilleur endroit pour faire �a) [yr: 17/08/2010] :


    ## Verification du type d'observation
    paste("Type d'observation =", unique(unitobs$type), sep=" ") # [inc] broken !
    if (length(unique(unitobs$type)) > 1)
    {
        tkmessageBox(message=paste("Un seul type d'observation � la fois peut �tre analys� :\n\n",
                                   "Choisissez le type d'observation que vous souhaitez analyser.", sep=""),
                     icon="warning", type="ok")

        message("Choix du type de jeux de donn�es activ�")
        ## browser()

        while (is.null(selectType <- ChoixFacteurSelect.f(unitobs$type, "type", "single", 1)))
        {}

        message("Choix du type de jeux de donn�es activ�, s�lection sur :")
        message(selectType)

        obs$type <- unitobs$type[match(obs$unite_observation, unitobs$unite_observation), drop=TRUE]

        obs <- dropLevels.f(subset(obs, obs$type == selectType))
        unitobs <- dropLevels.f(subset(unitobs, unitobs$type == selectType))

        assign("obs", obs, envir=.GlobalEnv)
        assign("unitobs", unitobs, envir=.GlobalEnv)

        ## Reconfiguration des infos sur l'AMP s�lectionn�e et le type d'observations analys�es :
        tkconfigure(ResumerAMPetType,
                    text=paste("Aire Marine Prot�g�e : ", unique(unitobs$AMP), " ; type d'observation : ",
                    unique(unitobs$type), sep=""))

    }

    ## Creation des tables de base :
    creationTablesBase.f()

    ## Exportation de la table de contingence si elle existe :
    if (exists("contingence", envir=.GlobalEnv, frame, mode="any", inherits=TRUE))
    {
        write.csv2(contingence,
                   file=paste(NomDossierTravail, "ContingenceUnitObsEspeces",
                              ifelse(Jeuxdonnescoupe, "_selection", ""),
                              ".csv", sep=""))
    }

    ## ! ici, donner des noms avec une base variable, pour rendre les fichiers ind�pendants et plus facilement
    ## ! reconnaissables

    ## Ajout des fichiers cr��s au log de chargement :
    add.logFrame.f(msgID="fichiers", env = .GlobalEnv, workSpace=nameWorkspace)

    gestionMSGaide.f("SelectionOuTraitement")
    MiseajourTableau.f(tclarray)

    ModifierMenuApresImport.f()

    creationTablesCalcul.f()

    ModifierInterfaceApresSelection.f("Tout", "NA")

    ## tkgrid.configure(scr, sticky="ns")

    ## creation du vecteur de couleurs pour les futurs graphiques
    cl <<- colors()
    ## Fin lignes temporaires
    ## ################################################################################

    ## Fin des informations de chargement (demande de confirmation utilisateur) :
    stepInnerProgressBar.f(n=0, msg="Fin de chargement !",
                           font=tkfont.create(weight="bold", size=9), foreground="darkred")

    infoLoading.f(button=TRUE)

    pampaProfilingEnd.f()
} # fin de opendefault.f
################################################################################


