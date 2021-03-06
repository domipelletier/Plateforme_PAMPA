################################################################################
# Nom               : InterfaceFonctions.r
# Type              : Programme
# Objet             : Fonctions diverses directement li�es � la gestion des 
#                     diff�rentes interfaces  (aspect, position, etc.)C
# Input             : aucun
# Output            : lancement de fonctions
# Auteur            : Elodie Gamp & Yves Reecht
# R version         : 2.11.1
# Date de cr�ation  : Mai 2011
# Sources
################################################################################


########################################################################################################################
winSmartPlace.f <- function(win, xoffset=0, yoffset=0)
{
    ## Purpose: Placement "intelligent" des fen�tres (centr�es en fonction de
    ##          leur taille) + apparaissent au premier plan.
    ## ----------------------------------------------------------------------
    ## Arguments: win : un objet de la classe tktoplevel
    ##            xoffset : d�calage horizontal (pixels)
    ##            yoffset : d�calage vertical (pixels)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2010, 14:14

    if (! is.tkwin(win))
    {
        warning("Non mais c'est quoi ce programmeur qui essaye de d�placer des non-fen�tres ?!")
    }else{
        if (! as.logical(as.integer(tclvalue(tkwinfo("exists", win)))))
        {
            warning("Tentative de d�placer une fen�tre d�j� d�truite !")
        }else{
            ## Largeur de la fen�tre :
            width <- as.integer(tclvalue(tkwinfo("width", win)))
            ## Hauteur de la fen�tre :
            height <- as.integer(tclvalue(tkwinfo("height", win)))
            ## calcul du d�calage horizontal :
            x <- as.integer((as.numeric(tclvalue(tkwinfo("screenwidth", win))) - width) / 2) + as.integer(xoffset)
            ## ... et du d�calage vertical :
            y <- as.integer((as.numeric(tclvalue(tkwinfo("screenheight", win))) - 60 # pour tenir compte de la barre de
                                        # tache g�n�ralement en bas.
                             - height) / 2) + as.integer(yoffset)

            ## print(tkwm.geometry(win))
            ## configuration de la nouvelle g�om�trie :
            tkwm.geometry(win, paste(width, "x", height, "+", x, "+", y, sep=""))
            tkwm.geometry(win, "")      # pour conserver le redimentionnement automatique.

            ## print(paste(width, "x", height, "+", x, "+", y, sep=""))

            ## Mettre la fen�tre au premier plan :
            tkwm.deiconify(win)
        }
    }
}


########################################################################################################################
winRaise.f <- function(win)
{
    ## Purpose: Remettre une fen�tre au premier plan
    ## ----------------------------------------------------------------------
    ## Arguments: win : un objet de la classe tktoplevel
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 28 sept. 2010, 16:41

    if (! is.tkwin(win))
    {
        warning("Non mais c'est quoi ce programmeur qui essaye de d�placer des non-fen�tres ?!")
    }else{
        if (! as.logical(as.integer(tclvalue(tkwinfo("exists", win)))))
        {
            warning("Tentative de d�placer une fen�tre d�j� d�truite !")
        }else{
            ## Mettre la fen�tre au premier plan :
            tkwm.deiconify(win)
        }
    }
}


########################################################################################################################
quitConfirm.f <- function(win)
{
    ## Purpose: Confirmer avant de quitter le programme (ou une fen�tre
    ##          quelconque).
    ## ----------------------------------------------------------------------
    ## Arguments: win : l'objet fen�tre.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 19 janv. 2011, 11:47

    Done <- tclVar("0")
    WinConfirm <- tktoplevel()

    tkwm.title(WinConfirm, "Confirmation...")

    ## Boutons :
    OK.but <- tkbutton(WinConfirm, text = "   Oui   ",
                       command = function() tclvalue(Done) <- 1)

    All.but <- tkbutton(WinConfirm, text = " Oui + R ",
                        command = function() tclvalue(Done) <- 2)

    Cancel.but <- tkbutton(WinConfirm, text = "   Non   ",
                           command = function() tclvalue(Done) <- 3)

    ## Placement des �l�ments graphiques :

    tkgrid(tklabel(WinConfirm, text="\n "), row=1)

    ## Question sensible au contexte (� am�liorer) :
    tkgrid(tklabel(WinConfirm, text=ifelse(win$ID == ".1",
                                           "Voulez vous vraiment quitter le programme ?",
                                           "Voulez vous vraiment fermer cette fen�tre ?")),
           row=1, column=1, columnspan=3)

    tkgrid(tklabel(WinConfirm, text=" "), row=1, column=4)

    tkgrid(tklabel(WinConfirm, text=" \n"), row=3)
    tkgrid(OK.but, row=3, column=1, padx=4)
    tkgrid(All.but, row=3, column=2, padx=4)
    tkgrid(Cancel.but, row=3, column=3, padx=4)

    ## Configuration :
    tkbind(WinConfirm, "<Destroy>", function() tclvalue(Done) <- 3)

    tcl("update")

    winSmartPlace.f(WinConfirm)         # placement de la fen�tre.
    tkfocus(Cancel.but)

    ## Attente d'une action de l'utilisateur :
    tkwait.variable(Done)

    ## Stockage de la valeur obtenue :
    doneVal <- tclvalue(Done)           # n�cessaire pour �viter d'avoir syst�matiquement "2" apr�s destruction
                                        # automatique de la fen�tre.

    ## Destruction automatique de la fen�tre :
    tkdestroy(WinConfirm)

    ## Si c'est le souhait de l'utilisateur, destruction de la fen�tre :
    if (doneVal == "1" || doneVal == "2")
    {
        tkdestroy(win)
        if (doneVal == "2")
        {
            q()
        }else{}
    }else{}
}


########################################################################################################################
infoGeneral.f <- function(msg,...)
{
    ## Purpose: Afficher un cadre g�n�ral dans la fen�tre d'info.
    ## ----------------------------------------------------------------------
    ## Arguments: msg : message.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 16 f�vr. 2011, 15:10

    ## Environnement de stockage des infos
    if (! exists(".InfoLoading", envir=.GlobalEnv))
    {
        assign(".InfoLoading", environment(), envir=.GlobalEnv)
    }else{
        .InfoLoading <- get(".InfoLoading", envir=.GlobalEnv)
    }

    ## Fen�tre graphique :
    if (! exists("WinInfoLoading", envir=.InfoLoading, inherits=FALSE) ||
         ! as.numeric(tclvalue(tkwinfo("exists",
                                       ## Assignation simultann�e dans l'environnement courant (pour le cas o� le test
                                       ## est FALSE) :
                                       WinInfoLoading <- get("WinInfoLoading",
                                                             envir=.InfoLoading,
                                                             inherits=FALSE)))))
    {

        ## Cr�ation de la fen�tre :
        assign("WinInfoLoading",
               WinInfoLoading <- tktoplevel(), # Assignation simultann�e dans l'environnement courant.
               envir=.InfoLoading)

        ## Titre de fen�tre :
        tkwm.title(WinInfoLoading, "Infos de chargement")

        ## Il faudra refaire le cadre principal d'info de chargement :
        assign("makeGlobalFrame", TRUE, envir=.InfoLoading)
    }else{
        ## Note : objet de fen�tre d�j� charg� lors du test !
    }


    ## nom du cadre :
    frameName <- paste("Frame", round(runif(1, 0, 2000)), sep="")

    ## Cr�ation du cadre :
    assign(frameName,
           FrameTmp <- tkframe(parent = WinInfoLoading), # Assignation simultann�e dans l'environnement courant.
           envir=.InfoLoading)

    ## Placement du cadre :
    tkgrid(tklabel(WinInfoLoading, text="\n "),
           FrameTmp,
           tklabel(WinInfoLoading, text=" \n"))

    ## On imprime le message :
    LabMsg <- tklabel(FrameTmp, text=msg,...)
    tkgrid(LabMsg)

    ## Finir l'affichage des �l�ments :
    tcl("update", "idletasks")

    winSmartPlace.f(WinInfoLoading)
    winRaise.f(WinInfoLoading)

    ## Update des fen�tres :
    tcl("update")
}


########################################################################################################################
infoLoading.f <- function(msg="", icon="info", button=FALSE,
                          WinRaise=tm,
                          command=function()
                      {
                          tkdestroy(WinInfoLoading)
                          winRaise.f(if(is.null(WinRaise)) tm else WinRaise)
                      }, titleType="load",...)
{
    ## Purpose: Afficher les informations sur le chargement des donn�es
    ## ----------------------------------------------------------------------
    ## Arguments: msg : message � afficher.
    ##            icon : icone � afficher � gauche du texte.
    ##            button : afficher le boutton "OK".
    ##            WinRaise : fen�tre � remettre au premier plan � la
    ##                       fermeture.
    ##            command : commande associ�e au bouton.
    ##            titleType : identifiant d'un type de titre de fen�tre.
    ##            ... : param�tres suppl�mentaires pour le texte.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 11 f�vr. 2011, 15:24

    ## Environnement de stockage des infos
    if (! exists(".InfoLoading", envir=.GlobalEnv))
    {
        assign(".InfoLoading", environment(), envir=.GlobalEnv)
    } else {
        .InfoLoading <- get(".InfoLoading", envir=.GlobalEnv)
    }

    ## Fen�tre graphique :
    if (! exists("WinInfoLoading", envir=.InfoLoading, inherits=FALSE) ||
         ! as.numeric(tclvalue(tkwinfo("exists",
                                       ## Assignation simultann�e dans l'environnement courant (pour le cas o� le test
                                       ## est FALSE) :
                                       WinInfoLoading <- get("WinInfoLoading",
                                                             envir=.InfoLoading,
                                                             inherits=FALSE)))))
    {

        ## Cr�ation de la fen�tre :
        assign("WinInfoLoading",
               WinInfoLoading <- tktoplevel(), # Assignation simultann�e dans l'environnement courant.
               envir=.InfoLoading)

        ## Titre de fen�tre :
        tkwm.title(WinInfoLoading,
                   switch(titleType,
                          "load"="Infos de chargement",
                          "check"="V�rification des s�lections",
                          "Infos de chargement"))

        ## Il faudra refaire le cadre principal d'info de chargement :
        assign("makeGlobalFrame", TRUE, envir=.InfoLoading)
    } else {
        ## Note : objet de fen�tre d�j� charg� lors du test !
    }

    if (! exists("FramePrinc", envir=.InfoLoading, inherits=FALSE) ||
        tryCatch(get("makeGlobalFrame", envir=.InfoLoading),
                 error=function(e){FALSE}))
    {
        ## Cr�ation du cadre principal :
        assign("FramePrinc",
               FramePrinc <- tkframe(parent = WinInfoLoading), # Assignation simultann�e dans l'environnement courant.
               envir=.InfoLoading)

        ## Placement du cadre principal :
        tkgrid(tklabel(WinInfoLoading, text="\n "),
               FramePrinc,
               tklabel(WinInfoLoading, text=" \n"))

        ## plus la peine de refaire le cadre principal d'info de chargement :
        assign("makeGlobalFrame", FALSE, envir=.InfoLoading)
    }else{
        ## Si le cadre principal existe, on le charge simplement :
        FramePrinc <- get("FramePrinc", envir=.InfoLoading, inherits=FALSE)
    }

    ## Fen�tre au premier plan :
    winRaise.f(WinInfoLoading)

    ## Label vide affich� en dernier (pour pouvoir forcer l'affichage de la fen�tre) :
    LabVide <- tklabel(FramePrinc, text="")

    if (! button)
    {
        ## Ecriture de la ligne de message :
        tkgrid(
               if (! is.na(icon))
               {
                   ## Affichage de l'icone :
                   tklabel(FramePrinc, image=loadIcon.f(icon))
               }else{
                   tklabel(FramePrinc, text=" \t ")
               },
               ## S�paration :
               tklabel(FramePrinc, text="\t"),
               ## Message :
               LabTmp <- tklabel(FramePrinc, text=msg, justify="left", ...), sticky="nw")

        ## Ligne vide :
        tkgrid(LabVide)
    }else{
        ## Cr�ation du bouton "OK" :
        OK.button <- tkbutton(FramePrinc,
                              text="   OK   ",
                              command=command)

        tkgrid(OK.button, columnspan=3)

        tkbind(OK.button, "<Return>", command)

        ## Ligne vide :
        tkgrid(LabVide)
    }

    ## Forcer l'affichage de la fen�tre avant la suite :
    ## tkwait.visibility(LabVide)

    ## Placement de la fen�tre :
    winSmartPlace.f(win=WinInfoLoading)
    winRaise.f(win=WinInfoLoading)

    if (button)
    {
        tkfocus(OK.button)
        tkwait.window(WinInfoLoading)
    }else{
        ## Update des fen�tres :
        tcl("update")
    }

    return(invisible(WinInfoLoading))
}

########################################################################################################################
loadIcon.f <- function(icon="info")
{
    ## Purpose: Charger les icones tcl/tk comme images
    ## ----------------------------------------------------------------------
    ## Arguments: icon : nom de l'icone � charger
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 15 f�vr. 2011, 16:27

    ## Environnement de stockage des infos
    if (! exists(".InfoLoading", envir=.GlobalEnv))
    {
        assign(".InfoLoading", environment(), envir=.GlobalEnv)
    }else{}

    ## Si l'icone n'est pas encore charg�e, on la cr�e :
    if (! exists(icon, envir=.InfoLoading, inherits=FALSE))
    {
        ## Cr�ation de la variable contenant l'image :
        assign(icon, tclVar(), envir=.InfoLoading)

        ## Stockage temporaire du nom dans ".InfoLoading" (n�cessaire pour utiliser evalq) :
        assign("icon.tmp", icon, envir=.InfoLoading)

        ## Cr�ation de l'image � partir des fichiers tcl de la distribution
        evalq(tcl("image", "create", "photo", eval(parse(text=icon.tmp)),
                 file=paste(R.home(), "/Tcl/lib/BWidget/images/", icon.tmp, ".gif", sep="")),
             envir=.InfoLoading)
    } else {}

    ## On retourne un lien vers l'image :
    return(get(icon, envir=.InfoLoading, inherits=FALSE))
}


########################################################################################################################
initInnerTkProgressBar.f <- function(title="Progression :", min = 0, max = 100,
                                     initial = 0, width = 300)
{
    ## Purpose: Initialisation d'une barre de progression tk sous forme de
    ##          widget.
    ## ----------------------------------------------------------------------
    ## Arguments: title : Titre de la barre de progression.
    ##            min : valeur minimale
    ##            max : valeur maximale
    ##            initial : valeur initiale.
    ##            width : largeur (pixels) de la barre.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  8 mars 2011, 13:13

    ## Environnement de stockage des infos
    if (! exists(".InfoLoading", envir=.GlobalEnv))
    {
        assign(".InfoLoading", environment(), envir=.GlobalEnv)
    }else{
        .InfoLoading <- get(".InfoLoading", envir=.GlobalEnv)
    }

    ## Fen�tre graphique :
    if (! exists("WinInfoLoading", envir=.InfoLoading, inherits=FALSE) ||
         ! as.numeric(tclvalue(tkwinfo("exists",
                                       ## Assignation simultann�e dans l'environnement courant (pour le cas o� le test
                                       ## est FALSE) :
                                       WinInfoLoading <- get("WinInfoLoading",
                                                             envir=.InfoLoading,
                                                             inherits=FALSE)))))
    {
        warning("pas de fen�tre pour la progressBar")

    } else {
        ## Note : objet de fen�tre d�j� charg� lors du test !

        ## Frame pour accueillir la progresse barre et ses infos
        assign("FramePG",
               FramePG <- tkframe(WinInfoLoading,  borderwidth=2, relief="groove", padx=5, pady=5),
               envir=.InfoLoading)

        ## Cr�ation de la variable d'avancement
        assign("ProgressVal",
               ProgressVal <- tclVar(initial),
               envir=.InfoLoading)

        ## Label avec le pourcentage d'avancement :
        assign("Lab.Progress",
               Lab.Progress <- tklabel(FramePG,
                                       text=paste(format(round(100 * (initial - min) / (max - min)), width=3),
                                                  " %", sep="")),
               envir=.InfoLoading)

        ## Label d'info sur l'�tape en cours :
        assign("Lab.StepInfo",
               Lab.StepInfo <- tklabel(FramePG,
                                       text="",
                                       wraplength=width+20),
               envir=.InfoLoading)

        ## Stockage des min et max :
        assign("IPG.min", min, envir=.InfoLoading)
        assign("IPG.max", max, envir=.InfoLoading)

        ## Barre de progression :
        assign("InnerPG",
               InnerPG <- tkwidget(FramePG, "ttk::progressbar", variable=ProgressVal,
                                   length=width, maximum=max - min, mode="determinate"),
               envir=.InfoLoading)

        ## Placement des �l�ments :
        tkgrid(tklabel(FramePG, text=title), columnspan=2, sticky="w")
        tkgrid(InnerPG, Lab.Progress, sticky="w")
        tkgrid(Lab.StepInfo, columnspan=2, sticky="w")

        tkgrid(tklabel(WinInfoLoading, text=""), FramePG)
        tkgrid(tklabel(WinInfoLoading, text=""))

        winSmartPlace.f(WinInfoLoading)
        winRaise.f(WinInfoLoading)

        ## Update des fen�tres :
        tcl("update")
    }
}

########################################################################################################################
stepInnerProgressBar.f <- function(n=1, msg=NULL,...)
{
    ## Purpose: Incr�mentation de l'avancement sur la progressBar.
    ## ----------------------------------------------------------------------
    ## Arguments: n : nombre d'incr�ments.
    ##            msg : message d'information.
    ##            ... : arguments suppl�mentaires pour le message
    ##                  (font, etc.)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  8 mars 2011, 15:07

    if (exists(".InfoLoading", envir=.GlobalEnv) &&                     # l'environnement d'info existe...
        exists("WinInfoLoading", envir=.InfoLoading, inherits=FALSE) && # l'objet de fen�tre d'info existe...
        as.numeric(tclvalue(tkwinfo("exists",                           # ... et la fen�tre existe...
                                    WinInfoLoading <- get("WinInfoLoading",               #
                                                          envir=.InfoLoading,             #
                                                          inherits=FALSE)))) &&           #
        exists("InnerPG", envir=.InfoLoading) &&                                     # l'objet de ProgressBar existe...
        as.numeric(tclvalue(tkwinfo("exists", get("InnerPG", envir=.InfoLoading))))) # ...et elle est effectivement sur
                                        # la fen�tre d'info.
    {
        ## R�cup�ration des variables :
        min <- get("IPG.min", envir=.InfoLoading)
        max <- get("IPG.max", envir=.InfoLoading)

        ## R�cup�ration des wigets :
        ProgressVal <- get("ProgressVal", envir=.InfoLoading)
        Lab.Progress <- get("Lab.Progress", envir=.InfoLoading)
        Lab.StepInfo <- get("Lab.StepInfo", envir=.InfoLoading)

        ## Progression de la barre :
        tclvalue(ProgressVal) <- as.numeric(tclvalue(ProgressVal)) + n

        ## Label de progression :
        tkconfigure(Lab.Progress,
                    text=paste(format(round(100 * (as.numeric(tclvalue(ProgressVal)) - min) / (max - min)), width=4),
                               " %", sep=""))

        ## Label d'information sur l'�tape en cours (suivante si % d'achev�) :
        if (! is.null(msg))
        {
            tkconfigure(Lab.StepInfo, text=msg,...)
        }else{}

        tkfocus(get("WinInfoLoading", envir=.InfoLoading))

        winSmartPlace.f(WinInfoLoading)
        winRaise.f(WinInfoLoading)

        ## Update des fen�tres :
        tcl("update")
    }
}

########################################################################################################################
reconfigureInnerProgressBar.f <- function(min=NULL, max=NULL, ...)
{
    ## Purpose: Reconfiguration d'une barre de progression interne.
    ## ----------------------------------------------------------------------
    ## Arguments: ... : options de reconfiguration
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  9 mars 2011, 11:26

    if (exists(".InfoLoading", envir=.GlobalEnv) &&
        exists("InnerPG", envir=.InfoLoading)&& # l'objet de ProgressBar existe...
        as.numeric(tclvalue(tkwinfo("exists", get("InnerPG", envir=.InfoLoading)))))
    {
        ## Changement de maximum :
        if (! is.null(max) || ! is.null(min))
        {
            ## Param�tre de la fonction ou valeur stock�e :
            assign("IPG.max",           # Il faut �galement stocker la "nouvelle" valeur.
                   max <- ifelse(is.null(max), get("IPG.max", envir=.InfoLoading), max),
                   envir=.InfoLoading)

            assign("IPG.min",           # Il faut �galement stocker la "nouvelle" valeur.
                   min <- ifelse(is.null(min), get("IPG.min", envir=.InfoLoading), min),
                   envir=.InfoLoading)

            ## Reconfiguration de la barre :
            tkconfigure(get("InnerPG", envir=.InfoLoading),
                        maximum=max - min,
                        ...)
            ## Modification du % d'avancement :
            tkconfigure(get("Lab.Progress", envir=.InfoLoading),
                        text=paste(format(round(100 *
                                                (as.numeric(tclvalue(get("ProgressVal", envir=.InfoLoading))) - min) /
                                                (max - min)), width=4),
                                   " %", sep=""))

        } else {
            ## sinon uniquement les changements sont dans ... :
            if (length(as.list(match.call())) > 1)
            {
                tkconfigure(get("InnerPG", envir=.InfoLoading),...)
            } else {
                warning("Pas d'options de configuration de la barre de progression !")
            }
        }
    } else {
        ## On ne fait rien si la barre de progression n'existe pas.
    }
}


########################################################################################################################
tkObj.gridInfo.f <- function(tkObj)
{
    ## Purpose: Pr�senter sous une forme plus exploitable les info de
    ##          placement d'un objet Tcl/Tk.
    ##          Renvoie les diff�rentes options de placement de l'objet
    ## ----------------------------------------------------------------------
    ## Arguments: tkObj : l'objet Tk affich� avec "grid"
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 15 mars 2011, 11:19

    return(unlist(lapply(unlist(strsplit(paste(" ", tclvalue(tkgrid.info(tkObj)), sep=""), " -")),
                         function(x)
                     {
                         res <- unlist(strsplit(x, " "))[2]
                         names(res) <- unlist(strsplit(x, " "))[1]
                         return(res)
                     }))[-1])
}



### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
