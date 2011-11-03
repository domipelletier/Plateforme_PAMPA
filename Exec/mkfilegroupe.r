
################################################################################
## CREATION DES TABLES DE BASE
##      Calcul par unit� d'observation par esp�ce : unitesp.f
##      Calcul par unit� d'observation toutes esp�ces confondues : unit.f
################################################################################


################################################################################
## Nom     : unitespta.f
## Objet   : calcul des m�triques par unit� d'observation / esp�ce et classe
##            de taille
## Input   : tables "obs" et "unitobs"
## Output  : table "unitespta"
################################################################################

unitespta.f <- function(){
    runLog.f(msg=c("Calcul des m�triques par unit� d'observation, esp�ce et classe de taille :"))

    ## Informations :
    stepInnerProgressBar.f(n=1, msg="Calcul des m�triques par unit� d'observation, esp�ce et classe de taille...")


    ## creation des classes de tailles si le champ classe taille contient des NA.
    if (any(is.na(obs$classe_taille)))
    {
        classeTaille.f()
    }else{
        ## si le champ taille contient uniquement des valeurs a NA
        if (all(is.na(obs$taille)))
        {
            ct <- 2
        }else{
            ct <- 1
        }
    }

    assign("ct", ct, envir=.GlobalEnv)  # � quoi �a sert au final [???]

    if (ct == 1 || !all(is.na(obs$classe_taille)))
    {
        ## #########################################################################################################
        ## Creation de la table par unite d'observation, par espece et par classe de taille et par rotation si SVR :

        ## Nombre d'individus :
        if (unique(unitobs$type) == "SVR")
        {
            stepInnerProgressBar.f(n=1, msg="Interpolations pour vid�os rotatives (�tape longue)")
            switch(getOption("PAMPA.SVR.interp"),
                   "extended"={
                       statRotations <- statRotation.extended.f(facteurs=c("unite_observation", "code_espece",
                                                                           "classe_taille"))
                   },
                   "basic"={
                       statRotations <- statRotation.basic.f(facteurs=c("unite_observation", "code_espece",
                                                             "classe_taille"))
                   },
                   stop(paste("Y'a un truc qui cloche dans les options d'interpolations : ",
                              "\n\tcontactez le support technique !", sep=""))
                   )

            ## Moyenne pour les vid�os rotatives (habituellement 3 rotation) :
            unitesptaT <- statRotations[["nombresMean"]]

            stepInnerProgressBar.f(n=7, msg="Calcul des m�triques par unit� d'observation, esp�ce et classe de taille...")
        }else{
            ## Somme des nombres d'individus :
            unitesptaT <- tapply(obs$nombre,
                                 as.list(obs[ , c("unite_observation", "code_espece", "classe_taille")]),
                                 sum, na.rm = TRUE)

            ## Absences consid�r�e comme "vrais z�ros" :
            unitesptaT[is.na(unitesptaT)] <- 0
        }

        unitespta <- as.data.frame(as.table(unitesptaT), responseName="nombre")
        unitespta$unitobs <- unitespta$unite_observation # Pour compatibilit� uniquement !!!

        unitespta$classe_taille[unitespta$classe_taille == ""] <- NA

        ## Si les nombres sont des entiers, leur redonner la bonne classe :
        if (isTRUE(all.equal(unitespta$nombre, as.integer(unitespta$nombre))))
        {
            unitespta$nombre <- as.integer(unitespta$nombre)
        }else{}

        ## Stats sur les nombres pour les (g�n�ralement 3) rotations :
        if (unique(unitobs$type) == "SVR")
        {
            unitespta$nombreMax <- as.vector(statRotations[["nombresMax"]])
            unitespta$nombreSD <- as.vector(statRotations[["nombresSD"]])
        }else{}

        ## ######################################################
        ## tailles moyennes ponderees si champ taille renseigne :
        if (!all(is.na(obs$taille)))        # (length(unique(obs$taille))>1)
        {
            unitespta$taille_moy <- as.vector(tapply(seq(length.out=nrow(obs)),
                                                     as.list(obs[ , c("unite_observation",
                                                                      "code_espece", "classe_taille")]),
                                                     function(ii)
                                                 {
                                                     weighted.mean(obs$taille[ii], obs$nombre[ii])
                                                 }))
        }

        ## ######################################################################
        ## sommes des biomasses par esp�ce par unitobs et par classes de taille :
        if (!all(is.na(obs$poids)))      # (length(unique(obs$biomasse))>1)
        {
            ## ##################################################
            ## biomasse :
            unitespta$biomasse <- as.vector(tapply(obs$poids,
                                                   as.list(obs[ , c("unite_observation",
                                                                    "code_espece", "classe_taille")]),
                                                   function(x)
                                               {
                                                   if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                               }))

            ## C'est b�te que la biomasse soit calcul�e comme �a... il faut faire des corrections
            ## pour les vid�os rotatives :
            if (unique(unitobs$type) == "SVR")
            {
                unitespta$biomasse <- unitespta$biomasse * unitespta$nombre /
                    as.vector(tapply(obs$nombre,
                                     as.list(obs[ , c("unite_observation",
                                                      "code_espece", "classe_taille")]),
                                     function(x)
                                 {
                                     if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                 }))

                ## Biomasse max
                unitespta$biomasseMax <- unitespta$biomasse * unitespta$nombreMax /
                    as.vector(tapply(obs$nombre,
                                     as.list(obs[ , c("unite_observation",
                                                      "code_espece", "classe_taille")]),
                                     function(x)
                                 {
                                     if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                 }))

            }else{}


            ## Certains NAs correspondent � des vrai z�ros :

            ## Especes pour lesquelles aucune biomasse n'est calcul�e.
            espSansBiom <- tapply(unitespta$biomasse, unitespta$code_espece,
                                  function(x)all(is.na(x) | x == 0))
            espSansBiom <- names(espSansBiom)[espSansBiom]

            ## Ajout des vrais z�ros :
            unitespta$biomasse[is.na(unitespta$biomasse) &
                               unitespta$nombre == 0 &
                               !is.element(unitespta$code_espece, espSansBiom)] <- 0


            if (unique(unitobs$type) == "SVR")
            {
                ## On divise par la surface du cercle contenant l'observation la plus lointaine :
                unitespta$biomasse <- unitespta$biomasse /
                    (pi * (as.vector(tapply(obs$dmin,
                                            as.list(obs[ , c("unite_observation", "code_espece")]),
                                            max, na.rm=TRUE)))^2) # Recycl� 3X.

                unitespta$biomasseMax <- unitespta$biomasseMax /
                    (pi * (as.vector(tapply(obs$dmin,
                                            as.list(obs[ , c("unite_observation", "code_espece")]),
                                            max, na.rm=TRUE)))^2) # Recycl� 3X.
            }else{
                ## on divise la biomasse par dimObs1*dimObs2
                unitespta$biomasse <- as.numeric(unitespta$biomasse) /
                    (unitobs$DimObs1[match(unitespta$unite_observation, unitobs$unite_observation)] *
                     unitobs$DimObs2[match(unitespta$unite_observation, unitobs$unite_observation)])
            }


        }else{
            ## alerte que les calculs de biomasse sont impossibles
            infoLoading.f(msg=paste("Calcul de biomasse impossible : ",
                                    "\nles poids ne sont pas renseign�s ou ne peuvent �tre calcul�s.", sep=""),
                          icon="warning")
        }

        ## poids

        ## ##################################################
        ## poids
        unitespta$poids <- as.vector(tapply(obs$poids,
                                            as.list(obs[ , c("unite_observation",
                                                             "code_espece", "classe_taille")]),
                                            function(x)
                                        {
                                            ifelse(all(is.na(x)),
                                                   as.numeric(NA),
                                                   sum(x, na.rm=TRUE))
                                        }))

        ## Certains NAs correspondent � des vrai z�ros :
        if (!all(is.na(obs$poids)))
        {
            unitespta$poids[is.na(unitespta$poids) & unitespta$nombre == 0] <- 0
        }

        ## ##################################################
        ## poids moyen :
        if (!all(is.na(unitespta$poids)))
        {
            unitespta$poids_moyen <- apply(unitespta[ , c("nombre", "poids")], 1,
                                           function(x)
                                       {
                                           return(as.vector(ifelse(is.na(x[2]) || x[1] == 0,
                                                                   as.numeric(NA),
                                                                   x[2]/x[1])))
                                       })
        }

        ## Presence - absence
        unitespta$pres_abs[unitespta$nombre > 0] <- as.integer(1) # pour avoir la richesse sp�cifique en 'integer'.1
        unitespta$pres_abs[unitespta$nombre == 0] <- as.integer(0) # pour avoir la richesse sp�cifique en 'integer'.0

        ## calcul densites (pour les p�ches, ce calcul correspond au CPUE en nombre par espece)
        ## [densit�]
        if (unique(unitobs$type) != "SVR")
        {
            unitespta$densite <- unitespta$nombre /
                (unitobs$DimObs1[match(unitespta$unite_observation, unitobs$unite_observation)] *
                 unitobs$DimObs2[match(unitespta$unite_observation, unitobs$unite_observation)])
        }else{
            ## Densit� :
            unitespta$densite <- unitespta$nombre /
                (pi * (as.vector(tapply(obs$dmin,
                                        as.list(obs[ , c("unite_observation", "code_espece")]),
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unitespta$densite[unitespta$nombre == 0 & !is.na(unitespta$nombre)] <- 0

            ## Densit� max :
            unitespta$densiteMax <- unitespta$nombreMax /
                (pi * (as.vector(tapply(obs$dmin,
                                        as.list(obs[ , c("unite_observation", "code_espece")]),
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unitespta$densiteMax[unitespta$nombreMax == 0 & !is.na(unitespta$nombreMax)] <- 0

            ## SD Densit� :
            unitespta$densiteSD <- unitespta$nombreSD /
                (pi * (as.vector(tapply(obs$dmin,
                                        as.list(obs[ , c("unite_observation", "code_espece")]),
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unitespta$densiteSD[unitespta$nombreSD == 0 & !is.na(unitespta$nombreSD)] <- 0
        }

        ## ajout des champs "an", "site", "statut_protection", "biotope", "latitude", "longitude" :
        unitespta <- cbind(unitespta,
                           unitobs[match(unitespta$unite_observation, unitobs$unite_observation),
                                   c("an", "site", "statut_protection", "biotope", "latitude", "longitude")])

        ## ##################################################
        ## Proportion d'abondance par classe de taille :
        abondance <- with(unitespta, tapply(densite, list(unite_observation, code_espece, classe_taille),
                                            function(x){x})) # -> tableau � 3D.

        ## Sommes d'abondances pour chaque unitobs pour chaque esp�ce :
        sommesCT <- apply(abondance, c(1, 2), sum, na.rm=TRUE)

        ## Calcul des proportions d'abondance -> tableau 3D :
        propAbondance <- sweep(abondance, c(1, 2), sommesCT, FUN="/")
        names(dimnames(propAbondance)) <- c("unite_observation", "code_espece", "classe_taille")

        ## Mise au format colonne + % :
        unitespta$prop.abondance.CL <- 100 * as.data.frame(as.table(propAbondance),
                                                           responseName="prop.abondance.CL",
                                                           stringsAsFactors=FALSE)$prop.abondance.CL

        ## ##################################################
        ## Proportion de biomasse par classe de taille :
        if (!is.null(unitespta$biomasse))
        {
            biomasses <- with(unitespta, tapply(biomasse,
                                                list(unite_observation, code_espece, classe_taille),
                                                function(x){x})) # -> tableau � 3D.

            ## Sommes de biomasses pour chaque unitobs pour chaque esp�ce :
            sommesCT <- apply(biomasses, c(1, 2), sum, na.rm=TRUE)

            ## Calcul des proportions de biomasse -> tableau 3D :
            propBiomasse <- sweep(biomasses, c(1, 2), sommesCT, FUN="/")
            names(dimnames(propBiomasse)) <- c("unite_observation", "code_espece", "classe_taille")

            ## Mise au format colonne + % :
            unitespta$prop.biomasse.CL <- 100 * as.data.frame(as.table(propBiomasse),
                                                              responseName="prop.biomasse.CL",
                                                              stringsAsFactors=FALSE)$prop.biomasse.CL
        }else{}

        ## #################################################
        ## on renomme densite et biomasse en CPUE
        ## pour les jeux de donn�es p�che
        if (is.peche.f())                   # length(typePeche)>1
        {
            unitespta$CPUE <- unitespta$densite
            unitespta$densite <- NULL
            unitespta$CPUEbiomasse <- unitespta$biomasse # Fonctionne m�me si biomasse n'existe pas.
            unitespta$biomasse <- NULL
        }

        assign("unitespta", unitespta, envir=.GlobalEnv)

        ## Certaines m�triques (densit�s) sont ramen�es � /100m� :
        if (any(is.element(colnames(unitespta),
                           colTmp <- c("densite", "densiteMax", "densiteSD",
                                       "biomasse", "biomassMax", "biomasseSD"))))
        {
            unitespta[ , is.element(colnames(unitespta),
                                    colTmp)] <- sweep(unitespta[ , is.element(colnames(unitespta),
                                                                              colTmp)],
                                                      2, 100, "*")
        }else{}

        ## Sauvegarde dans un fichier :
        write.csv2(merge(merge(unitespta,
                               unitobs[ , c("unite_observation", paste("habitat", 1:3, sep=""))],
                               by=c("unite_observation")),
                         especes[ , c("code_espece", "Famille", "Genre", "espece")],
                         by="code_espece"),
                   file=paste(nameWorkspace,
                              "/FichiersSortie/UnitobsEspeceClassetailleMetriques",
                              ifelse(Jeuxdonnescoupe, "_selection", ""),
                              ".csv", sep=""),
                   row.names = FALSE)
    }else{
        message("M�triques par classe de taille incalculables")
        assign("unitespta",
               data.frame("unite_observation"=NULL, "code_espece"=NULL, "nombre"=NULL,
                          "poids"=NULL, "poids_moyen"=NULL, "densite"=NULL,
                          "pres_abs"=NULL, "site"=NULL, "biotope"=NULL,
                          "an"=NULL, "statut_protection"=NULL),
               envir=.GlobalEnv)
    }

    stepInnerProgressBar.f(n=2)
} #fin unitespta.f()


################################################################################
## Nom     : unitesp.f
## Objet   : calcul des m�triques par unit� d'observation / esp�ce
## Input   : tables "obs" et "unitobs"
## Output  : table "unitesp" et "listespunit"
################################################################################

unitesp.f <- function(){

    runLog.f(msg=c("Calcul des m�triques par unit� d'observation et esp�ce :"))

    stepInnerProgressBar.f(n=1, msg="Calcul des m�triques par unit� d'observation et esp�ce...")

    ## ##################################################
    ## somme des abondances


    ## Si video rotative, on divise par le nombre de rotation
    if (unique(unitobs$type) == "SVR")
    {
        stepInnerProgressBar.f(n=1, msg="Interpolations pour vid�os rotatives")

        switch(getOption("PAMPA.SVR.interp"),
                   "extended"={
                       statRotations <- statRotation.extended.f(facteurs=c("unite_observation", "code_espece"))
                   },
                   "basic"={
                       statRotations <- statRotation.basic.f(facteurs=c("unite_observation", "code_espece"))
                   },
                   stop(paste("Y'a un truc qui cloche dans les options d'interpolations : ",
                              "\n\tcontactez le support technique !", sep=""))
                   )

        ## Moyenne pour les vid�os rotatives (habituellement 3 rotation) :
        unitespT <- statRotations[["nombresMean"]]

        stepInnerProgressBar.f(n=3, msg="Calcul des m�triques par unit� d'observation et esp�ce...")
    }else{
        unitespT <- tapply(obs$nombre,
                           as.list(obs[ , c("unite_observation", "code_espece")]),
                           sum, na.rm = TRUE)

        unitespT[is.na(unitespT)] <- 0      # Les NAs correspondent � des vrais z�ros.
    }


    unitesp <- as.data.frame(as.table(unitespT), responseName="nombre")

    if (isTRUE(all.equal(unitesp$nombre, as.integer(unitesp$nombre))))
    {
        unitesp$nombre <- as.integer(unitesp$nombre)
    }else{}

    ## Si video rotative, stat sur les rotations :
    if (unique(unitobs$type) == "SVR")
    {
        unitesp$nombreMax <- as.vector(statRotations[["nombresMax"]])
        unitesp$nombreSD <- as.vector(statRotations[["nombresSD"]])
    }else{}

    if (!is.benthos.f())                               # unique(unitobs$type) != "LIT"
    {

        ## ##################################################
        ## tailles moyennes ponderees
        if (!all(is.na(obs$taille)))
        {
            unitesp$taille_moy <- as.vector(tapply(seq(length.out=nrow(obs)),
                                                   list(obs$unite_observation, obs$code_espece),
                                                   function(ii)
                                               {
                                                   weighted.mean(obs$taille[ii], obs$nombre[ii])
                                               }))
        }else{}

        if (!all(is.na(obs$poids)))
        {
            unitesp$biomasse <- as.vector(tapply(obs$poids,
                                                 list(obs$unite_observation, obs$code_espece),
                                                 function(x)
                                             {
                                                 if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                             }))



            ## C'est b�te que la biomasse soit calcul�e comme �a... il faut faire des corrections pour les vid�os rotatives :
            if (unique(unitobs$type) == "SVR")
            {
                unitesp$biomasse <- unitesp$biomasse * unitesp$nombre /
                    as.vector(tapply(obs$nombre,
                                     as.list(obs[ , c("unite_observation",
                                                      "code_espece")]),
                                     function(x)
                                 {
                                     if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                 }))

                ## Biomasse max
                unitesp$biomasseMax <- unitesp$biomasse * unitesp$nombreMax /
                    as.vector(tapply(obs$nombre,
                                     as.list(obs[ , c("unite_observation",
                                                      "code_espece")]),
                                     function(x)
                                 {
                                     if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}
                                 }))

            }else{}


            ## Certains NAs correspondent � des vrai z�ros :

            ## Especes pour lesquelles aucune biomasse n'est calcul�e.
            espSansBiom <- tapply(unitesp$biomasse, unitesp$code_espece,
                                  function(x)all(is.na(x) | x == 0))
            espSansBiom <- names(espSansBiom)[espSansBiom]

            ## Ajout des vrais z�ros :
            unitesp$biomasse[is.na(unitesp$biomasse) &
                             unitesp$nombre == 0 &
                             !is.element(unitesp$code_espece, espSansBiom)] <- 0

            if (unique(unitobs$type) == "SVR")
            {
                ## On divise par la surface du cercle contenant l'observation la plus lointaine :
                unitesp$biomasse <- unitesp$biomasse /
                    (pi * (as.vector(tapply(obs$dmin,
                                            as.list(obs[ , c("unite_observation", "code_espece")]),
                                            max, na.rm=TRUE)))^2)

                unitesp$biomasseMax <- unitesp$biomasseMax /
                    (pi * (as.vector(tapply(obs$dmin,
                                            as.list(obs[ , c("unite_observation", "code_espece")]),
                                            max, na.rm=TRUE)))^2)
            }else{
                ## on divise la biomasse par dimObs1*dimObs2
                unitesp$biomasse <- as.numeric(unitesp$biomasse) /
                    (unitobs$DimObs1[match(unitesp$unite_observation, unitobs$unite_observation)] *
                     unitobs$DimObs2[match(unitesp$unite_observation, unitobs$unite_observation)])
            }
        }else{}

        ## ##################################################
        ## poids
        unitesp$poids <- as.vector(tapply(obs$poids,
                                          list(obs$unite_observation, obs$code_espece),
                                          function(x) {if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}}))

        ## Certains NAs correspondent � des vrai z�ros :
        if (!all(is.na(obs$poids)))
        {
            unitesp$poids[is.na(unitesp$poids) & unitesp$nombre == 0] <- 0
        }

        ## ##################################################
        ## poids moyen
        unitesp$poids_moyen <- apply(unitesp[ , c("nombre", "poids")], 1,
                                     function(x)
                                 {
                                     return(as.vector(ifelse(is.na(x[2]) || x[1] == 0,
                                                             as.numeric(NA),
                                                             x[2]/x[1])))
                                 })

        ## ##################################################
        ## calcul densites (pour les p�ches, ce calcul correspond aux captures par unite d'effort)
        if (unique(unitobs$type) != "SVR")
        {
            unitesp$densite <- unitesp$nombre /
                (unitobs$DimObs1[match(unitesp$unite_observation, unitobs$unite_observation)] *
                 unitobs$DimObs2[match(unitesp$unite_observation, unitobs$unite_observation)])

        }else{                          # Videos rotatives :
            unitesp$densite <- unitesp$nombre /
                (pi * (as.vector(tapply(obs$dmin,
                                        list(obs$unite_observation, obs$code_espece),
                                        max, na.rm=TRUE)))^2)

            ## Densit� max :
            unitesp$densiteMax <- unitesp$nombreMax /
                (pi * (as.vector(tapply(obs$dmin,
                                        as.list(obs[ , c("unite_observation", "code_espece")]),
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unitesp$densiteMax[unitesp$nombreMax == 0 & !is.na(unitesp$nombreMax)] <- 0

            ## SD Densit� :
            unitesp$densiteSD <- unitesp$nombreSD /
                (pi * (as.vector(tapply(obs$dmin,
                                        as.list(obs[ , c("unite_observation", "code_espece")]),
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unitesp$densiteSD[unitesp$nombreSD == 0 & !is.na(unitesp$nombreSD)] <- 0
        }

        ## Ajout des vrais z�ros :
        unitesp$densite[unitesp$nombre == 0 & !is.na(unitesp$nombre)] <- 0


    }else{ # cas LIT

        ## Pourcentage de recouvrement de chaque esp�ce/categorie pour les couvertures biotiques et abiotiques
        s <- tapply(unitesp$nombre, unitesp$unite_observation, sum, na.rm=TRUE)
        unitesp$recouvrement <- as.vector(100 * unitesp$nombre /
                                          s[match(unitesp$unite_observation, rownames(s))])
        rm(s)

        ## Nombre de colonies (longueurs de transition > 0) :
        obs$count <- ifelse(obs$nombre > 0, 1, 0)

        e <- tapply(obs$count, list(obs$unite_observation, obs$code_espece), sum, na.rm=TRUE)

        unitesp$colonie <- as.vector(e)
        unitesp$colonie[is.na(unitesp$colonie)] <- 0 # [???]
        unitesp$taille.moy.colonies <- apply(unitesp[ , c("nombre", "colonie")], 1,
                                             function(x){ifelse(x[2] == 0, NA, x[1] / x[2])})

        rm(e)
    }

    ## Creation de l'info Presence/Absence :
    unitesp$pres_abs[unitesp$nombre > 0] <- as.integer(1) # pour avoir la richesse sp�cifique en 'integer'.1
    unitesp$pres_abs[unitesp$nombre == 0] <- as.integer(0) # pour avoir la richesse sp�cifique en 'integer'.0

    unitesp <- cbind(unitesp,
                     unitobs[match(unitesp$unite_observation, unitobs$unite_observation),
                             c("site", "biotope", "an", "statut_protection")])

    ## on renomme densite en CPUE pour les jeux de donn�es p�che
    if (is.peche.f())                   # length(typePeche)>1
    {
        unitesp$CPUE <- unitesp$densite
        unitesp$densite <- NULL
        unitesp$CPUEbiomasse <- unitesp$biomasse
        unitesp$biomasse <- NULL
    }

    ## Ecriture du fichier des unit�s d'observations par esp�ce en sortie
    assign("unitesp", unitesp, envir=.GlobalEnv)

    ## table avec la liste des esp�ces presentes dans chaque transect
    listespunit <- unitesp## [unitesp$pres_abs != 0, ]
    listespunit <- listespunit[order(listespunit$code_espece), ]
    assign("listespunit", listespunit, envir=.GlobalEnv)

    ## Certaines m�triques (densit�s) sont ramen�es � /100m� pour les sorties fichier :
    if (any(is.element(colnames(unitesp),
                       colTmp <- c("densite", "densiteMax", "densiteSD",
                                   "biomasse", "biomassMax", "biomasseSD"))))
    {
        unitesp[ , is.element(colnames(unitesp),
                              colTmp)] <- sweep(unitesp[ , is.element(colnames(unitesp),
                                                                      colTmp)],
                                          2, 100, "*")
    }else{}

    ## Sauvegarde dans un fichier :
    write.csv2(merge(merge(unitesp,
                           unitobs[ , c("unite_observation", paste("habitat", 1:3, sep=""))],
                           by=c("unite_observation")),
                     especes[ , c("code_espece", "Famille", "Genre", "espece")],
                     by="code_espece"),
               file=paste(NomDossierTravail, "UnitobsEspeceMetriques",
                          ifelse(Jeuxdonnescoupe, "_selection", ""),
                          ".csv", sep=""), row.names = FALSE)

    ## write.csv2(listespunit, file=paste(NomDossierTravail, "ListeEspecesUnitobs.csv", sep=""), row.names = FALSE)
} # fin unitesp.f()


################################################################################
## Nom     : unit.f
## Objet   : calcul des m�triques par unit� d'observation toutes esp�ces confondues
## Input   : tables "obs" et "unitobs"
## Output  : table "unit" et carte de la CPUE pour les donn�es de p�che NC
################################################################################

unit.f <- function(){
    runLog.f(msg=c("Calcul des m�triques par unit� d'observation :"))

    stepInnerProgressBar.f(n=2, msg="Calcul des m�triques par unit� d'observation...")

    unit <- as.data.frame(as.table(tapply(obs$nombre, obs$unite_observation, sum, na.rm = TRUE))
                          , responseName="nombre")
    colnames(unit)[1] = c("unitobs")

    unit$nombre[is.na(unit$nombre)] <- 0      # Les NAs correspondent � des vrais z�ros.

    if (!is.benthos.f())                # unique(unitobs$type) != "LIT"
    {

        ## biomasse par unite d'observation
        unit.b <- tapply(obs$poids, obs$unite_observation,
                         function(x){if (all(is.na(x))) {return(NA)}else{return(sum(x, na.rm=TRUE))}}) # Pour �viter
                                        # des sommes � z�ro l� o� seulement des NAs. ## sum)
        unit$biomasse <- unit.b[match(unit$unitobs, rownames(unit.b))]



        if (unique(unitobs$type) != "SVR")
        {
            ## calcul biomasse :
            unit$biomasse <- as.numeric(unit$biomasse) /
                (unitobs$DimObs1[match(unit$unitobs, unitobs$unite_observation)] *
                 unitobs$DimObs2[match(unit$unitobs, unitobs$unite_observation)])

            ## calcul densite :
            unit.d <- tapply(obs$nombre, obs$unite_observation, sum, na.rm=TRUE)
            unit$densite <- unit.d[match(unit$unitobs, rownames(unit.d))]
            unit$densite <- as.numeric(unit$densite) /
                (unitobs$DimObs1[match(unit$unitobs, unitobs$unite_observation)] *
                 unitobs$DimObs2[match(unit$unitobs, unitobs$unite_observation)])
            unit$densite[is.na(unit$densite)] <- 0
        }else{                          # Vid�os rotatives :
            ## calcul densite d'abondance
            ## Moyennes :
            unit$nombre <- apply(.NombresSVR,
                                 1,
                                 function(x,...){ifelse(all(is.na(x)), NA, mean(x,...))}, na.rm=TRUE)

            ## Maxima :
            unit$nombreMax <- apply(.NombresSVR,
                                    1,
                                    function(x,...){ifelse(all(is.na(x)), NA, max(x,...))}, na.rm=TRUE)

            ## D�viation standard :
            unit$nombreSD <- apply(.NombresSVR,
                                   1,
                                   function(x,...){ifelse(all(is.na(x)), NA, sd(x,...))}, na.rm=TRUE)

            ## Nombre de rotations valides :
            nombresRotations <- apply(.Rotations, 1, sum, na.rm=TRUE)

            ## Densit� :
            unit$densite <- unit$nombre  /
                (pi * (as.vector(tapply(obs$dmin,
                                        obs[ , c("unite_observation")],
                                        max, na.rm=TRUE)))^2)

            ## Densit� max :
            unit$densiteMax <- unit$nombreMax  /
                (pi * (as.vector(tapply(obs$dmin,
                                        obs[ , c("unite_observation")],
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unit$densiteMax[unit$nombreMax == 0 & !is.na(unit$nombreMax)] <- 0

            ## SD Densit� :
            unit$densiteSD <- unit$nombreSD /
                (pi * (as.vector(tapply(obs$dmin,
                                        obs[ , c("unite_observation")],
                                        max, na.rm=TRUE)))^2)

            ## Vrais z�ros :
            unit$densiteSD[unit$nombreSD == 0 & !is.na(unit$nombreSD)] <- 0

        }

        ## Certains NAs correspondent � des vrai z�ros :
        if (!all(is.na(obs$poids)))  # Si les biomasses ne sont pas calculables, inutile de mettre les z�ros !
        {
            ## Ajout des vrais z�ros :
            unit$biomasse[is.na(unit$biomasse) & unit$nombre == 0] <- 0
        }else{}

        ## Ajout des vrais z�ros de densit� :
        unit$densite[unit$nombre == 0 & !is.na(unit$nombre)] <- 0

        ## ##################################################
        ##  Indices de diversit� :

        tmp <- calcBiodiv.f(Data=listespunit, unitobs = "unite_observation",
                            code.especes = "code_espece", nombres = "nombre", indices = "all")

        unit <- merge(unit, tmp[ , colnames(tmp) != "nombre"], by.x="unitobs", by.y="unite_observation")
    }else{
        ## Benthos :
        tmp <- calcBiodiv.f(Data=listespunit, unitobs = "unite_observation",
                            code.especes = "code_espece", nombres = "colonie", indices = "all")

        unit <- merge(unit, tmp[ , colnames(tmp) != "colonie"], by.x="unitobs", by.y="unite_observation")
    }

    ## ajout des champs "an", "site", "statut_protection", "biotope", "latitude", "longitude"
    unit <- cbind(unit,
                  unitobs[match(unit$unitobs, unitobs$unite_observation),
                          c("an", "site", "statut_protection", "biotope", "latitude", "longitude")])

    assign("unit", unit, envir=.GlobalEnv)

    ## on renomme densite en CPUE pour les jeux de donn�es p�che
    if (is.peche.f())                   # length(typePeche)>1
    {
        unit$CPUE <- unit$densite
        unit$densite <- NULL
        unit$CPUEbiomasse <- unit$biomasse
        unit$biomasse <- NULL
    }

    if (is.benthos.f())                 # unique(unitobs$type) == "LIT"
    {
        unit$richesse_specifique <- as.integer(tapply(unitesp$pres_abs, unitesp$unite_observation,
                                                      sum, na.rm=TRUE)) # chang� pour avoir des entiers.
        unit$richesse_specifique[is.na(unit$richesse_specifique)] <- as.integer(0) # pour conserver des entiers.
    }

    assign("unit", unit, envir=.GlobalEnv)

    ## Certaines m�triques (densit�s) sont ramen�es � /100m� :
    if (any(is.element(colnames(unit),
                       colTmp <- c("densite", "densiteMax", "densiteSD",
                                   "biomasse", "biomassMax", "biomasseSD"))))
    {
        unit[ , is.element(colnames(unit),
                           colTmp)] <- sweep(unit[ , is.element(colnames(unit),
                                                                colTmp)],
                                       2, 100, "*")
    }else{}

    ## Sauvegarde dans un fichier :
    write.csv2(merge(unit,
                     unitobs[ , c("unite_observation", paste("habitat", 1:3, sep=""))],
                     by.x="unitobs", by.y=c("unite_observation")),
               file=paste(NomDossierTravail, "UnitobsMetriques",
                          ifelse(Jeuxdonnescoupe, "_selection", ""),
                          ".csv", sep=""), row.names = FALSE)

    stepInnerProgressBar.f(n=1)

} # fin unit.f()


################################################################################
## Nom    : creationTablesBase.f()
## Objet  : ex�cution des fonctions unit.f, unitesp.f et unitespta.f
################################################################################

creationTablesBase.f <- function(){
    runLog.f(msg=c("Cr�ation des tables de base (calcul de m�triques) :"))

    ## ATTENTION A L'ORDRE D'APPEL DES FONCTIONS!!
    if (!is.benthos.f())                 # unique(unitobs$type) != "LIT"
    {  #car pas de classes de tailles avec les recouvrements

        ## Calculs des poids non observ�s :
        obs <- calcPoids.f(obs)
        assign("obs", obs, envir=.GlobalEnv)

        unitespta.f()
        if (Jeuxdonnescoupe==0)
        {
            ## SAUVunitespta <- unitespta  # stockage inutile [yr: 10/08/2010]
            assign("SAUVunitespta", unitespta, envir=.GlobalEnv)
        }
    }
    unitesp.f()
    unit.f()

    ## Sauvegarde des calculs pour restauration sans rechargement
    if (Jeuxdonnescoupe==0)
    {
        assign("SAUVobs", obs, envir=.GlobalEnv)
        assign("SAUVunitobs", unitobs, envir=.GlobalEnv)
        assign("SAUVcontingence", contingence, envir=.GlobalEnv)
        assign("SAUVunitesp", unitesp, envir=.GlobalEnv)
        assign("SAUVunit", unit, envir=.GlobalEnv)
        assign("SAUVlistespunit", listespunit, envir=.GlobalEnv)
    }

    ## Infos :
    if (Jeuxdonnescoupe==1)
    {
        infoLoading.f(msg=paste("Les m�triques ont �t�",
                                " recalcul�es sur le jeu de donn�es s�lectionn�.",
                                sep=""),
                      icon="info",
                      font=tkfont.create(weight="bold", size=9))

        infoLoading.f(button=TRUE)

        gestionMSGinfo.f("CalculSelectionFait")
    }
    if (Jeuxdonnescoupe==0)
    {
        infoLoading.f(msg=paste("Les m�triques ont �t�",
                                " calcul�es sur l'ensemble du jeu de donn�es import�.",
                                sep=""),
                      icon="info",
                      font=tkfont.create(weight="bold", size=9))

        gestionMSGinfo.f("CalculTotalFait")
    }
}

################################################################################
## Nom    : creationTablesCalcul.f()
## Objet  : G�n�ration d'une table globale bas�e sur obs a partir de listespunit
## rajoute des champs s�lectionn�s dans unitobs et especes
##          dans le cas de la vid�o
##          dans le cas du benthos
##          dans les cas autre que benthos
################################################################################

creationTablesCalcul.f <- function(){
    runLog.f(msg=c("Cr�ation des tables pour des analyses suppl�mentaires :",
                   "\t* TableMetrique : m�triques par unit� d'observation et par esp�ce.",
                   "\t* TableBiodiv : m�triques par unit� d'observation."))

    stepInnerProgressBar.f(n=1, msg="Cr�ation des tables de calcul suppl�mentaires...")

    ## Simplification OK [yreecht: 08/10/2010] :
    TableMetrique <- cbind(listespunit,
                           ## Colonnes d'unitobs :
                           unitobs[match(listespunit$unite_observation, unitobs$unite_observation),
                                   c("station", "caracteristique_1",
                                     ifelse(is.null(unitobs$caracteristique_2), "annee.campagne", "caracteristique_2"),
                                     "fraction_echantillonnee",
                                     "jour", "mois", "heure", "nebulosite", "direction_vent", "force_vent", "etat_mer",
                                     "courant", "maree", "phase_lunaire", "latitude", "longitude", "avant_apres",
                                     "biotope_2", "habitat1", "habitat2", "habitat3", "visibilite", "prof_min",
                                     "prof_max", "DimObs1", "DimObs2", "nb_plong", "plongeur")],
                           ## Colonnes du r�f�rentiel esp�ces :
                           especes[match(listespunit$code_espece, especes$code_espece),
                                   c("Genre", "Famille", "mobilite", "nocturne", "cryptique", "taillemax", "regim.alim",
                                     ## Inter�ts types de p�ches :
                                     grep(paste("^interet\\.[[:alpha:]]+", siteEtudie, "$", sep=""), # Colonnes
                                          colnames(especes), value=TRUE))])                          # site-sp�cifiques.

    ## Certaines m�triques (densit�s) sont ramen�es � /100m� :
    if (any(is.element(colnames(TableMetrique),
                       colTmp <- c("densite", "densiteMax", "densiteSD",
                                   "biomasse", "biomassMax", "biomasseSD"))))
    {
        TableMetrique[ , is.element(colnames(TableMetrique),
                                    colTmp)] <- sweep(TableMetrique[ , is.element(colnames(TableMetrique),
                                                                                  colTmp)],
                                                      2, 100, "*")
    }else{}

    if (is.benthos.f())                 # unique(unitobs$type) == "LIT"
    {
        TableMetrique$Cat_benthique <- especes$Cat_benthique[match(TableMetrique$code_espece, especes$code_espece)]
    }
    if (unique(unitobs$type) == "SVR")  # suppr: "UVC" �_� [???]
    {
        ## Si Video     "poids.moyen.petits" "poids.moyen.moyens" "poids.moyen.gros"   "taille_max_petits"  "taille_max_moyens"     "L50"
    }

    ## On peut rendre plus lisible ce qui suit... [yreecht: 22/07/2010] OK [yreecht: 08/10/2010]
    TableBiodiv <- unit
    names(TableBiodiv)[1] <- "unite_observation"

    TableBiodiv <- cbind(TableBiodiv,
                         ## Colonnes d'unitobs :
                         unitobs[match(TableBiodiv$unite_observation, unitobs$unite_observation),
                                 c("station", "caracteristique_1",
                                   ifelse(is.null(unitobs$caracteristique_2), "annee.campagne", "caracteristique_2"),
                                   "fraction_echantillonnee",
                                   "jour", "mois", "heure", "nebulosite", "direction_vent", "force_vent", "etat_mer",
                                   "courant", "maree", "phase_lunaire", "avant_apres", "biotope_2", "habitat1",
                                   "habitat2", "habitat3", "visibilite", "prof_min", "prof_max", "DimObs1", "DimObs2",
                                   "nb_plong", "plongeur")])

    ## Certaines m�triques (densit�s) sont ramen�es � /100m� :
    if (any(is.element(colnames(TableBiodiv),
                       colTmp <- c("densite", "densiteMax", "densiteSD",
                                   "biomasse", "biomassMax", "biomasseSD"))))
    {
        TableBiodiv[ , is.element(colnames(TableBiodiv),
                                  colTmp)] <- sweep(TableBiodiv[ , is.element(colnames(TableBiodiv),
                                                                              colTmp)],
                                                    2, 100, "*")
    }else{}


    assign("TableBiodiv", TableBiodiv, envir=.GlobalEnv)
    assign("TableMetrique", TableMetrique, envir=.GlobalEnv)

    ## Si on ne travaille pas sur une s�lection... :
    if (Jeuxdonnescoupe==0)
    {
        assign("SAUVTableBiodiv", TableBiodiv, envir=.GlobalEnv)
        assign("SAUVTableMetrique", TableMetrique, envir=.GlobalEnv)
    }else{}

    ## Info :
    infoLoading.f(msg=paste("Des tables suppl�mentaires (pour calculs additionnels) ont �t� cr��es :",
                            "\n\t* TableMetriques : m�triques / unit� d'observation / esp�ce.",
                            "\n\t* TableBiodiv : m�triques (dont biodiversit�) / unit� d'observation.",
                            sep=""),
                  icon="info")
}
