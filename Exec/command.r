RestaurerDonnees.f <- function ()
{
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
        Jeuxdonnescoupe <- 0
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
    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel esp�ces :"))

    obs <- UnCritereEspDansObs.f()
    assign("obs", obs, envir=.GlobalEnv)

    ## R�duction des tables de donn�es (au esp�ces s�lectionn�es) :
    if (exists("unitespta", envir=.GlobalEnv))
    {
        assign("unitespta",
               dropLevels.f(unitespta[is.element(unitespta$code_espece, obs$code_espece), ],
                            which="code_espece"),
               envir=.GlobalEnv)
    }else{}

    assign("unitesp",
           dropLevels.f(unitesp[is.element(unitesp$code_espece, obs$code_espece), ],
                        which="code_espece"),
           envir=.GlobalEnv)

    assign("listespunit",
           dropLevels.f(listespunit[is.element(listespunit$code_espece, obs$code_espece), ],
                        which="code_espece"),
           envir=.GlobalEnv)

    assign("contingence",
           contingence[ , is.element(colnames(contingence), obs$code_espece)],
           envir=.GlobalEnv)

    ## Recalcul des indices de biodiversit� :
    unit.f()

    ## Information de l'utilisateur :
    infoLoading.f(msg=paste("Les m�triques ont �t�",
                  " recalcul�es sur le jeu de donn�es s�lectionn�.",
                  sep=""),
                  icon="info",
                  font=tkfont.create(weight="bold", size=9))

    infoLoading.f(button=TRUE)

    gestionMSGinfo.f("CalculSelectionFait")

    ## Recr�ation des tables de calcul :
    ## creationTablesBase.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f(paste(factesp[1], ":", selectfactesp), dim(obs)[1])
    ## gestionMSGinfo.f("Critereselectionne", dim(obs)[1])
}

## ################################################################################
## Nom    : SelectionUnCritereUnitobs.f()
## Objet  : ex�cution de la s�lection par critere, choix de la valeur de s�lection
## et �crasement des donn�es dans "obs"
## ################################################################################

SelectionUnCritereUnitobs.f <- function ()
{
    runLog.f(msg=c("S�lection des enregistrement selon un crit�re du r�f�rentiel des unit�s d'observation :"))

    obs <- UnCritereUnitobsDansObs.f()
    assign("obs", obs, envir=.GlobalEnv)

    ## R�duction des tables de donn�es (au esp�ces s�lectionn�es) :
    if (exists("unitespta", envir=.GlobalEnv))
    {
        assign("unitespta",
               dropLevels.f(unitespta[is.element(unitespta$unite_observation, obs$unite_observation), ],
                            which="unite_observation"),
               envir=.GlobalEnv)
    }else{}

    assign("unitesp",
           dropLevels.f(unitesp[is.element(unitesp$unite_observation, obs$unite_observation), ],
                        which="unite_observation"),
           envir=.GlobalEnv)

    assign("listespunit",
           dropLevels.f(listespunit[is.element(listespunit$unite_observation, obs$unite_observation), ],
                        which="unite_observation"),
           envir=.GlobalEnv)

    assign("unit",
           dropLevels.f(unit[is.element(unit$unitobs, obs$unite_observation), ],
                        which="unitobs"),
           envir=.GlobalEnv)

    assign("contingence",
           contingence[is.element(row.names(contingence), obs$unite_observation), ],
           envir=.GlobalEnv)

    ## Information de l'utilisateur :
    infoLoading.f(msg=paste("Les m�triques ont �t�",
                  " recalcul�es sur le jeu de donn�es s�lectionn�.",
                  sep=""),
                  icon="info",
                  font=tkfont.create(weight="bold", size=9))

    infoLoading.f(button=TRUE)

    gestionMSGinfo.f("CalculSelectionFait")

    ## Recr�ation des tables de calcul :
    ## creationTablesBase.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f(paste(fact[1], ":", selectfactunitobs), dim(obs)[1])
    ## gestionMSGinfo.f("Critereselectionne", dim(obs)[1])
}

