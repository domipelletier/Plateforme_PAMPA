################################################################################
# Nom               : InterfaceExtrapolation.r
# Type              : Programme
# Objet             : Fonctions permettant de cr�er l'interface pour l'extrapolation
#                     des donn�es de fr�quentation.
#                     Cette interface permet � l'utilisateur de faire ses choix 
#                     pour l'extrapolation.
# Input             : clic souris
# Output            : cr�ation de l'interface
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : janvier 2012
# Sources
################################################################################


####################################################################################################

  calendrier <- read.table(file="C:/PAMPA/Donnees_Usages/Calendrier.txt", sep="\t", dec=".",header=T)
  assign("calendrier", calendrier, envir=.GlobalEnv)  

########################################################################################################################
selectModWindow.f <- function(champ, tab, selectmode="multiple", sort=TRUE, preselect=NULL, title=NULL, label=NULL)
{
    ## Purpose: Ouvre une fen�tre pour le choix des modalit�s d'un facteur
    ## ----------------------------------------------------------------------
    ## Arguments: champ : le nom de la colonne du facteur
    ##            data : la table de donn�es
    ##            selectmode : mode de s�lection (parmi "single" et
    ##                         "multiple")
    ##            sort : ordonner les modalit�s ? (bool�en)
    ##            preselect : un vecteur de modalit�s � pr�s�lectionner (pour
    ##                        des s�lections persistantes).
    ##            title : titre de la fen�tre.
    ##            label : texte d'explication.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  5 ao�t 2010, 09:38

    if(champ == "")                     # condition d'arr�t (pas de champ s�lectionn�).
    {
        return(NULL)
    } else {
        if (all(is.na(tab[ , champ])))  # Cas des champs vides (ajouter un message).
        {
            return(NULL)
        }
    }
    selection <- NULL

    ## ########## D�finition des �l�ments graphiques ##########
    winfac <- tktoplevel()   ## (width = 80)

    if (is.null(title))
    {
        tkwm.title(winfac, paste("Selection des valeurs de ", champ, sep=""))
    } else {
        tkwm.title(winfac, title)
    }

    ## Assenceur vertical :
    SCR.y <- tkscrollbar(winfac, repeatinterval=5, command=function(...){tkyview(LB, ...)})

    ## List Box de s�lection :
    LB <- tklistbox(winfac, height=20, width=50, selectmode=selectmode,
                    yscrollcommand=function(...)tkset(SCR.y, ...), background="white")

    ## Boutons :
    FrameB <- tkframe(winfac)
    B.OK <- tkbutton(FrameB, text=" OK ", command=function()
                {
                    assign("selection", listMod[as.numeric(tkcurselection(LB))+1], parent.env(environment()))
                    ## assign("tmptk", tkcurselection(LB), envir=.GlobalEnv)
                    tkdestroy(winfac)
                })
    B.Cancel <- tkbutton(FrameB, text=" Annuler ", command=function()
                     {
                         assign("selection", NULL, parent.env(environment()))
                         tkdestroy(winfac)
                     })

    ## ########## Placement des �l�ments sur la grille ##########
    ## Explications :
    if (is.null(label))
    {
        tkgrid(tklabel(winfac, text=paste("Liste des valeurs de '", champ,
                               "' pr�sentes.\n ",
                               sep="")), columnspan=2)
    } else {
        tkgrid(tklabel(winfac, text=label), columnspan=2)
    }

    ## Avertissement 'plusieurs s�lections possibles' :
    if (is.element(selectmode, c("extended", "multiple")))
    {
        tkgrid(tklabel(winfac, text="Plusieurs s�lections POSSIBLES.\n"), columnspan=2)
    } else {}

    ## Avertissement mode de s�lection �tendu :
    if (selectmode == "extended")
    {
        tkgrid(tklabel(winfac,
                       text=paste("!!Nouveau!! mode de s�lection �tendu : \n",
                       "*  utilisez Ctrl et Maj pour les s�lections multiples.\n",
                       "*  Ctrl+a pour tout s�lectionner\n", sep=""),
                       fg="red"), columnspan=2, rowspan=2)
    } else {}

    tkgrid(LB, SCR.y)
    tkgrid.configure(SCR.y, rowspan=4, sticky="nsw")
    tkgrid(FrameB, columnspan=2, sticky="")
    tkgrid(B.OK, tklabel(FrameB, text="        "), B.Cancel, sticky="", pady=5)

    ## Configuration de la liste :
    if (sort)
    {
        listMod <- unique(as.character(sort(tab[ , champ])))
    } else {
        listMod <- unique(as.character(tab[ , champ]))
    }

    invisible(sapply(listMod, function(x){tkinsert(LB, "end", x)}))

    ## S�lections persistantes :
    if (!is.null(preselect))
    {
        sapply(which(is.element(listMod, preselect)) - 1,
               function(i){tkselection.set(LB, i)})
    }
    ## tkselection.set(LB, 0)

    tkbind(winfac, "<Control-a>",       # Tout s�lectionner
           function()
       {
           sapply(seq(from=0, length.out=length(listMod)),
                  function(i) {tkselection.set(LB, i)})
       })

    ## Affichage/attente :
    tkfocus(LB)
    winSmartPlace.f(winfac, xoffset=50, yoffset=-100)

    tkwait.window(winfac)
    return(selection)
}


########################################################################################################################
listePeriode.f <- function()
{
    ## Purpose: Retourne la liste des p�riodes d'�chantillonnage disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    listPeriode <- unique(calendrier$periodEchant)

    return(listPeriode)          # 

}


########################################################################################################################
listeNivSpatial.f <- function()
{
    ## Purpose: Retourne la liste des niveaux spatiaux disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Niveaux spatiaux disponibles dans le r�f�rentiel spatial
    listeNiveauxSpa <- c("AMP" , "codeZone" , "site" , "station" , "groupe" , "statutProtec" ,
                     "zonagePeche" , "codeSIH" , "zonagePAMPA")

    ## Identification des champs non vides du r�f�rentiel du site �tudi�
    champsVide <- ! sapply(refSpatial,
                          function(x){all(is.na(x))})

    listNivSpatial <- listeNiveauxSpa[is.element(listeNiveauxSpa,names(champsVide)[champsVide])]

    return(listNivSpatial)          # ne prend que les niveaux spatiaux renseign�s

}


########################################################################################################################
listeNivTemporel.f <- function()
{
    ## Purpose: Retourne la liste des niveaux temporels disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Niveaux temporels disponibles dans le calendrier
    listNivTemporel <- c("periodEchant" , "mois" , "trimestre" , "semestre")

    return(listNivTemporel)          # actuellement tout est renseign� pour tous

}


########################################################################################################################
listeFacteursFreq.f <- function()
{
    ## Purpose: Retourne la liste des facteurs de s�paration disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Facteurs de s�paration disponibles
    facteursFreq <- sort(c("typeBat" , "tailleBat" , "mouillage" , "natureFond" , "act1" , "categAct1"))

    ## Identification des champs non vides de la table de fr�quentation
    champsVide <- ! sapply(freqtot,
                          function(x){all(is.na(x))})

    listFactFreq <- c("aucun",facteursFreq[is.element(facteursFreq,names(champsVide)[champsVide])])

    return(listFactFreq)          # ne prend que les facteurs de s�paration renseign�s

}


########################################################################################################################
listeModalitesFactExt.f <- function(facteurSep, ...)
{
   ## Purpose: si facteurSep != aucun et choix de s�lection de certaines modalit�s,
    ##          ouvre une fen�tre pour choisir la liste des modalit�s de ce facteur
    ##          � consid�rer pour les calculs
    ##          Retourne la liste des modalit�s choisies par l'utilisateur
    ## ----------------------------------------------------------------------
    ## Arguments: facteurSep : facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Niveaux du facteur de s�paration disponibles
    if (facteurSep == "aucun")
    {
        listNivFactFreq <- ""
    } else {
        listNivFactFreq <- selectModWindow.f(champ=facteurSep, tab=freqtot, selectmode="single", ...) #sort(unique(freqtot[,facteurSep]))
    }

    return(listNivFactFreq)          # retourne les valeurs disponibles dans le champ facteurSep

}


########################################################################################################################
listeVariables.f <- function(facteur)
{
    ## Purpose: retourne un vecteur de caract�res donnant les variables
    ##          disponibles selon le facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Arguments: facteur : cha�ne de caract�re donnant le facteur de s�paration
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 13 sept. 2011, 14:40

    if (is.element(facteur,
                   c("act1", "categAct1")))
    {
        listVariable <- c("nbBatAct", "nbPersAct", "nbLigne")
    } else {
        listVariable <- c("nbBat", "nbPers", "nbLigne")
    }

    return(listVariable)
}


########################################################################################################################
LancementExtrapolation.f <- function(tab, niveauSpatial, niveauTemporel, variable,
                                   periode, rgpmtJour, facteurSep=NULL, modalites=NULL, titre="", graph, statBoot = NULL)
{
    ## Purpose: Lance le calcul d'extrapolation ainsi que le barplot correspondant 
    ##          (pour les cas o� il n'y a pas de facteurs de s�paration)
    ## ----------------------------------------------------------------------
    ## Arguments: tab : tableau de donn�es � consid�rer
    ##            niveauSpatial : niveau spatial choisi pour le calcul (character)
    ##            niveauTemporel : niveau temporel choisi pour le calcul (character)
    ##            variable : la variable choisie pour le calcul (character)
    ##            periode : p�riode d'�chantillonnage choisie
    ##            rgpmtJour : choix de regroupement des types de jours (character)
    ##            facteurSep = NULL : facteur de s�paration non d�fini pour ce lancement
    ##            modalites = NULL : modalite du facteur de s�paration non d�finie pour ce lancement
    ##            titre : compl�ment du titre pour le graph
    ##            graph : lancement du graphique si graph=T
    ##            statBoot : tableau de sortie des estimations bootstrap (moy, var et ICs)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 sept. 2011

    if (graph == T) {
        ## d�finition de "nombre" selon la valeur de "variable"
        if (is.element(variable,
                       c("nbBat", "nbBatAct"))) {
            nombre <- "bateaux"
        } else {}
        
        if (is.element(variable,
                       c("nbPers", "nbPersAct"))) {
            nombre <- "personnes"
        } else {}
        
        if (is.element(variable,
                       c("nbLigne"))) {
            nombre <- "lignes"
        } else {}
        
        ## rajout de la colonne correspondant au niveau spatial choisi
        tab[, niveauSpatial] <- refSpatial[, niveauSpatial][match(tab$zone , refSpatial$codeZone)]
    
        ## rajout de la colonne correspondant au niveau temporel choisi
        tab[, niveauTemporel] <- calendrierGeneral[ , niveauTemporel][match(tab$moisAn , calendrierGeneral$moisAn)]
    
        ## subset du tableau de fr�quentation sur la p�riode choisie
        FreqAnneeChoisie <- subset(tab, tab$periodEchant == periode)
    } else {
        FreqAnneeChoisie <- tab
    }
    
    ## Fonction de calcul du calendrier
    InfoProtocoleEchant <- TabEchant.f (FreqAnneeChoisie = FreqAnneeChoisie, 
                                        niveauSpatial = "zone")

    ## Fonction du calcul de la moyenne et de la variance par mois, zone, et type de jour
    FreqMoyVar <- CalculMoyenneVariance.f (FreqAnneeChoisie = FreqAnneeChoisie,
                                           variable=variable, 
                                           niveauSpatial="zone")
   
    ## fonction de calcul de l'estimation de la fr�quentation par mois et zone (types de jour confondus)
    FreqSpatialMoisJour <- FreqTempSpatial.f (InfoProtocoleEchant = InfoProtocoleEchant, 
                                              FreqMoyVar = FreqMoyVar)

    ## fonction de calcul de l'estimation par niveau temporel choisi selon rgpmtJour choisi
                    switch(rgpmtJour,
                       "typeJours"={                                             # types de jours distincts
                                    EstimateurJ.f (FreqAnneeChoisie = FreqAnneeChoisie,
                                                   FreqSpatialMoisJour = FreqSpatialMoisJour, 
                                                   InfoProtocoleEchant = InfoProtocoleEchant, 
                                                   niveauTemporel = niveauTemporel, 
                                                   niveauSpatial = niveauSpatial,
                                                   periode = periode,
                                                   facteurSep = facteurSep,
                                                   modalites = modalites,                                                 
                                                   titre = "",
                                                   nombre = nombre,
                                                   graph = graph,
                                                   statBoot = statBoot)      
                       },
                       "tousJours"={                                             # types de jours confondus
                                    Estimateur.f (FreqSpatialMoisJour = FreqSpatialMoisJour, 
                                                  InfoProtocoleEchant = InfoProtocoleEchant, 
                                                  niveauTemporel = niveauTemporel, 
                                                  niveauSpatial = niveauSpatial,
                                                  periode = periode,
                                                  facteurSep = facteurSep,
                                                  modalites = modalites, 
                                                  titre = "",
                                                  nombre = nombre,
                                                  graph = graph,
                                                  statBoot = statBoot)       
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))
}


########################################################################################################################
LancementExtrapolationFacteursSep.f <- function(tab, niveauSpatial, niveauTemporel, variable,
                                                periode, rgpmtJour, facteurSep, modalites, titre="", graph, statBoot = NULL)
{
    ## Purpose: Lance le calcul d'extrapolation ainsi que le barplot correspondant 
    ##          (pour les cas o� il y a un facteur de s�paration)
    ## ----------------------------------------------------------------------
    ## Arguments: tab : tableau de donn�es � consid�rer
    ##            niveauSpatial : niveau spatial choisi pour le calcul (character)
    ##            niveauTemporel : niveau temporel choisi pour le calcul (character)
    ##            variable : la variable choisie pour le calcul (character)
    ##            periode : p�riode d'�chantillonnage choisie
    ##            rgpmtJour : choix de regroupement des types de jours (character)
    ##            facteurSep : facteur de s�paration choisi
    ##            modalites : modalites du facteur de s�paration choisi
    ##            titre : compl�ment du titre pour le graph
    ##            graph : lancement du graphique si graph=T
    ##            statBoot : tableau de sortie des estimations bootstrap (moy, var et ICs)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 sept. 2011

    if (graph == T) {
      ## d�finition de "nombre" selon la valeur de "variable"
      if (is.element(variable,
                     c("nbBat", "nbBatAct"))) {
          nombre <- "bateaux"
      } else {}
      
      if (is.element(variable,
                     c("nbPers", "nbPersAct"))) {
          nombre <- "personnes"
      } else {}
      
      if (is.element(variable,
                     c("nbLigne"))) {
          nombre <- "lignes"
      } else {}
      
      ## rajout de la colonne correspondant au niveau spatial choisi
      tab[, niveauSpatial] <- refSpatial[, niveauSpatial][match(tab$zone , refSpatial$codeZone)]
  
      ## rajout de la colonne correspondant au niveau temporel choisi
      tab[, niveauTemporel] <- calendrierGeneral[ , niveauTemporel][match(tab$moisAn , calendrierGeneral$moisAn)]
  
      ## subset du tableau de fr�quentation sur la p�riode choisie
      FreqAnneeChoisie <- subset(tab,tab$periodEchant == periode)
    
    } else {
    
        FreqAnneeChoisie <- tab
    }
    ## si le facteur de s�paration = act1 ou categAct1 on transforme le tableau
    ## freqtot initial pour prendre en compte les deux champs activit�

    if (is.element(facteurSep,
                   c("act1", "categAct1")))
    {
        freqtotExt <- TransfoDoubleActivite.f(FreqAnneeChoisie, facteurSep)
        facteurSep <- "act"
    } else {
        freqtotExt <- FreqAnneeChoisie
    }

    freqtotExt <- dropLevels.f(freqtotExt, which=niveauSpatial)

    ## Fonction de calcul du calendrier
    InfoProtocoleEchant <- TabEchant.f (FreqAnneeChoisie = freqtotExt, 
                                        niveauSpatial="zone")
                                        
    ## Fonction du calcul de la moyenne et de la variance par mois, niveau spatial, et type de jour
    ## sp�cifique pour facteur de s�paration
    FreqMoyVar <- CalculMoyenneVarianceAct.f (FreqAnneeChoisie = freqtotExt, 
                                              variable = variable, 
                                              niveauSpatial = "zone", 
                                              facteurSep = facteurSep, 
                                              modalites = modalites)    
        
    ## fonction de calcul de l'estimation de la fr�quentation par mois et zone (types de jour confondus)
    FreqSpatialMoisJour <- FreqTempSpatial.f (InfoProtocoleEchant = InfoProtocoleEchant, 
                                              FreqMoyVar = FreqMoyVar)

    ## fonction de calcul de l'estimation par niveau temporel choisi selon rgpmtJour choisi
                    switch(rgpmtJour,
                       "typeJours"={                                             # types de jours distincts
                                    EstimateurJ.f (FreqAnneeChoisie = freqtotExt,
                                                   FreqSpatialMoisJour = FreqSpatialMoisJour, 
                                                   InfoProtocoleEchant = InfoProtocoleEchant, 
                                                   niveauTemporel = niveauTemporel, 
                                                   niveauSpatial = niveauSpatial,
                                                   periode = periode,
                                                   facteurSep = facteurSep,
                                                   modalites = modalites, 
                                                   titre = paste("pour le facteur",facteurSep, "=",modalites),
                                                   nombre = nombre,
                                                   graph = graph,
                                                   statBoot = statBoot)      
                       },
                       "tousJours"={                                             # types de jours confondus
                                    Estimateur.f (FreqSpatialMoisJour = FreqSpatialMoisJour, 
                                                  InfoProtocoleEchant = InfoProtocoleEchant, 
                                                  niveauTemporel = niveauTemporel, 
                                                  niveauSpatial = niveauSpatial,
                                                  periode = periode,
                                                  facteurSep = facteurSep,
                                                  modalites = modalites, 
                                                  titre = paste("pour le facteur",facteurSep, "=",modalites),
                                                  nombre = nombre,
                                                  graph = graph,
                                                  statBoot = statBoot)      
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))
}


########################################################################################################################
updateListFacteursExt.f <- function(env)
{
    ## Purpose: Mise � jour du choix des modalit�ss (toutes ou certaines) si un
    ##          facteur choisi 
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 22 sept. 2011

    ## Grisage du choix des zones si inappropri� :
    evalq(if (is.element(tclvalue(FactFreq),
                          c("aucun")))
      {
          tkconfigure(RB.selecModalites, state = "disabled")
          tkconfigure(B.selecModalites, state = "disabled")
          tkconfigure(L.modalites, state = "disabled")
      } else {
          tkconfigure(RB.selecModalites, state = "normal")
          tkconfigure(L.modalites, state = "normal")
          updateChoixModalitesExt.f(env = env)
      }, envir = env)

    evalq(tkconfigure(CB.variables,
                      value = listeVariables.f(facteur = tclvalue(FactFreq))),
          envir = env)
    assign("modalitesChoisies", NULL, envir = env)

}

########################################################################################################################
updateChoixModalitesExt.f <- function(env)
{
    ## Purpose: Activer/d�sactiver le bouton de choix des modalit�s
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2011, 10:30

    
    evalq(if (!is.element(tclvalue(FactFreq), "aucun"))   
          {
            if (is.element(tclvalue(SelecModalites),
                           c("toutesModalites")))
            {
                tkconfigure(B.selecModalites, state = "disabled")
                 
                modalitesChoisies <- unique(freqtot[, tclvalue(FactFreq)])
            } else {
                tkconfigure(B.selecModalites, state = "normal")
                
                if (any(!is.element(modalitesChoisies, 
                                    unique(freqtot[, tclvalue(FactFreq)]))))
                {
                    modalitesChoisies <- NULL
                } else {}
       #       assign("modalitesChoisies", NULL, envir=env)
            }
          } else {}, envir = env)
}


########################################################################################################################
interfaceExtrapolation.f <- function()
{
    ## Purpose: cr�er l'interface pour les graphs dd'extrapolation de la fr�quentation
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution
    modalitesChoisies <- NULL               # vecteur de stockage des modalites choisies
    zonesChoisies <- NULL                   # vecteur de stockage des zones choisies

    ## S�lection de la p�riode d'�chantillonnage
    listPeriode <- listePeriode.f()
    PeriodeChoisie <- tclVar(listPeriode[1])            #
    
    ## Liste des niveaux spatiaux :
    listNivSpatial <- listeNivSpatial.f()
    NiveauSpatial <- tclVar(listNivSpatial[1])              #

    ## Liste des niveaux temporels :
    listNivTemporel <- listeNivTemporel.f()
    NiveauTemporel <- tclVar(listNivTemporel[1])            #

    ## Liste des facteurs de s�paration :
    listFacteursSep <- listeFacteursFreq.f()
    FactFreq <- tclVar(listFacteursSep[1])                  #

    ## Liste des variables :
    listVariables <- "" #listeVariables.f()
    VariableChoisie <- tclVar("")                       #


    ## S�lection du type de jours
    TypeJ <- tclVar("tousJours") ## ou "typeJours"

    ## S�lection des modalit�s du facteurs de s�paration
    SelecModalites <- tclVar("selectModalites") 

    ## Choix de calcul des IC
    LancerIC <- tclVar("calculIC") ## ou "sansIC"

    ## ########################
    ## �l�ments graphiques :
    WinExtrapolation <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinExtrapolation, "S�lections pour le calcul des extrapolation")

    F.main0 <- tkframe(WinExtrapolation, width = 30)       # p�riode �chantillonnage
    F.main1 <- tkframe(WinExtrapolation, width = 30)       # niveauSpatial
    F.main2 <- tkframe(WinExtrapolation, width = 30)       # niveauTemporel
    F.main3 <- tkframe(WinExtrapolation, width = 30)       # facteurs s�paration
    F.main4 <- tkframe(WinExtrapolation, width = 30)       # variables et graphiques
    F.radio1 <- tkframe(WinExtrapolation, borderwidth = 2, relief = "groove")         # type Jours
    F.button2 <- tkframe(F.main3, borderwidth = 2, relief = "groove")         # s�lection facteurs
    F.radio2 <- tkframe(WinExtrapolation, borderwidth = 2, relief = "groove")         # calcul des IC
    
    ## �l�ments graphiques :
    CB.periode <- ttkcombobox(F.main0, value = listPeriode, textvariable = PeriodeChoisie,
                          state = "readonly")

    CB.spatial <- ttkcombobox(F.main1, value = listNivSpatial, textvariable = NiveauSpatial,
                          state = "readonly")

    CB.temporel <- ttkcombobox(F.main2, value = listNivTemporel, textvariable = NiveauTemporel,
                          state = "readonly")

    CB.facteurs <- ttkcombobox(F.main3, value = listFacteursSep, textvariable = FactFreq,
                          state = "readonly")

    CB.variables <- ttkcombobox(F.main4, value = listVariables, textvariable = VariableChoisie,
                          state = "readonly")

    B.selecModalites <- tkbutton(F.button2, text = "choisir la modalit�",
                                 command = function()
                           {
                               assign("modalitesChoisies", listeModalitesFactExt.f(facteurSep = tclvalue(FactFreq), preselect = modalitesChoisies), envir = env)
                               winRaise.f(WinExtrapolation)
                           })

    RB.selecModalites <- tkradiobutton(F.button2, variable = SelecModalites, value = "selectModalites", text = "s�lection de la modalit�")

    RB.tousJours <- tkradiobutton(F.radio1, variable = TypeJ, value = "tousJours", text = "type de jours confondus")
    RB.typeJours <- tkradiobutton(F.radio1, variable = TypeJ, value = "typeJours", text = "par type de jours")

    RB.calculIC <- tkradiobutton(F.radio2, variable = LancerIC, value = "calculIC", text = "Calculer les IC")
    RB.sansIC <- tkradiobutton(F.radio2, variable = LancerIC, value = "sansIC", text = "Ne pas calculer les IC")


    ## barre de boutons :
    FrameBT <- tkframe(WinExtrapolation)
    B.OK <- tkbutton(FrameBT, text = "  Lancer  ", command = function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text = " Quitter ", command = function(){tclvalue(Done) <- 2})
    B.optGraph <- tkbutton(FrameBT, text = " Options graphiques... ",
                           command = function(x)
                       {
                           warning("Un peu de patience")
                           ## choixOptionsGraphiques.f()
                           ## winRaise.f(WinExtrapolation)
                       })
    tkconfigure(B.optGraph, state = "disabled")  # � enlever lors de la d�finition des options graphiques
    
    ## D�finition des actions :

    tkbind(WinExtrapolation, "<Destroy>", function(){tclvalue(Done) <- 2})

    tkbind(CB.facteurs, "<FocusIn>", function(){updateListFacteursExt.f(env = env)})

    tkbind(RB.selecModalites, "<Leave>", function(){updateChoixModalitesExt.f(env = env)})

    ## Placement des �l�ments sur l'interface :
    tkgrid(tklabel(F.main0, text = "P�riode d'�chantillonnage"),
           CB.periode, ## column=1, columnspan=3,
           sticky = "w", padx = 5, pady = 5)

    tkgrid(tklabel(F.main1, text = "Niveau spatial"),
           CB.spatial, ## column=1, columnspan=3,
           sticky = "w", padx = 5, pady = 5)

    tkgrid(tklabel(F.main2, text = "Niveau temporel"),
           CB.temporel, ## column=1, columnspan=3,
           sticky = "w", padx = 5, pady = 5)

    tkgrid(tklabel(F.radio1, text = "Choix du regroupement des types de jours (JS/JW)"), pady = 5)
    tkgrid(ttkseparator(F.radio1, orient = "horizontal"), column = 0, sticky = "ew")
    tkgrid(RB.tousJours, padx = 5, pady = 5, sticky = "w")
    tkgrid(RB.typeJours, padx = 5, pady = 5, sticky = "w")

    tkgrid(tklabel(F.main3, text = "Facteur de s�paration"),
           CB.facteurs, ## column=1, columnspan=3,
           sticky = "w", padx = 5, pady = 5)

    tkgrid(L.modalites <- tklabel(F.button2, text = "Choix de la modalit� du facteur de s�paration"),
           column = 0, columnspan = 3, pady = 5, sticky = "ew")
    tkgrid(ttkseparator(F.button2, orient = "horizontal"), column = 0, columnspan = 3, sticky = "ew")
    tkgrid(RB.selecModalites, B.selecModalites, padx = 5, pady = 5, sticky = "w")

    tkgrid(tklabel(F.main4, text = "Variable"),
           CB.variables, ## column=1, columnspan=3,
           sticky = "w", padx = 5, pady = 5)

    tkgrid(tklabel(F.radio2, text = "Choix de calculer les intervalles de confiance \n Attention, ce calcul prend du temps (entre 10 et 15min)"), pady = 5)
    tkgrid(ttkseparator(F.radio2, orient = "horizontal"), column = 0, sticky = "ew")
    tkgrid(RB.calculIC, padx = 5, pady = 5, sticky = "w")
    tkgrid(RB.sansIC, padx = 5, pady = 5, sticky = "w")


    tkgrid(F.main0, padx = 10, pady = 10)
    tkgrid(F.main1, padx = 10, pady = 10)
    tkgrid(F.main2, padx = 10, pady = 10)
    tkgrid(F.radio1, columnspan = 2)
    tkgrid(F.main3, padx = 10, pady = 10)
    tkgrid(F.button2, columnspan = 2)
    tkgrid(F.main4, padx = 10, pady = 10)
    tkgrid(F.radio2, columnspan = 2)
    
    ## Barre de boutons :
    tkgrid(FrameBT, column = 0, columnspan = 1, padx = 2, pady = 5)
    tkgrid(B.OK, tklabel(FrameBT, text = "      "), B.Cancel,
           tklabel(FrameBT, text = "               "), B.optGraph, tklabel(FrameBT, text = "\n"))

    ## Mise � jour des cadres � activation "dynamique" :
    updateListFacteursExt.f(env = env)
        
    ## tkfocus(WinEnquete)
    winSmartPlace.f(WinExtrapolation)

    ## Update des fen�tres :
    tcl("update")

    ## Tant que l'utilisateur ne ferme pas la fen�tre... :
    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        if (tclvalue(Done) == "1")      # statut ex�cution OK.
        {
            tableauCh <- freqtot
            niveauSpatialCh <- tclvalue(NiveauSpatial)
            niveauTemporelCh <- tclvalue(NiveauTemporel)
            variableCh <- tclvalue(VariableChoisie)
            periodeCh <- tclvalue(PeriodeChoisie)
            rgpmtJourCh <- tclvalue(TypeJ)
            facteurCh <- tclvalue(FactFreq)
            modaliteCh <- modalitesChoisies
            lancerIcCh <- tclvalue(LancerIC)
          
            
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(tableauCh,
                                                      niveauSpatialCh,
                                                      niveauTemporelCh,
                                                      variableCh,
                                                      periodeCh,
                                                      rgpmtJourCh,
                                                      facteurCh,
                                                      modaliteCh,
                                                      lancerIcCh,
                                                      ParentWin = WinExtrapolation)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.


            ## ##################################################
            ## Fonctions pour la cr�ation du graphique :

            ## #### toutes p�riodes d'�chantillonnage confondues
            if (facteurCh == "aucun")        # sans facteur choisi
            {
                if (lancerIcCh == "calculIC") {                                 # lancement du bootstrap si choix de calculer les IC
                  tkmessageBox(message="Cette fonction met un peu de temps � tourner!\n Soyez patients.",icon="warning",type="ok")
                  
                  switch(rgpmtJourCh,
                       "tousJours"={
                           statBoot <- BootstrapExtrapolationTsJ.f (niveauSpatial = niveauSpatialCh, 
                                                                    niveauTemporel = niveauTemporelCh,
                                                                    variable = variableCh, 
                                                                    anneeChoisie = periodeCh)
                           
                           LancementExtrapolation.f (tab = tableauCh,                      
                                                     niveauSpatial = niveauSpatialCh, 
                                                     niveauTemporel = niveauTemporelCh, 
                                                     variable = variableCh,
                                                     periode = periodeCh, 
                                                     rgpmtJour = rgpmtJourCh, 
                                                     titre = "", 
                                                     graph = T,
                                                     statBoot = statBoot)
                       },
                       "typeJours"={
                           statBoot <- BootstrapExtrapolationTyJ.f (niveauSpatial = niveauSpatialCh, 
                                                                    niveauTemporel = niveauTemporelCh,
                                                                    variable = variableCh, 
                                                                    anneeChoisie = periodeCh)
                           
                           LancementExtrapolation.f (tab = tableauCh,                      
                                                     niveauSpatial = niveauSpatialCh, 
                                                     niveauTemporel = niveauTemporelCh, 
                                                     variable = variableCh,
                                                     periode = periodeCh, 
                                                     rgpmtJour = rgpmtJourCh, 
                                                     titre = "", 
                                                     graph = T,
                                                     statBoot = statBoot)
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))

                } else {                                                       # pas d'IC si choix de ne pas calculer les IC
                                                                     
                  LancementExtrapolation.f (tab = tableauCh,                      
                                            niveauSpatial = niveauSpatialCh, 
                                            niveauTemporel = niveauTemporelCh, 
                                            variable = variableCh,
                                            periode = periodeCh, 
                                            rgpmtJour = rgpmtJourCh, 
                                            titre = "", 
                                            graph = T,
                                            statBoot = NULL)
                }
                
            } else {                           # un facteur choisi
                
                if (lancerIcCh == "calculIC") {                                 # lancement du bootstrap si choix de calculer les IC
                tkmessageBox(message="Cette fonction met un peu de temps � tourner!\n Soyez patients.",icon="warning",type="ok")
                 
                 statBoot <- switch(rgpmtJourCh,
                       "tousJours"={
                           statBoot <- BootstrapExtrapolationTsJFacteur.f (niveauSpatial = niveauSpatialCh, 
                                                                           niveauTemporel = niveauTemporelCh,
                                                                           variable = variableCh, 
                                                                           anneeChoisie = periodeCh, 
                                                                           facteurSep = facteurCh, 
                                                                           modalite = modaliteCh)
                                                                           
                           LancementExtrapolationFacteursSep.f (tab = tableauCh, 
                                                                niveauSpatial = niveauSpatialCh, 
                                                                niveauTemporel = niveauTemporelCh, 
                                                                variable = variableCh,
                                                                periode = periodeCh, 
                                                                rgpmtJour = rgpmtJourCh, 
                                                                facteurSep = facteurCh, 
                                                                modalites = modaliteCh, 
                                                                titre = "", 
                                                                graph = T,
                                                                statBoot = statBoot)
                       },
                       "typeJours"={
                           statBoot <- BootstrapExtrapolationTyJFacteur.f (niveauSpatial = niveauSpatialCh, 
                                                                           niveauTemporel = niveauTemporelCh,
                                                                           variable = variableCh, 
                                                                           anneeChoisie = periodeCh, 
                                                                           facteurSep = facteurCh, 
                                                                           modalite = modaliteCh)
                                                                           
                           LancementExtrapolationFacteursSep.f (tab = tableauCh, 
                                                                niveauSpatial = niveauSpatialCh, 
                                                                niveauTemporel = niveauTemporelCh, 
                                                                variable = variableCh,
                                                                periode = periodeCh, 
                                                                rgpmtJour = rgpmtJourCh, 
                                                                facteurSep = facteurCh, 
                                                                modalites = modaliteCh, 
                                                                titre = "", 
                                                                graph = T,
                                                                statBoot = statBoot)
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))

                } else {                                                       # pas d'IC si choix de ne pas calculer les IC
                
                  LancementExtrapolationFacteursSep.f (tab = tableauCh, 
                                                       niveauSpatial = niveauSpatialCh, 
                                                       niveauTemporel = niveauTemporelCh, 
                                                       variable = variableCh,
                                                       periode = periodeCh, 
                                                       rgpmtJour = rgpmtJourCh, 
                                                       facteurSep = facteurCh, 
                                                       modalites = modaliteCh, 
                                                       titre = "", 
                                                       graph = T,
                                                       statBoot = NULL)   
                }
            }

            ## ##################################################

            ## winRaise.f(WinEnquete)

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie :
            winSmartPlace.f(WinExtrapolation)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinExtrapolation)             # destruction de la fen�tre.

}


##############################################################################################################