### FONCTIONS UTILITAIRES
###     - Creation de classes de taille : classeTaille.f
###     - Calcul de recouvrement : CalculRecouvrement.f
################################################################################
################################################################################


################################################################################
## Nom    : classeTaille.f
## Objet  : fonction d'attribution des classes de taille � partir de la taille
##          maximale de l'esp�ce (valeur Fishbase).
##          Les classes sont petit, moyen, grand.
##          La classe juv�nile n'est pas prise en compte ici
## Input  : obs$taille
## Output : obs$classe_taille
################################################################################

classeTaille.f <- function()
{
    runLog.f(msg=c("Attribution des individus � des classes de taille :"))

    ## teste si les tailles sont renseignees dans la table observation
    if (length(unique(obs$taille))>1)
    {
        ## !  suggestion de test : format exact = si grand ou moyen ou petit -> sinon, retourne erreur de format

        ## obs$taille=as.numeric(obs$taille)
        obs$classe_taille[obs$taille < (especes$taillemax[match(obs$code_espece, especes$code_espece)]/3)] <- "P"
        obs$classe_taille[obs$taille >= (especes$taillemax[match(obs$code_espece, especes$code_espece)]/3) &
                          obs$taille < (2*(especes$taillemax[match(obs$code_espece, especes$code_espece)]/3))] <- "M"
        obs$classe_taille[obs$taille >= (2*(especes$taillemax[match(obs$code_espece, especes$code_espece)]/3))] <- "G"
        ct <- 1                         # en une ligne plut�t [yr: 27/07/2010]
        assign("ct", ct, envir=.GlobalEnv)

    }else{
        ct <- 2                         # en une ligne plut�t [yr: 27/07/2010]
        assign("ct", ct, envir=.GlobalEnv)
    }
    assign("obs", obs, envir=.GlobalEnv)
}

########################################################################################################################
AjoutTaillesMoyennes.f <- function(data)
{
    ## Purpose: Calcul des tailles comme les moyennes de classes de taille,
    ##          si seules ces derni�res sont renseign�es.
    ## ----------------------------------------------------------------------
    ## Arguments: data : les donn�es d'observation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 ao�t 2010, 16:20

    runLog.f(msg=c("Calcul des tailles moyennes d'apr�s les classes de taille :"))

    ## Calcul des tailles comme tailles moyennes � partir des classes de taille si n�cessaire :
    if (all(is.na(data$taille)) &
        length(grep("^([[:digit:]]+)[-_]([[:digit:]]+)$", data$classe_taille)) > 1)
    {
        ## Classes de tailles ferm�es :
        idxCT <- grep("^([[:digit:]]+)[-_]([[:digit:]]+)$", data$classe_taille)
        data$taille[idxCT] <- unlist(sapply(parse(text=sub("^([[:digit:]]+)[-_]([[:digit:]]+)$",
                                                  "mean(c(\\1, \\2), na.rm=TRUE)",
                                                  data$classe_taille[idxCT])),
                                            eval))
        ## Classes de tailles ouvertes vers le bas (borne inf�rieure <- 0) :
        idxCT <- grep("^[-_]([[:digit:]]+)$", data$classe_taille)
        data$taille[idxCT] <- unlist(sapply(parse(text=sub("^[-_]([[:digit:]]+)$",
                                                  "mean(c(0, \\1), na.rm=TRUE)",
                                                  data$classe_taille[idxCT])),
                                            eval))
        ## Classes de tailles ouvertes vers le haut (pas de borne sup�rieur, on fait l'hypoth�se que la taille est le
        ## minimum de la gamme) :
        idxCT <- grep("^([[:digit:]]+)[-_]$", data$classe_taille)
        data$taille[idxCT] <- unlist(sapply(parse(text=sub("^([[:digit:]]+)[-_]$",
                                                  "mean(c(\\1), na.rm=TRUE)",
                                                  data$classe_taille[idxCT])),
                                            eval))

        ## Avertissement :
        infoLoading.f(msg=paste("Attention, les tailles sont des estimations d'apr�s les classes de taille !",
                                "\nLes calculs de biomasses et tailles moyennes d�pendront directement",
                                " de ces estimations.", sep=""),
                     icon="warning")
    }else{}

    return(data)
}


########################################################################################################################
poids.moyen.CT.f <- function(Data)
{
    ## Purpose: poids moyens d'apr�s les classes de taille PMG du r�f�rentiel
    ##          esp�ces.
    ## ----------------------------------------------------------------------
    ## Arguments: Data (type obs).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 11 oct. 2010, 14:58

    runLog.f(msg=c("Calcul des poids moyens d'apr�s les classes de taille :"))

    refespTmp <- as.matrix(especes[ , c("poids.moyen.petits", "poids.moyen.moyens", "poids.moyen.gros")])
    row.names(refespTmp) <- as.character(especes$code_espece)

    classID <- c("P"=1, "M"=2, "G"=3)

    res <- sapply(seq(length.out=nrow(Data)),
                  function(i)
              {
                  ifelse(## Si l'esp�ce est dans le r�f�rentiel esp�ce...
                         is.element(Data$code_espece[i], row.names(refespTmp)),
                         ## ...poids moyen correspondant � l'esp�ce et la classe de taille :
                         refespTmp[as.character(Data$code_espece[i]),
                                   classID[as.character(Data$classe_taille[i])]],
                         ## Sinon rien :
                         NA)
              })

    return(res)
}


########################################################################################################################
calcTaillesMoyennes.f <- function(data)
{
    ## Purpose: Calcul des tailles comme les moyennes de classes de taille,
    ##          si seules ces derni�res sont renseign�es.
    ## ----------------------------------------------------------------------
    ## Arguments: data : les donn�es d'observation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 26 ao�t 2010, 16:20

    runLog.f(msg=c("Calcul des tailles moyennes d'apr�s les classes de taille :"))

    res <- data$taille
    classes.taille <- data$classe_taille

    ## Calcul des tailles comme tailles moyennes � partir des classes de taille si n�cessaire :
    if (any(is.na(res)[grep("^([[:digit:]]*)[-_]([[:digit:]]*)$", classes.taille)]))
    {

        ## Classes de tailles ferm�es :
        idxCT <- grep("^([[:digit:]]+)[-_]([[:digit:]]+)$", classes.taille) # classes de tailles qui correspondent aux
                                        # motifs pris en compte...
        idxCT <- idxCT[is.na(res[idxCT])] # ...pour lesquels la taille n'est pas renseign�e.
        res[idxCT] <- unlist(sapply(parse(text=sub("^([[:digit:]]+)[-_]([[:digit:]]+)$",
                                                  "mean(c(\\1, \\2), na.rm=TRUE)",
                                                  classes.taille[idxCT])),
                                            eval))

        ## Classes de tailles ouvertes vers le bas (borne inf�rieure <- 0) :
        idxCT <- grep("^[-_]([[:digit:]]+)$", classes.taille)
        idxCT <- idxCT[is.na(res[idxCT])] # ...pour lesquels la taille n'est pas renseign�e.
        res[idxCT] <- unlist(sapply(parse(text=sub("^[-_]([[:digit:]]+)$",
                                                  "mean(c(0, \\1), na.rm=TRUE)",
                                                  classes.taille[idxCT])),
                                            eval))

        ## Classes de tailles ouvertes vers le haut (pas de borne sup�rieur, on fait l'hypoth�se que la taille est le
        ## minimum de la gamme) :
        idxCT <- grep("^([[:digit:]]+)[-_]$", classes.taille)
        idxCT <- idxCT[is.na(res[idxCT])] # ...pour lesquels la taille n'est pas renseign�e.
        res[idxCT] <- unlist(sapply(parse(text=sub("^([[:digit:]]+)[-_]$",
                                                  "mean(c(\\1), na.rm=TRUE)",
                                                  classes.taille[idxCT])),
                                            eval))
    }else{}

    return(res)
}

########################################################################################################################
bilanCalcPoids.f <- function(x)
{
    ## Purpose: Affiche un pop-up avec un r�capitulatif des calculs de poids
    ##          (si n�cessaire).
    ## ----------------------------------------------------------------------
    ## Arguments: x : vecteur avec les nombres de poids ajout�s aux
    ##                observations suivant chaque type de calcul.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  7 d�c. 2010, 13:56

    runLog.f(msg=c("Affichage du bilan calculs de poids :"))

    infoLoading.f(msg=paste("Les poids sont renseign�s pour ",
                  sum(x[-1]), "/", x["total"], " observations",
                  ifelse(sum(x[-1]) > 0,
                         paste(         # Info compl�mentaires si des poids estim�s...
                               " et se r�partissent comme suit :",
                               "\n\t*  ", x["obs"], " poids observ�s.",
                               "\n\t*  ", x["taille"], " calculs d'apr�s la taille observ�e.",
                               ifelse(any(x[-(1:3)] > 0),
                                      paste("\n\t*  ", x["taille.moy"],
                                            " calculs d'apr�s des tailles estim�es",
                                            " sur la base des classes de tailles.",
                                            ifelse(!is.na(x["poids.moy"]),
                                                   paste("\n\t*  ", x["poids.moy"],
                                                         " poids moyens par classe de taille (P, M, G), ",
                                                         " par esp�ce.", sep=""),
                                                   ""),
                                            sep=""),
                                      ""),
                               "\n\nLes estimations de biomasses d�pendent de ces poids.",
                               sep=""),
                         "."),          # ...sinon rien.
                  sep=""),
                  icon=ifelse(any(x[-(1:3)] > 0), "warning", "info"))
}


########################################################################################################################
calcPoids.f <- function(Data)
{
    ## Purpose: Calculs des poids (manquants) pour un fichier de type
    ##          "observation", avec par ordre de priorit� :
    ##           1) conservation des poids observ�s.
    ##           2) calcul des poids avec les relations taille-poids.
    ##           3) idem avec les tailles d'apr�s les classes de tailles.
    ##           4) poids moyens d'apr�s les classes de tailles (G, M, P).
    ##           5) rien sinon (NAs).
    ##
    ##           Afficher les un bilan si n�cessaire.
    ## ----------------------------------------------------------------------
    ## Arguments: Data : jeu de donn�es ; doit contenir les colonnes
    ##                   "code_espece", "unite_observation", "taille",
    ##                   "poids" et �ventuellement "classe_taille".
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  6 d�c. 2010, 11:57

    runLog.f(msg=c("Calcul des poids :"))

    ## Identification des diff�rents cas :
    casSite <- c("BA"="Med", "BO"="Med", "CB"="Med", "CR"="Med", "STM"="Med", # [!!!] STM provisoire en attendant mieux.
                 "MAY"="MAY", "RUN"="MAY")

    ## Poids observ�s :
    res <- Data[ , "poids"]

    ## Nombre d'obs totales, nombre de poids obs et nombre de tailles obs (sans poids obs) :
    nbObsType <- c("total"=length(res), "obs"=sum(!is.na(res))) # , "taille"=sum(!is.na(Data[is.na(res) , "taille"])))

    ## indices des tailles renseign�es, pour lesquelles il n'y a pas de poids renseign� :
    idxTaille <- !is.na(Data$taille) & is.na(res)

    ## ajout des tailles moyennes d'apr�s la classe de taille :
    Data[ , "taille"] <- calcTaillesMoyennes.f(Data)

    ## indices des tailles ajout�es par cette m�thode, pour lesquelles il n'y a pas de poids renseign� :
    idxTailleMoy <- !is.na(Data$taille) & ! idxTaille & is.na(res)

    ## Calcul des poids � partir des relations taille-poids W�=�n*a*L^b :
    idxP <- is.na(res)                  # indices des poids � calculer.

    switch(casSite[unique(as.character(unitobs$AMP))],
           ## M�diterrann�e :
           "Med"={
               res[idxP] <- (Data$nombre * especes$Coeff.a.Med[match(Data$code_espece, especes$code_espece)] *
                             Data$taille ^ especes$Coeff.b.Med[match(Data$code_espece, especes$code_espece)])[idxP]
           },
           ## Certains sites outre-mer :
           "MAY"={
               res[idxP] <- (Data$nombre * especes$Coeff.a.MAY[match(Data$code_espece, especes$code_espece)] *
                             Data$taille ^ especes$Coeff.b.MAY[match(Data$code_espece, especes$code_espece)])[idxP]
           },
           ## Autres (NC,...) :
           res[idxP] <- (Data$nombre * especes$Coeff.a.NC[match(Data$code_espece, especes$code_espece)] *
                         Data$taille ^ especes$Coeff.b.NC[match(Data$code_espece, especes$code_espece)])[idxP]
           )

    ## [!!!] Comptabiliser les tailles incalculables !
    ## Nombre de poids ajout�es gr�ce � la m�thode :
    nbObsType[c("taille", "taille.moy")] <- c(sum(!is.na(res[idxTaille])), sum(!is.na(res[idxTailleMoy])))

    if (isTRUE(casSite[unique(as.character(unitobs$AMP))][1] == "Med"))
    {
        ## Poids d'apr�s les classes de taille lorsque la taille n'est pas renseign�e :
        tmpNb <- sum(!is.na(res))           # nombre de poids disponibles avant.

        res[is.na(res)] <- (poids.moyen.CT.f(Data=Data) * Data$nombre)[is.na(res)]

        nbObsType["poids.moy"] <- sum(!is.na(res)) - tmpNb # nombre de poids ajout�s.
    }

    ## R�capitulatif :
    bilanCalcPoids.f(x=nbObsType)

    ## Stockage et retour des donn�es :
    Data[ , "poids"] <- res
    return(Data)
}
