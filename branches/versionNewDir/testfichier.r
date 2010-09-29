
## V�rifie la pr�sence de caract�res list�s dans CaractereRecherche
testcaracteres.f <- function (dataframe, CaractereRecherche, nomdataframe)
{

    ## fonction cherchant   l e s   c  a r a c t � r e s
    print("fonction testcaracteres.f activ�e")
    listechamps <- "  * "

    if (length(colnames(dataframe[grep(CaractereRecherche, dataframe)]))>0)
    {
        TitreFichiers <- paste("LISTE DES CHAMPS DE ", nomdataframe, " contenant le caract�re \"", CaractereRecherche,
                               "\"\n******************\n\n", sep="")
        for (i in (1:length(colnames(dataframe[grep(CaractereRecherche, dataframe)]))))
        {
            listechamps <- paste(listechamps, " - ", colnames(dataframe[grep(CaractereRecherche, dataframe)])[i],
                                 sep="")
        }
        tkmessageBox(message=paste(TitreFichiers, listechamps))
        gestionMSGerreur.f("CaractereInterdit", nomdataframe)
        ## return(bilanFichiers)
    }
}


## testfichier
testdonnees.f <- function ()
{
    print("fonction testdonnees.f activ�e")
    ## liste des caract�res recherch�s
    MauvaisCaracteres <- c(";", " ", ",")
    for (j in 1:length(MauvaisCaracteres))
    {
        testcaracteres.f(unitobs, MauvaisCaracteres[j], "d'unit�s d'observation")
        testcaracteres.f(obs, MauvaisCaracteres[j], "d'observations")
        testcaracteres.f(especes, MauvaisCaracteres[j], "du r�f�rentiel esp�ces")
    }
    print("TEST des FICHIERS REALISE")
}

## essais de rendre g�n�rique apr�s avec unitobs et obs
testfileref.f <- function ()
{

    print("fonction testfileref.f activ�e")

    tclRequire("Tktable")
    ## D�claration des objets fenetre, tableau
    wintest <- tktoplevel(width = 100)
    tclarrayRefEsp <- tclArray()
    ## Fonctions activ�es par les boutons de la fen�tre
    FermerWinTest <- function ()
    {
        tkdestroy(wintest)
    }
    EnregistrerWinTest <- function ()
    {
        FichierCSV <- paste(NomDossierTravail, "Infos_", fileName3, ".csv", sep="")
        write.csv(dataframeRefEsp, file=FichierCSV, row.names = FALSE)
        gestionMSGinfo.f("InfoRefSpeEnregistre", FichierCSV)
        tkmessageBox(message="Votre fichier d'information sur le r�f�rentiel esp�ce a �t� enregistr� au format CSV dans le dossier de travail")
    }

    ## D�claration des objets bouton
    Fermer.but <- tkbutton(wintest, text="Fermer", command=FermerWinTest)
    Enregistrer.but <- tkbutton(wintest, text="Enregistrer en CSV", command=EnregistrerWinTest)

    ## S�lection des valeurs de la table esp�ces correspondant au jeux de donn�es
    matable <- "obs"
    objtable <- eval(parse(text=matable))
    ChampPresence <- paste("Obs", SiteEtudie, sep="")
    especesPresentes <- subset(especes, especes[, ChampPresence]=="oui")

    ## construction de l'objet dataframe
    dataframeRefEsp <- as.data.frame(names(especes))
    colnames(dataframeRefEsp)[1]="Nom_Champ"
    dataframeRefEsp[, 2]=""
    dataframeRefEsp[, 3]=""
    colnames(dataframeRefEsp)[2]="Nb_Valeurs"
    colnames(dataframeRefEsp)[3]="%_renseignement"

    ## construction de l'objet tableau
    tclarrayRefEsp[[0, 0]] <- "nb"
    tclarrayRefEsp[[0, 1]] <- "Nom"
    tclarrayRefEsp[[0, 2]] <- "nb valeurs"
    tclarrayRefEsp[[0, 3]] <- "Tx renseignement"

    for (nbChamp in (1:dim(especesPresentes)[2]))
    {
        ## Remplissage du tableau
        tclarrayRefEsp[[nbChamp, 0]] <- nbChamp
        tclarrayRefEsp[[nbChamp, 1]] <- names(especes[nbChamp])
        tclarrayRefEsp[[nbChamp, 2]] <- length(unique(especes[, nbChamp][match(obs$code_espece, especes$code_espece)],
                                                      na.rm=TRUE))
        tclarrayRefEsp[[nbChamp, 3]] <-
            paste(round(length(unique(especesPresentes$code_espece[!is.na(especesPresentes[, nbChamp])])) /
                        length(unique(especesPresentes$code_espece))*100, digits=2), "%")
        ## Remplissage du dataframe pour l'enregistrement
        dataframeRefEsp[nbChamp, 2] <- length(unique(especes[, nbChamp][match(obs$code_espece, especes$code_espece)],
                                                     na.rm=TRUE))
        dataframeRefEsp[nbChamp, 3] <-
            round(length(unique(especesPresentes$code_espece[!is.na(especesPresentes[, nbChamp])])) /
                  length(unique(especesPresentes$code_espece))*100, digits=2)
    }

    print(head(dataframeRefEsp))
    print(dim(tclarrayRefEsp[2]))
    ## print(head(dataframeRefEsp))

    ## construction de la fen�tre
    tkwm.title(wintest, paste("Informations sur ", fileName3))
    frameOverwintest <- tkframe(wintest)
    imgAsLabelwintest <- tklabel(wintest, image=imageAMP, bg="white")
    tkgrid(imgAsLabelwintest, frameOverwintest, sticky="w")
    tkgrid(tklabel(frameOverwintest, text=paste("Taux de renseignement des champs de ", fileName3,
                                     "\npour le jeu de donn�es\n", fileName2), relief="groove", borderwidth=2,
                   bg="yellow"))
    ## tkgrid.configure(frameOverwintest, columnspan=1, column=1)
    tkgrid(tklabel(wintest, text=paste("Nombre de champs de ", fileName3, " : ", dim(especesPresentes)[2])),
           Enregistrer.but)
    tkgrid(tklabel(wintest,
                   text=paste("Nombre d'esp�ces r�f�renc�es pour ", SiteEtudie, " : ", dim(especesPresentes)[1])))
    tkgrid(tklabel(wintest,
                   text=paste("Nombre d'esp�ces du jeux de donn�es ", fileName2, " : ",
                   length(unique(obs$code_espece)))), Fermer.but)
    tkgrid(tklabel(wintest,
                   text=paste("\nInformations sur les ", length(unique(obs$code_espece)),
                   "esp�ces \nDU JEU DE DONNEES \n\nVous pouvez copier-coller ce tableau dans Excel")))
    ## tclarrayRefEsp[[0, ]] <- c("Ann�e", "Type", "Fr�quence")
    ## tableTestRefEsp <- tkwidget(wintest, "table", variable=tclarrayRefEsp, rows=dim(especesPresentes)[1]+1, cols=4, titlerows=1, selectmode="extended", colwidth=25, background="white")
    ## largeurcol=c(3, 25, 25, 25)
    tableTestRefEsp <- tkwidget(wintest, "table", variable=tclarrayRefEsp, rows=dim(especesPresentes)[2]+1, cols=4,
                                colwidth=27, titlerows=1, titlecols=1, selectmode="extended", background="white",
                                xscrollcommand=function(...) {tkset(xscr, ...)}, yscrollcommand=function(...)
                                tkset(yscrtb, ...))
    xscr <-tkscrollbar(wintest, orient="horizontal", command=function(...)tkxview(tableTestRefEsp, ...))
    yscrtb <- tkscrollbar(wintest, command=function(...)tkyview(tableTestRefEsp, ...))
    tkgrid(tableTestRefEsp, yscrtb, columnspan=3)
    tkgrid.configure(yscrtb, sticky="nse")
    tkgrid(xscr, sticky="new")
    tkconfigure(tableTestRefEsp, variable=tclarrayRefEsp, background="white", selectmode="extended",
                rowseparator="\"\n\"", colseparator="\"\t\"")
    tkgrid.configure(tableTestRefEsp, columnspan=2, sticky="w")
    ## barplot(dataframeRefEsp)
    tkfocus(wintest)
    ## tkgrid.configure(button.widget1, column=0, sticky="w")
    ## TauxEspCritereSansNA <- round(length(unique(obsSansExtreme$code_espece[is.na(obsSansExtreme[, factesp])==TRUE]))/length(unique(obsSansExtreme$code_espece)), digits=2)
    ## tkgrid.configure(scr, rowspan=4, sticky="nsw")
    ## tkgrid.configure(sticky="w")
    ## tkwait.window(wintest)
}