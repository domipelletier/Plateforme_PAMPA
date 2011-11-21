#-*- coding: latin-1 -*-

### File: InterfaceOpinion_new.R
### Time-stamp: <2011-09-28 18:01:58 yreecht>
###
### Author: Elodie Gamp
###
####################################################################################################
### Description:
###
### Nouvelle interface pour les graph de pression/fr�quentation
####################################################################################################

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
    }else{
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
    }else{
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
    }else{
        tkgrid(tklabel(winfac, text=label), columnspan=2)
    }

    ## Avertissement 'plusieurs s�lections possibles' :
    if (is.element(selectmode, c("extended", "multiple")))
    {
        tkgrid(tklabel(winfac, text="Plusieurs s�lections POSSIBLES.\n"), columnspan=2)
    }else{}

    ## Avertissement mode de s�lection �tendu :
    if (selectmode == "extended")
    {
        tkgrid(tklabel(winfac,
                       text=paste("!!Nouveau!! mode de s�lection �tendu : \n",
                       "*  utilisez Ctrl et Maj pour les s�lections multiples.\n",
                       "*  Ctrl+a pour tout s�lectionner\n", sep=""),
                       fg="red"), columnspan=2, rowspan=2)
    }else{}

    tkgrid(LB, SCR.y)
    tkgrid.configure(SCR.y, rowspan=4, sticky="nsw")
    tkgrid(FrameB, columnspan=2, sticky="")
    tkgrid(B.OK, tklabel(FrameB, text="        "), B.Cancel, sticky="", pady=5)

    ## Configuration de la liste :
    if (sort)
    {
        listMod <- unique(as.character(sort(tab[ , champ])))
    }else{
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
listeZones.f <- function(nivSpatial, ...)
{
    ## Purpose: si nivSpatial = codeZone et choix de s�lection de certaines zones,
    ##          ouvre une fen�tre pour choisir la liste des zones � consid�rer
    ##          Retourne la liste des zones choisies par l'utilisateur
    ## ----------------------------------------------------------------------
    ## Arguments: facteurSep : facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## liste des zones disponibles
    if (nivSpatial != "codeZone")
    {
        listZones <- ""
    } else {
        listZones <- selectModWindow.f(champ="zone", tab=freqtot, selectmode="extended", ...) #sort(unique(freqtot[,nivSpatial]))
    }

    return(listZones)          # retourne la liste des zones si nivSpatial=codeZone

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
listeModalitesFact.f <- function(facteurSep, ...)
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
        listNivFactFreq <- selectModWindow.f(champ=facteurSep, tab=freqtot, selectmode="extended", ...) #sort(unique(freqtot[,facteurSep]))
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
listeGraphFreq.f <- function()
{
    ## Purpose: Retourne une liste de choix de graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Types de graphiques possibles pour les donn�es de fr�quentation
    listGraphFreq <- c("boxplot" ) #, "barplot")

    return(listGraphFreq)          # actuellement tout est possible
}


########################################################################################################################
LancementBoxplotFreq.f <- function(tab, niveauSpatial, niveauTemporel, variable,
                                   periode, rgpmtJour, facteurSep=NULL, modalites=NULL)
{
    ## Purpose: Lance le bon calcul de la moyenne stratifi�e ainsi que le
    ##          boxplot correspondant (pour les cas ou act1/categAct1 ne sont
    ##          les facteurs choisis)
    ## ----------------------------------------------------------------------
    ## Arguments: tab : tableau de donn�es � consid�rer
    ##            niveauSpatial : niveau spatial choisi pour le calcul (character)
    ##            niveauTemporel : niveau temporel choisi pour le calcul (character)
    ##            variable : la variable choisie pour le calcul (character)
    ##            periode : nom du champ de p�riode (character)
    ##            rgpmtJour : choix de regroupement des types de jours (character)
    ##            facteurSep=NULL : facteur de s�paration choisi
    ##            modalites=NULL : modalites du facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 sept. 2011

    ## rajout de la colonne correspondant au niveau spatial choisi
    tab[, niveauSpatial] <- refSpatial[, niveauSpatial][match(tab$zone , refSpatial$codeZone)]

    ## rajout de la colonne correspondant au niveau temporel choisi
    tab[, niveauTemporel] <- calendrierGeneral[ , niveauTemporel][match(tab$moisAn , calendrierGeneral$moisAn)]

    tab <- dropLevels.f(tab, which=niveauSpatial)

    MoyFreqJour <- CreationTabintermediaireFreq.f (tab, niveauSpatial, niveauTemporel, variable)
    InfoJour <- CreationInfoJour.f (niveauTemporel)

                    switch(rgpmtJour,
                       "typeJours"={
                           MoyStrat <- MoyenneStratifieeTypeJ.f (tab,
                                                                 MoyFreqJour,
                                                                 InfoJour,
                                                                 niveauTemporel)

                           BoxplotFreqTypeJ.f (tab,
                                               variable,
                                               niveauSpatial,
                                               niveauTemporel,
                                               MoyStrat,
                                               periode)
                       },
                       "tousJours"={
                           MoyStrat <- MoyenneStratifieeTousJ.f (tab,
                                                                 MoyFreqJour,
                                                                 InfoJour,
                                                                 niveauTemporel)

                           BoxplotFreqTousJ.f (tab,
                                               variable,
                                               niveauSpatial,
                                               niveauTemporel,
                                               MoyStrat,
                                               periode)
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))
}


########################################################################################################################
LancementBoxplotFreqFacteursSep.f <- function(tab, niveauSpatial, niveauTemporel, variable,
                                             periode, rgpmtJour, facteurSep, modalites)
{
    ## Purpose: Lance le bon calcul de la moyenne stratifi�e ainsi que le
    ##          boxplot correspondant (pour les cas ou act1/categAct1 ne sont
    ##          les facteurs choisis)
    ## ----------------------------------------------------------------------
    ## Arguments: tab : tableau de donn�es � consid�rer
    ##            niveauSpatial : niveau spatial choisi pour le calcul (character)
    ##            niveauTemporel : niveau temporel choisi pour le calcul (character)
    ##            variable : la variable choisie pour le calcul (character)
    ##            periode : nom du champ de p�riode (character)
    ##            rgpmtJour : choix de regroupement des types de jours (character)
    ##            facteurSep : facteur de s�paration choisi
    ##            modalites : modalites du facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 sept. 2011

    ## rajout de la colonne correspondant au niveau spatial choisi
    tab[, niveauSpatial] <- refSpatial[, niveauSpatial][match(tab$zone , refSpatial$codeZone)]

    ## rajout de la colonne correspondant au niveau temporel choisi
    tab[, niveauTemporel] <- calendrierGeneral[ , niveauTemporel][match(tab$moisAn , calendrierGeneral$moisAn)]

    ## si le facteur de s�paration = act1 ou categAct1 on transforme le tableau
    ## freqtot initial pour prendre en compte les deux champs activit�

    if (is.element(facteurSep,
                   c("act1", "categAct1")))
    {
        freqtotExt <- TransfoDoubleActivite.f(tab, facteurSep)
        facteurSep <- "act"
    } else {
        freqtotExt <- tab
    }

    freqtotExt <- dropLevels.f(freqtotExt, which=niveauSpatial)

    # lance la fonction pour corriger le tableau de fr�quentation en l'adaptant
    # � un choix de facteur de s�paration
    MoyFreqJourFact <- CasParticulierFacteurSep.f (tab=freqtotExt,
                                                   niveauSpatial=niveauSpatial,
                                                   niveauTemporel=niveauTemporel,
                                                   variable=variable,
                                                   facteurSep=facteurSep,
                                                   modalites=modalites)


    InfoJour <- CreationInfoJour.f (niveauTemporel=niveauTemporel)

    ## browser()
# calcul des moyennes stratifi�es par modalit�s du facteur
                    switch(rgpmtJour,
                       "typeJours"={
                              tmp <- sapply(1:length(x <- unlist(apply(MoyFreqJourFact, 5, list), recursive = FALSE)),
                                    FUN=function(i,...)
                            {

                                MoyStrat <- MoyenneStratifieeTypeJ.f(tab=freqtotExt,
                                                                     MoyFreqJour=x[[i]],
                                                                     InfoJour=InfoJour,
                                                                     niveauTemporel=niveauTemporel)

                                ## browser()

                                BoxplotFreqTypeJFacteur.f (tab=freqtotExt,
                                                           variable=variable,
                                                           niveauSpatial=niveauSpatial,
                                                           niveauTemporel=niveauTemporel,
                                                           MoyStrat=MoyStrat,
                                                           periode=periode,
                                                           facteurSep=facteurSep,
                                                           modalites=names(x)[i])
                                return(MoyStrat)
                            },
                                tab=freqtotExt,
                                variable=variable,
                                niveauSpatial=niveauSpatial,
                                niveauTemporel=niveauTemporel,
                                MoyStrat=MoyStrat,
                                periode=periode,
                                facteurSep=facteurSep,
                                InfoJour=InfoJour,
                                x=x, simplify=FALSE)
                                },

                       "tousJours"={
                              tmp <- sapply(1:length(x <- unlist(apply(MoyFreqJourFact, 5, list), recursive = FALSE)),
                                    FUN=function(i,...)
                              {
                                MoyStrat <- MoyenneStratifieeTousJ.f (tab=freqtotExt,
                                                                      MoyFreqJour=x[[i]],
                                                                      InfoJour=InfoJour,
                                                                      niveauTemporel=niveauTemporel)

                                BoxplotFreqTousJFacteur.f (tab=freqtotExt,
                                                           variable=variable,
                                                           niveauSpatial=niveauSpatial,
                                                           niveauTemporel=niveauTemporel,
                                                           MoyStrat=MoyStrat,
                                                           periode=periode,
                                                           facteurSep=facteurSep,
                                                           modalites=names(x)[i])

                                return(MoyStrat)
                              },
                                tab=freqtotExt,
                                variable=variable,
                                niveauSpatial=niveauSpatial,
                                niveauTemporel=niveauTemporel,
                                MoyStrat=MoyStrat,
                                periode=periode,
                                modalites=modalites,
                                facteurSep=facteurSep,
                                InfoJour=InfoJour,
                                x=x, simplify=FALSE)
                       },
                       warning("Pas impl�ment� : harcelez la hotline PAMPA !"))

      MoyStrat <-  array(unlist(tmp), dim=c(dim(tmp[[1]]), length(tmp)), dimnames=c(dimnames(tmp[[1]]), list(names(tmp))))

}


########################################################################################################################
updateListZone.f <- function(env)
{
    ## Purpose: Mise � jour du choix des zones (toutes ou certaines) selon le
    ##          niveau spatial choisi (choix dispo uniquement si niveau=codeZone)
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 22 sept. 2011

    ## Grisage du choix des zones si inappropri� :
    evalq(if (!is.element(tclvalue(NiveauSpatial),
                          c("codeZone")))
      {
          tkconfigure(RB.selecZones, state="disabled")
          tkconfigure(RB.toutesZones, state="disabled")
          tkconfigure(B.selecZones, state="disabled")
          tkconfigure(L.zones, state="disabled")
      }else{
          tkconfigure(RB.selecZones, state="normal")
          tkconfigure(RB.toutesZones, state="normal")
          tkconfigure(L.zones, state="normal")
          updateChoixZones.f(env=env)
      }, envir=env)
          assign("zonesChoisies", NULL, envir=env)
}

########################################################################################################################
updateChoixZones.f <- function(env)
{
    ## Purpose: Activer/d�sactiver le bouton de choix de zones
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2011, 10:30

    evalq(if (is.element(tclvalue(SelecZones),
                         c("toutesZones")))
          {
              tkconfigure(B.selecZones, state="disabled")
              assign("zonesChoisies", unique(freqtot$zone), envir=env)
          } else {
              tkconfigure(B.selecZones, state="normal")
    #          assign("zonesChoisies", NULL, envir=env)
          }, envir=env)

}

########################################################################################################################
updateListFacteurs.f <- function(env)
{
    ## Purpose: Mise � jour du choix des zones (toutes ou certaines) selon le
    ##          niveau spatial choisi (choix dispo uniquement si niveau=codeZone)
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 22 sept. 2011

    ## Grisage du choix des zones si inappropri� :
    evalq(if (is.element(tclvalue(FactFreq),
                          c("aucun")))
      {
          tkconfigure(RB.toutesModalites, state="disabled")
          tkconfigure(RB.selecModalites, state="disabled")
          tkconfigure(B.selecModalites, state="disabled")
          tkconfigure(L.modalites, state="disabled")
      } else {
          tkconfigure(RB.toutesModalites, state="normal")
          tkconfigure(RB.selecModalites, state="normal")
          tkconfigure(L.modalites, state="normal")
          updateChoixModalites.f(env=env)
      }, envir=env)

    evalq(tkconfigure(CB.variables,
                      value=listeVariables.f(facteur=tclvalue(FactFreq))),
          envir=env)
    assign("modalitesChoisies", NULL, envir=env)

}

########################################################################################################################
updateChoixModalites.f <- function(env)
{
    ## Purpose: Activer/d�sactiver le bouton de choix de zones
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2011, 10:30

    
    evalq(if (!is.element(tclvalue(FactFreq), "aucun"))   
          {
            if (is.element(tclvalue(SelecModalites),
                           c("toutesModalites")))
            {
                tkconfigure(B.selecModalites, state="disabled")
                 
                modalitesChoisies <- unique(freqtot[, tclvalue(FactFreq)])
            }else{
                tkconfigure(B.selecModalites, state="normal")
                
                if (any(!is.element(modalitesChoisies, 
                                    unique(freqtot[, tclvalue(FactFreq)]))))
                {
                    modalitesChoisies <- NULL
                }else{}
       #       assign("modalitesChoisies", NULL, envir=env)
            }
          }else{}, envir=env)
}


########################################################################################################################
interfaceFrequentation.f <- function()
{
    ## Purpose: cr�er l'interface pour les graphs de fr�quentation
    ##          et lancer les fonctions graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution
    modalitesChoisies <- NULL               # vecteur de stockage des modalites choisies
    zonesChoisies <- NULL                   # vecteur de stockage des zones choisies

    ## Liste des niveaux spatiaux :
    listNivSpatial <- listeNivSpatial.f()
    NiveauSpatial <- tclVar(listNivSpatial[1])              #

    ## Liste des zones :
    #choixZones <- "" # listeZones.f()
    #ZonesChoisies <- tclVar("")                         # restera nul si NiveauSpatial != codeZone

    ## Liste des niveaux temporels :
    listNivTemporel <- listeNivTemporel.f()
    NiveauTemporel <- tclVar(listNivTemporel[1])            #

    ## Liste des facteurs de s�paration :
    listFacteursSep <- listeFacteursFreq.f()
    FactFreq <- tclVar(listFacteursSep[1])                  #

    ## Liste des niveaux de facteurs de s�paration :
    #nivFacteursSep <- "" #listeNiveauFacteursFreq.f()
    #NivFactFreq <- tclVar("")                           #   restera nul si FactFreq=="aucun"

    ## Liste des variables :
    listVariables <- "" #listeVariables.f()
    VariableChoisie <- tclVar("")                       #

    ## Liste des graphiques :
    listGraphs <- listeGraphFreq.f()
    GraphChoisi <- tclVar("")                           #

    ## S�lection des zones
    SelecZones <-  tclVar("toutesZones") ## ou "selectZones"

    ## S�lection du type de jours
    TypeJ <- tclVar("tousJours") ## ou "typeJours"

    ## S�lection des modalit�s du facteurs de s�paration
    SelecModalites <- tclVar("toutesModalites") ## ou "selectModalites"

    ## S�lection de la p�riode d'�chantillonnage
    Periode <- tclVar("periode") ## ou "toutes"

    ## ########################
    ## �l�ments graphiques :
    WinFrequentation <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinFrequentation, "S�lections pour l'�tude de fr�quentation")

    F.main1 <- tkframe(WinFrequentation, width=30)       # niveauSpatial et selectionZones
    F.main2 <- tkframe(WinFrequentation, width=30)       # niveauTemporel
    F.main3 <- tkframe(WinFrequentation, width=30)       # facteurs s�paration
    F.main4 <- tkframe(WinFrequentation, width=30)       # variables et graphiques
    F.radio1 <- tkframe(WinFrequentation, borderwidth=2, relief="groove")         # type Jours
    F.radio2 <- tkframe(WinFrequentation, borderwidth=2, relief="groove")         # periode
    F.button1 <- tkframe(F.main1, borderwidth=2, relief="groove")         # s�lection zones
    F.button2 <- tkframe(F.main3, borderwidth=2, relief="groove")         # s�lection facteurs

    ## �l�ments graphiques :
    CB.spatial <- ttkcombobox(F.main1, value=listNivSpatial, textvariable=NiveauSpatial,
                          state="readonly")

#    CB.selecZones <- ttkcombobox(F.main1, value=choixZones, textvariable=ZonesChoisies,
#                          state="readonly")

    CB.temporel <- ttkcombobox(F.main2, value=listNivTemporel, textvariable=NiveauTemporel,
                          state="readonly")

    CB.facteurs <- ttkcombobox(F.main3, value=listFacteursSep, textvariable=FactFreq,
                          state="readonly")

    CB.variables <- ttkcombobox(F.main4, value=listVariables, textvariable=VariableChoisie,
                          state="readonly")

    CB.graphs <- ttkcombobox(F.main4, value=listGraphs, textvariable=GraphChoisi,
                          state="readonly")

    B.selecZones <- tkbutton(F.button1, text="choisir les zones", command=function()
                           {
                               assign("zonesChoisies",listeZones.f(nivSpatial=tclvalue(NiveauSpatial), preselect=zonesChoisies), envir=env)
                               winRaise.f(WinFrequentation)
                           })

    RB.toutesZones <- tkradiobutton(F.button1, variable=SelecZones, value="toutesZones", text="toutes les zones")
    RB.selecZones <- tkradiobutton(F.button1, variable=SelecZones, value="selecZones", text="s�lection de certaines zones")

    B.selecModalites <- tkbutton(F.button2, text="choisir les modalit�s",
                                 command=function()
                           {
                               assign("modalitesChoisies", listeModalitesFact.f(facteurSep=tclvalue(FactFreq), preselect=modalitesChoisies), envir=env)
                               winRaise.f(WinFrequentation)
                           })

    RB.toutesModalites <- tkradiobutton(F.button2, variable=SelecModalites, value="toutesModalites", text="toutes les modalit�s")
    RB.selecModalites <- tkradiobutton(F.button2, variable=SelecModalites, value="selecModalites", text="s�lection de certaines modalit�s")

    RB.tousJours <- tkradiobutton(F.radio1, variable=TypeJ, value="tousJours", text="type de jours confondus")
    RB.typeJours <- tkradiobutton(F.radio1, variable=TypeJ, value="typeJours", text="par type de jours")

    RB.periode <- tkradiobutton(F.radio2, variable=Periode, value="periode", text="par p�riode d'�chantillonnage")
    RB.toutes <- tkradiobutton(F.radio2, variable=Periode, value="toutes", text="toutes p�riodes d'�chantillonnage confondues")


    ## barre de boutons :
    FrameBT <- tkframe(WinFrequentation)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})
    B.optGraph <- tkbutton(FrameBT, text=" Options graphiques... ",
                           command=function(x)
                       {
                           warning("Un peu de patience, que diable !")
                           ## choixOptionsGraphiques.f()
                           ## winRaise.f(WinFrequentation)
                       })
    tkconfigure(B.optGraph, state="disabled")  # � enlever lors de la d�finition des options graphiques
    
    ## D�finition des actions :

    tkbind(WinFrequentation, "<Destroy>", function(){tclvalue(Done) <- 2})

    tkbind(CB.spatial, "<FocusIn>", function(){updateListZone.f(env=env)})

    tkbind(RB.selecZones, "<Leave>", function(){updateChoixZones.f(env=env)})
    tkbind(RB.toutesZones, "<Leave>", function(){updateChoixZones.f(env=env)})

    tkbind(CB.facteurs, "<FocusIn>", function(){updateListFacteurs.f(env=env)})

    tkbind(RB.selecModalites, "<Leave>", function(){updateChoixModalites.f(env=env)})
    tkbind(RB.toutesModalites, "<Leave>", function(){updateChoixModalites.f(env=env)})

    ## Placement des �l�ments sur l'interface :
    tkgrid(tklabel(F.main1, text="Niveau spatial"),
           CB.spatial, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(L.zones <- tklabel(F.button1, text="Choix des zones � consid�rer"), column=0, columnspan=3, pady=5, sticky="ew")
    tkgrid(ttkseparator(F.button1, orient = "horizontal"), column=0, columnspan=3, sticky="ew")
    tkgrid(RB.toutesZones, RB.selecZones, B.selecZones, padx=5, pady=5, sticky="w")

    tkgrid(tklabel(F.main2, text="Niveau temporel"),
           CB.temporel, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(tklabel(F.radio1, text="Choix du regroupement des types de jours (JS/JW)"), pady=5)
    tkgrid(ttkseparator(F.radio1, orient = "horizontal"), column=0, sticky="ew")
    tkgrid(RB.tousJours, padx=5, pady=5, sticky="w")
    tkgrid(RB.typeJours, padx=5, pady=5, sticky="w")

    tkgrid(tklabel(F.main3, text="Facteur de s�paration"),
           CB.facteurs, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(L.modalites <- tklabel(F.button2, text="Choix des modalit�s du facteur de s�paration"),
           column=0, columnspan=3, pady=5, sticky="ew")
    tkgrid(ttkseparator(F.button2, orient = "horizontal"), column=0, columnspan=3, sticky="ew")
    tkgrid(RB.toutesModalites, RB.selecModalites, B.selecModalites, padx=5, pady=5, sticky="w")

    tkgrid(tklabel(F.main4, text="Variable"),
           CB.variables, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(tklabel(F.main4, text="Graphique"),
           CB.graphs, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(L.periodes <- tklabel(F.radio2, text="Choix du regroupement des p�riodes d'�chantillonnage"), pady=5)
    tkgrid(ttkseparator(F.radio2, orient = "horizontal"), column=0, sticky="ew")
    tkgrid(RB.periode, padx=5, pady=5, sticky="w")
    tkgrid(RB.toutes, padx=5, pady=5, sticky="w")


    tkgrid(F.main1, padx=10, pady=10)
    tkgrid(F.button1, columnspan=2)
    tkgrid(F.main2, padx=10, pady=10)
    tkgrid(F.radio1, columnspan=2)
    tkgrid(F.main3, padx=10, pady=10)
    tkgrid(F.button2, columnspan=2)
    tkgrid(F.main4, padx=10, pady=10)
    tkgrid(F.radio2, columnspan=2)

    ## Barre de boutons :
    tkgrid(FrameBT, column=0, columnspan=1, padx=2, pady=5)
    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
           tklabel(FrameBT, text="               "), B.optGraph, tklabel(FrameBT, text="\n"))

    ## Mise � jour des cadres � activation "dynamique" :
    updateListFacteurs.f(env=env)
    updateListZone.f(env=env)
    tkconfigure(L.periodes, state="disabled")  # � enlever lors de la d�finition des choix de p�riodes
    tkconfigure(RB.periode, state="disabled")  # � enlever lors de la d�finition des choix de p�riodes
    tkconfigure(RB.toutes, state="disabled")  # � enlever lors de la d�finition des choix de p�riodes
        
    ## tkfocus(WinEnquete)
    winSmartPlace.f(WinFrequentation)

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
            periodeCh <- tclvalue(Periode)
            rgpmtJourCh <- tclvalue(TypeJ)
            facteurCh <- tclvalue(FactFreq)
            ## modalitesCh <- modalitesChoisies
            ## zoneCH <- zonesChoisies
            graphCh <- tclvalue(GraphChoisi)
            zoneSelec <- tclvalue(SelecZones)
            modSelec <- tclvalue(SelecModalites)

            if (tclvalue(SelecModalites) == "toutesModalites" && tclvalue(FactFreq) != "aucun") 
            {
            modalitesChoisies <- unique(tableauCh[, tclvalue(FactFreq)])
            } else {}
            
            if (tclvalue(SelecZones) == "toutesZones" && tclvalue(NiveauSpatial) == "codeZone") 
            {
            zonesChoisies <- unique(tableauCh[, "zone"])
            } else {}
            
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(tableauCh,
                                                      niveauSpatialCh,
                                                      niveauTemporelCh,
                                                      variableCh,
                                                      periodeCh,
                                                      rgpmtJourCh,
                                                      facteurCh,
                                                      ## ## modalitesCh <- modalitesChoisies
                                                      graphCh,
                                                      zoneSelec,
                                                      modSelec,
                                                      ParentWin = WinFrequentation)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.

            if (is.element(niveauSpatialCh, c("codeZone")) && !is.null(zonesChoisies))
            {
                tableauCh <- subset(tableauCh, is.element(zone, zonesChoisies))
            }else{}


            ## ##################################################
            ## Fonctions pour la cr�ation du graphique :

            ## #### toutes p�riodes d'�chantillonnage confondues
            if (periodeCh == "periode")
            {
                tabTmp <- split(tableauCh, tableauCh[ , "periodEchant"])

                sapply(tabTmp,
                       FUN=function(x,...)
                   {
                       tryCatch(switch(facteurCh,
                                       "aucun"={
                                           LancementBoxplotFreq.f(tab=x,...)
                                       },
                                       {
                                           LancementBoxplotFreqFacteursSep.f(tab=x,...)
                                       })## ,
                            ##     error=function(e)
                            ## {
                            ##     dev.off()

                            ##     message(paste("Pas de donn�es pour la p�riode \"",
                            ##                   unique(x$periodEchant),
                            ##                   "\"", sep=""))
                            ## }
                                )
                   },
                       niveauSpatial=niveauSpatialCh,
                       niveauTemporel=niveauTemporelCh,
                       variable=variableCh,
                       periode=periodeCh,
                       rgpmtJour=rgpmtJourCh,
                       facteurSep=facteurCh,
                       modalites=modalitesChoisies

                       ## graphCh
                       )
            } else {
                switch(facteurCh,
                       "aucun"={
                           LancementBoxplotFreq.f(tab=tableauCh,
                                                  niveauSpatial=niveauSpatialCh,
                                                  niveauTemporel=niveauTemporelCh,
                                                  variable=variableCh,
                                                  periode=periodeCh,
                                                  rgpmtJour=rgpmtJourCh)
                       },
                       {
                           LancementBoxplotFreqFacteursSep.f(tab=tableauCh,
                                                             niveauSpatial=niveauSpatialCh,
                                                             niveauTemporel=niveauTemporelCh,
                                                             variable=variableCh,
                                                             periode=periodeCh,
                                                             rgpmtJour=rgpmtJourCh,
                                                             facteurSep=facteurCh,
                                                             modalites=modalitesChoisies)
                       })
            }


            ## ##################################################

            ## winRaise.f(WinEnquete)

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie :
            winSmartPlace.f(WinFrequentation)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinFrequentation)             # destruction de la fen�tre.

}


