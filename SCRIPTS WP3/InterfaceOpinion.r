#-*- coding: latin-1 -*-

### File: InterfaceOpinion_new.R
### Time-stamp: <2011-09-15 11:57:14 yreecht>
###
### Author: Elodie Gamp
###
####################################################################################################
### Description:
###
### Nouvelle interface pour les graph d'opinion
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

listeMetriques.f <- function(tab)
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

    listMetrique <- c(metriqueRenseignee[! verifMetrique], listMetriqueParti)

    return(sort(listMetrique))
}


########################################################################################################################
listeFacteurs.f <- function(nomTab)
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
        listFact <- c("activite", "resident", "toutConfondu")
    } else {
        listFact <- c("resident", "toutConfondu")
    }

    return(listFact)
}


########################################################################################################################
listeGraph.f <- function(tab, metriqueChoisie)
{
    ## Purpose: Retourne une liste de choix de graphiques d'apr�s la m�trique
    ##          choisie
    ## ----------------------------------------------------------------------
    ## Arguments: tab : la data.frame
    ##            metriqueChoisie : nom de la m�trique choisie
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 13 sept. 2011, 15:09

    if (!is.element(metriqueChoisie, colnames(tab))) # M�trique "cas particulier".
    {
        if (is.element(tmpName <- paste(metriqueChoisie, "1", sep=""),
                       colnames(tab)))
        {
            listGraph <- "barplotParticulier"
            classMetrique <- class(tab[ , tmpName])
        } else {
            ## stop("La m�trique n'existe pas")
            listGraph <- ""
            classMetrique <- ""
        }
    } else {
        ## liste des choix de l'�tape suivante
        classMetrique <- class(tab[ , metriqueChoisie])

        graphDispo <- if (is.element(classMetrique, c("numeric", "integer")))
        {
            listGraph <- c("boxplot", "barplot")      # si num�ric alors boxplot/barplotMoy et stats num�riques
        } else {
            listGraph <- c("barplot", "camembert")    # si character alors barplot/pie et proportion de r�ponses
        }
    }

    return(list(typeGraph=listGraph,
                class=classMetrique))
}


########################################################################################################################
tableauUpdate.f <- function(env)
{
    ## Purpose: M�J des champs de la liste des m�triques, de la liste des
    ##          facteurs et des types de graphs au changement de tableau
    ##          s�l�ctionn�.
    ## ----------------------------------------------------------------------
    ## Arguments: ## nomTab : nom de tableau s�l�ctionn�.
    ##            env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 14 sept. 2011, 12:03

    if (tclvalue(get("TableauChoisi", envir=env)) == "") {return()}

    ## M�J de la liste des m�triques :
    evalq(tkconfigure(CB.metriques,
                      value=listeMetriques.f(tab=get(tclvalue(TableauChoisi),
                                                     envir=.GlobalEnv))),
          envir=env)

    ## R�initialisation du champs de la m�trique choisie si pas pr�sent dans le nouveau tableau :
    evalq(if (!is.element(tclvalue(MetriqueChoisie),
                          listeMetriques.f(tab=get(tclvalue(TableauChoisi),
                                                   envir=.GlobalEnv))))
      {
          tclvalue(MetriqueChoisie) <- ""                           # r�initialisation
      }, envir=env)

    ## M�J de la liste des facteurs :
    evalq(tkconfigure(CB.facteurs,
                      value=listeFacteurs.f(nomTab=tclvalue(TableauChoisi))),
          envir=env)

    ## R�initialisation du champs du facteurs choisi si pas pr�sent dans le nouveau tableau :
    evalq(if (!is.element(tclvalue(FacteurChoisi),
                          listeFacteurs.f(nomTab=tclvalue(TableauChoisi))))
      {
          tclvalue(FacteurChoisi) <- ""                           # r�initialisation
      }, envir=env)

    ## ## Update des fen�tres :
    ## tcl("update")

    ## M�J des types de graphs disponibles en fonction de la m�trique :
    updateTypeGraph.f(env=env)
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
updateTypeGraph.f <- function(env)
{
    ## Purpose: Mise � jour de la liste de types de graphiques disponibles.
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 14 sept. 2011, 12:34

    ## M�J de la liste des types de graphs :
    evalq(tkconfigure(CB.graphs,
                      value=listeGraph.f(tab=get(tclvalue(TableauChoisi),
                                                 envir=.GlobalEnv),
                                         metriqueChoisie=tclvalue(MetriqueChoisie))[["typeGraph"]]),
          envir=env)

    ## R�initialisation du champs du type de graph choisi si pas adapt� pour la nouvelle m�trique :
    evalq(if (!is.element(tclvalue(GraphChoisi),
                          listeGraph.f(tab=get(tclvalue(TableauChoisi),
                                               envir=.GlobalEnv),
                                       metriqueChoisie=tclvalue(MetriqueChoisie))[["typeGraph"]]))
      {
          tclvalue(GraphChoisi) <- ""                           # r�initialisation
      }, envir=env)

    ## For�age des "barplotParticulier" :
    evalq(if (is.element("barplotParticulier",
                          listeGraph.f(tab=get(tclvalue(TableauChoisi),
                                               envir=.GlobalEnv),
                                       metriqueChoisie=tclvalue(MetriqueChoisie))[["typeGraph"]]))
      {
          tclvalue(GraphChoisi) <- "barplotParticulier"                           # r�initialisation
          tkconfigure(CB.graphs, state="disabled")
      } else {
          tkconfigure(CB.graphs, state="readonly")
      }, envir=env)
}


########################################################################################################################
LancementGraphsEnquete.f <- function(typeGraph, tab, nomTable, facteur, metrique, periode)
{
    ## Purpose: Lance le bon type de graphique en fonction du choix de
    ##          l'utilisateur
    ## ----------------------------------------------------------------------
    ## Arguments: typeGraph : type de graphique (character)
    ##            tab : table de donn�es (data.frame)
    ##            nomTable : nom de la table de donn�es (character)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ##            periode : nom du champ de p�riode (character)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011, 11:21

                    switch(typeGraph,
                       "boxplot"={
                           BoxplotEnquetes.f (tableau=tab,
                                              nomTable=nomTable, facteur=facteur,
                                              metrique=metrique, periode=periode)
                       },
                       "camembert"={
                           CamembertEnquetes.f(tableau=tab,
                                               nomTable=nomTable, facteur=facteur,
                                               metrique=metrique, periode=periode)
                       },
                       "barplot"={
                           if (is.numeric(tab[ , metrique]))
                           {
                               BarplotMoyenneEnquetes.f (tableau=tab,
                                                         nomTable=nomTable, facteur=facteur,
                                                         metrique=metrique, periode=periode)
                           }else{
                               BarplotPropEnquetes.f (tableau=tab,
                                                      nomTable=nomTable, facteur=facteur,
                                                      metrique=metrique, periode=periode)
                           }
                       },
                       "barplotParticulier"={
                           BarplotParticulier.f(tableau=tab,
                                                nomTable=nomTable, facteur=facteur,
                                                metrique=metrique, periode=periode)
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))
}


########################################################################################################################
interfaceEnquete.f <- function()
{
    ## Purpose: cr�er l'interface pour les graphs d'enqu�tes d'opinion
    ##          et lancer les fonctions graphiques
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
    metriques <- ""  ## listeMetriques.f()
    MetriqueChoisie <- tclVar("")           #

    ## Liste des facteurs :
    facteurs <- ""  ## listeFacteurs.f()
    FacteurChoisi <- tclVar("")           #

    ## Liste des graphiques :
    graphs <- ""  ## listeGraph.f()
    GraphChoisi <- tclVar("")           #    Attention car c'est une liste � deux �l�ments

    ## S�lection des p�riodes :
    Periode <- tclVar("periode")


    ## ########################
    ## �l�ments graphiques :
    WinEnquete <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinEnquete, "S�lections pour les enqu�tes")

    F.main <- tkframe(WinEnquete, width=30)

    F.radio <- tkframe(F.main, borderwidth=2, relief="groove")


    ## �l�ments graphiques :
    CB.tab <- ttkcombobox(F.main, value=tableaux, textvariable=TableauChoisi,
                          state="readonly")

    CB.metriques <- ttkcombobox(F.main, value=metriques, textvariable=MetriqueChoisie,
                                state="readonly")

    CB.facteurs <- ttkcombobox(F.main, value=facteurs, textvariable=FacteurChoisi,
                               state="readonly")

    CB.graphs <- ttkcombobox(F.main, value=graphs, textvariable=GraphChoisi,
                             state="readonly")

    RB.periode <- tkradiobutton(F.radio, variable=Periode, value="periode", text="Par p�riode d'�chantillonnage")
    RB.toutes <- tkradiobutton(F.radio, variable=Periode, value="toutes", text="Toutes p�riodes d'�chantillonnage confondues")

    ## barre de boutons :
    FrameBT <- tkframe(WinEnquete)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})
    B.optGraph <- tkbutton(FrameBT, text=" Options graphiques... ",
                           command=function(x)
                       {
                           warning("Un peu de patience, que diable !")
                           ## choixOptionsGraphiques.f()
                           ## winRaise.f(WinEnquete)
                       })
    tkconfigure(B.optGraph, state="disabled")      # � enlever lors de la d�finition des options graphiques
    
    ## D�finition des actions :
    tkbind(CB.tab, "<FocusIn>", function() {tableauUpdate.f(env=env)})
    tkbind(CB.metriques, "<FocusIn>", function() {updateTypeGraph.f(env=env)})

    tkbind(WinEnquete, "<Destroy>", function(){tclvalue(Done) <- 2})

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

    tkgrid(tklabel(F.main, text="Type de graphique"),
           CB.graphs, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(tklabel(F.radio, text="Choix du regroupement des p�riodes d'�chantillonnage"))
    tkgrid(ttkseparator(F.radio, orient = "horizontal"), column=0, sticky="ew")
    tkgrid(RB.periode, padx=5, sticky="w")
    tkgrid(RB.toutes, padx=5, sticky="w")

    tkgrid(F.radio, columnspan=2)

    tkgrid(F.main, padx=10, pady=10)

    ## Barre de boutons :
    tkgrid(FrameBT, column=0, columnspan=1, padx=2, pady=2)
    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
           tklabel(FrameBT, text="               "), B.optGraph, tklabel(FrameBT, text="\n"))

    ## tkfocus(WinEnquete)
    winSmartPlace.f(WinEnquete)

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
            graphCh <- tclvalue(GraphChoisi)
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


            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(tableauCh,
                                                      metriqueCh,
                                                      facteurCh,
                                                      graphCh,
                                                      periodeCh,
                                                      ParentWin = WinEnquete)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.

            ## ##################################################
            ## Fonctions pour la cr�ation du graphique :

            #### toutes p�riodes d'�chantillonnage confondues
           if (periodeCh == "periode")
           {
               tabTmp <- split(get(tableauCh, envir=.GlobalEnv), get(tableauCh, envir=.GlobalEnv)[ , "periodEchant"])

               sapply(tabTmp,
                      FUN=function(x,...)
                  {
                      tryCatch(LancementGraphsEnquete.f(tab=x,...),
                               ## warning=function(w){},
                               error=function(e)
                           {
                               dev.off()

                               message(paste("Pas de donn�es pour la p�riode \"",
                                             unique(x$periodEchant),
                                             "\"", sep=""))
                           })
                  },
                      typeGraph=graphCh,
                      nomTable=tableauCh,
                      facteur=facteurCh,
                      metrique=metriqueCh,
                      periode="periodEchant")
           } else {
               LancementGraphsEnquete.f(typeGraph=graphCh,
                                        tab=get(tableauCh, envir=.GlobalEnv),
                                        nomTable=tableauCh,
                                        facteur=facteurCh,
                                        metrique=metriqueCh,
                                        periode="periodEchantCouplee")
           }

            #} else {print("coucou")}  # fin de boucle sur periodeEchantCouplee

            ## ##################################################

            ## winRaise.f(WinEnquete)

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie :
            winSmartPlace.f(WinEnquete)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinEnquete)             # destruction de la fen�tre.


####

}





### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
