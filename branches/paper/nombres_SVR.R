#-*- coding: latin-1 -*-

### File: nombres_SVR.R
### Time-stamp: <2011-08-09 18:31:08 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Calculs deqs nombres pour les donn�es vid�os rotatives.
####################################################################################################

statRotation.basic.f <- function(facteurs)
{
    ## Purpose: Calcul des statistiques des abondances (max, sd) par rotation
    ##          en se basant sur des interpolations basiques.
    ## ----------------------------------------------------------------------
    ## Arguments: facteurs : vecteur des noms de facteurs d'agr�gation
    ##                       (r�solution � laquelle on travaille).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 d�c. 2010, 10:01

    ## Identification des secteurs et rotations valides :
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
    ## Ajouter les interpolations [!!!][SVR]
    nombresR <- tapply(obs$nombre,
                       as.list(obs[ , c(facteurs, "rotation"), drop=FALSE]),
                       function(x,...){ifelse(all(is.na(x)), NA, sum(x,...))},
                       na.rm = TRUE)

    ## Nombres de secteurs valides / rotation (au m�me format que nombresR) :
    nombresSecVal <- tapply(obs$sec.valides,
                            as.list(obs[ , c(facteurs, "rotation"), drop=FALSE]),
                            mean, na.rm = TRUE)

    ## Correction des nombres (r�gle de trois) :
    nombresR <- nombresR * max(nombresSecVal, na.rm=TRUE) / nombresSecVal

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

    if (!is.element("classe_taille", facteurs))
    {
        ## Pour les calculs agr�g�s par unitobs :
        tmpNombresSVR <- apply(nombresR,
                               which(names(dimnames(nombresR)) != "code_espece"),
                               sum, na.rm=TRUE)

        tmpNombresSVR[!rotations] <- NA

        assign(".NombresSVR", tmpNombresSVR, envir=.GlobalEnv)
        assign(".Rotations", rotations, envir=.GlobalEnv)
    }else{}

    ## Retour des r�sultats sous forme de liste :
    return(list(nombresMean=nombresMean, nombresMax=nombresMax, nombresSD=nombresSD,
                nombresRotations=nombresRotations))
}

########################################################################################################################
interpSecteurs.f <- function(sectUnitobs)
{
    ## Purpose: Interpolation des valeurs pour les secteurs non valides
    ##          (rotations valides seulement ; interpolations �tendues)
    ##          en trois �tapes :
    ##            1) interpolation sur le m�me secteur d'apr�s les autres
    ##               rotations.
    ##            2) interpolation sur les secteurs adjacents de la m�me
    ##               rotation.
    ##            3) moyenne sur la roatation pour les secteurs qui ne
    ##               peuvent �tre interpol�s avec les deux premi�res �tapes.
    ## ----------------------------------------------------------------------
    ## Arguments: sectUnitobs : matrice des secteurs de l'unit�
    ##                          d'observation, avec les secteurs en colonnes
    ##                          et les rotations en lignes.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 nov. 2010, 14:52


    ## On ne travaille que sur les rotations valides (i.e. ayant au moins un secteur valide) :
    idx <- apply(sectUnitobs, 1, function(x)!all(is.na(x)))

    tmp <- sectUnitobs[idx, , drop=FALSE]

    ## �tape 1 : interpolation sur le m�me secteur dans les autres rotations :
    tmp <- matrix(apply(tmp, 2, function(x)
                    {
                        x[which(is.na(x))] <- mean(x, na.rm=TRUE)
                        return(x)
                    }), ncol=ncol(tmp))

    ## �tape 2 : interpolation sur les secteurs adjacents de la m�me rotation :
    if (any(is.na(tmp)))
    {
        tmp <- t(apply(tmp,
                       1,
                       function(x)
                   {
                       xi <- which(is.na(x))
                       x[xi] <- sapply(xi,
                                       function(i, x){mean(x[i + c(0, 2)], na.rm=TRUE)},
                                       x=c(tail(x, 1), x, head(x, 1)))
                       return(x)
                   }))

        if (any(is.na(tmp)))
        {
            ## �tape 3 : moyenne de la rotation sinon :
            tmp <- t(apply(tmp, 1,
                           function(x)
                       {
                           x[which(is.na(x))] <- mean(x, na.rm=TRUE)
                           return(x)
                       }))
        }else{}
    }else{}



    ## R�cup�ration dans le tableau d'origine :
    sectUnitobs[idx, ] <- tmp
    ## sectUnitobs <- as.array(sectUnitobs)

    if (any(dim(sectUnitobs) != c(3, 6))) print(sectUnitobs)


    return(sectUnitobs)
}

########################################################################################################################
statRotation.extended.f <- function(facteurs)
{
    ## Purpose: Calcul des statistiques des abondances (max, sd) par
    ##          rotation, en utilisant des interpolations �tendues.
    ## ----------------------------------------------------------------------
    ## Arguments: facteurs : vecteur des noms de facteurs d'agr�gation
    ##                       (r�solution � laquelle on travaille).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 nov. 2010, 09:25

    ## Identification des secteurs et rotations valides :
    if (is.element("unite_observation", facteurs))
    {
        ## Secteurs valides (les vides doivent tout de m�me �tre renseign�s) :
        secteurs <- tapply(obs$secteur,
                           as.list(obs[ , c("unite_observation", "rotation", "secteur"), drop=FALSE]),
                           function(x)length(x) > 0)

        ## Les secteurs non renseign�s apparaissent en NA et on veut FALSE :
        secteurs[is.na(secteurs)] <- FALSE

        ## Rotations valides :
        rotations <- apply(secteurs, c(1, 2), any) # Au moins un secteur renseign�.

    }else{
        stop("\n\tL'unit� d'observation doit faire partie des facteurs d'agr�gation !!\n")
    }

    ## ###########################################################
    ## Nombres par rotation avec le niveau d'agr�gation souhait� :
    ## Ajouter les interpolations [!!!][SVR]
    nombresRS <- tapply(obs$nombre,
                        as.list(obs[ , c(facteurs, "rotation", "secteur"), drop=FALSE]),
                        sum, na.rm = TRUE)

    tmp <- apply(nombresRS,
                 which(is.element(names(dimnames(nombresRS)), facteurs)),
                 interpSecteurs.f)

    ## On r�cup�re les dimensions d'origine (r�sultats de la fonction dans 1 vecteur ; attention, plus le m�me ordre) :
    dim(tmp) <- c(tail(dim(nombresRS), 2), head(dim(nombresRS), -2))

    ## On renomme les dimensions avec leur nom d'origine en tenant compte du nouvel ordre :
    dimnames(tmp) <- dimnames(nombresRS)[c(tail(seq_along(dimnames(nombresRS)), 2),
                                           head(seq_along(dimnames(nombresRS)), -2))]

    ## On restocke le tout dans nombresRS (attentions, toujours travailler sur les noms de dimensions)
    nombresRS <- tmp


    ## Les NAs sont consid�r�s comme des vrais z�ros lorsque la rotation est valide :
    nombresRS <- sweep(nombresRS,
                       match(names(dimnames(secteurs)), names(dimnames(nombresRS)), nomatch=NULL),
                       secteurs,        # Tableau des secteurs valides (bool�ens).
                       function(x, y)
                   {
                       x[is.na(x) & y] <- 0 # Lorsque NA et secteur valide => 0.
                       return(x)
                   })


    nombresR <- apply(nombresRS,
                      which(is.element(names(dimnames(nombresRS)), c(facteurs, "rotation"))),
                      function(x){ifelse(all(is.na(x)), NA, sum(x, na.rm=TRUE))})



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

    ## Retour des r�sultats sous forme de liste :
    return(list(nombresMean=nombresMean, nombresMax=nombresMax, nombresSD=nombresSD,
                nombresRotations=nombresRotations))
}







### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
