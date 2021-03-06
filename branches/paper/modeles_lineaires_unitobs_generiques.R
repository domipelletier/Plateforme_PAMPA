#-*- coding: latin-1 -*-

### File: modeles_lineaires_unitobs_generiques.R
### Time-stamp: <2011-05-12 13:47:22 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Mod�les lin�aires pour les donn�es agr�g�es par unitobs (toutes esp�ces, �ventuellement
### s�lectionn�es selon un crit�re du r�f�rentiel).
####################################################################################################


########################################################################################################################
modeleLineaireWP2.unitobs.f <- function(metrique, factAna, factAnaSel, listFact, listFactSel, tableMetrique)
{
    ## Purpose: Gestions des diff�rentes �tapes des mod�les lin�aires.
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : la m�trique choisie.
    ##            factAna : le facteur de s�paration des graphiques.
    ##            factAnaSel : la s�lection de modalit�s pour ce dernier
    ##            listFact : liste du (des) facteur(s) de regroupement
    ##            listFactSel : liste des modalit�s s�lectionn�es pour ce(s)
    ##                          dernier(s)
    ##            tableMetrique : nom de la table de m�triques.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 18 ao�t 2010, 15:59

    ## Nettoyage des facteurs (l'interface de s�lection produit des valeurs vides) :
    listFactSel <- listFactSel[unlist(listFact) != ""]
    ## listFactSel <- listFactSel[length(listFactSel):1]

    listFact <- listFact[unlist(listFact) != ""]
    ## listFact <- listFact[length(listFact):1]

    ## Concat�nation
    facteurs <- c(factAna, unlist(listFact)) # Concat�nation des facteurs

    selections <- c(list(factAnaSel), listFactSel) # Concat�nation des leurs listes de modalit�s s�lectionn�es

    ## Donn�es pour la s�rie d'analyses :
    if (tableMetrique == "TableBiodiv")
    {
        ## Pour les indices de biodiversit�, il faut travailler sur les nombres... :
        tmpData <- subsetToutesTables.f(metrique="nombre", facteurs=facteurs,
                                        selections=selections, tableMetrique="listespunit",
                                        exclude = NULL, add=c("unite_observation", "code_espece"))
    }else{
        ## ...sinon sur la m�trique choisie :
        tmpData <- subsetToutesTables.f(metrique=metrique, facteurs=facteurs, selections=selections,
                                        tableMetrique=tableMetrique, exclude = NULL,
                                        add=c("unite_observation", "code_espece"))
    }

    ## Identification des diff�rents lots d'analyses � faire:
    if (factAna == "")                # Pas de facteur de s�paration des graphiques.
    {
        iFactGraphSel <- ""
    }else{
        if (is.na(factAnaSel[1]))            # Toutes les modalit�s.
        {
            iFactGraphSel <- unique(as.character(sort(tmpData[ , factAna])))
        }else{                              # Modalit�s s�lectionn�es (et pr�sentes parmi les donn�es retenues).
            iFactGraphSel <- factAnaSel[is.element(factAnaSel, tmpData[ , factAna])]
        }
    }

    ## Formules pour diff�rents mod�les (avec ou sans transformation log) :
    exprML <- eval(parse(text=paste(metrique, "~", paste(listFact, collapse=" * "))))
    logExprML <- eval(parse(text=paste("log(", metrique, ") ~", paste(listFact, collapse=" * "))))

    ## Agr�gation des observations / unit� d'observation :
    if (tableMetrique == "unitespta" && factAna != "classe_taille")
    {
        tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                       metrique=metrique,
                                                       facteurs=c("unite_observation", "classe_taille"),
                                                       listFact=listFact))
    }else{
        if (tableMetrique == "TableBiodiv")
        {
            ## Calcul des indices de biodiversit� sur s�lection d'esp�ces :
            tmp <- calcBiodiv.f(Data=tmpData,
                                unitobs = "unite_observation", code.especes = "code_espece",
                                nombres = "nombre",
                                indices=metrique)

            ## On rajoute les anciennes colonnes :
            tmpData <- cbind(tmp,
                             tmpData[match(tmp$unite_observation, tmpData$unite_observation),
                                     !is.element(colnames(tmpData), colnames(tmp))])

            ## On garde le strict minimum :
            tmpData <- tmpData[ , is.element(colnames(tmpData), c(metrique, facteurs))]
        }else{
            tmpData <- na.omit(agregationTableParCritere.f(Data=tmpData,
                                                           metrique=metrique,
                                                           facteurs=c("unite_observation"),
                                                           listFact=listFact))
        }
    }

    ## Sauvegarde temporaire des donn�es utilis�es pour les analyses (attention : �cras�e � chaque nouvelle s�rie de
    ## graphiques) :
    DataBackup <<- list(tmpData)


    ## Suppression des 'levels' non utilis�s :
    tmpData <- dropLevels.f(tmpData)

    ## Aide au choix du type d'analyse :
    if (metrique == "pres_abs")
    {
        loiChoisie <- "BI"
    }else{
        loiChoisie <- choixDistri.f(metrique=metrique, Data=tmpData[ , metrique, drop=FALSE])
    }

    if (!is.null(loiChoisie))
    {
        message("Loi de distribution choisie = ", loiChoisie)

        if (is.element(loiChoisie, c("LOGNO")))
        {
            Log <- TRUE
            formule <- logExprML
        }else{
            Log <- FALSE
            formule <- exprML
        }

        res <- calcLM.f(loiChoisie=loiChoisie, formule=formule, metrique=metrique, Data=tmpData)

        ## �criture des r�sultats format�s dans un fichier :
        tryCatch(sortiesLM.f(objLM=res, formule=formule, metrique=metrique,
                             factAna=factAna, modSel=iFactGraphSel, listFact=listFact,
                             Data=tmpData, Log=Log,
                             type=ifelse(tableMetrique == "unitespta" && factAna != "classe_taille",
                                         "CL_unitobs",
                                         "unitobs")),
                 error=errorLog.f)

        resid.out <- boxplot(residuals(res), plot=FALSE)$out

        if (length(resid.out))
        {
            suppr <- supprimeObs.f(residus=resid.out)

            if(!is.null(suppr))
            {
                if (!is.numeric(suppr)) # conversion en num�ros de lignes lorsque ce sont des noms :
                {
                    suppr <- which(is.element(row.names(tmpData), suppr))
                }else{}

                tmpData <- tmpData[ - suppr, ]
                res.red <- calcLM.f(loiChoisie=loiChoisie, formule=formule, metrique=metrique, Data=tmpData)

                resLM.red <<- res.red

                tryCatch(sortiesLM.f(objLM=res.red, formule=formule, metrique=metrique,
                                     factAna=factAna, modSel=iFactGraphSel, listFact=listFact,
                                     Data=tmpData, Log=Log, sufixe="(red)", type="unitobs"),
                         error=errorLog.f)
            }else{}

        }else{}


    }else{
        message("Annul� !")
    }
}






### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
