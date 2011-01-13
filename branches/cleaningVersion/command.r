RestaurerDonnees.f <- function ()
{
    print("fonction RestaurerDonnees.f activ�e")
    if (Jeuxdonnescoupe==1)
    {
        ## obs <- SAUVobs
        ## unitobs <- SAUVunitobs
        ## contingence <- SAUVcontingence
        ## unitesp <- SAUVunitesp
        ## unit <- SAUVunit
        assign("obs", SAUVobs, envir=.GlobalEnv)
        assign("unitobs", SAUVunitobs, envir=.GlobalEnv)
        assign("contingence", SAUVcontingence, envir=.GlobalEnv)
        assign("unitesp", SAUVunitesp, envir=.GlobalEnv)
        assign("unit", SAUVunit, envir=.GlobalEnv)
        assign("TablePresAbs", SAUVTablePresAbs, envir=.GlobalEnv)
        assign("listespunit", SAUVlistespunit, envir=.GlobalEnv)
        assign("TableBiodiv", SAUVTableBiodiv, envir=.GlobalEnv)
        assign("TableMetrique", SAUVTableMetrique, envir=.GlobalEnv)

        if (!is.benthos.f())               # unique(unitobs$type) != "LIT"
        {  # car pas de classes de tailles avec les recouvrements
            ## unitespta <- SAUVunitespta
            assign("unitespta", SAUVunitespta, envir=.GlobalEnv)
        }
        ## si SVR calcul des metriques par rotation
        if (unique(unitobs$type) == "SVR")
        {
            ## unitesptar <- SAUVunitesptar
            ## unitespr <- SAUVunitespr
            ## unitr <- SAUVunitr
            assign("unitesptar", SAUVunitesptar, envir=.GlobalEnv)
            assign("unitespr", SAUVunitespr, envir=.GlobalEnv)
            assign("unitr", SAUVunitr, envir=.GlobalEnv)
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


## ################################################################################
## Nom    : benthosUneEspece.f()
## Objet  : ex�cution des fonctions ChoixUneEspece.f et ___.f
                                        #A FINIR
## ################################################################################
## [sup] [yr: 13/01/2011]:
## benthosUneEspece.f <- function ()
## {
##     ChoixUneEspece.f()
## } # fin

## ################################################################################
## Nom    : changerUnitobs.f()      changerObservations.f
## Objet  :
## ################################################################################

## [sup] [yr: 13/01/2011]:

## changerUnitobs.f <- function ()
## {
##     tkmessageBox(message="Choisissez tout d'abord votre fichier unit�s d'observation")
##     openUnitobs.f()
##     tkmessageBox(message="Choisissez ensuite votre fichier d'observations")
##     openObservations.f()
##     tkmessageBox(message="assurez vous que le r�f�rentiel utilis� soit adapt� � votre fichier d'observations")
##     opendefault.f()
##     ## message : les fichiers source sont tous recharg�s
## }

## [sup] [yr: 13/01/2011]:

## changerObservations.f <- function ()
## {
##     ## on ne se sert plus de cette fonction car lorsque l'on change unitobs, on change aussi obs en m�me temps
##     openObservations.f()
##     opendefault.f()
##     ## message : les fichiers source sont tous recharg�s
## }

## [sup] [yr: 13/01/2011]:

## changerListespeces.f <- function ()
## {
##     openListespeces.f()
##     opendefault.f()
##     ## message : les fichiers source sont tous recharg�s
## }

## ################################################################################
## Nom    : unFacteur.f()
## Objet  : ex�cution des fonctions choixUnFacteur.f, grp1.f, graph1.f et
##          occurrence.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## unfacteur.f <- function ()
## {
##     print("fonction unfacteur.f activ�e")
##     choixunfacteurUnitobs.f()
##     grp1.f(fact)
##     graph1.f(fact)
##     occurrence.f(fact)
## } #fin unfacteur.f

## ################################################################################
## Nom    : unf.f()
## Objet  : ex�cution des fonctions choixUnFacteur.f et gra1.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## unf.f <- function ()
## {
##     choixunfacteurUnitobs.f()
##     gra1.f(fact)
## }

## ################################################################################
## Nom    : deuxf.f()
## Objet  : ex�cution des fonctions choixdeuxFacteurs.f et gra2.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## deuxf.f <- function ()
## {
##     ChoixUneEspece.f()
##     choixDeuxFacteursUnitobs.f()
##     gra2.f(fact21, fact22)
## }

## ################################################################################
## Nom    : troisf.f()
## Objet  : ex�cution des fonctions choixtroisFacteurs.f et gra3.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## troisf.f <- function ()
## {
##     choixtroisfacteurs.f ()
##     gra3.f (fact31, fact32, fact33)
## }

## ################################################################################
## Nom    : deuxFacteur.f()
## Objet  : ex�cution des fonctions choixDeuxFacteur.f, grp2f.f,
##          graph2.f et occurrence2.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## deuxfacteur.f <- function ()
## {
##     choixDeuxFacteursUnitobs.f()
##     grp2f.f(fact21, fact22)
##     graph2.f(fact21, fact22)
##     occurrence2.f(fact21, fact22)
## } # fin deuxfacteur.f

## ################################################################################
## Nom    : troisFacteur.f()
## Objet  : ex�cution des fonctions choixtroisFacteur.f, grp3f.f, graph3.f et
##          occurrence3.f
## ################################################################################

## [sup] [yr: 13/01/2011]:

## troisfacteur.f <- function ()
## {
##     choixtroisfacteurs.f()
##     grp3f.f(fact31, fact32, fact33)
##     graph3.f(fact31, fact32, fact33)
##     occurrence3.f(fact31, fact32, fact33)
## } # fin troisfacteur.f
