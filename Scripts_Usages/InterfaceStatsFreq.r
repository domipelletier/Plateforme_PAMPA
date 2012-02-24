################################################################################
# Nom               : InterfaceStatsFreq.r
# Type              : Programme
# Objet             : Fonctions permettant de cr�er l'interface pour les traitements
#                     statistiques des donn�es de fr�quentation.
#                     Cette interface permet � l'utilisateur de faire ses choix 
#                     pour les traitements.
# Input             : clic souris
# Output            : lancement de fonctions
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : janvier 2012
# Sources
################################################################################


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
listeNivSpatialStat.f <- function()
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
listeNivTemporelStat.f <- function()                
{
    ## Purpose: Retourne la liste des niveaux temporels disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Niveaux temporels disponibles dans le calendrier
    listNivTemporel <- c("periodEchant" , "mois" , "trimestre" , "semestre", "typeJ", "saison")

    return(listNivTemporel)          # actuellement tout est renseign� pour tous

}


########################################################################################################################
listeFacteursMeteoStat.f <- function()           
{
    ## Purpose: Retourne la liste des facteurs m�t�o disponibles pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## Facteurs m�t�o disponibles
    facteursMeteo <- sort(c("meteo" , "nebulosite" , "directionVent" , "forceVent" , "etatMer" , "lune"))

    ## Identification des champs non vides de la table de fr�quentation
    champsVide <- ! sapply(freqtot,
                          function(x){all(is.na(x))})

    listFactMeteo <- facteursMeteo[is.element(facteursMeteo,names(champsVide)[champsVide])]

    return(listFactMeteo)          # ne prend que les facteurs de s�paration renseign�s

}


########################################################################################################################
listeFacteursFreqStat.f <- function()                   
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
listeFacteursStat.f <- function()
{
    ## Purpose: G�n�re la liste compl�te des facteurs disponibles pour l'analyse des
    ##          donn�es de fr�quentation (spatial, temporel, m�t�o, caract�ristiques bateaux)
    ## ----------------------------------------------------------------------
    ## Arguments: facteur : facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    listeSpatial <- listeNivSpatialStat.f () 
    listeTemporel <- listeNivTemporelStat.f () 
    listeMeteo <- listeFacteursMeteoStat.f () 
    listeCarac <- listeFacteursFreqStat.f ()
    listeFacteurs <- c("aucun", listeSpatial, listeTemporel, listeMeteo, listeCarac)  
    
    return (listeFacteurs)
}


########################################################################################################################
listeModalitesStat.f <- function(facteur, env, ...)
{
   ## Purpose: si facteur != "aucun" et choix de s�lection de certaines modalit�s,
    ##          ouvre une fen�tre pour choisir la liste des modalit�s de ce facteur
    ##          � consid�rer pour les calculs
    ##          Retourne la liste des modalit�s choisies par l'utilisateur
    ## ----------------------------------------------------------------------
    ## Arguments: facteur : facteur de s�paration choisi
    ##            env : environnement de l'interface
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

 
    ## v�rification de la pr�sence des facteurs explicatifs dans la table freqtot
    ## (parfois absent si ce sont des niveaux du r�f�rentiel spatial ou temporel)
        if (!is.element(facteur, 
                      names(freqtot)))
    {
        if (is.element(facteur, 
                      names(refSpatial)))
        {
          freqtot[, facteur] <- refSpatial[, facteur][match(freqtot$zone , refSpatial$codeZone)] 
        } else {
          freqtot[, facteur] <- calendrierGeneral[ , facteur][match(freqtot$moisAn , calendrierGeneral$moisAn)]
        }
    } else {}

    ## Niveaux du facteur de s�paration disponibles
    if (facteur == "aucun")
    {
        listNivFactFreq <- ""
    } else {
        listNivFactFreq <- selectModWindow.f(champ=facteur, tab=freqtot, selectmode="extended", ...) 
    }

    return(listNivFactFreq)          # retourne les valeurs disponibles dans le champ facteurSep

}


########################################################################################################################
listeVariablesStat.f <- function()
{
    ## Purpose: retourne un vecteur de caract�res donnant les variables
    ##          disponibles selon le facteur de s�paration choisi
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 13 sept. 2011, 14:40

    listVariable <- c("nbBat", "nbPers", "nbLigne")

    return(listVariable)
}


########################################################################################################################
LancementAnalyse.f <- function(variable, facteur1, facteur2, tableMetrique,
                                 modalites1, modalites2, sufixe=NULL)
{
    ## Purpose: Lance les fonctions d'analyse statistique selon les choix
    ##          effectu�s par l'utilisateur
    ## ----------------------------------------------------------------------
    ## Arguments: variable : la variable choisie pour le calcul (character)
    ##            facteur1 : le premier facteur � tester
    ##            facteur1 : le second facteur � tester
    ##            tableMetrique : la table de donn�es � consid�rer (freqtot)
    ##            modalites1 : les niveaux du facteur1 � consid�rer (uniquement)
    ##            modalites2 : les niveaux du facteur2 � consid�rer (uniquement)
    ##            env : environnement de l'interface
    ##            sufixe=NULL : un sufixe pour le nom de fichier (utilis� pour l'enregistrement)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 sept. 2011

    ## v�rification de la pr�sence des facteurs explicatifs dans la table freqtot
    ## (parfois absent si ce sont des niveaux du r�f�rentiel spatial ou temporel)
        if (!is.element(facteur1, 
                      c("aucun", names(freqtot))))
    {
        if (is.element(facteur1, 
                      names(refSpatial)))
        {
          freqtot[, facteur1] <- refSpatial[, facteur1][match(freqtot$zone , refSpatial$codeZone)] 
        } else {
          freqtot[, facteur1] <- calendrierGeneral[ , facteur1][match(freqtot$moisAn , calendrierGeneral$moisAn)]
        }
    } else {}

        ## v�rification de la pr�sence des facteurs explicatifs dans la table freqtot
    ## (parfois absent si ce sont des niveaux du r�f�rentiel spatial ou temporel)
        if (!is.element(facteur2, 
                      c("aucun", names(freqtot))))
    {
        if (is.element(facteur2, 
                      names(refSpatial)))
        {
          freqtot[, facteur2] <- refSpatial[, facteur2][match(freqtot$zone , refSpatial$codeZone)] 
        } else {
          freqtot[, facteur2] <- calendrierGeneral[ , facteur2][match(freqtot$moisAn , calendrierGeneral$moisAn)]
        }
    } else {}

    freqtot$aucun <- rep(NA, nrow(freqtot))
    assign("freqtot2", freqtot, envir=.GlobalEnv)


    ## formation du vecteur listFact
    if (facteur2 == "aucun") {
      listFact <- facteur1
    } 
    if (facteur1 =="aucun") {
      listFact <- facteur2
    } 
    if ((facteur1 != "aucun") && (facteur2 != "aucun")) {
      listFact <- c(facteur1, facteur2)
    }
    facteurs <- c("numSortie", listFact)
    
        
        ## si s�lection de certaines modalit�s, restriction du tableau � ces modalit�s
        tableauCh <- subset(freqtot2, is.element(freqtot2[, facteur1], modalites1))
        tableauCh1 <- subset(tableauCh, is.element(tableauCh[, facteur2], modalites2))
        assign("freqtot2", tableauCh1, envir=.GlobalEnv)
        
        ## lancement de la fonction d'analyse
        modeleLineaireWP3.f ( variable = variable,
                              facteurs = facteurs,
                              listFact = listFact,
                              tableMetrique = "freqtot2",                                   # get(tableMetrique, envir=env)
                              sufixe = NULL)
    
}


########################################################################################################################
updateListFacteursStat1.f <- function(env)
{
    ## Purpose: Mise � jour du choix des niveaux de facteur 1(toutes ou certaines) 
    ##          selon le facteur choisi
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 22 sept. 2011
       
    ## r�cup�ration du facteur dans l'environnement 'env'
    Facteur1 <- get("Facteur1", envir=env)
       
    ## Grisage du choix du choix des niveaux si inappropri�
    evalq(if (is.element(tclvalue(Facteur1),
                          c("aucun")))
      {
          tkconfigure(RB.toutesModalites1, state="disabled")
          tkconfigure(RB.selecModalites1, state="disabled")
          tkconfigure(B.selecModalites1, state="disabled")
          tkconfigure(L.modalites1, state="disabled")
      } else {
          tkconfigure(RB.toutesModalites1, state="normal")
          tkconfigure(RB.selecModalites1, state="normal")
          tkconfigure(L.modalites1, state="normal")
          updateChoixModalitesStat1.f(env=env)
      }, envir=env)

    assign("modalitesChoisies1", NULL, envir=env)

}

########################################################################################################################
updateChoixModalitesStat1.f <- function(env)
{
    ## Purpose: Activer/d�sactiver le bouton de choix de niveaux de facteur 1
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement de l'interface
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2011, 10:30

    ## r�cup�ration du facteur dans l'environnement 'env'
       Facteur1 <- get("Facteur1", envir=env)
       
    ## v�rification de la pr�sence des facteurs explicatifs dans la table freqtot
    ## (parfois absent si ce sont des niveaux du r�f�rentiel spatial ou temporel)
        if (!is.element(tclvalue(Facteur1), 
                      c("aucun", names(freqtot))))
    {
        if (is.element(tclvalue(Facteur1), 
                      names(refSpatial)))
        {
          freqtot[, tclvalue(Facteur1)] <- refSpatial[, tclvalue(Facteur1)][match(freqtot$zone , refSpatial$codeZone)] 
        } else {
          freqtot[, tclvalue(Facteur1)] <- calendrierGeneral[ , tclvalue(Facteur1)][match(freqtot$moisAn , calendrierGeneral$moisAn)]
        }
    } else {}

    assign("freqtot2", freqtot, envir=.GlobalEnv)
        
    evalq(if (!is.element(tclvalue(Facteur1), "aucun"))   
          {
            if (is.element(tclvalue(SelecModalites1),
                           c("toutesModalites")))
            {
                tkconfigure(B.selecModalites1, state="disabled")
                 
                modalitesChoisies1 <- unique(freqtot2[, tclvalue(Facteur1)])
            } else {
                tkconfigure(B.selecModalites1, state="normal")
                
                if (any(!is.element(modalitesChoisies1, 
                                    unique(freqtot2[, tclvalue(Facteur1)]))))
                {
                    modalitesChoisies1 <- NULL
                } else {}
       #       assign("modalitesChoisies1", NULL, envir=env)
            }
          } else {}, envir=env)
}


########################################################################################################################
updateListFacteursStat2.f <- function(env)
{
    ## Purpose: Mise � jour du choix des niveaux de facteur 2(toutes ou certaines) 
    ##          selon le facteur choisi
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement o� faire les M�J.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 22 sept. 2011

    ## r�cup�ration du facteur dans l'environnement 'env'
    Facteur2 <- get("Facteur2", envir=env)
    
    ## Grisage du choix des zones si inappropri� :
    evalq(if (is.element(tclvalue(Facteur2),
                          c("aucun")))
      {
          tkconfigure(RB.toutesModalites2, state="disabled")
          tkconfigure(RB.selecModalites2, state="disabled")
          tkconfigure(B.selecModalites2, state="disabled")
          tkconfigure(L.modalites2, state="disabled")
      } else {
          tkconfigure(RB.toutesModalites2, state="normal")
          tkconfigure(RB.selecModalites2, state="normal")
          tkconfigure(L.modalites2, state="normal")
          updateChoixModalitesStat2.f(env=env)
      }, envir=env)

    assign("modalitesChoisies2", NULL, envir=env)

}

########################################################################################################################
updateChoixModalitesStat2.f <- function(env)
{
    ## Purpose: Activer/d�sactiver le bouton de choix de niveaux de facteur 2
    ## ----------------------------------------------------------------------
    ## Arguments: env : l'environnement de l'interface.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2011, 10:30

    ## r�cup�ration du facteur dans l'environnement 'env'
    Facteur2 <- get("Facteur2", envir=env)
    freqtot <- freqtot2
        
    ## v�rification de la pr�sence des facteurs explicatifs dans la table freqtot
    ## (parfois absent si ce sont des niveaux du r�f�rentiel spatial ou temporel)
        if (!is.element(tclvalue(Facteur2), 
                      c("aucun", names(freqtot))))
    {
        if (is.element(tclvalue(Facteur2), 
                      names(refSpatial)))
        {
          freqtot[, tclvalue(Facteur2)] <- refSpatial[, tclvalue(Facteur2)][match(freqtot$zone , refSpatial$codeZone)] 
        } else {
          freqtot[, tclvalue(Facteur2)] <- calendrierGeneral[ , tclvalue(Facteur2)][match(freqtot$moisAn , calendrierGeneral$moisAn)]
        }
    } else {}
    
    assign("freqtot2", freqtot, envir=.GlobalEnv)
          
    evalq(if (!is.element(tclvalue(Facteur2), "aucun"))   
          {
            if (is.element(tclvalue(SelecModalites2),
                           c("toutesModalites")))
            {
                tkconfigure(B.selecModalites2, state="disabled")
                 
                modalitesChoisies2 <- unique(freqtot2[, tclvalue(Facteur2)])
            } else {
                tkconfigure(B.selecModalites2, state="normal")
                
                if (any(!is.element(modalitesChoisies2, 
                                    unique(freqtot2[, tclvalue(Facteur2)]))))
                {
                    modalitesChoisies2 <- NULL
                } else {}
       #       assign("modalitesChoisies2", NULL, envir=env)
            }
          } else {}, envir=env)
}


########################################################################################################################
interfaceStatsFrequentation.f <- function()
{
    ## Purpose: cr�er l'interface pour les analyses stat de la  fr�quentation
    ##          et lancer les analyses
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 15 sept. 2011

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution
    modalitesChoisies1 <- NULL               # vecteur de stockage des modalites choisies du facteur 1
    modalitesChoisies2 <- NULL               # vecteur de stockage des modalites choisies du facteur 2
    
    ## Liste de choix du premier facteur
    listFacteur1 <- listeFacteursStat.f()
    Facteur1 <- tclVar(listFacteur1[1])              

    ## Liste de choix du second facteur
    listFacteur2 <- listeFacteursStat.f()
    Facteur2 <- tclVar(listFacteur2[1])            

    ## Liste des variables :
    listVariables <- listeVariablesStat.f()
    VariableChoisie <- tclVar("")                       

    ## S�lection des modalit�s du premier facteur
    SelecModalites1 <- tclVar("toutesModalites") ## ou "selectModalites"

    ## S�lection des modalit�s du second facteur
    SelecModalites2 <- tclVar("toutesModalites") ## ou "selectModalites"


    ## ########################
    ## �l�ments graphiques :
    WinStatFrequentation <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinStatFrequentation, "S�lections pour l'analyse stat de la fr�quentation")

    F.main1 <- tkframe(WinStatFrequentation, width=30)       # facteur 1
    F.main2 <- tkframe(WinStatFrequentation, width=30)       # facteur 2
    F.main3 <- tkframe(WinStatFrequentation, width=30)       # variable
    F.button1 <- tkframe(F.main1, borderwidth=2, relief="groove")         # s�lection niveaux facteurs 1
    F.button2 <- tkframe(F.main2, borderwidth=2, relief="groove")         # s�lection niveaux facteurs 2

    ## �l�ments graphiques :
    CB.facteur1 <- ttkcombobox(F.main1, value=listFacteur1, textvariable=Facteur1,
                          state="readonly")

    CB.facteur2 <- ttkcombobox(F.main2, value=listFacteur2, textvariable=Facteur2,
                          state="readonly")

    CB.variable <- ttkcombobox(F.main3, value=listVariables, textvariable=VariableChoisie,
                          state="readonly")


    B.selecModalites1 <- tkbutton(F.button1, text="choisir les modalit�s du facteur 1",
                                 command=function()
                           {
                               assign("modalitesChoisies1", listeModalitesStat.f (facteur = tclvalue(Facteur1), env=env, preselect=modalitesChoisies1), envir=env)
                               winRaise.f(WinStatFrequentation)
                           })

    RB.toutesModalites1 <- tkradiobutton(F.button1, variable=SelecModalites1, value="toutesModalites", text="toutes les modalit�s")
    RB.selecModalites1 <- tkradiobutton(F.button1, variable=SelecModalites1, value="selecModalites", text="s�lection de certaines modalit�s")


    B.selecModalites2 <- tkbutton(F.button2, text="choisir les modalit�s du facteur 2",
                                 command=function()
                           {
                               assign("modalitesChoisies2", listeModalitesStat.f (facteur = tclvalue(Facteur2), env=env, preselect=modalitesChoisies2), envir=env)
                               winRaise.f(WinStatFrequentation)
                           })

    RB.toutesModalites2 <- tkradiobutton(F.button2, variable=SelecModalites2, value="toutesModalites", text="toutes les modalit�s")
    RB.selecModalites2 <- tkradiobutton(F.button2, variable=SelecModalites2, value="selecModalites", text="s�lection de certaines modalit�s")


    ## barre de boutons
    FrameBT <- tkframe(WinStatFrequentation)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})
    
    ## D�finition des actions

    tkbind(WinStatFrequentation, "<Destroy>", function(){tclvalue(Done) <- 2})

    tkbind(CB.facteur1, "<FocusIn>", function(){updateListFacteursStat1.f(env=env)})

    tkbind(RB.selecModalites1, "<Leave>", function(){updateChoixModalitesStat1.f(env=env)})
    tkbind(RB.toutesModalites1, "<Leave>", function(){updateChoixModalitesStat1.f(env=env)})

    tkbind(CB.facteur2, "<FocusIn>", function(){updateListFacteursStat2.f(env=env)})

    tkbind(RB.selecModalites2, "<Leave>", function(){updateChoixModalitesStat2.f(env=env)})
    tkbind(RB.toutesModalites2, "<Leave>", function(){updateChoixModalitesStat2.f(env=env)})

    ## Placement des �l�ments sur l'interface :
    tkgrid(tklabel(F.main1, text="Premier facteur � tester"),
           CB.facteur1, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(L.modalites1 <- tklabel(F.button1, text="Choix des modalit�s du facteur 1"),
           column=0, columnspan=3, pady=5, sticky="ew")
    tkgrid(ttkseparator(F.button1, orient = "horizontal"), column=0, columnspan=3, sticky="ew")
    tkgrid(RB.toutesModalites1, RB.selecModalites1, B.selecModalites1, padx=5, pady=5, sticky="w")
    
    tkgrid(tklabel(F.main2, text="Second facteur � tester"),
           CB.facteur2, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)

    tkgrid(L.modalites2 <- tklabel(F.button2, text="Choix des modalit�s du facteur 2"),
           column=0, columnspan=3, pady=5, sticky="ew")
    tkgrid(ttkseparator(F.button2, orient = "horizontal"), column=0, columnspan=3, sticky="ew")
    tkgrid(RB.toutesModalites2, RB.selecModalites2, B.selecModalites2, padx=5, pady=5, sticky="w")
    
    tkgrid(tklabel(F.main3, text="Variable"),
           CB.variable, ## column=1, columnspan=3,
           sticky="w", padx=5, pady=5)


    tkgrid(F.main1, padx=10, pady=10)
    tkgrid(F.button1, columnspan=2)
    tkgrid(F.main2, padx=10, pady=10)
    tkgrid(F.button2, columnspan=2)
    tkgrid(F.main3, padx=10, pady=10)

    ## Barre de boutons :
    tkgrid(FrameBT, column=0, columnspan=3, padx=2, pady=5)
    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
           tklabel(FrameBT, text="               "))

    ## Mise � jour des cadres � activation "dynamique" :
    updateListFacteursStat1.f(env = env)
    updateListFacteursStat2.f(env = env)
        
    ## tkfocus(WinEnquete)
    winSmartPlace.f(WinStatFrequentation)

    ## Update des fen�tres :
    tcl("update")

    ## Tant que l'utilisateur ne ferme pas la fen�tre... :
    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        if (tclvalue(Done) == "1")      # statut ex�cution OK.
        {
            tableauCh <- freqtot
            nomTableauCh <- "freqtot"
            facteur1Ch <- tclvalue(Facteur1)
            facteur2Ch <- tclvalue(Facteur2)
            variableCh <- tclvalue(VariableChoisie)
            modSelec1 <- tclvalue(SelecModalites1)
            modSelec2 <- tclvalue(SelecModalites2)

                        
            tabVerif <- freqtot2
            
            if (tclvalue(SelecModalites1) == "toutesModalites" && tclvalue(Facteur1) != "aucun") 
            {
            modalitesChoisies1 <- unique(tabVerif[, tclvalue(Facteur1)])
            } else {}

            if (tclvalue(SelecModalites2) == "toutesModalites" && tclvalue(Facteur2) != "aucun") 
            {
            modalitesChoisies2 <- unique(tabVerif[, tclvalue(Facteur2)])
            } else {}
            
            
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(tableauCh,
                                                      facteur1Ch,
                                                      facteur2Ch,
                                                      variableCh,
                                                      modSelec1,
                                                      modSelec2,
                                                      modalitesChoisies1,
                                                      modalitesChoisies2,
                                                      ParentWin = WinStatFrequentation)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                        # suivante si les variables ne sont pas bonnes.


            ## ##################################################
            ## Fonctions pour lancer les analyses

              LancementAnalyse.f(variable = variableCh, 
                                 facteur1 = facteur1Ch, 
                                 facteur2 = facteur2Ch, 
                                 tableMetrique = nomTableauCh,
                                 modalites1 = modalitesChoisies1, 
                                 modalites2 = modalitesChoisies2,
                                 sufixe=NULL)



            ## ##################################################

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie :
            winSmartPlace.f(WinStatFrequentation)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinStatFrequentation)             # destruction de la fen�tre.

}


