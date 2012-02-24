################################################################################
# Nom               : TestsStatistiquesFreq.r
# Type              : Programme
# Objet             : Ce programme comporte toutes les fonctions d'analyses 
#                     statistiques pour l'�tude des m�triques de fr�quentation
#                     Ces fonctions seront appel�es dans l'interface relative aux 
#                     traitements statistiques des donn�es quantitatives
# Input             : aucun
# Output            : lancement de fonctions
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : janvier 2012
# Sources
################################################################################


############               LES ANALYSES DE VARIANCE                 ############
###                    Pour les variables quantitatives                      ###


################################################################################
subsetToutesTables.f <- function(variable, listFact, facteurs, tableMetrique) {
    ## Purpose: Former le tableau de donn�es n�cessaires pour les analyses de variance, 
    ##          d'apr�s les m�triques et facteur(s) s�l�ctionn�s
    ## ----------------------------------------------------------------------
    ## Arguments: variable : la m�trique choisie
    ##            listFact : les facteurs s�lectionn�s
    ##            facteurs : les facteurs s�lectionn�s + numSortie ou numQuest
    ##            tableMetrique : le nom de la table de donn�es
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date:  janvier 2012

#  variable = "nbBat"
#  facteurs = c("numSortie","periodEchant","zone")
#  listFact = c("zone","periodEchant")
#  tableMetrique = "freqtot"         # ne contient que le nom du tableau consid�r�
  dataMetrique <- eval(parse(text=tableMetrique))      # donc dataMetrique = freqtot par exemple

      # FreqJour <- tapply(dataMetrique[,variable],list(factor(dataMetrique[,listFact[1]]),
      #                                    factor(dataMetrique[,listFact[2]]), factor(dataMetrique$numSortie)),
      #                                    sum , na.rm=T)
      # FreqJourList <- unlist(apply(FreqJour, 3, list), recursive=FALSE)
      # do.call(rbind, FreqJourList)
      
        
  ## Subset en fonction de la table de m�trique
  switch(tableMetrique,                                    # permet de faire des traitements diff�rents selon le nom du tableau consid�r�
      ## Cas de la table de fr�quentation
      freqtot2 = {
             FreqJour <- with(dataMetrique,
                              tapply(dataMetrique[ , variable],
                              as.list(dataMetrique[, c("numSortie", listFact)]),          # listFact correspond aux facteurs � tester
                              sum, na.rm=TRUE))
    
          ## Formation du nouveau tableau pour y appliquer les analyses de variances
          ## selon les facteurs choisis
            if (length(listFact) == 2) {
                tmp <- as.data.frame(matrix(0,length(FreqJour),4))  
                colnames(tmp) <- c(names(dimnames(FreqJour)), variable)
                tmp [,1] <- rep(as.vector(unlist(dimnames(FreqJour)["numSortie"])),
                                time=(length(FreqJour)/dim(FreqJour)[1]))              # r�p�te le num�ro de sortie
                tmp [,2] <- rep (as.vector(unlist(dimnames(FreqJour)[listFact[1]])),
                                 each=dim(FreqJour)[1], times = dim(FreqJour)[3])      # r�p�te le code de la zone
                tmp [,3] <- rep (as.vector(unlist(dimnames(FreqJour)[listFact[2]])),
                                 each=(dim(FreqJour)[1]*dim(FreqJour)[2]))             # r�p�te le code de la zone
                tmp [,4] <- c(FreqJour)
            }
            if (length(listFact) == 1) { 
                tmp <- as.data.frame(matrix(0,length(FreqJour),3))  
                colnames(tmp) <- c(names(dimnames(FreqJour)), variable)
                tmp [,1] <- rep(as.vector(unlist(dimnames(FreqJour)["numSortie"])),
                                time=(length(FreqJour)/dim(FreqJour)[1]))              # r�p�te le num�ro de sortie
                tmp [,2] <- rep (as.vector(unlist(dimnames(FreqJour)[listFact[1]])),
                                 each=(length(FreqJour)/dim(FreqJour)[2]))             # r�p�te le code de la zone
                tmp [,3] <- c(FreqJour)
            }
      },
      ### cas des tables d'enqu�tes
      peche = {
        tmp = peche [,c(facteurs, variable)]
      },
      pecheQ = {                                         
        tmp = pecheQ [,c(facteurs, variable)]
      },
      tousQuest = {
        tmp = tousQuest [,c(facteurs, variable)]
      },
      plaisance = {
        tmp = plaisance [,c(facteurs, variable)]
      },
      excursion = {
        tmp = excursion [,c(facteurs, variable)]
      },
      plongee = {
        tmp = plongee [,c(facteurs, variable)]
      },
      ## Autres cas :
        tkmessageBox(message="Erreur dans la s�lection de la table", icon="info")
    )
    
    ### transformation des valeurs num�riques en integer si valeurs enti�res
      aa <- round(tmp[,variable])
      a <- tmp[,variable]
      if (all(na.omit(a==aa))){tmp[,variable] <- as.integer(tmp[,variable])}     
      tmp <- tmp[!is.na(tmp[,variable]),]       ## suppression des NA = valeurs non observ�es
      
    ## transformation des variables explicatives en facteur
    for (i in 1 : length(listFact)){
      tmp[,listFact[i]] <- as.factor(tmp[,listFact[i]])
    }
    
    return(tmp)
}


################################################################################
modeleLineaireWP3.f <- function(variable, facteurs, listFact, tableMetrique, sufixe=NULL, ...) {
    ## Purpose: Gestions des diff�rentes �tapes des mod�les lin�aires.
    ## ----------------------------------------------------------------------
    ## Arguments: variable : la m�trique choisie
    ##            listFact : liste du (des) facteur(s) explicatifs � tester
    ##            facteurs : liste des facteurs � tester (listFact) + numSortie ou numQuest
    ##            tableMetrique : nom de la table de m�triques
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    # facteurs <- facteurs
    # listFact <- listFact
    listFactOriginal <- listFact
    aGarder=NULL
    # v�rification de la pr�sence de plus d'un niveau pour chaque facteur choisi
    tableTest <- eval(parse(text = tableMetrique)) 
    for (i in 1 : length(listFact)) {
      if(length(levels(as.factor(tableTest[,listFact[i]]))) > 1 ) {aGarder = c(aGarder,i)}
    }
    listFact <- listFact[aGarder]  # nouvelle liste de facteur
    # si la liste des nouveaux facteurs est vide
    if (length(listFact)==0) {
      print(paste("Il est impossible de tester les facteurs", listFactOriginal, "sur la m�trique", variable))
    } else {
      ## Donn�es pour la s�rie d'analyses :
      tmpData <- subsetToutesTables.f(variable = variable, 
                                      facteurs = facteurs, 
                                      listFact = listFact, 
                                      tableMetrique = tableMetrique)
  
      ## Formules pour diff�rents mod�les (avec ou sans transformation log)
      exprML <- eval(parse(text=paste(variable, "~", paste(listFact, collapse=" * "))))
      logExprML <- eval(parse(text=paste("log(", variable, ") ~", paste(listFact, collapse=" * "))))
  
      ## Sauvegarde temporaire des donn�es utilis�es pour les analyses 
      ## (attention : �cras�e � chaque nouvelle s�rie de graphiques)
      DataBackup <<- list()
      tmpDataMod <- tmpData  # sauvegarde
  
  
      ## Aide au choix du type d'analyse
      loiChoisie <- choixDistri.f(variable = variable, 
                                  Data = tmpDataMod[ , variable, drop=FALSE])
  
          if (!is.null(loiChoisie)) {          
              message("Loi de distribution choisie = ", loiChoisie)
                                                                        
              Log <- FALSE
              formule <- exprML
  
              switch(loiChoisie,
                     ## Mod�le lin�aire :
                     NO = {
                         res <- lm(exprML, data = tmpDataMod)
                    },
                     ## Mod�le lin�aire, donn�es log-transform�es
                     LOGNO = {
                         ## Ajout d'une constante � la m�trique si contient des z�ros
                         if (sum(tmpDataMod[ , variable] == 0, na.rm=TRUE))
                         {
                             tmpDataMod[ , variable] <- tmpDataMod[ , variable] +
                                 ((min(tmpDataMod[ , variable], na.rm=TRUE) + 1) / 1000)
                         } else {}
  
                         res <- lm(logExprML, data=tmpDataMod)
                         ## Mise en forme :
                         Log <- TRUE
                         formule <- logExprML
                     },
                     ## GLM, distribution de Poisson
                     PO = {
                         res <- glm(exprML, data=tmpDataMod, family="poisson")
                     },
                     ## GLM, distribution binomiale n�gative
                     NBI = {
                         res <- glm.nb(exprML, data=tmpDataMod)
                     },)
  
                res <<- res
                              
                  sortiesLM.f(objLM = res, formule = formule, variable = variable,
                          listFact = listFact, Data = tmpDataMod, Log = Log, sufixe = sufixe)
  
              resid.out <- boxplot(residuals(res), plot=FALSE)$out
  
          } else {
              message("Annul� !")
          }
      }
}


################################################################################
choixDistri.f <- function(variable, Data) {
    ## Purpose: Aider l'utilisateur dans le choix d'une distribution de la
    ##          m�trique et lancer les analyses ad�quates.
    ## ----------------------------------------------------------------------
    ## Arguments: variable : le nom de la m�trique (variable d�pendant)
    ##                       choisie
    ##            Data : le jeu de donn�es contenant la m�trique
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## Syst�matiquement d�truire la fen�tre en quitant :
    on.exit(tkdestroy(WinDistri))


    ## ##################################################
    ## Variables :
    env <- environment()                # environnement courant.
    Done <- tclVar(0)                   # �tat d'ex�cution.
    LoiChoisie <- tclVar("NO")          # Variable pour le choix de distribution th�orique.
    vscale <- 0.6                      # dimension verticale des graphiques.
    hscale <- 1.05                       # dimension horizontale des graphiques.
    pointsize <- 10                     # taille du point pour les graphiques
    distList <- list()                  # liste pour le stockage des AIC et autres.


    ## ##################################################
    ## �l�ments graphiques :
    WinDistri <- tktoplevel()           # Fen�tre principale.
    tkwm.title(WinDistri, paste("Choix de distribution th�orique de la m�trique '", variable, "'", sep=""))

    tmp <- tktoplevel(WinDistri)
    tkfocus(tmp)
    tkdestroy(tmp)

    ## Frame d'aide :
    FrameHelp <- tkframe(WinDistri)
    T.help <- tktext(FrameHelp, bg="#fae18d", font="arial", width=100,
                     height=4, relief="groove", borderwidth=2)


    ## Frame pour la loi Normale :
    FrameN <- tkframe(WinDistri, borderwidth=2, relief="groove")
    Img.N <- tkrplot(FrameN,            # Cr�ation de l'image.
                     fun=function()
                 {
                     plotDist.f(y = Data[ , variable], family="NO", variable=variable, env=env)
                 },
                     vscale=vscale, hscale=hscale, pointsize=pointsize)

    RB.N <- tkradiobutton(FrameN, variable=LoiChoisie, value="NO",   # bouton de s�lection.
                          text=paste("loi Normale (AIC=", round(distList[["NO"]]$aic, 0), "). ", sep=""))


    ## Frame pour la loi log-Normale :
    FrameLogN <- tkframe(WinDistri, borderwidth=2, relief="groove")
    Img.LogN <- tkrplot(FrameLogN, fun=function()   # Cr�ation de l'image.
                    {
                        plotDist.f(y = Data[ , variable], family="LOGNO", variable=variable, env=env)
                    },
                        vscale=vscale, hscale=hscale, pointsize=pointsize)

    RB.LogN <- tkradiobutton(FrameLogN, variable=LoiChoisie, value="LOGNO",   # bouton de s�lection.
                             text=paste("loi log-Normale (AIC=", round(distList[["LOGNO"]]$aic, 0), "). ", sep=""))

    if (is.integer(Data[ , variable]))
    {
        ## Frame pour la loi de Poisson :
        FramePois <- tkframe(WinDistri, borderwidth=2, relief="groove")
        Img.Pois <- tkrplot(FramePois,    # Cr�ation de l'image.
                            fun=function()
                        {
                            plotDist.f(y = Data[ , variable], family="PO", variable=variable, env=env)
                        },
                            vscale=vscale, hscale=hscale, pointsize=pointsize)

        RB.Pois <- tkradiobutton(FramePois, variable=LoiChoisie, value="PO",   # bouton de s�lection.
                                 text=paste("loi de Poisson (AIC=", round(distList[["PO"]]$aic, 0), "). ", sep=""))

        ## Frame pour la loi bionomiale n�gative :
        FrameNBinom <- tkframe(WinDistri, borderwidth=2, relief="groove")

        Img.NBinom <- tkrplot(FrameNBinom,    # Cr�ation de l'image.
                              fun=function()
                          {
                              plotDist.f(y = Data[ , variable], family="NBI", variable=variable, env=env)
                          },
                              vscale=vscale, hscale=hscale, pointsize=pointsize)

        RB.NBinom <- tkradiobutton(FrameNBinom, variable=LoiChoisie, value="NBI",   # bouton de s�lection.
                                   text=paste("loi Binomiale n�gative (AIC=",
                                              round(distList[["NBI"]]$aic, 0), "). ", sep=""))
    } else {}

    ## Boutons :
    FrameB <- tkframe(WinDistri)
    B.OK <- tkbutton(FrameB, text="     OK     ", command=function(){tclvalue(Done) <- "1"})
    B.Cancel <- tkbutton(FrameB, text="   Annuler   ", command=function(){tclvalue(Done) <- "2"})

    ## ##################################################
    ## Placement des �l�ments sur la grille :

    tkgrid(tklabel(WinDistri, text=" "))
    tkinsert(T.help, "end", paste("INFO :\n", # texte de l'aide.
                                  "Cette fen�tre vous permet de choisir la distribution",
                                  " la plus adapt�e pour faire vos analyses.\n",
                                  "La distribution (courbe rouge) s'ajustant le mieux � vos donn�es (histogramme) d'apr�s \n",
                                  "le crit�re d'information de Akaike (AIC ; doit �tre le plus petit possible) est pr�-s�lectionn�e.", sep=""))
    tkgrid(T.help)
    tkgrid(FrameHelp, column=1, columnspan=3)

    tkgrid(tklabel(WinDistri, text=" "))
    tkgrid(Img.N, columnspan=2)
    tkgrid(RB.N, row=1, sticky="e")
    tkgrid(tklabel(FrameN, text=" Mod�le : ANOVA", fg="red"), row=1, column=1, sticky="w")
    tkgrid(Img.LogN, columnspan=2)
    tkgrid(RB.LogN, sticky="e")
    tkgrid(tklabel(FrameLogN, text=" Mod�le : ANOVA, donn�es log-transform�es", fg="red"), row=1, column=1, sticky="w")
    tkgrid(tklabel(WinDistri, text=" "), FrameN, tklabel(WinDistri, text=" "), FrameLogN, tklabel(WinDistri, text=" "),
           sticky="ew")
    tkgrid(tklabel(WinDistri, text=" "))

    ## �v�nements : s�lections en cliquant sur les graphiques :
    tkbind(Img.N, "<Button-1>", function(){tclvalue(LoiChoisie) <- "NO"})
    tkbind(Img.LogN, "<Button-1>", function(){tclvalue(LoiChoisie) <- "LOGNO"})


    ## Pour les donn�es enti�res seulement :
    if (is.integer(Data[ , variable])) {
    
        tkgrid(Img.Pois, columnspan=2)
        tkgrid(RB.Pois, sticky="e")
        tkgrid(tklabel(FramePois, text=" Mod�le : GLM, famille 'Poisson'", fg="red"), row=1, column=1, sticky="w")
        tkgrid(Img.NBinom, columnspan=2)
        tkgrid(RB.NBinom, sticky="e")
        tkgrid(tklabel(FrameNBinom, text=" Mod�le : GLM, famille 'Binomiale n�gative'", fg="red"), row=1, column=1, sticky="w")
        tkgrid(tklabel(WinDistri, text=" "), FramePois, tklabel(WinDistri, text=" "), FrameNBinom,
               tklabel(WinDistri, text=" "), sticky="ew")
        tkgrid(tklabel(WinDistri, text=" "))

        ## �v�nements : s�lections en cliquant sur les graphiques :
        tkbind(Img.Pois, "<Button-1>", function(){tclvalue(LoiChoisie) <- "PO"})
        tkbind(Img.NBinom, "<Button-1>", function(){tclvalue(LoiChoisie) <- "NBI"})
    } else {}

    ## Boutons :
    tkgrid(FrameB, column=1, columnspan=3)
    tkgrid(B.OK, tklabel(FrameB, text="                         "), B.Cancel)
    tkgrid(tklabel(WinDistri, text=" "))

    ## ##################################################
    ## Autres �v�nements :
    tkbind(WinDistri, "<Destroy>", function(){tclvalue(Done) <- "2"}) # en cas de destruction de la fen�tre.

    ## Pr�s�lection de la distribution avec le plus petit AIC :
    tclvalue(LoiChoisie) <- names(distList)[which.min(sapply(distList, function(x){x$aic}))]
    ## flush.console()

    tkwait.variable(Done)               # Attente d'une action de l'utilisateur.

    if (tclvalue(Done) == "1") {    
        return(tclvalue(LoiChoisie))
    } else {
        return(NULL)
    }

}


########################################################################################################################
resFileLM.f <- function(objLM, variable, listFact, Log=FALSE,  prefix=NULL, ext="txt", sufixe=NULL) {
    ## Purpose: D�finit les noms du fichiers pour les r�sultats des mod�les
    ##          lin�aires. L'extension et un prefixe peuvent �tres pr�cis�s,
    ##          mais par d�faut, c'est le fichier de sorties texte qui est
    ##          cr��.
    ## ----------------------------------------------------------------------
    ## Arguments: objLM : un objet de classe 'lm' ou 'glm'
    ##            variable : nom de la m�trique analys�e
    ##            listFact : vecteur des noms de facteurs de l'analyse
    ##            Log : Est-ce que les donn�es sont log-transform�es
    ##            prefix : pr�fixe du nom de fichier
    ##            sufixe : un sufixe pour le nom de fichier
    ##            ext : extension du fichier
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## si pas de pr�fix fourni :
    if (is.null(prefix)){
        prefix <- ifelse(length(grep("^lm\\(", deparse(objLM$call), perl=TRUE)) > 0,
                         paste("LM", ifelse(Log, "-log", ""), sep=""),
                         ifelse(length(grep("^glm\\.nb", deparse(objLM$call), perl=TRUE)) > 0,
                                "GLM-NB",
                                ifelse(length(grep("^glm.*poisson", deparse(objLM$call), perl=TRUE)) > 0,
                                       "GLM-P",
                                       "Unknown-model")))
    } else {}

    ## Nom de fichier :
    filename <- paste("C:/PAMPA/Resultats_Usages/stats/", prefix, "_",
                      ## Tableau de donn�es :
#                      nomTable, "_",
                      ## M�trique analys�e :
                      variable, "_",
                      ## liste des facteurs de l'analyse
                      paste(listFact, collapse="-"),
                      ## sufixe :
                      ifelse(is.null(sufixe), "", paste("_", sufixe, sep="")),
                      ## Extension du fichier :
                      ".", gsub("^\\.([^.]*)", "\\1", ext[1], perl=TRUE), # nettoyage de l'extension si besoin.
                      sep="")

    ## Ouverture de la connection (retourne l'objet de type 'connection') si pas un fichier avec extension graphique,
    ## retourne le nom de fichier sinon :
    if (!is.element(gsub("^\\.([^.]*)", "\\1", ext[1], perl=TRUE),
                    c("pdf", "PDF", "png", "PNG", "jpg", "JPG"))) {
        return(resFile <- file(filename, open="w"))
    } else {
        return(filename)
    }
}


########################################################################################################################
valPreditesLM.f <- function(objLM, Data, listFact, resFile){
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments: objLM : objet de classe 'lm' ou 'glm'
    ##            Data : les donn�es utilis�es pour ajuster le mod�le
    ##            listFact : un vecteur donnant la liste des noms de
    ##                       facteurs
    ##            resFile : la connection au fichier r�sultat
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012


    ## ##################################################
    ## Valeurs pr�dites :
    OrdreNivFact <- sapply(unique(Data[ , listFact]), as.numeric)

    if (!is.matrix(OrdreNivFact)) {      # Si un seul facteur, on transforme le vecteur d'ordre des niveaux en matrice.
        OrdreNivFact <- matrix(OrdreNivFact, ncol=1, dimnames=list(NULL, listFact))
    } else {}

    ## Valeurs pr�dites pour chaque combinaison r�alis�e des facteurs :
    if (length(grep("^glm", objLM$call)) > 0) {    
        valPredites <- predict(objLM, newdata=unique(Data[ , listFact, drop=FALSE]), type="response")
    } else {
        valPredites <- predict(objLM, newdata=unique(Data[ , listFact, drop=FALSE]))
    }

    ## Noms des valeurs pr�dites (combinaisons des diff�rents niveaux de facteurs) :
    nomCoefs <- unique(apply(Data[ , listFact, drop=FALSE], 1, paste, collapse=":"))
    names(valPredites) <- nomCoefs

    ## On remet les modalit�s en ordre :
    valPredites <- valPredites[eval(parse(text=paste("order(",
                                          paste("OrdreNivFact[ , ", 1:ncol(OrdreNivFact), "]", sep="", collapse=", "),
                                          ")", sep="")))]

    ## �criture de l'en-t�te :
    cat("\n\n\n---------------------------------------------------------------------------",
        "\nValeurs pr�dites par le mod�le :\n\n",
        file=resFile)

    ## �criture du r�sultat :
    capture.output(print(valPredites), file=resFile)
}


########################################################################################################################
infoStatLM.f <- function(objLM, resFile) {

    ## Purpose: �crit les informations sur le mod�le insi que les
    ##          statistiques globale dans un fichier r�sultat
    ## ----------------------------------------------------------------------
    ## Arguments: objLM un objet de classe 'lm' ou 'glm'
    ##            resFile : une connection pour les sorties
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## [!!!] Attention, il arrive que les calculs bloquent ici lors du premier lancement (origine inconnue)
    sumLM <- switch(class(objLM)[1],
                    lm = summary.lm(objLM),
                    glm = summary.glm(objLM),
                    negbin = MASS:::summary.negbin(objLM),
                    summary(objLM))

    ## Informations sur le mod�le :
    cat("Mod�le ajust� :", file=resFile, fill=1)
    cat("\t", deparse(objLM$call), "\n\n\n", file=resFile, sep="")

    ## Stats globales :
    if (length(grep("^glm", objLM$call)) == 0) {
    
        cat("Statistique de Fisher Globale et R^2 :\n\n", file=resFile)
        cat("\tR^2 multiple : ", format(sumLM$r.squared, digits=3),
            " ;\tR^2 ajust� : ", format(sumLM$adj.r.squared, digits=3), "\n", file=resFile, sep="")

        cat("\tF-statistique : ",
            paste(sapply(sumLM$fstatistic, format, digits=4, nsmall=0),
                  c(" sur ", " et ", " DL,"), sep=""),
            "\tP-valeur : ",
            format.pval(pf(sumLM$fstatistic[1L], sumLM$fstatistic[2L], sumLM$fstatistic[3L], lower.tail = FALSE), digits=4),
            "\n\n\n", file=resFile, sep="")
    } else { }
}


########################################################################################################################
signifParamLM.f <- function(objLM, resFile)  {
    ## Purpose: �crire les r�sultats de l'anova globale du mod�le et
    ##          l'estimation de significativit�s des coefficients du mod�le.
    ## ----------------------------------------------------------------------
    ## Arguments: objLM un objet de classe 'lm' ou 'glm'
    ##            resFile : une connection pour les sorties
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## Anovas et r�sum�s :
    if (length(grep("^glm", objLM$call)) > 0) {# Pour les GLMs.    
        anovaLM <- anova(objLM, test="Chisq") # Pour les LMs.
    } else {
        anovaLM <- anova(objLM)
    }
    sumLM <- summary(objLM)

    ## Anova globale du mod�le :
    capture.output(print.anova.fr(anovaLM), file=resFile)

    ## Significativit�s des param�tres :
    cat("\n\nSignificativit�s des param�tres ",
        "\n(seuls ceux correspondant � des facteurs/int�ractions significatifs sont repr�sent�s) :\n\n",
        file=resFile)

    capture.output(printCoefmat.red(sumLM$coef, anovaLM=anovaLM, objLM=objLM), file=resFile)
}


########################################################################################################################
sortiesLM.f <- function(objLM, formule, variable, listFact, Data, Log=FALSE, sufixe=NULL) {
    ## Purpose: Formater les r�sultats de lm et les �crire dans un fichier
    ## ----------------------------------------------------------------------
    ## Arguments: objLM : un objet de classe lm
    ##            formule : la formule utilis�e (pas lisible dans le call)
    ##            variable : la m�trique choisie
    ##            listFact : liste du (des) facteur(s) � tester
    ##            Data : les donn�es utilis�es
    ##            Log : donn�es log-transform�es ou non (bool�en)
    ##            sufixe : un sufixe pour le nom de fichier
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## longueur des lignes pour les sorties textes :
    oOpt <- options()
    on.exit(options(oOpt))

    options(width=120)

    ## Formule de mod�le lisible:
    objLM$call$formula <- formule
    formule <<- formule

    ## Chemin et nom de fichier :
    resFile <- resFileLM.f(objLM=objLM, variable=variable, listFact=listFact,
                           Log=Log, sufixe=sufixe)
    on.exit(close(resFile), add=TRUE)


    ## Informations et statistiques globales sur le mod�le :
    infoStatLM.f(objLM=objLM, resFile=resFile)


    ## Anova globale du mod�le + significativit� des coefficients :
    signifParamLM.f(objLM=objLM, resFile=resFile)


    ## ##################################################
    ## Valeurs pr�dites par le mod�le :
    valPreditesLM.f(objLM=objLM, Data=Data, listFact=listFact, resFile=resFile)

    ## ##################################################
    # interaction plot si deux facteurs explicatifs
    if (length(listFact)==2){
         x11(width=50,height=30,pointsize=10)
#          par(mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))

      cols <- nrow(unique(Data[listFact[2]]))
      if (Log) {                  # Les sens de variations peuvent changer en log (sur les moyennes) =>
                                        # besoin d'un graphique adapt� :             
             with(Data, {
                 eval(parse(text=paste("interaction.plot(", listFact[1], ", ", listFact[2],", log(", variable, "), ylab=\"",
                                       paste("log(", variable, ") moyen", sep=""), "\",col=1:cols)", sep="")))
              })                         

              } else {
              
             with(Data, {
                 eval(parse(text=paste("interaction.plot(", listFact[1], ", ", listFact[2],", ", variable, ", ylab=\"",
                                       paste("nombre(", variable, ") moyen", sep=""), "\",col=1:cols)", sep="")))
              })
              mtext("Interaction plot", side=3, cex=2) 
             }
    }     

}

########################################################################################################################
