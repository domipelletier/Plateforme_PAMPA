RestaurerDonnees.f <- function ()
{
    on.exit(winRaise.f(tm))

    runLog.f(msg=c("Restauration des donn�es originales :"))

    if (Jeuxdonnescoupe==1)
    {
        assign("obs", SAUVobs, envir=.GlobalEnv)
        assign("unitobs", SAUVunitobs, envir=.GlobalEnv)
        assign("contingence", SAUVcontingence, envir=.GlobalEnv)
        assign("unitesp", SAUVunitesp, envir=.GlobalEnv)
        assign("unit", SAUVunit, envir=.GlobalEnv)
        assign("listespunit", SAUVlistespunit, envir=.GlobalEnv)
        assign("TableBiodiv", SAUVTableBiodiv, envir=.GlobalEnv)
        assign("TableMetrique", SAUVTableMetrique, envir=.GlobalEnv)

        if (!is.benthos.f())               # unique(unitobs$type) != "LIT"
        {  # car pas de classes de tailles avec les recouvrements
            ## unitespta <- SAUVunitespta
            assign("unitespta", SAUVunitespta, envir=.GlobalEnv)
        }

        message("donn�es sauv�es r�initialis�es dans les tables de base")
        ModifierInterfaceApresRestore.f("Aucun", "Aucune")
        assign("Jeuxdonnescoupe", 0, envir=.GlobalEnv)

        gestionMSGinfo.f("Jeuxdedonnerestore", dim(obs)[1])
        tkmessageBox(message=paste("Jeu de donn�es restaur� \n", dim(obs)[1],
                                   "enregistrements dans la table observation"))
        message("Jeu de donn�es restaur�")
    }
}


## ################################################################################
## Nom    : SelectionUnCritereEsp.f()
## Objet  : ex�cution de la s�lection par critere, choix de la valeur de s�lection
## et �crasement des donn�es dans "obs"
## ################################################################################

SelectionUnCritereEsp.f <- function ()
{
    on.exit(winRaise.f(tm))

    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel esp�ces :"))

    selection <- UnCritereEspDansObs.f()
    assign("obs", obs <- selection[["obs"]], envir=.GlobalEnv)

    infoGeneral.f(msg="S�lection et recalcul selon un crit�re du r�f�rentiel esp�ces :",
                  font=tkfont.create(weight="bold", size=9), foreground="darkred")

    keptEspeces <- as.character(especes$code_espece[is.element(especes[ , selection[["facteur"]]],
                                                                     selection[["selection"]])])

    ## R�duction des tables de donn�es (au esp�ces s�lectionn�es) :
    if (exists("unitespta", envir=.GlobalEnv))
    {
        assign("unitespta",
               dropLevels.f(unitespta[is.element(unitespta$code_espece, keptEspeces), , drop=FALSE],
                            which="code_espece"),
               envir=.GlobalEnv)
    }else{}

    assign("unitesp",
           dropLevels.f(unitesp[is.element(unitesp$code_espece, keptEspeces), , drop=FALSE],
                        which="code_espece"),
           envir=.GlobalEnv)

    assign("listespunit",
           dropLevels.f(listespunit[is.element(listespunit$code_espece, keptEspeces), , drop=FALSE],
                        which="code_espece"),
           envir=.GlobalEnv)

    assign("contingence",
           contingence[ , is.element(colnames(contingence), keptEspeces), drop=FALSE],
           envir=.GlobalEnv)

    ## Recalcul des indices de biodiversit� :
    unit.f()

    ## Information de l'utilisateur :
    infoLoading.f(msg=paste("Les m�triques ont �t�",
                  " recalcul�es sur le jeu de donn�es s�lectionn�.",
                  sep=""),
                  icon="info",
                  font=tkfont.create(weight="bold", size=9))

    gestionMSGinfo.f("CalculSelectionFait")

    ## Recr�ation des tables de calcul :
    ## creationTablesBase.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f(paste(factesp[1], ":", paste(selectfactesp, collapse=", ")), dim(obs)[1])
    ## gestionMSGinfo.f("Critereselectionne", dim(obs)[1])

    infoLoading.f(button=TRUE)
}

## ################################################################################
## Nom    : SelectionUnCritereUnitobs.f()
## Objet  : ex�cution de la s�lection par critere, choix de la valeur de s�lection
## et �crasement des donn�es dans "obs"
## ################################################################################

SelectionUnCritereUnitobs.f <- function ()
{
    on.exit(winRaise.f(tm))

    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel des unit�s d'observation :"))

    selection <- UnCritereUnitobsDansObs.f()
    assign("obs", selection[["obs"]], envir=.GlobalEnv)

    infoGeneral.f(msg="S�lection et recalcul selon un crit�re du r�f�rentiel d'unit�s d'observation :",
                  font=tkfont.create(weight="bold", size=9), foreground="darkred")

    keptUnitobs <- as.character(unitobs$unite_observation[is.element(unitobs[ , selection[["facteur"]]],
                                                                     selection[["selection"]])])

    ## R�duction des tables de donn�es (au esp�ces s�lectionn�es) :
    if (exists("unitespta", envir=.GlobalEnv))
    {
        assign("unitespta",
               dropLevels.f(unitespta[is.element(unitespta$unite_observation,
                                                 keptUnitobs),
                                      , drop=FALSE],
                            which="unite_observation"),
               envir=.GlobalEnv)
    }else{}

    assign("unitesp",
           dropLevels.f(unitesp[is.element(unitesp$unite_observation,
                                           keptUnitobs),
                                , drop=FALSE],
                        which="unite_observation"),
           envir=.GlobalEnv)

    assign("listespunit",
           dropLevels.f(listespunit[is.element(listespunit$unite_observation,
                                               keptUnitobs),
                                    , drop=FALSE],
                        which="unite_observation"),
           envir=.GlobalEnv)

    assign("unit",
           dropLevels.f(unit[is.element(unit$unitobs,
                                        keptUnitobs),
                             , drop=FALSE],
                        which="unitobs"),
           envir=.GlobalEnv)

    assign("contingence",
           contingence[is.element(row.names(contingence),
                                  keptUnitobs),
                       , drop=FALSE],
           envir=.GlobalEnv)

    ## Information de l'utilisateur :
    infoLoading.f(msg=paste("Les m�triques ont �t�",
                  " recalcul�es sur le jeu de donn�es s�lectionn�.",
                  sep=""),
                  icon="info",
                  font=tkfont.create(weight="bold", size=9))

    gestionMSGinfo.f("CalculSelectionFait")

    ## Recr�ation des tables de calcul :
    ## creationTablesBase.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f(paste(fact[1], ":", paste(selectfactunitobs, collapse=", ")), dim(obs)[1])
    ## gestionMSGinfo.f("Critereselectionne", dim(obs)[1])

    infoLoading.f(button=TRUE)
}

