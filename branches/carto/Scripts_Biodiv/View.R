#-*- coding: latin-1 -*-
# Time-stamp: <2013-01-29 17:48:52 yves>

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

########################################################################################################################
Voirentableau <- function(Montclarray, title="", height=-1, width=-1, nrow=-1, ncol=-1, infos=title,
                          image)
{
    tclRequire("Tktable")

    tb <- tktoplevel()
    tkwm.title(tb, title)

    tkbind(tb, "<Destroy>",
           function()
       {
           ## winRaise.f(W.main)
       })

    ## Fonctions activ�es par les boutons de la fen�tre
    FermerWintb <- function()
    {
        tkdestroy(tb)
    }

    EnregistrerWintb <- function()
    {
        FichierCSV <- paste(NomDossierTravail, "Tableau_", title, ".csv", sep="")
        write.csv2(dataframetb, file=FichierCSV, row.names = FALSE)

        add.logFrame.f(msgID="InfoRefSpeEnregistre", env = .GlobalEnv, file=FichierCSV)
    }

    ## D�claration des objets bouton
    Fermer.but <- tkbutton(tb, text="Fermer", command=FermerWintb)
    Enregistrer.but <- tkbutton(tb, text="Enregistrer en CSV", command=EnregistrerWintb)

    ## ICI CONTINUER LA MISE EN FORME
    dataframetb <- data.frame(1:nrow)

    for (nbChamps in (1:nrow))          # Vectoriser ??? [yr: 27/07/2010]
    {
        for (nbCol in (1:ncol))
        {
            dataframetb[nbChamps, nbCol] <- "a remplir" # tclvalue(Montclarray[[nbCol, nbChamps]])
            ## A FINIR!!!
        }
    }

    ## �l�ments graphiques :
    frameOverwintb <- tkframe(tb)
    imgAsLabelwintb <- tklabel(frameOverwintb, image=image, bg="white")

    xscr <-tkscrollbar(tb, orient="horizontal", command=function(...)tkxview(tabletb,...))
    yscrtb <- tkscrollbar(tb, repeatinterval=3, command=function(...)tkyview(tabletb,...))

    tabletb <- tkwidget(tb, "table", rows=nrow, cols=ncol, titlerows=1, titlecols=0,
                        height=height+1, width=width+1, colwidth=23,
                        xscrollcommand=function(...) tkset(xscr,...),
                        yscrollcommand=function(...) tkset(yscrtb,...))

    ## ## Ne fonctionne pas [!!!] :
    ## tkbind(tabletb, "<MouseWheel>", function(...) tkyview(tabletb,...))
    ## tkbind(yscrtb, "<MouseWheel>", function(...) tkyview(tabletb,...))

    ## Placement des �l�ments :
    tkgrid(frameOverwintb, sticky="ew", columnspan=4)
    tkgrid(imgAsLabelwintb,
           tklabel(frameOverwintb, text=""),
           LB.titre <- tklabel(frameOverwintb, text=infos, relief="groove",
                               borderwidth=2, bg="yellow", justify="left"),
           padx=5, pady=5, sticky="nw")

    tkgrid.configure(LB.titre, sticky="new")

    tkgrid(tklabel(tb, text=paste("\n***", "\nVous pouvez copier-coller ce tableau dans Excel")))

    tkgrid(Enregistrer.but, Fermer.but, pady=5, padx=5)

    tkgrid(tabletb, yscrtb, columnspan=3, sticky="nsew")
    tkgrid.configure(yscrtb, sticky="nse")
    tkgrid(xscr, sticky="new", columnspan=2)

    tkconfigure(tabletb, variable=Montclarray, background="white", selectmode="extended", rowseparator="\"\n\"",
                colseparator="\"\t\"", titlerows=1,
                maxwidth=550)

    tkgrid.configure(tabletb, columnspan=2, sticky="w")

    tcl("update")
    ColAutoWidth.f(tabletb)
    RowAutoEight.f(tabletb)

    tcl("update")
    winSmartPlace.f(tb, xoffset=-30)

    return (tabletb)
}

########################################################################################################################
VoirPlanEchantillonnage.f <- function(dataEnv)
{
    runLog.f(msg=c("Affichage du plan d'�chantillonnage :"))

    resultsDir <- get("filePathes", envir=dataEnv)["results"]

    myRarrayPE <- read.csv2(paste(resultsDir,
                                  "PlanEchantillonnage_basique",
                                  ifelse(getOption("P.selection"), "_selection", ""),
                                  ".csv", sep=""),
                            row.names=1)

    tclarrayPE <- tclArray()
    ## tclarrayPE[[0, ]] <- c("Ann�e", "Type", "Fr�quence")

    tclarrayPE[[0, 0]] <- paste("\tStatut de protection ",
                                "\n  Ann�e\t\t\t", sep="")

    ## Remplissage du tableau tcl :
    for (i in (1:nrow(myRarrayPE)))
    {
        tclarrayPE[[i, 0]] <- row.names(myRarrayPE)[i]

        for (j in (1:ncol(myRarrayPE)))
        {
            if (i == 1)
            {
                tclarrayPE[[0, j]] <- colnames(myRarrayPE)[j]
            }else{}

            tclarrayPE[[i, j]] <- as.character(myRarrayPE[i, j])
        }
    }

    pe <- tktoplevel()
    tkwm.title(pe, "Plan d'�chantillonnage")
    tablePlanEch <- tkwidget(pe, "table", variable=tclarrayPE, rows=dim(myRarrayPE)[1]+1, cols=3,
                             titlerows=1, titlecol=1,
                             selectmode="extended", colwidth=30, background="white")


    tkpack(tablePlanEch)
    tcl("update")

    RowAutoEight.f(tablePlanEch)
    ColAutoWidth.f(tablePlanEch)

    tcl("update")
    winSmartPlace.f(pe)
}

########################################################################################################################
VoirInformationsDonneesEspeces.f <- function(dataEnv, image)
{

    unitSp <- get("unitSp", envir=dataEnv)
    refesp <- get("refesp", envir=dataEnv)
    unitobs <- get("unitobs", envir=dataEnv)
    nombres <- ifelse(is.benthos.f(), "colonie", getOption("P.nbName"))

    Nbesp <- length(unique(unitSp[ , "code_espece"]))

    tclarrayID <- tclArray()
    tclarrayID[[0, 0]] <- "Esp�ce"
    tclarrayID[[0, 1]] <- paste("Nb ", ifelse(is.benthos.f(), "colonies", "indiv"),
                                " min/unitobs", sep="")
    tclarrayID[[0, 2]] <- paste("Nb ", ifelse(is.benthos.f(), "colonies", "indiv"),
                                " max/unitobs", sep="")
    tclarrayID[[0, 3]] <- "Fr�quence d'occurrence"

    mini <- tapply(unitSp[ , nombres], unitSp[ , "code_espece"], min, na.rm=TRUE)
    maxi <- tapply(unitSp[ , nombres], unitSp[ , "code_espece"], max, na.rm=TRUE)

    nbunitobs <- nrow(unique(unitobs))
    pacha <- unitSp[, c("unite_observation", "code_espece", nombres, "pres_abs"), drop=FALSE]

    for (i in (1:Nbesp))
    {
        tclarrayID[[i, 0]] <- unique(as.character(unitSp[ , "code_espece"]))[i]
        tclarrayID[[i, 1]] <- mini[i]
        tclarrayID[[i, 2]] <- maxi[i]
        tclarrayID[[i, 3]] <-
            paste(round(length(pacha[(pacha[ , "pres_abs"] == 1 &
                                      pacha[ , "code_espece"] == unique(unitSp[ , "code_espece"])[i]),
                                     "unite_observation"]) /
                        length(pacha[pacha[ , "code_espece"] == unique(unitSp[ , "code_espece"])[i],
                                     "unite_observation"]) * 100,
                        digits=2), "%")
    }

    ## Pour informations sur le nombre d'esp�ces :
    tmp <- unique(cbind(pacha[ , "code_espece"],
                        refesp[match(pacha[ , "code_espece"], refesp[ , "code_espece"]),
                               c("Phylum", "espece")]))

    tableInfodonnees <- Voirentableau(tclarrayID,
                                      title="Informations par esp�ce",
                                      infos=paste("Informations par esp�ce :",
                                                  " \n\n\t* nombre de cat�gories observ�es = ", nrow(tmp),
                                                  " \n\t* nombre de cat�gories taxinomiques (biotiques) observ�es = ",
                                                  sum(!is.na(tmp[ , "Phylum"])),
                                                  " \n\t* nombre d'esp�ces observ�es = ",
                                                  sum(!is.na(tmp[ , "espece"]) & tmp[ , "espece"] != "sp."),
                                                  " \n\nCes informations tiennent compte des s�lections en cours.", sep=""),
                                      height=Nbesp, width=4, nrow=Nbesp + 1, ncol=4,
                                      image=image)
}#fin VoirInformationsDonneesEspeces

########################################################################################################################
VoirInformationsDonneesUnitobs.f <- function(dataEnv, image)
{
    obs <- get("obs", envir=dataEnv)
    unitobs <- get("unitobs", envir=dataEnv)
    unitSp <- get("unitSp", envir=dataEnv)
    nombres <- ifelse(is.benthos.f(), "colonie", getOption("P.nbName"))

    Nbunitobs <- nlevels(obs[ , "unite_observation"]) ## length(unique(unitobs[ , "unite_observation"]))

    tclarrayID <- tclArray()

    tclarrayID[[0, 0]] <- "Unit� d'observation"    #
    tclarrayID[[0, 1]] <- "Site"                   #
    tclarrayID[[0, 2]] <- "Biotope"                #
    tclarrayID[[0, 3]] <- "Nb \"esp�ces\""              #
    tclarrayID[[0, 4]] <- paste("Nb ",
                                ifelse(is.benthos.f(), "colonies", "indiv"),
                                " max/esp�ce", sep="")    #

    pacha <- unitSp[ , c("unite_observation", "code_espece", nombres, "pres_abs"), drop=FALSE]

    ## mini <- tapply(unitSp[ , nombres], unitSp[ , "unite_observation"], min, na.rm=TRUE) # [!!!]

    maxi <- tapply(unitSp[ , nombres], unitSp[ , "unite_observation"], max, na.rm=TRUE) # [!!!]

    for (i in (1:Nbunitobs))
    {
        tclarrayID[[i, 0]] <- levels(obs[ , "unite_observation"])[i]

        tclarrayID[[i, 1]] <- as.character(unitobs[(unitobs[ , "unite_observation"] ==
                                                    levels(obs[ , "unite_observation"])[i]),
                                                   "site"])

        tclarrayID[[i, 2]] <- as.character(unitobs[(unitobs[ , "unite_observation"] ==
                                                    levels(obs[ , "unite_observation"])[i]),
                                                   "biotope"])
        tclarrayID[[i, 3]] <-                                                                        #
            length(pacha[(pacha[ , "pres_abs"]==1 &
                          pacha[ , "unite_observation"] == levels(obs[ , "unite_observation"])[i]),
                         "code_espece"])

        tclarrayID[[i, 4]] <- maxi[i]
    }

    tableInfodonnees <- Voirentableau(tclarrayID,
                                      title="Informations par unitobs",
                                      infos=paste("Informations par unit� d'observation :",
                                                  "\n\n! tiennent compte des s�lections en cours.",
                                                  sep=""),
                                      height=Nbunitobs, width=5, nrow=Nbunitobs + 1, ncol=5,
                                      image=image)
}


