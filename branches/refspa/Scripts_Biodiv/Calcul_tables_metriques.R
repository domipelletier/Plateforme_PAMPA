#-*- coding: latin-1 -*-

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2012 Ifremer - Tous droits r�serv�s.
##
##   Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
##   modifier suivant les termes de la "GNU General Public License" telle que
##   publi�e par la Free Software Foundation : soit la version 2 de cette
##   licence, soit (� votre gr�) toute version ult�rieure.
##
##   Ce programme est distribu� dans l'espoir qu'il vous sera utile, mais SANS
##   AUCUNE GARANTIE : sans m�me la garantie implicite de COMMERCIALISABILIT�
##   ni d'AD�QUATION � UN OBJECTIF PARTICULIER. Consultez la Licence G�n�rale
##   Publique GNU pour plus de d�tails.
##
##   Vous devriez avoir re�u une copie de la Licence G�n�rale Publique GNU avec
##   ce programme ; si ce n'est pas le cas, consultez :
##   <http://www.gnu.org/licenses/>.

### File: Calcul_tables_metriques.R
### Time-stamp: <2012-02-24 19:58:32 Yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Calcul des tables de m�triques (unitSpSz, unitSp, unit)
####################################################################################################
########################################################################################################################
calcNumber.default.f <- function(obs,
                                 factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul des nombres au niveau d'agr�gation souhait�.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            factors : les facteurs d'agr�gation.
    ##
    ## Output : un array avec autant de dimensions que de facteurs
    ##          d'agr�gation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 13:38

    ## Somme des nombres d'individus :
    nbr <- tapply(obs[ , "nombre"],
                  as.list(obs[ , factors]),
                  sum, na.rm = TRUE)

    ## Absences consid�r�e comme "vrais z�ros" :
    nbr[is.na(nbr)] <- 0

    return(nbr)
}

########################################################################################################################
calc.numbers.f <- function(nbr)
{
    ## Purpose: Produit la data.frame qui va servir de table, � partir du
    ##          tableau de nombres produit par calcNumber.default.f().
    ## ----------------------------------------------------------------------
    ## Arguments: nbr : array de nombres avec autant de dimensions que de
    ##                  facteurs d'agr�gations.
    ##
    ## Output: une data.frame avec (nombre de facteurs d'agr�gation + 1)
    ##         colonnes.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 13:46

    res <- as.data.frame(as.table(nbr), responseName="nombre")
    ## res$unitobs <- res$unite_observation # Pour compatibilit� uniquement !!!

    if (is.element("classe_taille", colnames(res)))
    {
        res$classe_taille[res$classe_taille == ""] <- NA
    }else{}

    ## Si les nombres sont des entiers, leur redonner la bonne classe :
    if (isTRUE(all.equal(res$nombre, as.integer(res$nombre))))
    {
        res$nombre <- as.integer(res$nombre)
    }else{}

    return(res)
}

########################################################################################################################
calc.meanSize.f <- function(obs,
                            factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul des tailles moyennes pond�r�es (par le nombre
    ##          d'individus)
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            factors : les facteurs d'agr�gation.
    ##
    ## Output: vecteur des tailles moyennes.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 13:51

    return(as.vector(tapply(seq(length.out=nrow(obs)),
                            as.list(obs[ , factors]),
                            function(ii)
                        {
                            weighted.mean(obs[ii, "taille"], obs[ii, "nombre"])
                        })))
}

########################################################################################################################
calc.weight.f <- function(obs, Data,
                              factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul des poids totaux.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            Data : la table de m�trique (temporaire).
    ##            factors : les facteurs d'agr�gation.
    ##
    ## Output: vecteur des poids.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 14:12

    weight <- as.vector(tapply(obs[ , "poids"],
                               as.list(obs[ , factors]),
                               function(x)
                           {
                               ifelse(all(is.na(x)),
                                      as.numeric(NA),
                                      sum(x, na.rm=TRUE))
                           }))

    ## Coh�rence des z�ros avec la calculabilit� des poids par esp�ce :
    if (is.element("code_espece", factors))
    {
        ## Certains NAs correspondent � des vrai z�ros :
        if (!all(is.na(obs[ , "poids"])))
        {
            weight[is.na(weight) & Data[ , "nombre"] == 0] <- 0
        }

        ## Especes pour lesquelles aucune biomasse n'est calcul�e.
        noWeightSp <- tapply(weight, Data[ , "code_espece"],
                             function(x)all(is.na(x) | x == 0))

        noWeightSp <- names(noWeightSp)[noWeightSp]

        ## Donn�es non disponibles
        ## (�vite d'avoir des z�ros pour des esp�ces pour lesquelles le poids ne peut �tre estim�) :
        weight[is.element(Data[ , "code_espece"], noWeightSp)] <- NA
    }else{}

    return(weight)
}

########################################################################################################################
calc.meanWeight.f <- function(Data)
{
    ## Purpose: Calcul des poids moyens (d'individus).
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##
    ## Output: vecteur des poids moyens.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 14:17

    if ( ! all(is.na(Data[ , "poids"])))
    {
        return(apply(Data[ , c("nombre", "poids")], 1,
                     function(x)
                 {
                     ## Le poids moyen par individu est le poids total / le nombre d'individus :
                     return(as.vector(ifelse(is.na(x[2]) || x[1] == 0,
                                             as.numeric(NA),
                                             x[2]/x[1])))
                 }))
    }else{
        return(NA)
    }
}

########################################################################################################################
calc.density.f <- function(Data, unitobs)
{
    ## Purpose: Calcul g�n�ric des densit�s (�galement utilisable pour des
    ##          CPUE).
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##
    ## Output: vecteur des densit�s.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 15:47

    ## Traitement sp�cial si la fraction est un facteur (on doit dabord passer par la classe "character") :
    if (is.factor(unitobs[ , "fraction_echantillonnee"]))
    {
        unitobs[ , "fraction_echantillonnee"] <- as.numeric(as.character(unitobs[ , "fraction_echantillonnee"]))
    }else{}

    ## Calculs :
    return(Data[ , "nombre"] /
           ## Surface/unit� d'effort :
           (unitobs[(idx <- match(Data[ , "unite_observation"],
                                  unitobs[ , "unite_observation"])) ,
                    "DimObs1"] *
            unitobs[idx, "DimObs2"] *
            ## ...qui tient compte de la fraction �chantillonn�e :
            ifelse(is.na(as.numeric(unitobs[idx , "fraction_echantillonnee"])),
                   1,
                   as.numeric(unitobs[idx , "fraction_echantillonnee"]))))
}

########################################################################################################################
calc.biomass.f <- function(Data, unitobs)
{
    ## Purpose: Calcul g�n�ric des biomasses (�galement utilisable pour des
    ##          CPUEbiomasse).
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##
    ## Output: vecteur des biomasses.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 11:05

    if (!all(is.na(Data[ , "poids"])))      # (length(unique(obs$biomasse))>1)
    {
        ## ##################################################
        ## poids :
        weight <- Data[ , "poids"]

        ## Coh�rence des z�ros avec la calculabilit� des poids par esp�ce (en principe inutile car fait pr�c�demment sur
        ## le poids mais mis en s�curit� si autre utilisation que l'originale) :
        if (is.element("code_espece", colnames(Data)))
        {
            ## Especes pour lesquelles aucune biomasse n'est calcul�e.
            noBiomSp <- tapply(weight, Data[ , "code_espece"],
                               function(x)all(is.na(x) | x == 0))

            noBiomSp <- names(noBiomSp)[noBiomSp]

            ## Donn�es non disponibles
            ## (�vite d'avoir des z�ros pour des esp�ces pour lesquelles le poids ne peut �tre estim�) :
            weight[is.element(Data[ , "code_espece"], noBiomSp)] <- NA
        }else{}

        ## Poids / surface ou unit� d'effort :
        return(as.numeric(weight) /
               ## Surface/unit� d'effort :
               (unitobs[(idx <- match(Data[ , "unite_observation"],
                                      unitobs[ , "unite_observation"])) ,
                        "DimObs1"] *
                unitobs[idx, "DimObs2"] *
                ## ...qui tient compte de la fraction �chantillonn�e :
                ifelse(is.na(as.numeric(unitobs[idx , "fraction_echantillonnee"])),
                       1,
                       as.numeric(unitobs[idx , "fraction_echantillonnee"]))))
    }else{
        ## alerte que les calculs de biomasse sont impossibles
        infoLoading.f(msg=paste("Calcul de biomasse impossible : ",
                                "\nles poids ne sont pas renseign�s ou ne peuvent �tre calcul�s.", sep=""),
                      icon="warning")

        return(NA)
    }
}

########################################################################################################################
calc.presAbs.f <- function(Data)
{
    ## Purpose: Calcul des pr�sences/absences � partir des abondances.
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##
    ## Output: vecteur des pr�sences/absences (0 ou 1).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 12:04

    ## Presence - absence :
    presAbs <- integer(nrow(Data))
    presAbs[Data[ , "nombre"] > 0] <- as.integer(1) # pour avoir la richesse sp�cifique en 'integer'.1
    presAbs[Data[ , "nombre"] == 0] <- as.integer(0) # pour avoir la richesse sp�cifique en 'integer'.0

    return(presAbs)
}

########################################################################################################################
unitSpSz.propAb.f <- function(unitSpSz, factors)
{
    ## Purpose: Calcul des proportions d'abondance par classe de taille (au
    ##          sein des croisements d'autres facteurs que "classe_taille",
    ##          i.e. par unit� d'observation par esp�ce en g�n�ral).
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##            factors : les facteurs d'agr�gation.
    ##
    ## Output: vecteur des proportions d'abondance.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 12:11

    ## ##################################################
    ## Proportion d'abondance par classe de taille :

    ## Mise sous forme de tableau multi-dimensionel :
    abondance <- tapply(unitSpSz$densite,
                        as.list(unitSpSz[ , factors]),
                        function(x){x}) # -> tableau � 3D.

    ## Autres facteurs que "classe_taille" :
    factRed <- which(!is.element(factors, "classe_taille"))

    ## Sommes d'abondances pour chaque unitobs pour chaque esp�ce :
    sumsCT <- apply(abondance, factRed, sum, na.rm=TRUE)

    ## Calcul des proportions d'abondance -> tableau 3D :
    propAbondance <- sweep(abondance, factRed, sumsCT, FUN="/")
    names(dimnames(propAbondance)) <- factors

    ## Extraction des r�sultats et remise en ordre :
    tmp <- as.data.frame(as.table(propAbondance),
                         responseName="prop.abondance.SC",
                         stringsAsFactors=FALSE)

    row.names(tmp) <- apply(tmp[ , factors], 1, paste, collapse=":")

    ## M�me ordre que unitSpSz :
    tmp <- tmp[apply(unitSpSz[ , factors], 1, paste, collapse=":") , ]

    ## Mise au format colonne + % : ordre [OK]  [yr: 30/10/2012]
    return(100 * tmp$prop.abondance.SC)
}

########################################################################################################################
unitSpSz.propBiom.f <- function(unitSpSz, factors)
{
    ## Purpose: Calcul des proportions de biomasse par classe de taille (au
    ##          sein des croisements d'autres facteurs que "classe_taille",
    ##          i.e. par unit� d'observation par esp�ce en g�n�ral).
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de m�trique (temporaire).
    ##            factors : les facteurs d'agr�gation.
    ##
    ## Output: vecteur des proportions de biomasse.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 12:17

    if (!is.null(unitSpSz[ , "biomasse"]))
    {
        biomasses <- tapply(unitSpSz$biomasse,
                            as.list(unitSpSz[ , factors]),
                            function(x){x}) # -> tableau � 3D.

        ## Autres facteurs que "classe_taille" :
        factRed <- which(!is.element(factors, "classe_taille"))

        ## Sommes de biomasses pour chaque unitobs pour chaque esp�ce :
        sumsCT <- apply(biomasses, factRed, sum, na.rm=TRUE)

        ## Calcul des proportions de biomasse -> tableau 3D :
        propBiomass <- sweep(biomasses, factRed, sumsCT, FUN="/")
        names(dimnames(propBiomass)) <- factors

        ## Extraction des r�sultats et remise en ordre :
        tmp <- as.data.frame(as.table(propBiomass),
                             responseName="prop.biomasse.SC",
                             stringsAsFactors=FALSE)

        row.names(tmp) <- apply(tmp[ , factors], 1, paste, collapse=":")

        ## M�me ordre que unitSpSz :
        tmp <- tmp[apply(unitSpSz[ , factors], 1, paste, collapse=":") , ]

        ## Mise au format colonne + % : ordre [OK]  [yr: 30/10/2012]
        return(100 * tmp$prop.biomasse.SC)
    }else{
        return(NULL)
    }
}

########################################################################################################################
########################################################################################################################
calc.tables.Transect.f <- function(obs, unitobs, dataEnv,
                                   factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul de tables de m�triques pour les transects par d�faut.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            dataEnv : environnement des donn�es.
    ##            factors : les facteurs d'agr�gation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 d�c. 2011, 12:18

    ## Calcul des nombres par cl / esp�ces / unitobs :
    nbr <- calcNumber.default.f(obs, factors=factors)

    ## Cr�ation de la data.frame de r�sultats (avec nombres, unitobs, ):
    res <- calc.numbers.f(nbr)

    ## Tailles moyennes :
    res[ , "taille_moyenne"] <- calc.meanSize.f(obs, factors=factors)

    ## Poids :
    res[ , "poids"] <- calc.weight.f(obs=obs, Data=res, factors=factors)

    ## Poids moyen par individu :
    res[ , "poids_moyen"] <- calc.meanWeight.f(Data=res)

    ## Densit� :
    res[ , "densite"] <- calc.density.f(Data=res, unitobs=unitobs)

    ## Biomasse :
    res[ , "biomasse"] <- calc.biomass.f(Data=res, unitobs=unitobs)

    ## Pr�sence/absence :
    res[ , "pres_abs"] <- calc.presAbs.f(Data=res)

    if (is.element("classe_taille", factors))
    {
        ## Proportions d'abondance par classe de taille :
        res[ , "prop.abondance.CL"] <- unitSpSz.propAb.f(unitSpSz=res,
                                                         factors=factors)

        ## Proportions de biomasse par classe de taille :
        res[ , "prop.biomasse.CL"] <- unitSpSz.propBiom.f(unitSpSz=res,
                                                          factors=factors)
    }else{}

    return(res)
}

########################################################################################################################
calc.tables.Fishing.f <- function(obs, unitobs, dataEnv,
                                  factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul des m�triques par unit� d'observation, par esp�ce et
    ##          par classe de taille pour la p�che (seules des noms de
    ##          colonnes changent par rapport aux transects par defaut).
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            dataEnv : environnement des donn�es.
    ##            factors : les facteurs d'agr�gation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 d�c. 2011, 13:20

    res <- calc.tables.Transect.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv, factors=factors)

    ## Renommage des colonnes de densit� et biomasse :
    res[ , "CPUE"] <- res$densite
    res$densite <- NULL
    res[ , "CPUEbiomasse"] <- res$biomasse # Fonctionne m�me si biomasse n'existe pas.
    res$biomasse <- NULL

    return(res)
}


########################################################################################################################
calc.unitSpSz.f <- function(obs, unitobs, refesp, dataEnv)
{
    ## Purpose: Calcul de la table de m�triques par  unit� d'observation par
    ##          esp�ce par classe de taille.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            refesp : r�f�rentiel esp�ces.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 16 d�c. 2011, 11:51

    runLog.f(msg=c("Calcul des m�triques par unit� d'observation, esp�ce et classe de taille :"))

    pampaProfilingStart.f()

    ## Informations :
    stepInnerProgressBar.f(n=2, msg="Calcul des m�triques par unit� d'observation, esp�ce et classe de taille...")

    ## D�finition des types d'observation n�cessitant les m�mes m�thodes de calcul :
    casObsType <- c("SVR"="SVR",
                    "EMB"="Fishing", "DEB"="Fishing", "PSCI"="Fishing", "PecRec"="Fishing",
                    "LIT"="LIT",
                    "PIT"="PIT",
                    "TRUVC"="Transect", "UVC"="Transect",
                    "TRVID"="Transect", "Q"="Transect",
                    "PFUVC"="Fixe")

    ## Calcul des m�triques selon cas d'observation :
    if ( ! all(is.na(obs[ , "classe_taille"])))
    {
        factors <- c("unite_observation", "code_espece", "classe_taille")

        unitSpSz <- switch(casObsType[getOption("P.obsType")],
                           "SVR"={
                               calc.tables.SVR.f(obs=obs, dataEnv=dataEnv, factors=factors)
                           },
                           "Fishing"={
                               calc.tables.Fishing.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv, factors=factors)
                           },
                           "LIT"={
                               ## Pas calcul� par classe de taille
                           },
                           "PIT"={
                               ## Pas calcul� par classe de taille
                           },
                           "Transect"={
                               calc.tables.Transect.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv, factors=factors)
                           },
                           "Fixe"={
                               ## calc.unitSpSz.Fixe.f()
                           },
                       {
                           warning("\n\tType d'observation inconnu pour le calcul des m�triques par classe de taille !")
                           NULL
                       })
    }else{
        unitSpSz <- data.frame("unite_observation"=NULL, "code_espece"=NULL, "nombre"=NULL,
                               "poids"=NULL, "poids_moyen"=NULL, "densite"=NULL,
                               "pres_abs"=NULL, "site"=NULL, "biotope"=NULL,
                               "an"=NULL, "statut_protection"=NULL)
    }

    pampaProfilingEnd.f()

    return(unitSpSz)
}

########################################################################################################################
calc.unitSp.default.f <- function(unitSpSz, dataEnv=.GlobalEnv)
{
    ## Purpose: Calcul de la table de m�triques par unit� d'observation par
    ##          esp�ce, cas g�n�ral (� l'aide d'agr�gations).
    ## ----------------------------------------------------------------------
    ## Arguments: unitSpSz : table de m�triques par unit� d'observation, par
    ##                       esp�ce par classe de taille.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 15:31

    metrics <- c("nombre", "taille_moyenne", "poids", "poids_moyen", "densite", "biomasse",
                 "pres_abs",
                 "CPUE", "CPUEbiomasse",
                 "colonie", "recouvrement", "taille.moy.colonies")

    usedMetrics <- metrics[is.element(metrics, colnames(unitSpSz))]

    return(agregations.generic.f(Data=unitSpSz,
                                 metrics=usedMetrics,
                                 factors=c("unite_observation", "code_espece"),
                                 listFact = NULL,
                                 unitSpSz = unitSpSz,
                                 unitSp = NULL,
                                 dataEnv=dataEnv))
}

########################################################################################################################
calc.unitSp.f <- function(unitSpSz, obs, unitobs, dataEnv)
{
    ## Purpose: Calcul de la table de m�triques par unit� d'observation par
    ##          esp�ce (choix de la m�thode ad�quate en fonction du
    ##          protocole).
    ## ----------------------------------------------------------------------
    ## Arguments: unitSpSz : table de m�triques par unit� d'observation, par
    ##                       esp�ce par classe de taille.
    ##            obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 d�c. 2011, 10:04

    ## Informations :
    stepInnerProgressBar.f(n=1, msg="Calcul des m�triques par unit� d'observation et esp�ce...")

    pampaProfilingStart.f()

    if (FALSE) ## ! is.null(unitSpSz) && nrow(unitSpSz))
    {
        ## Note : d�sactiv� car plus long que de recalculer la table.
        ##        Conserv� car pourrait redevenir int�ressant avec de la parallelisation.

        unitSp <- switch(getOption("P.obsType"),
                         SVR=calc.unitSp.SVR.f(unitSpSz=unitSpSz, obs=obs, dataEnv=dataEnv),
                         LIT={
                             warning(paste("Depuis quand les m�triques par classe de taille sont calcul�es ",
                                           "pour du benthos ?", sep=""))

                             calc.unitSp.LIT.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv)
                         },
                         calc.unitSp.default.f(unitSpSz=unitSpSz, dataEnv=dataEnv))
    }else{
        factors <- c("unite_observation", "code_espece")

        casObsType <- c("SVR"="SVR",
                        "EMB"="Fishing", "DEB"="Fishing", "PSCI"="Fishing", "PecRec"="Fishing",
                        "LIT"="LIT",
                        "PIT"="PIT",
                        "TRUVC"="Transect", "UVC"="Transect",
                        "TRVID"="Transect", "Q"="Transect",
                        "PFUVC"="Fixe")

        unitSp <- switch(casObsType[getOption("P.obsType")],
                         "SVR"={
                             calc.tables.SVR.f(obs=obs, dataEnv=dataEnv, factors=factors)
                         },
                         "Fishing"={
                             calc.tables.Fishing.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv, factors=factors)
                         },
                         "LIT"={
                             calc.unitSp.LIT.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv)
                         },
                         "PIT"={
                             warning("Protocole PIT pas impl�ment� pour l'instant !")
                             ## calc.unitSpSz.PIT.f()
                         },
                         "Transect"={
                             calc.tables.Transect.f(obs=obs, unitobs=unitobs, dataEnv=dataEnv, factors=factors)
                         },
                         "Fixe"={
                             warning("Protocole \"Point fixe\" pas impl�ment� pour l'instant !")
                             ## calc.unitSpSz.Fixe.f()
                         },
                     {
                         warning("\n\tType d'observation inconnu pour le calcul des m�triques par esp�ce !")
                         NULL
                     })
    }

    pampaProfilingEnd.f()

    return(unitSp)
}

########################################################################################################################
calc.unit.default.f <- function(unitSp, refesp, unitobs, colNombres="nombre", dataEnv=.GlobalEnv)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 d�c. 2011, 17:07

    metrics <- c("nombre", "taille_moyenne", "poids", "poids_moyen", "densite", "biomasse",
                 "pres_abs",
                 "CPUE", "CPUEbiomasse",
                 "colonie", "recouvrement", "taille.moy.colonies")

    usedMetrics <- metrics[is.element(metrics, colnames(unitSp))]

    if ( ! is.null(unitSp))
    {
        unit <- agregations.generic.f(Data=unitSp,
                                      metrics=usedMetrics,
                                      factors=c("unite_observation"),
                                      listFact = NULL,
                                      unitSpSz = NULL,
                                      unitSp = unitSp,
                                      dataEnv=dataEnv)

        tmp <- do.call(rbind,
                       lapply(unique(as.character(unitobs[ , getOption("P.MPAfield")])),
                              function(MPA)
                          {
                              calcBiodiv.f(Data=subset(unitSp,
                                                       is.element(unite_observation,
                                                                  unitobs[unitobs[ , getOption("P.MPAfield")] == MPA ,
                                                                          "unite_observation"])),
                                           refesp=refesp,
                                           MPA=MPA,
                                           unitobs = "unite_observation",
                                           code.especes = "code_espece", nombres = colNombres, indices = "all",
                                           printInfo=TRUE, global=TRUE,
                                           dataEnv=dataEnv)
                          }))

        unit <- merge(unit, tmp[ , colnames(tmp) != colNombres],
                      by.x="unite_observation", by.y="unite_observation")



        return(unit)
    }else{}
}

########################################################################################################################
calc.unit.f <- function(unitSp, obs, refesp, unitobs, dataEnv)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ##            obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            refesp : r�f�rentiel esp�ces.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 d�c. 2011, 10:08

    ## Informations :
    stepInnerProgressBar.f(n=1, msg="Calcul des m�triques par unit� d'observation...")

    pampaProfilingStart.f()

    casObsType <- c("SVR"="SVR",
                    "EMB"="Fishing", "DEB"="Fishing", "PSCI"="Fishing", "PecRec"="Fishing",
                    "LIT"="LIT",
                    "PIT"="PIT",
                    "TRUVC"="Transect", "UVC"="Transect",
                    "TRVID"="Transect", "Q"="Transect",
                    "PFUVC"="Fixe")

    ##
    if ( ! is.null(unitSp) && nrow(unitSp))
    {
        unit <- switch(casObsType[getOption("P.obsType")],
                       "SVR"={
                           calc.unit.SVR.f(unitSp=unitSp, obs=obs, refesp=refesp,
                                           unitobs=unitobs, dataEnv=dataEnv, colNombres = "nombre")
                       },
                       "LIT"={        # Pour les types d'observation qui ont une colonne "colonie" � la place de
                                      # "nombre" :
                           calc.unit.default.f(unitSp=unitSp, refesp=refesp, unitobs=unitobs, colNombres="colonie",
                                               dataEnv=dataEnv)
                       },
                       calc.unit.default.f(unitSp=unitSp, refesp=refesp, unitobs=unitobs, colNombres="nombre",
                                           dataEnv=dataEnv))
    }else{
        unit <- NULL
    }

    pampaProfilingEnd.f()
    return(unit)
}


########################################################################################################################
########################################################################################################################
calcTables.f <- function(obs, unitobs, refesp, dataEnv)
{
    ## Purpose: Lance le calcul des tables de m�triques � divers niveaux
    ##          d'agr�gation.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            unitobs : table des unit�s d'observation (data.frame).
    ##            refesp : r�f�rentiel esp�ces.
    ##            dataEnv : environnement des donn�es.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 15 d�c. 2011, 10:33

    pampaProfilingStart.f()

    runLog.f(msg=c("Cr�ation des tables de base (calcul de m�triques) :"))

    ## M�triques par classe de taille par esp�ce par unit� d'observation :
    unitSpSz <- calc.unitSpSz.f(obs=obs, unitobs=unitobs, refesp=refesp, dataEnv=dataEnv)

    ## M�triques par esp�ce par unit� d'observation :
    unitSp <- calc.unitSp.f(unitSpSz=unitSpSz, obs=obs, unitobs=unitobs, dataEnv=dataEnv)

    ## M�triques par unit� d'observation (dont biodiversit�) :
    unit <- calc.unit.f(unitSp=unitSp, obs=obs, refesp=refesp, unitobs=unitobs, dataEnv=dataEnv)

    pampaProfilingEnd.f()

    return(list(unitSpSz=unitSpSz, unitSp=unitSp, unit=unit))
}


### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
