## le fichier gestionmessages.r a besoin du fichier config.r pour �tre execut�
## les passages � la ligne se font � la fin des messages
## on retourne encore � la ligne avant une erreur

gestionMSGerreur.f <- function (nameerror, variable)
{

    print("fonction gestionMSGerreur.f activ�e")

    ## langue = FR
    ## [!!!]: utiliser un switch � la place !!
    if (nameerror=="recouvrementsansLIT")
    {
        MGS <- "Le champs obs$type n'est pas 'LIT', vous ne pouvez pas calculer un % de recouvrement avec des esp�ces non benthiques\n"
    }
    if (nameerror=="noWorkspace")
    {
        MGS <- "Aucun espace de travail n'est choisi ou op�rationnel\n"
    }
    if (nameerror=="nbChampUnitobs")
    {
        MGS <- "Votre fichier 'Unites d'observation' ne comporte pas le bon nombre de champs! Il devrait en contenir 35. Corrigez le et recommencez l'importation.\n"
    }
    if (nameerror=="nbChampEsp")
    {
        MGS <- "Votre fichier 'r�f�rentiel esp�ces' ne comporte pas le bon nombre de champs! Il devrait en contenir 124. Corrigez le et recommencez l'importation.\n"
    }
    if (nameerror=="nbChampObs")
    {
        MGS <- "Votre fichier 'observations' ne comporte pas le bon nombre de champs! Il devrait en contenir 11 . Corrigez le et recommencez l'importation.\n"
    }
    if (nameerror=="UnitobsDsObsUnitobs")
    {
        MGS <- "Votre fichier 'observations' ne comporte pas les m�mes unitobs que votre fichier 'Unites d'observation'. Corrigez les et recommencez l'importation.\n"
    }
    if (nameerror=="CaractereInterditDsObs")
    {
        MGS <- "Votre fichier observations contient des "&". Corrigez les et recommencez l'importation.\n"
    }
    if (nameerror=="CaractereInterditDsUnitObs")
    {
        MGS <- "Votre fichier unit�s d'observations contient des . Corrigez les et recommencez l'importation.\n"
    }
    if (nameerror=="ZeroEnregistrement")
    {
        MGS <- "Graphique impossible - pas d'enregistrements dans votre s�lection.\n"
    }
    if (nameerror=="UneSeuleValeurRegroupement")
    {
        MGS <- "Graphique sans int�r�t - votre crit�re de regroupement n'a qu'une seule valeur.\n"
    }
    if (nameerror=="CritereMalRenseigne50")
    {
        MGS <- "Graphique sans int�r�t - le crit�re de regroupement s�lectionn� est renseign� pour moins de 50% des observations.\n"
    }
    if (nameerror=="CaractereInterdit")
    {
        MGS <- paste("Votre table", variable,
                     " contient des caract�res non d�conseill�s par le r�f�rentiel des donn�es ('espaces',',',';' ",
                     "\n-> vous devez corriger le probl�me pour ne pas rencontrer d'erreurs.\n")
    }
                                        # "non d�conseill�s" ? [yreecht: 21/07/2010]


    ## gestionMSGerreur.f(nbChampUnitobs)
    ## langue = EN

    tkinsert(helpframe, "end", paste("\nERROR : ", MGS, sep=""))
    tkyview.moveto(helpframe, 1)
}

## [sup] [yr: 13/01/2011]:

## gestionMSGmenus.f <- function (namemenu)
## {
## }

gestionMSGaide.f <- function (namemsg)
{

    print("fonction gestionMSGaide.f activ�e")

    MGS <- "message � renseigner"

    if (namemsg=="ZeroEnregistrement")
    {
        MGS <- "! votre s�lection ne contient plus d'enregistrement, veuillez recharger les donn�es (CTRL + A)"
    }
    if (namemsg=="etapeImport")
    {
        MGS <- "1 Choisissez c:/PAMPA comme dossier d'importation et de travail \n ou importez vos fichiers un � un"
    }
    if (namemsg=="SelectionOuTraitement")
    {
        MGS <- "2 Vous pouvez restreindre votre s�lection de donn�es \n ou commencer les traitements standards"
    }
    if (namemsg=="startsansficher")
    {
        MGS <- paste("Si les fichiers par d�fauts param�tr�s dans 'config.r'- ", fileName1, " - ", fileName2, " - ",
                     fileName3, " ne sont pas les bons, Veuillez les modifier", sep="")
    }
    if (namemsg=="etapeselected")
    {
        MGS <- "3 Vous pouvez retrouver l'ensemble des observations en les rechargeant (CTRL+A)"
    }

    tkinsert(helpframe, "end", paste("ETAPE : ", MGS, "\n", sep=""))
    tkyview.moveto(helpframe, 1)
}

gestionMSGinfo.f <- function (namemsg, parametrenum,...)
{
    print("fonction gestionMSGinfo.f activ�e")

    MGS <- "message � renseigner"

    if (namemsg=="plusieursAMP")
    {
        MGS <- "Votre fichier unit�s d'observations fait r�f�rence � plusieurs AMP! Corrigez les et recommencez l'importation.\n"
    }
    if (namemsg=="start")
    {
        MGS <- "Bienvenue sur l'interface TclTK de PAMPA\n"
    }
    if (namemsg=="config")
    {
        MGS <- paste("Les fichiers par d�fauts param�tr�s dans 'config.r' sont :
    - ", fileName1, "
    - ", fileName2, "
    - ", fileName3, "\n", sep="")
    }

    if (namemsg=="BasetxtCreate")
    {
        MGS <- "Les fichiers .csv:
         - Contingence
         - PlanEchantillonnage
         - Metriques par unite d observation (UnitobsMetriques.csv)
         - Metriques par unite d observation pour les especes presentes (ListeEspecesUnitobs.csv)
         - Metriques par unite d observation / espece (UnitobsEspeceMetriques.csv)
         - Metriques par unite d observation / espece / classe de taille (UnitobsEspeceClassetailleMetriques.csv )
         ont ete crees\n"
    }
    if (namemsg=="MSGnbgraphe")
    {
        MGS <- paste("Le nombre de cath�gories de votre graphique �tant trop important, celui ci a �t� d�coup� en ",
                     parametrenum, " parties\n")
    }
    if (namemsg=="Familleselectionne")
    {
        MGS <- paste("Vous avez r�duit les obsertations � la famille ", fa, " et ", parametrenum, " enregistrements\n")
    }
    if (namemsg=="Phylumselectionne")
    {
        MGS <- paste("Vous avez r�duit les obsertations au phylum ", phy, " et ", parametrenum, " enregistrements\n")
    }
    if (namemsg=="Ordreselectionne")
    {
        MGS <- paste("Vous avez r�duit les obsertations � l'ordre ", ord, " et ", parametrenum, " enregistrements\n")
    }
    if (namemsg=="Classeselectionne")
    {
        MGS <- paste("Vous avez r�duit les obsertations � la classe ", cla, " et ", parametrenum, " enregistrements\n")
    }
    if (namemsg=="Biotopeselectionne")
    {
        MGS <- paste("Vous avez r�duit les obsertations biotope ", biotopechoisi, " et ", parametrenum,
                     " enregistrements\n")
    }
    if (namemsg=="Statutselectionne")
    {
        MGS <- paste("Vous avez r�duit  les obsertations au statut ", statut, " et ", parametrenum,
                     " enregistrements\n")
    }
    if (namemsg=="CatBenthselectionne")
    {
        MGS <- paste("Vous avez r�duit  les obsertations � la categorie benthique ", selectcb, " et ", parametrenum,
                     " enregistrements\n", sep="")
    }
    if (namemsg=="InfoRefSpeEnregistre")
    {
        MGS <- paste("Votre fichier d'information sur le r�f�rentiel esp�ce a �t� enregistr�",
                     " au format CSV\n dans le dossier de travail sous le nom", parametrenum, ".\n")
    }
    if (namemsg=="InfoPDFdansFichierSortie")
    {
        MGS <- paste("Vos Fichier regroupant tous les graphes par esp�ce",
                     " pour une m�trique sont enregistr�s dans FichiersSortie.\n", sep="")
    }
    if (namemsg=="AucunPDFdansFichierSortie")
    {
        MGS <- paste("Aucun type de graphes par esp�ce pour une m�trique n'est s�lectionn�.\n")
    }
    if (namemsg=="Jeuxdedonnerestore")
    {
        MGS <- paste("Votre jeux de donn�es a �t� restaur� ainsi que les tables de m�triques originales",
                     " \nAttention, pour restaurer les CSV initiaux, vous devez r�importer les donn�es\n ",
                     parametrenum, " dans la table d'observation.\n", sep="")
    }
    if (namemsg=="CalculSelectionFait")
    {
        MGS <- paste("Les m�triques par unit�s d'observations ont �t� recalcul�es sur le jeu de donn�es s�lectionn�s")
    }
    if (namemsg=="CalculTotalFait")
    {
        MGS <- paste("Les m�triques par unit�s d'observations ont �t� calcul�es sur l'ensemble",
                     " du jeu de donn�es import�", sep="")
    }
    tkinsert(txt.w, "end", paste("INFO : ", MGS, sep=""))
    ## tkset(scr, 0.999, 1)     # pour activer l'acensseur : activate, cget, configure, delta, fraction, get, identify,
    ## or set.
    tkyview.moveto(txt.w, 1) # bbox, cget, compare, configure, count, debug, delete, dlineinfo, dump, edit, get, image,
                             # index, insert, mark, peer, replace, scan, search, see, tag, window, xview, or yview.
}

## [sup] [yr: 13/01/2011]:

## gestionMSGchoix <- function(title, question, valeurdef, Largeurchamp=5, returnValOnCancel="ID_CANCEL")
## {
##     print("fonction gestionMSGchoix.f activ�e")
##     dlg <- tktoplevel()
##     tkwm.deiconify(dlg)
##     tkgrab.set(dlg)
##     tkfocus(dlg)
##     tkwm.title(dlg, title)
##     MSGchoixVarTcl <- tclVar(paste(valeurdef))
##     MSGchoixWidget <- tkentry(dlg, width=paste(Largeurchamp), textvariable=MSGchoixVarTcl)
##     tkgrid(tklabel(dlg, text="       "))
##     tkgrid(tklabel(dlg, text=question), MSGchoixWidget)
##     tkgrid(tklabel(dlg, text="       "))
##     ReturnVal <- returnValOnCancel
##     onOK <- function()
##     {
##         ReturnVal <<- tclvalue(MSGchoixVarTcl)
##         tkgrab.release(dlg)
##         tkdestroy(dlg)
##         tkfocus(tm)
##     }
##     onCancel <- function()
##     {
##         ReturnVal <<- returnValOnCancel
##         tkgrab.release(dlg)
##         tkdestroy(dlg)
##         tkfocus(tm)
##     }
##     OK.but     <-tkbutton(dlg, text="   OK   ", command=onOK)
##     Cancel.but <-tkbutton(dlg, text=" Cancel ", command=onCancel)
##     tkgrid(OK.but, Cancel.but)
##     tkgrid(tklabel(dlg, text="    "))

##     tkfocus(dlg)
##     tkbind(dlg, "<Destroy>", function() {tkgrab.release(dlg);tkfocus(tm)})
##     tkbind(MSGchoixWidget, "<Return>", onOK)
##     tkwait.window(dlg)

##     return(ReturnVal)
## }

## [sup] [yr: 13/01/2011]:

## aide.f <- function()
## {

##     require(tcltk) || stop("Package tcltk is not available.") # Add path to BWidgets
##     addTclPath(".")
##     version.BWidget <<- tclvalue(tclRequire("BWidget"))

##     print("fonction aide.f activ�e")
##     tmaide <- tktoplevel()
##     tkwm.title(tmaide, "aide de l'utilisateur de l'interface PAMPA")
##     tn <- tkwidget(tmaide, "ttk::notebook")
##     tkgrid(tn, sticky="news")

##     tbn <- tclvalue(tkadd(tn, label="1"))
##     tkgrid(tbw <- .Tk.newwin(tbn))
##     tkgrid(fr <- tkframe(tbw))
##     tkgrid(lb <- tklabel(fr, text=paste("This is tab", "1")))
##     ID <- paste(tn$ID, evalq(num.subwin <- num.subwin+1, tn$env), sep=".")
##     win <- .Tk.newwin(ID)
##     assign(ID, tbw, envir = tn$env)
##     assign("parent", tn, envir = tbw$env)

##     tbn <- tclvalue(tkadd(tn, label="2"))
##     tkgrid(tbw <- .Tk.newwin(tbn))
##     tkgrid(fr <- tkframe(tbw))
##     tkgrid(lb <- tklabel(fr, text=paste("This is tab", "2")))

##     ## list(tbw, fr, lb) # return all three in case you need them later
## }

## tcl(tn, "raise", "text2")

## gestion des doubles et triples regroupement impossibles pour chaque champ
