RestaurerDonnees.f <- function ()
{
    print("fonction RestaurerDonnees.f activ�e")
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

        print("donn�es sauv�es r�initialis�es dans les tables de base")
        ModifierInterfaceApresRestore.f("Aucun", "Aucune")
        Jeuxdonnescoupe <- 0
        gestionMSGinfo.f("Jeuxdedonnerestore", dim(obs)[1])
        tkmessageBox(message=paste("Jeu de donn�es restaur� \n", dim(obs)[1],
                                   "enregistrements dans la table observation"))
        print("Jeu de donn�es restaur�")
    }
}


## ################################################################################
## Nom    : SelectionUnCritereEsp.f()
## Objet  : ex�cution de la s�lection par critere, choix de la valeur de s�lection
## et �crasement des donn�es dans "obs"
## ################################################################################

SelectionUnCritereEsp.f <- function ()
{

    print("fonction SelectionUnCritere.f activ�e")
    obs <- UnCritereEspDansObs.f()
    assign("obs", obs, envir=.GlobalEnv)
    creationTablesBase.f()
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

    print("fonction SelectionUnCritereUnitobs.f activ�e")
    obs <- UnCritereUnitobsDansObs.f()
    assign("obs", obs, envir=.GlobalEnv)
    creationTablesBase.f()
    creationTablesCalcul.f()
    ModifierInterfaceApresSelection.f(paste(fact[1], ":", selectfactunitobs), dim(obs)[1])
    ## gestionMSGinfo.f("Critereselectionne", dim(obs)[1])
}

