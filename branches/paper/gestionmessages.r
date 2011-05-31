## le fichier gestionmessages.r a besoin du fichier config.r pour �tre execut�
## les passages � la ligne se font � la fin des messages
## on retourne encore � la ligne avant une erreur

gestionMSGerreur.f <- function (nameerror, variable)
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

    tkinsert(helpframe, "end", paste("\nERREUR : ", MSG, sep=""))
    tkyview.moveto(helpframe, 1)
}

gestionMSGaide.f <- function (namemsg)
{
    runLog.f(msg=c("Envoie d'un message d'aide dans l'interface :"))

    ## Message :
    MSG <-
        switch(namemsg,
               "ZeroEnregistrement"={
                   paste("! votre s�lection ne contient plus d'enregistrement",
                         ", veuillez restaurer ou recharger les donn�es (CTRL + a) !\n", sep="")
               },
               "etapeImport"={
                   paste("1 : Chargez les \"Dossiers et fichiers par d�faut\" (CTRL + a)\n",
                         "\t ou choisissez les dossier/fichiers un � un (CTRL + n).\n",
                         "\t (�galement accessibles par le menu \"Donn�es\")", sep="")
               },
               "SelectionOuTraitement"={
                   paste("2 : Vous pouvez restreindre votre s�lection de donn�es\n",
                         "\t (menu \"S�lection et recalcul\")\n",
                         "\t ou commencer les traitements standards.", sep="")
               },
               "startsansficher"={
                   paste("Si les fichiers par d�fauts param�tr�s dans 'config.r'- ", fileName1, " - ", fileName2, " - ",
                         fileName3, " ne sont pas les bons, Veuillez les modifier\n", sep="")
               },
               "etapeselected"={
                   paste("3 : Vous pouvez retrouver l'ensemble des observations en",
                         "\n\t* les restaurant : menu \"S�lection et recalcul\" ou bouton en bas � gauche.",
                         "\n\t* les rechargeant (CTRL + a)",
                         sep="")
               },
               "message � d�finir")

    tkinsert(helpframe, "end", paste("\nETAPE ", MSG, "", sep=""))
    tkyview.moveto(helpframe, 1)
}

gestionMSGinfo.f <- function (namemsg, parametrenum,...)
{
    runLog.f(msg=c("Envoie d'un message d'information dans l'interface :"))

    ## Message :
    MSG <-
        switch(namemsg,
               "plusieursAMP"={
                   paste("Votre fichier d'unit�s d'observation fait r�f�rence � plusieurs AMP!",
                         " Corrigez le et recommencez l'importation.\n", sep="")
               },
               "start"={
                   "Bienvenue sur l'interface TclTK de PAMPA\n"
               },
               "config"={
                   paste("Les fichiers par d�fauts param�tr�s dans 'config.r' sont :",
                         "\n    - ", fileName1,
                         "\n    - ", fileName2,
                         "\n    - ", fileName3, "\n", sep="")
               },
               "BasetxtCreate"={
                   paste("Les fichiers .csv:",
                         "\n         - Contingence",
                         "\n         - PlanEchantillonnage",
                         "\n         - M�triques par unit� d'observation (UnitobsMetriques.csv)",
                         "\n         - M�triques par unit� d'observation pour les esp�ces pr�sentes",
                         " (ListeEspecesUnitobs.csv)",
                         "\n         - M�triques par unit� d'observation / esp�ce (UnitobsEspeceMetriques.csv)",
                         "\n         - M�triques par unit� d'observation / esp�ce / classe de taille",
                         " (UnitobsEspeceClassetailleMetriques.csv)",
                         "\nont �t� cr��s\n", sep="")
               },
               "MSGnbgraphe"={
                   paste("Le nombre de cat�gories de votre graphique �tant trop important, celui ci a �t� d�coup� en ",
                         parametrenum, " parties\n")
               },
               "Familleselectionne"={
                   paste("Vous avez r�duit les observations � la famille ", fa,
                         " et ", parametrenum, " enregistrements\n")
               },
               "Phylumselectionne"={
                   paste("Vous avez r�duit les observations au phylum ", phy,
                         " et ", parametrenum, " enregistrements\n")
               },
               "Ordreselectionne"={
                   paste("Vous avez r�duit les observations � l'ordre ", ord,
                         " et ", parametrenum, " enregistrements\n")
               },
               "Classeselectionne"={
                   paste("Vous avez r�duit les observations � la classe ", cla,
                         " et ", parametrenum, " enregistrements\n")
               },
               "Biotopeselectionne"={
                   paste("Vous avez r�duit les observations biotope ", biotopechoisi, " et ", parametrenum,
                         " enregistrements\n")
               },
               "Statutselectionne"={
                   paste("Vous avez r�duit  les observations au statut ", statut, " et ", parametrenum,
                         " enregistrements\n")
               },
               "InfoRefSpeEnregistre"={
                   paste("Votre fichier d'information sur le r�f�rentiel esp�ce a �t� enregistr�",
                         " au format CSV\n dans le dossier de travail sous le nom", parametrenum, ".\n")
               },
               "InfoPDFdansFichierSortie"={
                   paste("Vos Fichiers regroupant tous les graphiques par esp�ce",
                         " pour une m�trique sont enregistr�s dans FichiersSortie.\n", sep="")
               },
               "AucunPDFdansFichierSortie"={
                   paste("Aucun type de graphes par esp�ce pour une m�trique n'est s�lectionn�.\n")
               },
               "Jeuxdedonnerestore"={
                   paste("Votre jeu de donn�es a �t� restaur� ainsi que les tables de m�triques originales",
                         " \nAttention, pour restaurer les CSV initiaux, vous devez r�importer les donn�es\n ",
                         parametrenum, " dans la table d'observation.\n", sep="")
               },
               "CalculSelectionFait"={
                   paste("Les m�triques par unit�s d'observations ont",
                         " �t� recalcul�es sur le jeu de donn�es s�lectionn�", sep="")
               },
               "CalculTotalFait"={
                   paste("Les m�triques par unit�s d'observations ont �t� calcul�es sur l'ensemble",
                         " du jeu de donn�es import�", sep="")
               },
               "message � d�finir")

    tkinsert(txt.w, "end", paste("\nINFO : ", MSG, sep=""))
    ## tkset(scr, 0.999, 1)     # pour activer l'acensseur : activate, cget, configure, delta, fraction, get, identify,
    ## or set.
    tkyview.moveto(txt.w, 1) # bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image,
                             # index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview.
}


