#-*- coding: latin-1 -*-
# Time-stamp: <2013-04-24 17:39:10 yves>

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2013 Ifremer - Tous droits r�serv�s.
##
##   Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
##   modifier suivant les termes de la "GNU General Public License" telle que
##   publi�e par la Free Software Foundation : soit la version 2 de cette
##   licence, soit (� votre gr�) toute version ult�rieure.
##
##   Ce programme est distribu� dans l'espoir qu'il vous sera utile, mais SANS
##   AUCUNE GARANTIE : sans m�me la garantie implicite de COMMERCIALISABILIT�
##   ni d'AD�QUATION � UN OBJECTIF PARTICULIER. Consultez la Licence G�n�rale
##   Publique GNU pour plus de d�tails.
##
##   Vous devriez avoir re�u une copie de la Licence G�n�rale Publique GNU avec
##   ce programme ; si ce n'est pas le cas, consultez :
##   <http://www.gnu.org/licenses/>.

## le fichier gestionmessages.r a besoin du fichier Config.R pour �tre execut�
## les passages � la ligne se font � la fin des messages
## on retourne encore � la ligne avant une erreur

gestionMSGerreur.f <- function (nameerror, variable, env=.GlobalEnv)
{
    runLog.f(msg=c("Envoie d'un message d'erreur dans l'interface :"))

    ## Message :
    MSG <-
        switch(nameerror,
               "recouvrementsansLIT"={
                   paste("Le champ obs$type n'est pas 'LIT', vous ne pouvez pas calculer",
                         " un % de recouvrement avec des esp�ces non benthiques\n", sep="")
               },
               "noWorkspace"={
                   "Aucun espace de travail n'est choisi ou op�rationnel\n"
               },
               "nbChampUnitobs"={
                   paste("Votre fichier 'Unites d'observation' ne comporte pas le bon nombre de champs!",
                         " Il devrait en contenir 35. Corrigez le et recommencez l'importation.\n", sep="")
               },
               "nbChampUnitobs"={
                   paste("Votre fichier 'Unites d'observation' ne comporte pas le bon nombre de champs!",
                         " Il devrait en contenir 35. Corrigez le et recommencez l'importation.\n", sep="")
               },
               "nbChampEsp"={
                   paste("Votre fichier 'r�f�rentiel esp�ces' ne comporte pas le bon nombre de champs!",
                         " Il devrait en contenir 124. Corrigez le et recommencez l'importation.\n", sep="")
               },
               "nbChampObs"={
                   paste("Votre fichier 'observations' ne comporte pas le bon nombre de champs!",
                         " Il devrait en contenir 11 . Corrigez le et recommencez l'importation.\n", sep="")
               },
               "UnitobsDsObsUnitobs"={
                   paste("Votre fichier 'observations' ne comporte pas les m�mes unitobs que votre fichier",
                         " 'Unites d'observation'. Corrigez les et recommencez l'importation.\n", sep="")
               },
               "CaractereInterditDsObs"={
                   "Votre fichier observations contient des \"&\". Corrigez les et recommencez l'importation.\n"
               },
               "CaractereInterditDsUnitObs"={
                   "Votre fichier unit�s d'observations contient des \".\" Corrigez les et recommencez l'importation.\n"
               },
               "ZeroEnregistrement"={
                   "Graphique impossible - pas d'enregistrements dans votre s�lection.\n"
               },
               "UneSeuleValeurRegroupement"={
                   "Graphique sans int�r�t - votre crit�re de regroupement n'a qu'une seule valeur.\n"
               },
               "CritereMalRenseigne50"={
                   paste("Graphique sans int�r�t - le crit�re de regroupement s�lectionn�",
                         " est renseign� pour moins de 50% des observations.\n", sep="")
               },
               "CaractereInterdit"={
                   paste("Votre table ", variable,
                         " contient des caract�res d�conseill�s par le r�f�rentiel des donn�es ('espaces',',',';' ",
                         "\n-> vous devez corriger le probl�me pour ne pas rencontrer d'erreurs.\n", sep="")
               },
               ## Message par d�faut :
               "message � renseigner")

    ## gestionMSGerreur.f(nbChampUnitobs)
    ## langue = EN

    tkinsert(get("helpframe", envir=env), "end", paste("\nERREUR : ", MSG, sep=""))
    tkyview.moveto(get("helpframe", envir=env), 1)
}

gestionMSGaide.f <- function (namemsg, env=.GlobalEnv)
{
    runLog.f(msg=c("Envoie d'un message d'aide dans l'interface :"))

    ## Message :
    MSG <-
        switch(namemsg,
               "ZeroEnregistrement"={
                   paste("Attention : votre s�lection ne contient plus d'enregistrement",
                         ", veuillez restaurer ou recharger les donn�es (CTRL + a) !\n", sep="")
               },
               "etapeImport"={
                   paste("  * charger les \"Dossiers et fichiers par d�faut\" (CTRL + a).",
                         "\n  * choisir les dossier/fichiers un � un (CTRL + n).",
                         "\n\t(actions �galement accessibles par le menu \"Donn�es\")",
                         sep="")
               },
               "SelectionOuTraitement"={
                   paste("  * restreindre votre s�lection de donn�es (menu \"S�lection et recalcul\").\n",
                         "  * commencer les traitements standards (graphiques & analyses statistiques).",
                         "\n", sep="")
               },
               ## "startsansficher"={
               ##     paste("Si les fichiers par d�fauts param�tr�s dans 'Config.R'- ", fileNameUnitobs, " - ",
               ##           fileNameObs, " - ",
               ##           fileNameRefesp, " ne sont pas les bons, Veuillez les modifier\n", sep="")
               ## },
               "etapeselected"={
                   paste("  * restaurer les donn�es originales (sans s�lection) :",
                         " menu \"S�lection et recalcul\" ou bouton ci-dessous � droite.",
                         "\n  * faire d'autres s�lections (imbriqu�es avec les s�lections courantes).",
                         "\n  * commencer les traitements standards (graphiques & analyses statistiques).",
                         sep="")
               },
               "message � d�finir")

    tkinsert(get("helpframe", envir=env), "end", paste("\n", MSG, "", sep=""))
    tkyview.moveto(get("helpframe", envir=env), 1)
}

########################################################################################################################
add.logFrame.f <- function(msgID, env=dataEnv,...)
{
    ## Purpose: Ajout de messages dans le cadre d'info sur les chargements
    ##          et s�lections.
    ## ----------------------------------------------------------------------
    ## Arguments: msgID : identifiant du type de message.
    ##            env : environnement o� est d�finit le cadre d'information
    ##                  (interface).
    ##            ... : arguments suppl�mentaires (dont l'existence est
    ##                  test�e en fonction du type de message choisi.)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 nov. 2011, 16:01

    ## On r�cup�re les arguments suppl�mentaires sous une forme facilement utilisable (list) :
    argsSup <- list(...)

    ## Traitement des diff�rents cas de message :
    msg <- switch(msgID,
                  "dataLoadingNew"={
                      if (any(!is.element("filePathes",
                                          names(argsSup))))
                      {
                          stop("Arguments incorrects !")
                      }else{
                          paste("",
                                paste(rep("=", 100), collapse=""),
                                paste("\nChargement de donn�es  (",
                                      format(Sys.time(), "%d/%m/%Y\t%H:%M:%S"),
                                      ")", sep=""),

                                paste("\n   Fichier d'observation :", argsSup$filePathes["obs"]),
                                paste("\n   Fichier d'unit�s d'observation :", argsSup$filePathes["unitobs"]),
                                paste("\n   Fichier du r�f�rentiel esp�ces :", argsSup$filePathes["refesp"]),
                                ifelse(is.na(argsSup$filePathes["refspa"]), "",
                                       paste("\n   Fichier du r�f�rentiel spatial :", argsSup$filePathes["refspa"])),
                                paste("\n   R�pertoire des r�sultats et des exports :", argsSup$filePathes["results"]),
                                "\n", sep="")
                      }
                  },
                  "restauration"={
                      paste("",
                            paste(rep("-", 80), collapse=""),
                            paste("Restauration des donn�es originales  (sans s�lection ; ",
                                  format(Sys.time(), "%d/%m/%Y\t%H:%M:%S"),
                                  ")", sep=""),
                            "\n", sep="\n")
                  },
                  "selection"={
                      if (any(!is.element(c("facteur", "selection", "results", "referentiel", "has.SzCl"),
                                          names(argsSup))))
                      {
                          stop("Arguments incorrects !")
                      }else{
                          paste("\n",
                                paste(rep("-", 100), collapse=""),
                                paste("\nS�lection des observations selon un crit�re",
                                      ifelse(argsSup$referentiel == "especes",
                                             " du r�f�rentiel esp�ces",
                                             " des unit�s d'observation"),
                                      " (",
                                      format(Sys.time(), "%d/%m/%Y\t%H:%M:%S"),
                                      ")", sep=""),
                                paste("\n\n   Facteur :", argsSup$facteur),
                                paste("\n   Modalit�s :",
                                      paste(argsSup$selection, collapse=", ")),
                                paste("\n\nFichiers export�s dans ", argsSup$results, " :", sep=""),
                                ifelse(isTRUE(argsSup$has.SzCl),
                                       paste("\n   - m�triques par unit� d'observation / esp. / cl. de taille :",
                                             "UnitobsEspeceClassetailleMetriques_selection.csv"),
                                       ""),
                                paste("\n   - m�triques par unit� d'observation / esp. :",
                                      "UnitobsEspeceMetriques_selection.csv"),
                                paste("\n   - m�triques par unit� d'observation :",
                                      "UnitobsMetriques_selection.csv"),
                                paste("\n   - plan d'�chantillonnage basique (ann�e - statut de protection) :",
                                      "PlanEchantillonnage_basique_selection.csv"),
                                "\n\n", sep="")
                      }
                  },
                  "fichiers"={
                      if (any(!is.element(c("results", "has.SzCl"),
                                          names(argsSup))))
                      {
                          stop("Arguments incorrects !")
                      }else{
                          paste("\n",
                                paste(rep("-", 100), collapse=""),
                                paste("\nFichiers export�s dans ", argsSup$results, sep=""),
                                paste("\n   (avant ", format(Sys.time(), "%d/%m/%Y\t%H:%M:%S"), ") :", sep=""),
                                ifelse(isTRUE(argsSup$has.SzCl),
                                       paste("\n   - m�triques par unit� d'observation / esp. / cl. de taille :",
                                             "UnitobsEspeceClassetailleMetriques.csv"),
                                       ""),
                                paste("\n   - m�triques par unit� d'observation / esp. :",
                                      "UnitobsEspeceMetriques.csv"),
                                paste("\n   - m�triques par unit� d'observation :",
                                      "UnitobsMetriques.csv"),
                                paste("\n   - plan d'�chantillonnage basique (ann�e - statut de protection) :",
                                      "PlanEchantillonnage_basique.csv"),
                                "\n\n", sep="")
                      }
                  },
                  "InfoRefSpeEnregistre"={
                      if (any(!is.element(c("file"),
                                          names(argsSup))))
                      {
                          stop("Arguments incorrects !")
                      }else{
                          paste("",
                                paste(rep("-", 100), collapse=""),
                                "Enregistrement des informations sur le r�f�rentiel esp�ce dans le fichier :",
                                paste("   ", argsSup$file, format(Sys.time(), "  (%d/%m/%Y\t%H:%M:%S)"), sep=""),
                                "\n", sep="\n")
                      }
                  },
                  "")

    ## Ajout du message :
    tkinsert(get("txt.w", envir=env), "end", msg)
    tkyview.moveto(get("txt.w", envir=env), 1)
}




