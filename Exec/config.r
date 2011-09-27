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
                               "\n\nVous devez �diter ce fichier",
                               "\n\t(ouvert automatiquement, ainsi que la sauvegarde si elle existe).",
                               sep=""),
                 icon="error")

    if (getOption("editor") != "")
    {
        file.edit(paste(basePath, "/Exec/config.r", sep=""), title="�ditez \"config.r\" (zone �ditable uniquement)")

        if (file.exists(fileTmp <- paste(basePath, "/Exec/config.bak.r", sep="")))
        {
            file.edit(fileTmp, title="Pr�c�dente sauvegarde de \"config.r\"")
        }else{}
    }else{
        shell.exec(paste(basePath, "/Exec/config.r", sep=""))

        if (file.exists(fileTmp <- paste(basePath, "/Exec/config.bak.r", sep="")))
        {
            shell.exec(fileTmp)
        }else{}
    }

    ## stop("Configuration incorrecte : relancez la plateforme une fois la configuration effectu�e.")

}else{
    pathMaker.f()

    assign("siteEtudie", SiteEtudie, envir=.GlobalEnv)
}



##################### Initialisation des variables globales ####################
Jeuxdonnescoupe <- 0
assign("Jeuxdonnescoupe", Jeuxdonnescoupe, envir=.GlobalEnv)

#### Logo :
fileimage <- "./Exec/img/pampa2.GIF"
assign("fileimage", fileimage, envir=.GlobalEnv)


## variables d'environnement pour l'interface
lang <- "FR"


########################################################################################################################
## Ajouts pour les graphs g�n�riques [yr: 13/08/2010] :

## Noms d'usage des variables des principales tables de donn�es
## (r�f�rentiels compris) :
assign("varNames",
       read.csv(paste(basePath, "/Exec/NomsVariables_fr.csv", sep=""),
                header=TRUE, row.names=1, stringsAsFactors=FALSE),
       envir=.GlobalEnv)

## Remplacer "/Exec/NomsVariables_fr.csv" par "/Exec/NomsVariables_en.csv" pour des axes et noms de variables en
## anglais.
## Affecte uniquement les sorties !

