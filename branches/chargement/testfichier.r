
## essais de rendre g�n�rique apr�s avec unitobs et obs
testfileref.f <- function ()
{
    runLog.f(msg=c("Informations sur le r�f�rentiel esp�ces :"))

    tclRequire("Tktable")
    ## D�claration des objets fenetre, tableau
    wintest <- tktoplevel(width = 100)
    tclarrayRefEsp <- tclArray()

    ## Fonctions activ�es par les boutons de la fen�tre
    FermerWinTest <- function ()
    {
        tkdestroy(wintest)
        winRaise.f(tm)
    }

    EnregistrerWinTest <- function ()
    {
        FichierCSV <- paste(NomDossierTravail, "Infos_", fileNameRefesp, ".csv", sep="")
        write.csv2(dataframeRefEsp, file=FichierCSV, row.names = FALSE)

        add.logFrame.f(msgID="InfoRefSpeEnregistre", env = .GlobalEnv, file=FichierCSV)
    }

    ## D�claration des objets bouton
    Fermer.but <- tkbutton(wintest, text="Fermer", command=FermerWinTest)
    Enregistrer.but <- tkbutton(wintest, text="Enregistrer en CSV", command=EnregistrerWinTest)

    ## S�lection des valeurs de la table esp�ces correspondant au jeux de donn�es
    matable <- "obs"
    objtable <- eval(parse(text=matable))

    espSite <- paste("Obs", siteEtudie, sep="")

    especes.select <- dropLevels.f(subset(especes,
                                            is.element(code_espece, levels(obs$code_espece))))

    ## Externaliser la d�finition des sites par la suite...
    listeSite <- c("RUN" , "MAY" , "BA" , "BO" , "CB" , "CR" , "STM" , "NC")

    ## Noms des sites dont on doit exclure les colonnes :
    sitesExclus <- listeSite[ ! grepl(pattern=paste("^", siteEtudie, "$", sep=""), x=listeSite)]

    ## champs ne correspondant pas au motif "(Site1|Site2|...)$" :
    champsSite <- colnames(especes.select)[! grepl(paste("(", paste(sitesExclus, collapse="|"), ")$", sep=""),
                                                   colnames(especes.select))]

    especes.select <- especes.select[ , champsSite]

    ## construction de l'objet dataframe
    dataframeRefEsp <- as.data.frame(names(especes))
    colnames(dataframeRefEsp)[1]="Nom_Champ"
    dataframeRefEsp[, 2]=""
    dataframeRefEsp[, 3]=""
    colnames(dataframeRefEsp)[2]="Nb_Valeurs"
    colnames(dataframeRefEsp)[3]="%_renseignement"

    ## construction de l'objet tableau
    tclarrayRefEsp[[0, 0]] <- "Champ #"
    tclarrayRefEsp[[0, 1]] <- "Nom"
    tclarrayRefEsp[[0, 2]] <- "Nb de valeurs"
    tclarrayRefEsp[[0, 3]] <- "% renseign�"

    for (nbChamp in (1:dim(especes.select)[2]))
    {
        ## Remplissage du tableau
        tclarrayRefEsp[[nbChamp, 0]] <- nbChamp
        tclarrayRefEsp[[nbChamp, 1]] <- names(especes.select)[nbChamp]
        tclarrayRefEsp[[nbChamp, 2]] <- sum(!is.na(especes.select[, nbChamp]))

        tclarrayRefEsp[[nbChamp, 3]] <-
            paste(round(sum(!is.na(especes.select[ , nbChamp])) /
                        nrow(especes.select) * 100, digits=2), "%")

        ## Remplissage du dataframe pour l'enregistrement
        dataframeRefEsp[nbChamp, 2] <- sum(!is.na(especes.select[, nbChamp]))
        dataframeRefEsp[nbChamp, 3] <-
            paste(round(sum(!is.na(especes.select[ , nbChamp])) /
                        nrow(especes.select) * 100, digits=2), "%")
    }

    ## construction de la fen�tre
    tkwm.title(wintest, paste("Informations sur ", fileNameRefesp))
    frameOverwintest <- tkframe(wintest)
    imgAsLabelwintest <- tklabel(frameOverwintest, image=imageAMP, bg="white")


    tkgrid(frameOverwintest, sticky="ew", columnspan=2)

    tkgrid(imgAsLabelwintest,
           tklabel(frameOverwintest,
                   text=paste("Taux de renseignement des champs de ", fileNameRefesp,
                              "\npour le jeu de donn�es (tient compte des s�lections)\n", fileNameObs), relief="groove", borderwidth=2,
                   bg="yellow", justify="left"),
           padx=5, sticky="e")

    tkgrid.configure(imgAsLabelwintest, sticky="w")

    ## tkgrid.configure(frameOverwintest, columnspan=1, column=1)
    tkgrid(tklabel(wintest, text=paste("Nombre de champs de ", fileNameRefesp, " : ", dim(especes.select)[2])),
           Enregistrer.but)

    tkgrid(tklabel(wintest,
                   text=paste("Nombre d'esp�ces r�f�renc�es pour ", siteEtudie, " : ",
                   nrow(subset(especes, especes[, espSite]=="oui")))))

    tkgrid(tklabel(wintest,
                   text=paste("Nombre d'esp�ces du jeux de donn�es ", fileNameObs, " : ",
                   length(unique(obs$code_espece)))), Fermer.but)

    tkgrid(tklabel(wintest,
                   text=paste(## "\nInformations sur les ", length(unique(obs$code_espece)),
                              ## "esp�ces \nDU JEU DE DONNEES ",
                              "\n\nVous pouvez copier-coller ce tableau dans Excel", sep="")))

    tableTestRefEsp <- tkwidget(wintest, "table",
                                variable=tclarrayRefEsp, rows=ncol(especes.select) + 1, cols=4,
                                colwidth=27, titlerows=1, titlecols=1, selectmode="extended", background="white",
                                xscrollcommand=function(...) {tkset(xscr, ...)},
                                yscrollcommand=function(...) {tkset(yscrtb, ...)})

    xscr <-tkscrollbar(wintest, orient="horizontal", command=function(...)tkxview(tableTestRefEsp, ...))
    yscrtb <- tkscrollbar(wintest, command=function(...)tkyview(tableTestRefEsp, ...))
    tkgrid(tableTestRefEsp, yscrtb, columnspan=3)
    tkgrid.configure(yscrtb, sticky="nsw")
    tkgrid(xscr, sticky="new", columnspan=3)

    tkconfigure(tableTestRefEsp, variable=tclarrayRefEsp, background="white", selectmode="extended",
                rowseparator="\"\n\"", colseparator="\"\t\"")

    tkgrid.configure(tableTestRefEsp, columnspan=2, sticky="w")
    ## barplot(dataframeRefEsp)
    tkfocus(wintest)
    winSmartPlace.f(wintest)
}
