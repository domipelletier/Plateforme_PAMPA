## noms de fichiers utilis�s par le chargement automatique

########################################################################################################################
## Zone �ditable :

## #########################################################################################################
## Exemple : faites de m�me avec vos jeux de donn�e (sans les commentaires -- "## " -- en d�but de ligne.) :

## #### RUN :
## SiteEtudie <- "RUN"
## fileName1 <- "unitobspampaGCRMNpoisson-100810.txt"
## fileName2 <- "obspampaGCRMNpoisson-100810.txt"
## fileName3 <- "PAMPA-WP1-Meth-4-RefSpOM 110810.txt"
## nameWorkspace <- "C:/PAMPA"




     ######################################
     ### Copiez votre configuration ici ###
     ######################################





## Fin de la zone �ditable
########################################################################################################################

## Type de p�che.
typePeche <- c("")

## V�rification de l'existances de la configuration :
requiredVar <- c("SiteEtudie", "fileName1", "fileName2", "fileName3", "nameWorkspace")
existVar <- sapply(requiredVar, exists)

if (any(! existVar))                    # Si au moins une des variables n'est pas d�finie.
{
    pluriel <- sum(! existVar) > 1

    tkmessageBox(message=paste(ifelse(pluriel,
                                      "Les variables suivantes ne sont pas d�finies ",
                                      "La variable suivante n'est pas d�finie "),
                               "dans votre fichier \"", basePath, "/Exec/config.r\" :\n\n\t*  ",
                               paste(requiredVar[! existVar], collapse="\n\t*  "),
                               "\n\nVous devez �diter le fichier.", sep=""),
                 icon="error")

    if (getOption("editor") != "")
    {
        file.edit(paste(basePath, "/Exec/config.r", sep=""), title="�ditez \"config.r\" (zone �ditable uniquement)")
    }else{}

    stop("Configuration incorrecte : relancez la plateforme une fois la configuration effectu�e.")

}else{}

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

assign("typePeche", typePeche)
## ! cette variable sert visiblement � choisir le type de graphique. le code ci dessous est dupliqu� dans plusieurs fonctions
## !#on renomme densite en CPUE pour les jeux de donn�es p�che
## !if (length(typePeche)>1) {
## !   unit$CPUE <- unit$densite
## !   unit$densite = NULL
## ! }


assign("siteEtudie", SiteEtudie, envir=.GlobalEnv)
assign("fileimage", fileimage, envir=.GlobalEnv)
assign("Jeuxdonnescoupe", Jeuxdonnescoupe, envir=.GlobalEnv)

assign("nbColMax", nbColMax, envir=.GlobalEnv)
assign("GraphPartMax", GraphPartMax, envir=.GlobalEnv)

########################################################################################################################
## Ajouts pour les graphs g�n�riques [yr: 13/08/2010] :

## Noms d'usage des variables des principales tables de donn�es (r�f�rentiels compris) :
assign("varNames", read.csv(paste(basePath, "/Exec/NomsVariables.csv", sep=""),
                            header=TRUE, row.names=1, stringsAsFactors=FALSE),
       envir=.GlobalEnv)

