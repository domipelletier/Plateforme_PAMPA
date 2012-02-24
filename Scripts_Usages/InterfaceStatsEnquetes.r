################################################################################
# Nom               : InterfaceStatsEnquetes.r
# Type              : Programme
# Objet             : Fonctions permettant de cr�er l'interface pour les traitements
#                     statistiques des donn�es d'enqu�tes.
#                     Cette interface permet � l'utilisateur de faire ses choix 
#                     pour les traitements.
# Input             : clic souris
# Output            : lancement de fonctions
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : janvier 2012
# Sources
################################################################################


####################################################################################################
listeTableaux.f <- function()
{
    ## Purpose: Retourne la liste des tableaux non-vides.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 15:43

    ## Tableaux disponibles pour le calcul des m�triques sur les donn�es d'enqu�tes
    tables <- c("peche", "plaisance", "excursion", "plongee", "tousQuest")

    ## Identification des tables non vides :
    Disponibilite <- sapply(tables,
                            function(x){as.logical(nrow(get(x, envir=.GlobalEnv)))})

    return(tables[Disponibilite])   # ne prend que les enqu�tes ayant des donn�es

}


########################################################################################################################
casParticulier.f <- function()
{
    ## Purpose: liste des m�triques n�cessitant un calcul particulier
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 15:02

    c("choixSite1", "choixSite2", "choixSite3", "raison1", "raison2", "site1", "site2", "site3",
      "chgmt1", "chgmt2", "nuisance1", "nuisance2", "preInfo1", "preInfo2", # plongee
      "planifEnv1", "planifEnv2", "actHab1", "enginHab1a", "enginHab1b", "nbSortie1", "actHab2",
      "enginHab2a", "enginHab2b", "nbSortie2", "raisonPeche1", "raisonPeche2",  # peche
      "interetAMP1", "interetAMP2",                              # plaisance
      "satisfaction1", "satisfaction2", "satisfaction3", "satisfaction4", "satisfaction5")   # excursion
}


########################################################################################################################
listeMetriquesS.f <- function(tab)
{
    ## Purpose: Retourne la liste (sous forme de vecteur de caract�res)
    ##          des m�triques renseign�es d'apr�s le
    ##          tableau d'enqu�te choisi
    ## ----------------------------------------------------------------------
    ## Arguments: tab : tableau (data.frame)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 14:18

    ## Indices des champs vides :
    ## champsVide <- sapply(tab, verifVide.f)
    champsVide <- sapply(tab,
                         function(x){all(is.na(x))})

    metriqueRenseignee <- names(champsVide)[!champsVide]  # liste des metriques renseign�es
                                        #verifNumeric <- apply(tab,2,verifNumeric.f)
                                        #metriqueQualitative <-

    ## liste des m�triques de contexte, pas � prendre dans les questions d'enqu�tes :
    contexte <- c("quest", "periodEchant", "AMP", "enqueteur", "dejaEnq", "periodEchantCouplee", "refus", "toutConfondu", # plongee et excursion
                  "numSortie", "annee", "mois", "activite", "activiteSpe",
                  "jour", "saison", "typeJ", "heure", "zone", "nomZone", "statut", "groupe", "meteo", "etatMer", "lune",
                  "directionVent", "forceVent", "nebulosite", "latitude", "longitude", "tailleBat", "categBat",
                  "typeBat", "mouillage", "actPeche1", "actPeche2", "zone1", "zone2", "engin1", "nbEngin1", "engin2",
                  "nbEngin2", "engin3", "nbEngin3", "debutPec", "finPec", "dureeSortie", "dureePec", "capture", # peche
                  "act1", "categAct1", "act2", "categAct2") # plaisance


    casParticulier <- casParticulier.f()

    ## M�triques renseign�es quicorrespondent � des cas particuliers (� regrouper) :
    metriqueParti <- is.element(metriqueRenseignee, casParticulier)

    listMetriqueParti1 <- metriqueRenseignee[metriqueParti]
    listMetriqueParti <- unique(sub("^([^[:digit:]]+)[[:digit:]]*.*", "\\1", listMetriqueParti1))

    ## liste des m�triques renseign�es hors contexte et rajout des cas particuliers
    verifMetrique <- is.element(metriqueRenseignee,
                                c(contexte, casParticulier))

    listMetrique <- metriqueRenseignee[! verifMetrique]

    return(sort(listMetrique))
}


########################################################################################################################
listeFacteursS.f <- function(nomTab)
{
    ## Purpose: retourne un vecteur de caract�res donnant les facteurs
    ##          disponibles selon la table d'enqu�te choisie
    ## ----------------------------------------------------------------------
    ## Arguments: nomTab : cha�ne de caract�re donant le nom de la table.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 14:40

    if (is.element(nomTab,
                   c("peche", "plaisance", "tousQuest")))
    {
        listFact <- c("activite", "resident")
    } else {
        listFact <- c("resident")
    }

    return(listFact)
}


########################################################################################################################
tableauUpdateS.f <- function(env)
{
    ## Purpose: M�J des champs de la liste des m�triques, de la liste des
    ##          facteurs au changement de tableau
    ##          s�l�ctionn�.
    ## ----------------------------------------------------------------------
    ## Arguments: ## nomTab : nom de tableau s�l�ctionn�.
    ##            env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 14 sept. 2011, 12:03

    if (tclvalue(get("TableauChoisi", envir=env)) == "") {return()}

    ## M�J de la liste des m�triques :
    evalq(tkconfigure(CB.metriques,
                      value=listeMetriquesS.f(tab=get(tclvalue(TableauChoisi),
                                                     envir=.GlobalEnv))),
          envir=env)

    ## R�initialisation du champs de la m�trique choisie si pas pr�sent dans le nouveau tableau :
    evalq(if (!is.element(tclvalue(MetriqueChoisie),
                          listeMetriquesS.f(tab=get(tclvalue(TableauChoisi),
                                                   envir=.GlobalEnv))))
      {
          tclvalue(MetriqueChoisie) <- ""                           # r�initialisation
      }, envir=env)

    ## M�J de la liste des facteurs :
    evalq(tkconfigure(CB.facteurs,
                      value=listeFacteursS.f(nomTab=tclvalue(TableauChoisi))),
          envir=env)

    ## R�initialisation du champs du facteurs choisi si pas pr�sent dans le nouveau tableau :
    evalq(if (!is.element(tclvalue(FacteurChoisi),
                          listeFacteursS.f(nomTab=tclvalue(TableauChoisi))))
      {
          tclvalue(FacteurChoisi) <- ""                           # r�initialisation
      }, envir=env)

    ## ## Update des fen�tres :
    ## tcl("update")

}


########################################################################################################################
verifVariablesEnquete.f <- function(ParentWin=NULL,...)
{
    ## Purpose: v�rifie que les diff�rents �l�ments sont s�lectionn�s.
    ## ----------------------------------------------------------------------
    ## Arguments: ... : pour l'instant, v�rifie simplement que tous les
    ##                  arguments sont != ""
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 14 sept. 2011, 15:51

    res <- ifelse(is.element("", unlist(list(...))), "0", "1")

    if (res == "0")
    {
        infoLoading.f(msg=paste("Au moins un des champs n'est pas rempli : ",
                                "\nveuillez saisir le/les champ(s) manquants et r�p�ter l'op�ration",
                                sep=""),
                      icon="error")

        ## Bouton OK + attente de confirmation.
        infoLoading.f(button = TRUE,
                      WinRaise=ParentWin)
    } else {}

    return(res)
}


########################################################################################################################
interfaceStatsEnquete.f <- function()
{
    ## Purpose: cr�er l'interface pour les tests stats d'enqu�tes 
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 15:30

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution

    ## Liste des tableaux :
    tableaux <- listeTableaux.f()
    TableauChoisi <- tclVar("")           #

    ## Liste des metriques :
    metriques <- ""  ## listeMetriquesS.f()
    MetriqueChoisie <- tclVar("")           #

    ## Liste des facteurs :
    facteurs <- ""  ## listeFacteursS.f()
    FacteurChoisi <- tclVar("")           #


    ## S�lection des p�riodes :
    Periode <- tclVar("periode")


    ## ########################
    ## �l�ments graphiques :
    WinStatEnquete <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinStatEnquete, "S�lections pour les tests des enqu�tes")

    F.main <- tkframe(WinStatEnquete, width=30)

    F.radio <- tkframe(F.main, borderwidth=2, relief="groove")


    ## �l�ments graphiques :
    CB.tab <- ttkcombobox(F.main, value=tableaux, textvariable=TableauChoisi,
                          state="readonly")

    CB.metriques <- ttkcombobox(F.main, value=metriques, textvariable=MetriqueChoisie,
                                state="readonly")

    CB.facteurs <- ttkcombobox(F.main, value=facteurs, textvariable=FacteurChoisi,
                               state="readonly")

    RB.periode <- tkradiobutton(F.radio, variable=Periode, value="periode", text="Tester la p�riode d'�chantillonnage")
    RB.toutes <- tkradiobutton(F.radio, variable=Periode, value="toutes", text="Sans tester la p�riode d'�chantillonnage")

    ## barre de boutons :
    FrameBT <- tkframe(WinStatEnquete)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})

    
    ## D�finition des actions :
    tkbind(CB.tab, "<FocusIn>", function() {tableauUpdateS.f(env=env)})

    tkbind(WinStatEnquete, "<Destroy>", function(){tclvalue(Done) <- 2})

    ## Placement des �l�ments sur l'interface :
    tkgrid(tklabel(F.main, text="Table de donn�es"),
           CB.tab, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(tklabel(F.main, text="M�trique"),
           CB.metriques, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(tklabel(F.main, text="Facteur de s�paration"),
           CB.facteurs, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)


    tkgrid(tklabel(F.radio, text="Choix du test des p�riodes d'�chantillonnage"))
    tkgrid(ttkseparator(F.radio, orient = "horizontal"), column=0, sticky="ew")
    tkgrid(RB.periode, padx=5, sticky="w")
    tkgrid(RB.toutes, padx=5, sticky="w")

    tkgrid(F.radio, columnspan=2)

    tkgrid(F.main, padx=10, pady=10)

    ## Barre de boutons :
    tkgrid(FrameBT, column=0, columnspan=1, padx=2, pady=2)
    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
           tklabel(FrameBT, text="               "), tklabel(FrameBT, text="\n"))

    ## tkfocus(WinStatEnquete)
    winSmartPlace.f(WinStatEnquete)

    ## Update des fen�tres :
    tcl("update")

    ## Tant que l'utilisateur ne ferme pas la fen�tre... :
    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        if (tclvalue(Done) == "1")      # statut ex�cution OK.
        {
            tableauCh <- tclvalue(TableauChoisi)
            metriqueCh <- tclvalue(MetriqueChoisie)
            facteurCh <- tclvalue(FacteurChoisi)
            periodeCh <- tclvalue(Periode)

            ## Traitement des cas particuliers :
            if (tableauCh == "peche")
            {
                tableauCh <- "pecheQ"
            } else {}

            if (tableauCh == "pecheQ" && facteurCh == "activite")
            {
                facteurCh <- "actPeche1"
            } else {}

            if (tableauCh == "plaisance" && facteurCh == "activite")
            {
                facteurCh <- "categAct1"
            } else {}

            ## traitement du test de la p�riode d'�chantillonnage
            if (periodeCh == "periode")
            {
               facteurCh <- c(facteurCh, "periodEchant")
            } else {}
            
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(tableauCh,
                                                      metriqueCh,
                                                      facteurCh,
                                                      periodeCh,
                                                      ParentWin = WinStatEnquete)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.

            ## Fonctions pour lancer les tests

            Data = eval(parse(text=tableauCh))
            classMetriqueS <- class(Data[, metriqueCh])
            
            if (is.element(classMetriqueS, c("numeric", "integer"))) {          ## tests quantitatifs pour les variables quantitatives
                 modeleLineaireWP3.f ( variable = metriqueCh,
                                       facteurs = c("quest", facteurCh),
                                       listFact = facteurCh,
                                       tableMetrique = tableauCh,                                   
                                       sufixe = NULL)
            } else {                                                            ## tests qualitatifs pour les variables qualitatives
                 if (lengthnna.f(unique(Data [,metriqueCh])) == 2)
                 {
                     sortiesBINOM.f (metrique = metriqueCh, 
                                     listFact = facteurCh, 
                                     Data = eval(parse(text=tableauCh)),
                                     nomData = tableauCh,  
                                     prefix = "binom")
                 } else {
                     sortiesMULTI.f(metrique = metriqueCh, 
                                     listFact = facteurCh, 
                                     Data = eval(parse(text=tableauCh)),
                                     nomData = tableauCh,  
                                     prefix = "multinom")
                 }
            }

            ## ##################################################

            ## winRaise.f(WinStatEnquete)

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie :
            winSmartPlace.f(WinStatEnquete)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinStatEnquete)             # destruction de la fen�tre.


####

}


### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
