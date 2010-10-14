## noms de fichiers utilis�s par le chargement automatique

########################################################################################################################
## Zone �ditable :

## ##########
## Exemple : faites de m�me avec vos jeux de donn�e (sans les commentaires -- "## " -- en d�but de ligne.)

## #### RUN :
## SiteEtudie <- "RUN"
## fileName1 <- "unitobspampaGCRMNpoisson-100810.txt"
## fileName2 <- "obspampaGCRMNpoisson-100810.txt"
## fileName3 <- "PAMPA-WP1-Meth-4-RefSpOM 110810.txt"
## nameWorkspace <- "C:/PAMPA"








## Fin de la zone �ditable
########################################################################################################################


#### Logo :
fileimage <- "./Exec/img/pampa2.GIF"


##################### Initialisation des variables globales ####################
## variables d'environnement pour les graphiques (couleurs et colonnes)
nbColMax <- 30
GraphPartMax <- 0.95
choixPDF <- 0
Jeuxdonnescoupe <- 0
## variables d'environnement pour l'interface
lang <- "FR"

pathMaker.f <- function()
{
    ## Purpose: Red�finir les chemins (par exemple apr�s changement du
    ##          dossier de travail)
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2010, 10:05
    assign("nameWorkspace", nameWorkspace, envir=.GlobalEnv)
    assign("NomDossierTravail", paste(nameWorkspace, "/FichiersSortie/", sep=""), envir=.GlobalEnv)
    assign("NomDossierData", paste(nameWorkspace, "/Data/", sep=""), envir=.GlobalEnv)   # sert a concat�ner les
                                        # variables fileNameUnitObs fileNameObs   fileNameRefEsp fileNameRefSpa
    assign("fileNameUnitObs", paste(NomDossierData, fileName1, sep=""), envir=.GlobalEnv)
    assign("fileNameObs", paste(NomDossierData, fileName2, sep=""), envir=.GlobalEnv)
    assign("fileNameRefEsp", paste(NomDossierData, fileName3, sep=""), envir=.GlobalEnv)
    ## assign("fileNameRefSpa", paste(NomDossierData, fileNameRefSpa, sep=""), envir=.GlobalEnv)
}

pathMaker.f()

assign("siteEtudie", SiteEtudie, envir=.GlobalEnv)
assign("fileimage", fileimage, envir=.GlobalEnv)
assign("Jeuxdonnescoupe", Jeuxdonnescoupe, envir=.GlobalEnv)

assign("nbColMax", nbColMax, envir=.GlobalEnv)
assign("GraphPartMax", GraphPartMax, envir=.GlobalEnv)

typePeche <- ""
assign("typePeche", typePeche)

########################################################################################################################
## Ajouts pour les graphs g�n�riques [yr: 13/08/2010] :

## Noms d'usage des variables des principales tables de donn�es (r�f�rentiels compris) :
assign("varNames", read.csv(paste(basePath, "/Exec/NomsVariables.csv", sep=""),
                            header=TRUE, row.names=1, stringsAsFactors=FALSE),
       envir=.GlobalEnv)


## ! cette variable sert visiblement � choisir le type de graphique. le code ci dessous est dupliqu� dans plusieurs fonctions
## !#on renomme densite en CPUE pour les jeux de donn�es p�che
## !if (length(typePeche)>1) {
## !   unit$CPUE <- unit$densite
## !   unit$densite = NULL
## ! }
