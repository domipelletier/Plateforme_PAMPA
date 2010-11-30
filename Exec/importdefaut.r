
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

    CB.supprObs <- tkcheckbutton(WinSVR, variable=Suppr)
    E.supprLevel <- tkentry(WinSVR, width=3, textvariable=Level)

    FrameBT <- tkframe(WinSVR)
    BT.OK <- tkbutton(FrameBT, text="   OK   ",
                      command=onOK.selectionObs.SVR.f)

    tkbind(WinSVR, "<Destroy>", function(){tclvalue(Done) <- "3"}) # En cas de destruction de fen�tre.
    tkbind(E.supprLevel, "<Return>", onOK.selectionObs.SVR.f)

    ## Placement des �l�ments graphiques :
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

########################################################################################################################
## Choix des fichiers de donnees source en .txt
openUnitobs.f <- function()
{

    print("fonction openUnitobs activ�e")
    nameUnitobs <- tclvalue(tkgetOpenFile())
    nameUnitobs <- sub(paste(nameWorkspace, "/Data/", sep=""), '', nameUnitobs)   #ici, on enl�ve le nom de chemin pour ne conserver que le nom du fichier
    if (!nchar(nameUnitobs))
    {
        tkmessageBox(message="Aucun fichier n'a ete selectionne!")
    }
    print(nameUnitobs)

    tkconfigure(ResumerSituationFichierUnitesObs, text=paste("Fichier d'unit�s d'observations : ", nameUnitobs))
    tkinsert(helpframe, "end", "\n Choisissez maintenant votre fichier d'observations")
    ## nameUnitobs
    assign("fileNameUnitObs", paste(nameWorkspace, "/Data/", nameUnitobs, sep=""), envir=.GlobalEnv)
    assign("fileName1", paste(nameWorkspace, "/Data/", nameUnitobs, sep=""), envir=.GlobalEnv)
}

openObservations.f <- function()
{

    print("fonction openObservations activ�e")
    namefileObs <- tclvalue(tkgetOpenFile())
    namefileObs <- sub(paste(nameWorkspace, "/Data/", sep=""), '', namefileObs)   #ici, on enl�ve le nom de chemin pour ne conserver que le nom du fichier
    if (!nchar(namefileObs))
    {
        tkmessageBox(message="Aucun fichier n'a ete selectionne!")
    }
    print(namefileObs)
    assign("fileNameObs", namefileObs, envir=.GlobalEnv)
    assign("fileName2", namefileObs, envir=.GlobalEnv)
    ## ici du coup, on peut y mettre un choix ou reconnaitre le r�f�renciel automatiquement
    tkconfigure(ResumerSituationFichierObs, text=paste("Fichier d'observations : ", namefileObs))
    tkinsert(helpframe, "end", "\n S�lectionnez votre r�f�renciel esp�ce")
}

openListespeces.f <- function()
{

    print("fonction openListespeces activ�e")
    namefileRef <- tclvalue(tkgetOpenFile())
    namefileRef <- sub(paste(nameWorkspace, "/Data/", sep=""), '', namefileRef)   #ici, on enl�ve le nom de chemin pour ne conserver que le nom du fichier
    if (!nchar(namefileRef))
    {
        tkmessageBox(message="Aucun fichier n'a ete selectionne!")
    }
    print(namefileRef)
    tkconfigure(ResumerSituationReferencielEspece, text=paste("Fichier r�f�renciel esp�ce : ", namefileRef))
    assign("fileName3", namefileRef, envir=.GlobalEnv)
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
    print("fonction lectureFichierEspeces activ�e")
    ## Importation des caracteristiques des especes
    especes <- read.table(fileNameRefEsp, sep="\t", dec=".", quote="", header=TRUE, encoding="latin1")
    names(especes)=c("code_espece", "GrSIH", "CodeSIH", "IssCaap", "TaxoCode", "CodeFAO", "CodeFB", "Phylum", "Cath_benthique", "Classe", "Ordre", "Famille", "Genre", "espece", "Identifiant",
         "ObsNC", "ObsRUN", "ObsMAY", "ObsSTM", "ObsCB", "ObsBA", "ObsBO", "ObsCR",
         "taillemax", "L50", "cryptique", "mobilite", "territorial", "nocturne", "comportement.grp", "agreg.saison", "position.col.eau",
         "strategie.demo", "Type.ponte", "Habitat.Prefere", "Changement.sexe", "regim.alim",
         "interet.chasseNC", "interet.chasseRUN", "interet.chasseMAY", "interet.chasseSTM", "interet.chasseCB", "interet.chasseBA", "interet.chasseBO", "interet.chasseCR",
         "interet.ligneNC", "interet.ligneRUN", "interet.ligneMAY", "interet.ligneSTM", "interet.ligneCB", "interet.ligneBA", "interet.ligneBO", "interet.ligneCR",
         "interet.filetNC", "interet.filetRUN", "interet.filetMAY", "interet.filetSTM", "interet.filetCB", "interet.filetBA", "interet.filetBO", "interet.filetCR",
         "interet.casierNC", "interet.casierRUN", "interet.casierMAY", "interet.casierSTM", "interet.casierCB", "interet.casierBA", "interet.casierBO", "interet.casierCR",
         "interet.piedNC", "interet.piedRUN", "interet.piedMAY", "interet.piedSTM", "interet.piedCB", "interet.piedBA", "interet.piedBO", "interet.piedCR", "interetComMAY",
         "Coeff.a.Med", "Coeff.b.Med", "Coeff.a.NC", "Coeff.a.MAY", "Coeff.b.NC", "Coeff.b.MAY", "poids.moyen.petits", "poids.moyen.moyens", "poids.moyen.gros",
         "taille_max_petits", "taille_max_moyens", "niveau.a.et.b.MED", "niveau.a.et.b.NC", "niveau.a.et.b.MAY", "emblematiqueNC", "emblematiqueRUN", "emblematiqueMAY",
         "emblematiqueSTM", "emblematiqueCB", "emblematiqueBA", "emblematiqueBO", "emblematiqueCR", "stat.IUCN", "autre.statutNC", "autre.statutRUN", "autre.statutMAY",
         "autre.statutSTM", "autre.statutCB", "autre.statutBA", "autre.statutBO", "autre.statutCR", "etat.pop.localNC", "etat.pop.localRUN", "etat.pop.localMAY", "etat.pop.localSTM",
         "etat.pop.localCB", "etat.pop.localBA", "etat.pop.localBO", "etat.pop.localCR", "endemiqueNC", "endemiqueRUN", "endemiqueMAY", "endemiqueSTM", "endemiqueCB", "endemiqueBA",
         "endemiqueBO", "endemiqueCR")

    ## Verification du nombre de colonnes:
    if (dim(especes)[2] != 125)
    {
        rm(especes)
        gestionMSGerreur.f("nbChampEsp")
    }
    if (nrow(especes)!=0)
    {
        especes[especes=="-999"] <- NA
    }

    ## Ajout de cath�gories benthiques suppl�mentaires lues dans un fichier de correspondance :
    correspCatBenthique <- read.csv(paste(basePath, "/Exec/corresp-cat-benth.csv", sep=""), row.names=1)

    especes <- cbind(especes, correspCatBenthique[as.character(especes$Cath_benthique), , drop=FALSE])

    ## Pour v�rif :
    ## na.omit(especes[as.integer(runif(50,min=1, max=3553)), c("Cath_benthique", "CategB_general", "CategB_groupe")])

    ## Suppression de la ligne en NA
    especes <- subset(especes, !is.na(especes$code_espece))
    assign("especes", especes, envir=.GlobalEnv)
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

    print("fonction environnementdefault activ�e")
    if (!missing(nameWorkspace))
    {
        if (file.access(nameWorkspace, mode = 0)== 0)
        {
            tkinsert(txt.w, "end", paste(nameWorkspace, " existe\n", sep=""))
            if (file.access(paste(nameWorkspace, "/FichiersSortie", sep=""), mode = 0)==-1)
            {
                dir.create(paste(nameWorkspace, "/FichiersSortie", sep=""), showWarnings = TRUE, recursive = FALSE, mode = "0777")
                tkinsert(txt.w, "end", paste("\n", nameWorkspace, "/FichiersSortie a �t� cr��", sep=""))
            }
        }else{
            dir.create(nameWorkspace, showWarnings = TRUE, recursive = FALSE, mode = "0777")
            dir.create(paste(nameWorkspace, "/FichiersSortie", sep=""), showWarnings = TRUE, recursive = FALSE, mode = "0777")
            tkinsert(txt.w, "end", paste("\n", nameWorkspace, " et", nameWorkspace, "/FichiersSortie ont �t� cr��s", sep=""))
        }
    }else{
        gestionMSGerreur.f("noWorkspace")
    }
    print(nameWorkspace)
    return(nameWorkspace)
}

## Choix par defauts de C:/PAMPA
opendefault.f <- function ()
{

    print("fonction opendefault activ�e !!")
    pathMaker.f()                       # M�J des variables "fileNameUnitObs", "fileNameObs", "fileNameRefEsp". Pour les
                                        # cas o� les variables fileName1-3 auraient chang�.

    print(paste("chargement de ", fileNameUnitObs, fileNameObs, fileNameRefEsp))

    tkconfigure(ResumerEspaceTravail, text=paste("Espace de travail : ", nameWorkspace))
    environnementdefault.f(nameWorkspace)
    ## apr�s, return fonction dans variables environnement
    tkinsert(txt.w, "end", paste("\n", "Patientez, chargement des donn�es en cours ...\n", sep=""))
    ## ################################################################################
    print(fileNameUnitObs)
    unitobs <- read.table(fileNameUnitObs, sep="\t", dec=".", header=TRUE, encoding="latin1")
    names(unitobs)=c("AMP", "unite_observation", "type", "site", "station", "caracteristique_1", "caracteristique_2",
         "fraction_echantillonnee", "jour", "mois", "an",
         "heure", "nebulosite", "direction_vent", "force_vent", "etat_mer", "courant", "maree", "phase_lunaire",
         "latitude", "longitude", "statut_protection", "avant_apres", "biotope", "biotope_2",
         "habitat1", "habitat2", "habitat3", "visibilite", "prof_min", "prof_max", "DimObs1", "DimObs2", "nb_plong", "plongeur")

    levels(unitobs$caracteristique_1) <- c(levels(unitobs$caracteristique_1), "NA") # bon �a corrige l'erreur ci-dessous
                                        # mais est-ce bien n�cessaire ? [yr: 23/08/2010]
    unitobs$caracteristique_1[is.na(unitobs$caracteristique_1)] <- "NA" # [!!!] Erreur !

    ## ## R�organisation des niveaux du facteur "statut_protection" pour avoir les bonnes couleurs dans les graphiques :
    ## if (all(is.element(levels(unitobs$statut_protection), c("RE", "PP", "HR"))))
    ## {
    ##     levels(unitobs$statut_protection) <- sort(levels(unitobs$statut_protection), decreasing=TRUE)
    ## }else{}

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

        ## unitobs <- unitobs[, c("AMP", "unite_observation", "type", "site", "station",
        ##                        "caracteristique_1", "caracteristique_2", "fraction_echantillonnee",
        ##                        "jour", "mois", "an", "heure", "nebulosite", "direction_vent",
        ##                        "force_vent", "etat_mer", "courant", "maree", "phase_lunaire",
        ##                        "latitude", "longitude", "statut_protection", "avant_apres",
        ##                        "biotope", "biotope_2", "habitat1", "habitat2", "habitat3",
        ##                        "visibilite", "prof_min", "prof_max", "DimObs1", "DimObs2",
        ##                        "nb_plong", "plongeur")]
    }

    if (nrow(unitobs)!=0)
    {
        unitobs[unitobs=="-999"] <- NA
    }

    ## Ann�es : integer -> factor (n�cessaire pour les analyses stats):
    unitobs$an <- factor(unitobs$an)

    assign("unitobs", unitobs, envir=.GlobalEnv)
    assign("siteEtudie", unique(unitobs$AMP), envir=.GlobalEnv)

    ## ## R�f�rentiel spatial de l'AMP
    ## refSpatial <- read.table(file=fileNameRefSpa, header=TRUE, sep="\t", dec=".", quote="", encoding="latin1")
    ## ## 15 colonnes
    ## ## V�rification du nombre de colonnes:
    ## if (dim(refSpatial)[2] != 15)
    ## {
    ##     tkmessageBox(message=paste("ATTENTION, votre fichier 'R�f�rentiel spatial' comporte ", dim(refSpatial)[2], " champs au lieu de 15. Corrigez le et recommencez l'importation.", sep=""), icon="warning", type="ok")
    ##     rm(refSpatial)
    ## }
    ## ## renomination des colonnes du r�f�rentiel spatial

    ## colnames(refSpatial) <- c("codeZone", "zone", "AMP", "site", "station", "groupe", "longitude", "latitude", "surface", "lineaireCotier", "statutProtec", "zonagePeche", "codeSIH", "statutPAMPA", "nbCM")
    ## ## remplacement des -999 en NA
    ## if (nrow(refSpatial)!=0)
    ## {
    ##     refSpatial[refSpatial=="-999"] <- NA
    ## }
    ## assign("refSpatial", refSpatial, envir=.GlobalEnv)

    obs <- read.table(fileNameObs, sep="\t", dec=".", header=TRUE, encoding="latin1")

    if (unique(unitobs$type) != "SVR")
    {
        colnames(obs) <- c("unite_observation", "secteur", "code_espece", "sexe", "taille", "classe_taille", "poids", "nombre", "dmin", "dmax")
    }else{
        colnames(obs) <- c("unite_observation", "rotation", "secteur", "code_espece", "sexe", "taille", "classe_taille", "poids", "nombre", "dmin", "dmax")
        obs$rotation <- as.numeric(obs$rotation)

        dminMax <- NULL
        while (is.null(dminMax))
        {
            dminMax <- selectionObs.SVR.f()
        }

        obs <- subset(obs, dmin <= dminMax)
    }


    ## remplacement des -999 en NA
    if (as.logical(nrow(obs)))                      # !=0
    {
        obs[obs == "-999"] <- NA
    }

    ## nombre : numeric -> factor (n�cessaire pour une bonne prise en compte dans les analyses stat) :
    obs$nombre <- as.integer(obs$nombre)

    ## Ajout d'estimations de tailles si seules les classes de taille sont renseign�es:
    obs <- AjoutTaillesMoyennes.f(data=obs)


    ## if (is.na(unique(obs$unite_observation[-unique(unitobs$unite_observation)]))==FALSE) # [!!!]
                                        # cause erreur + compl�tement tordu
    if (!all(is.element(obs$unite_observation, unitobs$unite_observation))) # �a devrait �tre mieux
                                        # comme �a !
    {
        ## cas ou obs contient des unites d'obs absentes dans unitobs
        print("erreur, la Table obs contient des unites d'obs absentes dans la table unitobs ")
        tkmessageBox(message="erreur, la Table obs contient des unites d'obs absentes dans la table unitobs ")
    }


    ## ## suppression des observations dont le nombre d'individus est � zero
    ## if (dim(subset(obs, nombre == 0))[1] > 0) # [!!!] nrow ?
    ## {
    ##     obs0 <- dim(subset(obs, nombre != 0))
    ##     obssup <- dim(subset(obs, nombre == 0))
    ##     obs <- subset(obs, nombre != 0)
    ##     ## tkinsert(txt.w, "end",
    ##     ##          paste("\n", obssup[1],
    ##     ##                " observations dont le nombre d'individus est � 0 ont ete supprimees.", sep=""))
    ## }

    lectureFichierEspeces.f()

    ## ############# R�capitulatif du plan d'�chantillonnage #############
    if (NA %in% unique(unitobs$site) == FALSE) # [!!!]
    {
        PlanEchantillonnage <- with(unitobs, table(an, caracteristique_1, biotope, statut_protection, exclude = NA))
    }else{
        if (NA %in% unique(unitobs$biotope) == FALSE) # [!!!]
        {
            PlanEchantillonnage <- with(unitobs, table(an, habitat3, statut_protection, exclude = NA))
        }else{
            PlanEchantillonnage <- with(unitobs, table(an, site, statut_protection, exclude = NA))
        }
    }

    PlanEchantillonnage <- with(unitobs, table(an, type, exclude = NA))
    ## A l'ajout de avant_apres, table de sortie vide ! trop de parametres ?
    ## PlanEchantillonnage = with(unitobs, table(an, type, site, biotope, statut_protection, avant_apres, exclude = NA))
    recap <- as.data.frame(PlanEchantillonnage)
    write.csv(recap, file=paste(NomDossierTravail, "PlanEchantillonnage.csv", sep=""), row.names=FALSE)
    print("Recapitulatif du plan d'echantillonnage cree : PlanEchantillonnage.csv")
    ## rm(PlanEchantillonnage)
    ## ################
    assign("obs", obs, envir=.GlobalEnv)
    tkconfigure(ResumerSituationFichierUnitesObs,
                text=paste("Fichier d'unit�s d'observations : ", fileNameUnitObs, " Nb Enr : ",
                           dim(unitobs)[1], " Nb Champs : ", dim(unitobs)[2]))
    tkconfigure(ResumerSituationFichierObs,
                text=paste("Fichier d'observations : ", fileNameObs, " Nb Enr : ",
                           dim(obs)[1], " Nb Champs : ", dim(obs)[2]))
    tkconfigure(ResumerSituationReferencielEspece,
                text=paste("Fichier r�f�renciel esp�ce : ", fileNameRefEsp, " Nb Enr : ",
                           dim(especes)[1], " Nb Champs : ", dim(especes)[2]))
    tkconfigure(ResumerAMPetType,
                text=paste("AMP consid�r�e", unique(unitobs$AMP), " type d'observation : ", unique(unitobs$type)))

    ## ################# Creation de la table de contingence ##################

    if (unique(unitobs$type) != "SVR")
    {
        obsSansCathBenth <- obs
        obsSansCathBenth$Genre <- especes$Genre[match(obsSansCathBenth$code_espece, especes$code_espece)]
        if(length(obsSansCathBenth$Genre[obsSansCathBenth$Genre=="ge."])>0)
        {
            tkmessageBox(message=paste("Pour les calculs d'indices de diversit�, ",
                         length(obsSansCathBenth$Genre[obsSansCathBenth$Genre=="ge."]),
                         "observations de la table de contingence pour lesquels le genre \n
        n'est pas renseign� ('ge.') dans le r�f�rentiel esp�ce sont �t� supprim�es"), icon="info")
            obsSansCathBenth <- subset(obsSansCathBenth, obsSansCathBenth$Genre!="ge.")

        }
        contingence <- tapply(obsSansCathBenth$nombre,
                              list(obsSansCathBenth$unite_observation, obsSansCathBenth$code_espece), na.rm=TRUE, sum)
    }else{
        contingenceSVRt <- tapply(obs$nombre,
                                  list(obs$unite_observation, obs$rotation, obs$code_espece), na.rm=TRUE, mean)
        contingenceSVRt[is.na(contingenceSVRt)] <- 0
        contingenceSVR <- as.data.frame(matrix(NA, dim(contingenceSVRt)[1] * dim(contingenceSVRt)[2] *
                                               dim(contingenceSVRt)[3], 4))
        colnames(contingenceSVR) = c("unitobs", "rotation", "code_espece", "abondance")
        contingenceSVR$abondance <- as.vector(contingenceSVRt)
        contingenceSVR$unitobs <- rep(dimnames(contingenceSVRt)[[1]],
                                      times = dim(contingenceSVRt)[2] * dim(contingenceSVRt)[3])
        contingenceSVR$rotation <- rep(dimnames(contingenceSVRt)[[2]],
                                       each = dim(contingenceSVRt)[1], times = dim(contingenceSVRt)[3])
        contingenceSVR$code_espece <- rep(dimnames(contingenceSVRt)[[3]],
                                          each = dim(contingenceSVRt)[1]*dim(contingenceSVRt)[2])
        contingence <- tapply(contingenceSVR$abondance,
                              list(contingenceSVR$unitobs, contingenceSVR$code_espece), na.rm=TRUE, sum)
    }

    contingence[is.na(contingence)] <- 0
    ## Suppression des especes qui ne sont jamais vues
    ## Sinon problemes pour les calculs d'indices de diversite.
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
    calcPresAbs.f()

    ## Attention, si la table de contingence avait ete cree anterieurement lors
    ## d'une utilisation des routines par exemple, et est toujours presente
    ## dans le dossier de travail, elle sera detectee comme existante.
    if (exists("contingence", envir=.GlobalEnv, frame, mode="any", inherits=TRUE))
    {
        write.csv(contingence, file=paste(NomDossierTravail, "ContingenceUnitObsEspeces.csv", sep=""))
        print("Table de contingence unite d'observations/especes creee : ContingenceUnitObsEspeces.csv")
    }
    if (!exists("contingence", envir=.GlobalEnv, frame, mode="any", inherits=TRUE))
    {
        ReturnVal <- tkmessageBox(title="Table de contingence", message="La table de contingence n'a pas ete calculee",
                                  icon <- "warning", type="ok")
        print("La table de contingence n'a pas ete calculee")
    }

    ## Conversion des dates (tester si meilleur endroit pour faire �a) [yr: 17/08/2010] :


    ## Verification du type d'observation
    paste("Type d'observation =", unique(unitobs$type), sep=" ")
    if (length(unique(unitobs$type)) > 1)
    {
        tkmessageBox(message="Choisissez le ou les types d'observations que vous souhaitez analyser", icon="warning", type="ok")
        print("choix du type de jeux de donn�es activ�")
        ChoixFacteurSelect.f(unitobs$type, "type", "multiple", 1, "selectType")
        print("choix du type de jeux de donn�es activ�, s�lection sur :")
        print(selectType)
        obs$type <- unitobs$type[match(obs$unite_observation, unitobs$unite_observation)]
        obs <- subset(obs$type, obs$type == selectType)
        unitobs <- subset(unitobs$type, unitobs$type == selectType)
        assign("obs", obs, envir=.GlobalEnv)
        assign("unitobs", unitobs, envir=.GlobalEnv)
    }

    ## print(paste("\t\t", paste(dim(obs), collapse="x")))
    ## Creation des tables de base
    creationTablesBase.f()
    ## biomasse.f()

    ## print(paste("\t\t", paste(dim(obs), collapse="x")))
    ## ! ici, donner des noms avec une base variable, pour rendre les fichiers ind�pendants et plus facilement reconnaissables

    gestionMSGinfo.f("BasetxtCreate")
    gestionMSGaide.f("SelectionOuTraitement")
    MiseajourTableau.f(tclarray)
    ModifierMenuApresImport.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f("Aucun", "NA")

    tkgrid.configure(scr, sticky="ns")

    ## creation du vecteur de couleurs pour les futurs graphiques
    cl <<- colors()
    ## Fin lignes temporaires
    ## ################################################################################
} # fin de opendefault.f
################################################################################
################################################################################
################################################################################

