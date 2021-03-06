#-*- coding: latin-1 -*-

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2010 Ifremer - Tous droits r�serv�s.
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

### File: Calcul_tables_metriques_SVR.R
### Time-stamp: <2012-01-19 13:37:52 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Fonctions sp�cifiques aux vid�os rotatives pour le calcul des tables de m�triques :
####################################################################################################


########################################################################################################################
statRotations.f <- function(facteurs, obs, dataEnv=.GlobalEnv)
{
    ## Purpose: Calcul des statistiques des abondances (max, sd) par rotation
    ##          en se basant sur des donn�es d�j� interpol�es.
    ## ----------------------------------------------------------------------
    ## Arguments: facteurs : vecteur des noms de facteurs d'agr�gation
    ##                       (r�solution � laquelle on travaille).
    ##            obs : donn�es d'observation.
    ##            dataEnv : environnement des donn�es (pour sauvegarde de
    ##                      r�sultats interm�diaires).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 29 oct. 2012, 16:01

    ## Identification des rotations valides :
    if (is.element("unite_observation", facteurs))
    {
        ## Rotations valides (les vides doivent tout de m�me �tre renseign�s) :
        rotations <- tapply(obs$rotation,
                            as.list(obs[ , c("unite_observation", "rotation"), drop=FALSE]),
                            function(x)length(x) > 0)

        ## Les rotations non renseign�s apparaissent en NA et on veut FALSE :
        rotations[is.na(rotations)] <- FALSE
    }else{
        stop("\n\tL'unit� d'observation doit faire partie des facteurs d'agr�gation !!\n")
    }

    ## ###########################################################
    ## Nombres par rotation avec le niveau d'agr�gation souhait� :
    nombresR <- tapply(obs$nombre,
                       as.list(obs[ , c(facteurs, "rotation"), drop=FALSE]),
                       function(x,...){ifelse(all(is.na(x)), NA, sum(x,...))},
                       na.rm = TRUE)

    ## Les NAs sont consid�r�s comme des vrais z�ros lorsque la rotation est valide :
    nombresR <- sweep(nombresR,
                      match(names(dimnames(rotations)), names(dimnames(nombresR)), nomatch=NULL),
                      rotations,        # Tableau des secteurs valides (bool�ens).
                      function(x, y)
                  {
                      x[is.na(x) & y] <- 0 # Lorsque NA et secteur valide => 0.
                      return(x)
                  })

    ## ##################################################
    ## Statistiques :

    ## Moyennes :
    nombresMean <- apply(nombresR, which(is.element(names(dimnames(nombresR)), facteurs)),
                         function(x,...){ifelse(all(is.na(x)), NA, mean(x,...))}, na.rm=TRUE)

    ## Maxima :
    nombresMax <- apply(nombresR, which(is.element(names(dimnames(nombresR)), facteurs)),
                        function(x,...){ifelse(all(is.na(x)), NA, max(x,...))}, na.rm=TRUE)

    ## D�viation standard :
    nombresSD <- apply(nombresR, which(is.element(names(dimnames(nombresR)), facteurs)),
                       function(x,...){ifelse(all(is.na(x)), NA, sd(x,...))}, na.rm=TRUE)

    ## Nombre de rotations valides :
    nombresRotations <- apply(rotations, 1, sum, na.rm=TRUE)

    if (is.element("classe_taille", facteurs))
    {
    ## ## Pour les calculs agr�g�s par unitobs :
    ## tmpNombresSVR <- apply(nombresR,
    ##                        which(names(dimnames(nombresR)) != "code_espece"),
    ##                        sum, na.rm=TRUE)

    ## tmpNombresSVR[!rotations] <- NA

        ## #### Densit�s brutes (pour agr�gations) :
        ## on r�duit les facteurs (calcul de rayon par esp�ce) :
        factors2 <- facteurs[ ! is.element(facteurs, "classe_taille")]


        ## rayons par esp�ce / unitobs :
        rayons <- as.table(tapply(obs[obs[ , "nombre"] > 0 , "dmin"],
                                  as.list(obs[obs[ , "nombre"] > 0,
                                              factors2, drop=FALSE]),
                                  max, na.rm=TRUE))

        densitesR <- sweep(nombresR,
                           match(names(dimnames(rayons)), names(dimnames(nombresR))),
                           pi * rayons ^ 2,
                           "/")

        ## Les NAs sont consid�r�s comme des vrais z�ros lorsque la rotation est valide :
        densitesR <- sweep(densitesR,
                          match(names(dimnames(rotations)), names(dimnames(densitesR)), nomatch=NULL),
                          rotations,        # Tableau des secteurs valides (bool�ens).
                          function(x, y)
                      {
                          x[is.na(x) & y] <- 0 # Lorsque NA et secteur valide => 0.
                          return(x)
                      })

        ## Sauvegardes dans l'environnement des donn�es :
        assign(".NombresSVR", nombresR, envir=dataEnv)
        assign(".DensitesSVR", densitesR, envir=dataEnv)
        assign(".Rotations", rotations, envir=dataEnv)
    }else{}

    ## Retour des r�sultats sous forme de liste :
    return(list(nombresMean=nombresMean, nombresMax=nombresMax, nombresSD=nombresSD,
                nombresRotations=nombresRotations, nombresTot=nombresR))
}


########################################################################################################################
calc.density.SVR.f <- function(Data, obs, metric="densite",
                               factors=c("unite_observation", "code_espece"))
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 22 d�c. 2011, 11:12

    ## Nom de la colonne de nombre en fonction de la m�trique de densit� :
    nbMetric <- c(densite="nombre",
                  densiteMax="nombreMax",
                  densiteSD="nombreSD")

    if ( ! all(is.na(nbMetric[metric])))     # la colonne de nombre doit �tre d�finie.
    {
        metric <- metric[!is.na(nbMetric[metric])]

        ## Calcul du rayon d'observation :
        Data <- merge(Data,
                      ## Calcul du max du diam�tre minimum sur les observation conserv�es(nombre > 0) :
                      as.data.frame(as.table(tapply(obs[obs[ , "nombre"] > 0 , "dmin"],
                                                    as.list(obs[obs[ , "nombre"] > 0, factors, drop=FALSE]),
                                                    max, na.rm=TRUE)),
                                    responseName="r"))

        ## Calcul des diff�rentes densit�s :
        res <- lapply(metric,
                      function(x, Data, nbMetrics)
                  {
                      density <- Data[ , nbMetric[x]] /
                          (pi * (Data[ , "r"] ^ 2))

                      ## Vrais z�ros :
                      density[Data[ , nbMetric[x]] == 0 & !is.na(Data[ , nbMetric[x]])] <- 0

                      return(density)
                  },
                      Data=Data, nbMetrics=nbMetrics)

        ## Ajout des r�sultats � Data
        names(res) <- metric

        res <- as.data.frame(res)

        Data <- cbind(Data, res)
        Data$r <- NULL

        ## density <- Data[ , nbMetric[metric]] /
        ##     ## Surface : vecteur recycl� autant de fois qu'il y a de classes de taille
        ##     ##           si Data  en contient.
        ##     (pi * (as.vector(t(tapply(obs[ , "dmin"],
        ##                               as.list(obs[ , factors, drop=FALSE]),
        ##                               max, na.rm=TRUE))))^2)

        ## Seconde m�thode d�sactiv�e car certaines fois t() requis, d'autres fois pas.

        return(Data)
    }else{
        stop("M�trique de densit� inconnue !")
    }
}

########################################################################################################################
calc.biomass.SVR.f <- function(Data, obs, factors=c("unite_observation", "code_espece"))
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 22 d�c. 2011, 12:02

    ## Calcul du rayon d'observation :
    Data <- merge(Data,
                  ## Calcul du max du diam�tre minimum sur les observation conserv�es(nombre > 0) :
                  as.data.frame(as.table(tapply(obs[obs[ , "nombre"] > 0 , "dmin"],
                                                as.list(obs[obs[ , "nombre"] > 0, factors, drop=FALSE]),
                                                max, na.rm=TRUE)),
                                responseName="r"))

    biomass <- Data[ , "poids"] /
        (pi * (Data[ , "r"] ^ 2))
    ## Les poids ont �t� corrig�s au pr�alable et tiennent compte des esp�ces pour lesquelles
    ## ils ne peuvent �tre calcul�s.
    ## Aucune correction n'est donc n�cessaire.

    return(biomass)
}

########################################################################################################################
stat.biomass.SVR.f <- function(Data, obs, metric,
                               factors=c("unite_observation", "code_espece"))
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 22 d�c. 2011, 12:10

    ## Nom de la colonne de nombre en fonction de la m�trique de densit� :
    nbMetric <- c(biomasseMax="nombreMax",
                  biomasseSD="nombreSD")

    if ( ! all(is.na(nbMetric[metric])))     # la colonne de nombre doit �tre d�finie.
    {
        metric <- metric[!is.na(nbMetric[metric])]

        ## Calcul du rayon d'observation :
        Data <- merge(Data,
                      ## Calcul du max du diam�tre minimum sur les observation conserv�es(nombre > 0) :
                      as.data.frame(as.table(tapply(obs[obs[ , "nombre"] > 0 , "dmin"],
                                                    as.list(obs[obs[ , "nombre"] > 0, factors, drop=FALSE]),
                                                    max, na.rm=TRUE)),
                                    responseName="r"))

        ## Calcul des diff�rentes densit�s :
        res <- lapply(metric,
                      function(x, Data, nbMetrics)
                  {
                      return(Data[ , nbMetric[x]] * # m�trique de nombre
                             Data[ , "poids_moyen"] /    # * poids moyens d'un individu.
                             (pi * (Data[ , "r"] ^ 2)))
                  },
                      Data=Data, nbMetrics=nbMetrics)

        ## Ajout des r�sultats � Data
        names(res) <- metric

        res <- as.data.frame(res)

        Data <- cbind(Data, res)
        Data$r <- NULL

        return(Data)
    }else{
        stop("M�trique de biomasse inconnue !")
    }
}


########################################################################################################################
calc.tables.SVR.f <- function(obs,
                              dataEnv,
                              factors=c("unite_observation", "code_espece", "classe_taille"))
{
    ## Purpose: Calcul g�n�rique d'une table de m�triques pour les vid�os
    ##          rotatives.
    ## ----------------------------------------------------------------------
    ## Arguments: obs : table des observations (data.frame).
    ##            dataEnv : environnement des donn�es.
    ##            factors : les facteurs d'agr�gation.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 21 d�c. 2011, 14:33

    stepInnerProgressBar.f(n=1, msg="Statistiques pour vid�os rotatives (�tape longue)")

    ## Calcul des statistiques de nombres :
    statRotations <- statRotations.f(facteurs=factors,
                                             obs=obs,
                                             dataEnv=dataEnv)

    ## Moyenne pour les vid�os rotatives (habituellement 3 rotation) :
    nbr <- statRotations[["nombresMean"]]

    switch(is.element("classe_taille", factors),
           "TRUE"=stepInnerProgressBar.f(n=7, msg=paste("Calcul des m�triques par unit� d'observation, ",
                                                        "esp�ce et classe de taille...", sep="")),
           "FALSE"=stepInnerProgressBar.f(n=7, msg=paste("Calcul des m�triques par unit� d'observation et ",
                                                         "esp�ce...", sep="")))

    ## Cr�ation de la data.frame de r�sultats (avec nombres, unitobs, ):
    res <- calc.numbers.f(nbr)

    ## Statistiques sur les nombres :
    res$nombreMax <- as.vector(statRotations[["nombresMax"]])
    res$nombreSD <- as.vector(statRotations[["nombresSD"]])

    ## Tailles moyennes :
    res[ , "taille_moyenne"] <- calc.meanSize.f(obs=obs, factors=factors)

    ## Poids :
    res[ , "poids"] <- calc.weight.f(obs=obs, Data=res, factors=factors)

    ## Poids moyen par individu :
    res[ , "poids_moyen"] <- calc.meanWeight.f(Data=res)

    ## Densit� (+Max +SD) :
    res <- calc.density.SVR.f(Data=res, obs=obs,
                               metric=c("densite", "densiteMax", "densiteSD"))

    ## Biomasse :
    res[ , "biomasse"] <- calc.biomass.SVR.f(Data=res, obs=obs)

    ## Biomasse max+SD :
    res <- stat.biomass.SVR.f(Data=res, obs=obs,
                              metric=c("biomasseMax", "biomasseSD"))

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
calc.unitSp.SVR.f <- function(unitSpSz, obs, dataEnv)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 23 d�c. 2011, 09:43

    ## Agr�gation pour les m�triques par d�faut (idem cas g�n�ral) :
    unitSp <- calc.unitSp.default.f(unitSpSz, dataEnv=dataEnv)

    ## Calcul � partir des donn�es extrapol�es brutes pour les statistiques :
    nbInterp <- get(".NombresSVR", envir=dataEnv)

    nbTmp <- apply(nbInterp,
                   which( ! is.element(names(dimnames(nbInterp)), "classe_taille")),
                   function(x,...)
               {
                   ifelse(all(is.na(x)), NA, sum(x,...))
               }, na.rm=TRUE)

    ## nombres calcul�s... pour comparaison avec nombres agr�g� uniquement :
    nbTest <- as.vector(t(apply(nbTmp,
                                which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                function(x,...)
                            {
                                ifelse(all(is.na(x)), NA, mean(x,...))
                            }, na.rm=TRUE)))

    if ( ! isTRUE(all.equal(unitSp$nombre, nbTest))) stop("Probl�me dans le calcul des statistiques SVR !")

    ## nombre max :
    unitSp[ , "nombreMax"] <- as.vector(t(apply(nbTmp,
                                                which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                                function(x,...)
                                            {
                                                ifelse(all(is.na(x)), NA, max(x,...))
                                            }, na.rm=TRUE)))

    ## nombre SD :
    unitSp[ , "nombreSD"] <- as.vector(t(apply(nbTmp,
                                               which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                               function(x,...)
                                           {
                                               ifelse(all(is.na(x)), NA, sd(x,...))
                                           }, na.rm=TRUE)))

    ## densit� max :
    unitSp <- calc.density.SVR.f(Data=unitSp, obs=obs,
                                 metric=c("densiteMax", "densiteSD"))

    ## Biomasse max :
    unitSp <- stat.biomass.SVR.f(Data=unitSp, obs=obs,
                                 metric=c("biomasseMax", "biomasseSD"))

    return(unitSp)
}

########################################################################################################################
calc.unit.SVR.f <- function(unitSp, obs, refesp, unitobs, dataEnv,
                            colNombres="nombre")
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 23 d�c. 2011, 10:36

    ## Agr�gation des m�triques par d�faut :
    unit <- calc.unit.default.f(unitSp=unitSp, refesp=refesp, unitobs=unitobs, colNombres="nombre", dataEnv=dataEnv)

    ## Ajout des statistiques sur les rotations
    ## (calcul � partir des donn�es extrapol�es brutes pour les statistiques) :
    nbInterp <- get(".NombresSVR", envir=dataEnv)

    ## R�duction de la liste d'esp�ces si besoin (si s�lection sur les esp�ces) :
    if (dim(nbInterp)[names(dimnames(nbInterp)) == "code_espece"] > nlevels(unitSp[ , "code_espece"]))
    {
        species <- dimnames(nbInterp)[["code_espece"]]

        nbInterp <- extract(nbInterp,
                            indices=list(species[is.element(species,
                                                            levels(unitSp[ , "code_espece"]))]),
                            dims=which(is.element(names(dimnames(nbInterp)), "code_espece")))

    }else{}

    nbTmp <- apply(nbInterp,
                   which( ! is.element(names(dimnames(nbInterp)), c("classe_taille", "code_espece"))),
                   function(x,...)
               {
                   ifelse(all(is.na(x)), NA, sum(x,...))
               }, na.rm=TRUE)

    ## nombres calcul�s... pour comparaison avec nombres agr�g� uniquement :
    nbTest <- as.vector(t(apply(nbTmp,
                                which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                function(x,...)
                            {
                                ifelse(all(is.na(x)), NA, mean(x,...))
                            }, na.rm=TRUE)))

    if ( ! isTRUE(all.equal(unit$nombre, nbTest))) stop("Probl�me dans le calcul des statistiques SVR !")

    ## nombre max :
    unit[ , "nombreMax"] <- as.vector(t(apply(nbTmp,
                                              which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                              function(x,...)
                                          {
                                              ifelse(all(is.na(x)), NA, max(x,...))
                                          }, na.rm=TRUE)))

    ## nombre SD :
    unit[ , "nombreSD"] <- as.vector(t(apply(nbTmp,
                                             which( ! is.element(names(dimnames(nbTmp)), "rotation")),
                                             function(x,...)
                                         {
                                             ifelse(all(is.na(x)), NA, sd(x,...))
                                         }, na.rm=TRUE)))

    ## Densite max :
    unit <- calc.density.SVR.f(Data=unit, obs=obs,
                               metric=c("densiteMax", "densiteSD"),
                               factors="unite_observation")

    ## Biomasse max :
    unit <- stat.biomass.SVR.f(Data=unit, obs=obs,
                               metric=c("biomasseMax", "biomasseSD"),
                               factors="unite_observation")

    return(unit)
}




## ## tmp :
## names(dimnames(.dataEnv$.NombresSVR))
## [1] "unite_observation" "code_espece"       "classe_taille"
## [4] "rotation"

## nombre <- apply(.dataEnv$.NombresSVR, c(1, 2, 4), function(x,...){ifelse(all(is.na(x)), NA, sum(x,...))}, na.rm=TRUE)

## names(dimnames(nombre))
## [1] "unite_observation" "code_espece"       "rotation"

## nombre2 <- apply(nombre, c(1, 2), function(x,...){ifelse(all(is.na(x)), NA, mean(x,...))}, na.rm=TRUE)

## test2$nbcalc <- as.vector(t(nombre2))

## head(subset(test2[ , c(1:3, 10)], nbcalc > 0 & nombre > 0))


## ## unit :
## nombre <- apply(.dataEnv$.NombresSVR, c(1, 4), function(x,...){ifelse(all(is.na(x)), NA, sum(x,...))}, na.rm=TRUE)

## names(dimnames(nombre))

## nombre3 <- apply(nombre, c(1), function(x,...){ifelse(all(is.na(x)), NA, mean(x,...))}, na.rm=TRUE)

## test3$nbcalc <- as.vector(nombre3)

## head(subset(test3[ , c(1:2, ncol(test3))], nbcalc > 0 & nombre > 0))


### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
