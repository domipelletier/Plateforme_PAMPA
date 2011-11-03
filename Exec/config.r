## noms de fichiers utilis�s par le chargement automatique

########################################################################################################################
## Zone �ditable :

## #########################################################################################################
## Exemple : faites de m�me avec vos jeux de donn�e (sans les commentaires -- "## " -- en d�but de ligne.) :

## #### RUN :
## siteEtudie <- "RUN"
## fileName1 <- "unitobspampaGCRMNpoisson-100810.txt"
## fileName2 <- "obspampaGCRMNpoisson-100810.txt"
## fileName3 <- "PAMPA-WP1-Meth-4-RefSpOM 110810.txt"
## nameWorkspace <- "C:/PAMPA"




     ######################################
     ### Copiez votre configuration ici ###
     ######################################





## Fin de la zone �ditable
########################################################################################################################

pathMaker.f <- function(nameWorkspace, fileName1, fileName2, fileName3)
{
    ## Purpose: Red�finir les chemins (par exemple apr�s changement du
    ##          dossier de travail)
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2010, 10:05

    ## browser()

    assign("nameWorkspace", nameWorkspace, envir=.GlobalEnv)
    assign("fileName1", fileName1, envir=.GlobalEnv)
    assign("fileName2", fileName2, envir=.GlobalEnv)
    assign("fileName3", fileName3, envir=.GlobalEnv)

    assign("NomDossierTravail", paste(nameWorkspace, "/FichiersSortie/", sep=""), envir=.GlobalEnv)
    assign("NomDossierData", paste(nameWorkspace, "/Data/", sep=""), envir=.GlobalEnv)   # sert a concat�ner les
                                        # variables fileNameUnitObs fileNameObs   fileNameRefEsp fileNameRefSpa
    assign("fileNameUnitObs", paste(NomDossierData, fileName1, sep=""), envir=.GlobalEnv)
    assign("fileNameObs", paste(NomDossierData, fileName2, sep=""), envir=.GlobalEnv)
    assign("fileNameRefEsp", paste(NomDossierData, fileName3, sep=""), envir=.GlobalEnv)
    ## assign("fileNameRefSpa", paste(NomDossierData, fileNameRefSpa, sep=""), envir=.GlobalEnv)
}

## V�rification de l'existances de la configuration :
requiredVar <- c(## "siteEtudie",
                 "fileName1", "fileName2", "fileName3", "nameWorkspace")
existVar <- sapply(requiredVar, exists)

if (any(! existVar))                    # Si au moins une des variables n'est pas d�finie.
{
    pluriel <- sum(! existVar) > 1

    ## Demande pour l'ouverture du fichier de configuration :
    if(tclvalue(tkmessageBox(message=paste(ifelse(pluriel,
                                           "Les variables suivantes ne sont pas d�finies ",
                                           "La variable suivante n'est pas d�finie "),
                                           "dans votre fichier \"", basePath, "/Exec/config.r\" :\n\n\t*  ",
                                           paste(requiredVar[! existVar], collapse="\n\t*  "),
                                           "\n\nVoulez-vous �diter ce fichier ?",
                                           "\n\t(ouverture automatiquement de la sauvegarde �galement, si elle existe).",
                                           sep=""),
                             icon="warning", type="yesno", title="Configuration imcompl�te",
                             default="no")) == "yes")
    {
        shell.exec(paste(basePath, "/Exec/config.r", sep=""))

        if (file.exists(fileTmp <- paste(basePath, "/Exec/config.bak.r", sep="")))
        {
            shell.exec(fileTmp)
        }else{}
    }else{}
}else{
    pathMaker.f(nameWorkspace=nameWorkspace,
                fileName1=fileName1,
                fileName2=fileName2,
                fileName3=fileName3)
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

