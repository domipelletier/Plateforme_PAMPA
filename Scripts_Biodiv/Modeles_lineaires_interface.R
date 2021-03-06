#-*- coding: latin-1 -*-
# Time-stamp: <2013-02-12 11:28:49 Yves>

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

### File: Modeles_lineaires_interface.R
### Created: <2010-12-16 11:32:33 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
###
####################################################################################################

########################################################################################################################
## Fonctions pour ajouter des barres de d�filement dans une fen�tre principale :

.RDEnv <- new.env(hash=TRUE)                   # Private environment

rdenv <- function() {
    return(.RDEnv)
}


scrollframeCreate.f <- function(parent,env=rdenv(),...)
{
    stopifnot(is.tkwin(parent))

    frame <- tkframe(parent,
                     class="ScrollFrame",...)
    xscroll <- tkscrollbar(frame,
                           repeatinterval=5,
                           orient="horizontal",
                           command=function(...) tkxview(vport, ...))
    yscroll <- tkscrollbar(frame,
                           repeatinterval=5,
                           orient="vertical",
                           command=function(...) tkyview(vport, ...))
    vport <- tkcanvas(frame)
    tkconfigure(vport, xscrollcommand=function(...) tkset(xscroll, ...))
    tkconfigure(vport, yscrollcommand=function(...) tkset(yscroll, ...))

    pady <- paste("0", tclvalue(tkwinfo("reqheight", xscroll)))
    tkpack(yscroll, side="right", fill="y", pady=pady)
    tkpack(xscroll, side="bottom", fill="x")
    tkpack(vport, side="left", fill="both", expand=TRUE)

    int.frame <- tkframe(vport,
                         borderwidth=4,
                         relief="groove")
    tkcreate(vport, "window", "0 0", anchor="nw", window=int.frame$ID)
    tkbind(int.frame, "<Configure>", function() scrollframeResize(int.frame))

    ## Save this so items can be put in it
    assign("interior.frame", int.frame, envir=env)

    return(frame)
}


scrollframeResize <- function(iframe) {
    stopifnot(tclvalue(tkwinfo("class", iframe)) == "Frame")

    w <- tkwinfo("width", iframe)
    h <- tkwinfo("height", iframe)

    vport <- tkwinfo("parent", iframe)
    stopifnot(tclvalue(tkwinfo("class", vport)) == "Canvas")
    bbox <- tkbbox(vport, "all")

    tkconfigure(vport,
                width=w,
                height=h,
                scrollregion=bbox,
                xscrollincrement="0.1i",
                yscrollincrement="0.1i")
}


scrollframeInterior <- function(env=rdenv()) {
    return(get("interior.frame", envir=env))
}


########################################################################################################################
choixDistri.f <- function(metrique, Data)
{
    ## Purpose: Aider l'utilisateur dans le choix d'une distribution de la
    ##          m�trique et lancer les analyses ad�quates.
    ## ----------------------------------------------------------------------
    ## Arguments: metrique : le nom de la m�trique (variable d�pendant)
    ##                       choisie.
    ##            Data : le jeu de donn�es contenant la m�trique.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 18 ao�t 2010, 16:19

    ## Syst�matiquement d�truire la fen�tre en quitant :
    on.exit(tkdestroy(WinDistri))
    ## on.exit(print("WinDistri d�truite !"), add=TRUE)


    ## ##################################################
    ## Variables :
    env <- environment()                # environnement courant.
    Done <- tclVar(0)                   # �tat d'ex�cution.
    LoiChoisie <- tclVar("NO")          # Variable pour le choix de distribution th�orique.
    vscale <- 0.48                      # dimension verticale des graphiques.
    hscale <- 0.95                      # dimension horizontale des graphiques.
    pointsize <- 10                     # taille du point pour les graphiques
    distList <- list()                  # liste pour le stockage des AIC et autres.


    ## ##################################################
    ## �l�ments graphiques :
    WinDistri <- tktoplevel()           # Fen�tre principale.
    tkwm.title(WinDistri, paste("Choix de distribution th�orique de la m�trique '", metrique, "'", sep=""))

    ## tkfocus(WinDistri)

    ## Frame d'aide :
    FrameHelp <- tkframe(WinDistri)
    T.help <- tktext(FrameHelp, bg="#fae18d", font="arial", width=100,
                     height=4, relief="groove", borderwidth=2)


    ## Frame pour la loi Normale :
    FrameN <- tkframe(WinDistri, borderwidth=2, relief="groove")
    Img.N <- tkrplot(FrameN,            # Cr�ation de l'image.
                     fun=function()
                 {
                     plotDist.f(y=Data[ , metrique], family="NO", metrique=metrique, env=env)
                 },
                     vscale=vscale, hscale=hscale, pointsize=pointsize)

    RB.N <- tkradiobutton(FrameN, variable=LoiChoisie, value="NO", # bouton de s�lection.
                          text=paste("loi Normale (AIC=", round(distList[["NO"]]$aic, 0), "). ", sep=""))


    ## Frame pour la loi log-Normale :
    FrameLogN <- tkframe(WinDistri, borderwidth=2, relief="groove")
    Img.LogN <- tkrplot(FrameLogN, fun=function() # Cr�ation de l'image.
                    {
                        plotDist.f(y=Data[ , metrique], family="LOGNO", metrique=metrique, env=env)
                    },
                        vscale=vscale, hscale=hscale, pointsize=pointsize)

    RB.LogN <- tkradiobutton(FrameLogN, variable=LoiChoisie, value="LOGNO", # bouton de s�lection.
                             text=paste("loi log-Normale (AIC=", round(distList[["LOGNO"]]$aic, 0), "). ", sep=""))

    ## Frame pour la loi Gamma :
    FrameGa <- tkframe(WinDistri, borderwidth=2, relief="groove")
    Img.Ga <- tkrplot(FrameGa, fun=function() # Cr�ation de l'image.
                    {
                        plotDist.f(y=Data[ , metrique], family="GA", metrique=metrique, env=env)
                    },
                        vscale=vscale, hscale=hscale, pointsize=pointsize)

    RB.Ga <- tkradiobutton(FrameGa, variable=LoiChoisie, value="GA", # bouton de s�lection.
                             text=paste("loi Gamma (AIC=", round(distList[["GA"]]$aic, 0), "). ", sep=""))

    if (is.integer(Data[ , metrique]))
    {
        ## ## Frame pour la loi de Poisson :
        ## FramePois <- tkframe(WinDistri, borderwidth=2, relief="groove")
        ## Img.Pois <- tkrplot(FramePois,  # Cr�ation de l'image.
        ##                     fun=function()
        ##                 {
        ##                     plotDist.f(y=Data[ , metrique], family="PO", metrique=metrique, env=env)
        ##                 },
        ##                     vscale=vscale, hscale=hscale, pointsize=pointsize)

        ## RB.Pois <- tkradiobutton(FramePois, variable=LoiChoisie, value="PO", # bouton de s�lection.
        ##                          text=paste("loi de Poisson (AIC=", round(distList[["PO"]]$aic, 0), "). ", sep=""))

        ## Frame pour la loi bionomiale n�gative :
        FrameNBinom <- tkframe(WinDistri, borderwidth=2, relief="groove")

        Img.NBinom <- tkrplot(FrameNBinom, # Cr�ation de l'image.
                              fun=function()
                          {
                              plotDist.f(y=Data[ , metrique], family="NBI", metrique=metrique, env=env)
                          },
                              vscale=vscale, hscale=hscale, pointsize=pointsize)

        RB.NBinom <- tkradiobutton(FrameNBinom, variable=LoiChoisie, value="NBI", # bouton de s�lection.
                                   text=paste("loi Binomiale n�gative (AIC=",
                                              round(distList[["NBI"]]$aic, 0), "). ", sep=""))
    }else{}

    ## Boutons :
    FrameB <- tkframe(WinDistri)
    B.OK <- tkbutton(FrameB, text="     OK     ", command=function(){tclvalue(Done) <- "1"})
    B.Cancel <- tkbutton(FrameB, text="   Annuler   ", command=function(){tclvalue(Done) <- "2"})

    ## ##################################################
    ## Placement des �l�ments sur la grille :

    tkgrid(tklabel(WinDistri, text=" "))
    tkinsert(T.help, "end", paste("INFO :\n", # texte de l'aide.
                                  "Cette fen�tre vous permet de choisir la distribution",
                                  " la plus adapt�e pour faire vos analyses.\n",
                                  "La distribution (courbe rouge) s'ajustant le mieux � vos donn�es (histogramme) d'apr�s \n",
                                  "le crit�re d'information de Akaike (AIC ; doit �tre le plus petit possible) est pr�-s�lectionn�e.", sep=""))
    tkgrid(T.help)
    tkgrid(FrameHelp, column=1, columnspan=3)

    tkgrid(tklabel(WinDistri, text=" "))
    tkgrid(Img.N, columnspan=2)
    tkgrid(RB.N, row=1, sticky="e")
    tkgrid(tklabel(FrameN, text=" Mod�le : ANOVA", fg="red"), row=1, column=1, sticky="w")

    tkgrid(Img.LogN, columnspan=2)
    tkgrid(RB.LogN, sticky="e")
    tkgrid(tklabel(FrameLogN, text=" Mod�le : ANOVA, donn�es log-transform�es", fg="red"), row=1, column=1, sticky="w")
    tkgrid(tklabel(WinDistri, text=" "), FrameN, tklabel(WinDistri, text=" "), FrameLogN, tklabel(WinDistri, text="
    "),
    sticky="ew")

    tkgrid(tklabel(WinDistri, text=" "))

    tkgrid(tklabel(WinDistri, text=" "), FrameN, tklabel(WinDistri, text=" "), FrameLogN, tklabel(WinDistri, text=" "),
           sticky="ew")

    tkgrid(Img.Ga, columnspan=2)
    tkgrid(RB.Ga, sticky="e")
    tkgrid(tklabel(FrameGa, text=" Mod�le : GLM, famille 'Gamma'", fg="red"), row=1, column=1, sticky="w")


    ## �v�nements : s�lections en cliquant sur les graphiques :
    tkbind(Img.N, "<Button-1>", function(){tclvalue(LoiChoisie) <- "NO"})
    tkbind(Img.LogN, "<Button-1>", function(){tclvalue(LoiChoisie) <- "LOGNO"})
    tkbind(Img.Ga, "<Button-1>", function(){tclvalue(LoiChoisie) <- "GA"})

    ## Pour les donn�es enti�res seulement :
    if (is.integer(Data[ , metrique]))
    {
        ## tkgrid(Img.Pois, columnspan=2)
        ## tkgrid(RB.Pois, sticky="e")
        ## tkgrid(tklabel(FramePois, text=" Mod�le : GLM, famille 'Poisson'", fg="red"), row=1, column=1, sticky="w")
        tkgrid(Img.NBinom, columnspan=2)
        tkgrid(RB.NBinom, sticky="e")
        tkgrid(tklabel(FrameNBinom, text=" Mod�le : GLM, famille 'Binomiale n�gative'", fg="red"), row=1, column=1, sticky="w")
        tkgrid(tklabel(WinDistri, text=" "), FrameGa, ## FramePois,
               tklabel(WinDistri, text=" "), FrameNBinom,
               tklabel(WinDistri, text=" "), sticky="ew")
        tkgrid(tklabel(WinDistri, text=" "))

        ## �v�nements : s�lections en cliquant sur les graphiques :
        ## tkbind(Img.Pois, "<Button-1>", function(){tclvalue(LoiChoisie) <- "PO"})
        tkbind(Img.NBinom, "<Button-1>", function(){tclvalue(LoiChoisie) <- "NBI"})
    }else{
        tkgrid(tklabel(WinDistri, text=" "), FrameGa, ## FramePois,
               tklabel(WinDistri, text=" "), tklabel(WinDistri, text=" "),
               tklabel(WinDistri, text=" "), sticky="ew")
        tkgrid(tklabel(WinDistri, text=" "))
    }

    ## Boutons :
    tkgrid(FrameB, column=1, columnspan=3)
    tkgrid(B.OK, tklabel(FrameB, text="                         "), B.Cancel)
    tkgrid(tklabel(WinDistri, text=" "))

    ## ##################################################
    ## Autres �v�nements :
    tkbind(WinDistri, "<Destroy>", function(){tclvalue(Done) <- "2"}) # en cas de destruction de la fen�tre.

    ## Pr�s�lection de la distribution avec le plus petit AIC :
    tclvalue(LoiChoisie) <- names(distList)[which.min(sapply(distList, function(x){x$aic}))]
    ## flush.console()

    ## Placement et mise au premier plan de la fen�tre :
    winSmartPlace.f(WinDistri)

    tkwait.variable(Done)               # Attente d'une action de l'utilisateur.

    if (tclvalue(Done) == "1")
    {
        return(tclvalue(LoiChoisie))
    }else{
        return(NULL)
    }

}

########################################################################################################################
supprimeObs.f <- function(residus)
{
    ## Purpose: Choisir des observations � supprimer d'apr�s leur r�sidus.
    ## ----------------------------------------------------------------------
    ## Arguments: residus : un vecteur de r�sidus avec les num�ros
    ##                        d'observations en noms (obtenus par la fonction
    ##                        'boxplot(...)$out' par exemple).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 17 sept. 2010, 13:52

    Done <- tclVar("0")
    res <- NULL

    WinSuppr <- tktoplevel()
    tkwm.title(WinSuppr, "Suppression d'outliers ?")

    FrameB <- tkframe(WinSuppr)
    B.Oui <- tkbutton(FrameB, text="    Oui    ", command=function(){tclvalue(Done) <- "1"})
    B.Non <- tkbutton(FrameB, text="    Non    ", command=function(){tclvalue(Done) <- "2"})

    tkgrid(tklabel(WinSuppr, text="\t"),
           tklabel(WinSuppr, text=paste("\nSouhaitez vous supprimer des observations pr�sentant de forts r�sidus ?",
                             "\n(Vous devrez choisir les observations � supprimer).\n", sep="")),
           tklabel(WinSuppr, text="\t"),
           sticky="w")

    tkgrid(FrameB, column=1)
    tkgrid(B.Oui, tklabel(FrameB, text="\t\t\n"), B.Non)


    tkbind(WinSuppr, "<Destroy>", function(){tclvalue(Done) <- "2"})

    tkfocus(WinSuppr)
    ## Placement et mise au premier plan de la fen�tre :
    winSmartPlace.f(WinSuppr)

    tkwait.variable(Done)

    if (tclvalue(Done) == "1")
    {
        tkdestroy(WinSuppr)
        ## S�lection des observations par l'utilisateur :
        select <-
            selectModWindow.f("residus",
                              data= if (any(is.na(tryCatch(as.integer(names(residus)), warning=function(w){NA}))))
                                    {   # Si les noms de lignes correspondent � des noms d'unitobs...
                                        data.frame(residus=paste("Unitobs. ",
                                                  names(sort(abs(residus), decreasing=TRUE)),
                                                   "  (",
                                                   format(residus[order(abs(residus), decreasing=TRUE)],
                                                          digits=3),
                                                   ")",
                                                   sep=""))
                                    }else{ # ...si ce sont des num�ros :
                                        data.frame(residus=paste("Obs. ",
                                                   format(as.integer(names(sort(abs(residus), decreasing=TRUE))),
                                                          width=ceiling(log(max(as.integer(names(residus))), 10)),
                                                          justify="right"),
                                                   "  (",
                                                   format(residus[order(abs(residus), decreasing=TRUE)],
                                                          digits=3),
                                                   ")",
                                                   sep=""))
                                    },
                              sort=FALSE, selectmode="extended",
                              title="S�lection des observations � supprimer",
                              label=paste("\n'Observations (r�sidu)' tri�s par ordre d�croissant",
                              "\nde la valeur absolue des r�sidus.", sep=""))

        if (length(select))
        {
            if (any(is.na(tryCatch(as.integer(names(residus)), warning=function(w){NA}))))
            {   # Si les noms de lignes correspondent � des noms d'unitobs...
                res <- sub("^Unitobs.[[:blank:]]+([^[:blank:]]+)[[:blank:]]+.*", "\\1", select, perl=TRUE)
            }else{
                ## ...sinon, num�ro des observations � supprimer : [!!!] on pourrait s'en passer (� r�gler plus tard).
                res <- as.integer(sub("^Obs.[[:blank:]]+([[:digit:]]+)[[:blank:]]+.*", "\\1", select, perl=TRUE))
            }
        }else{}
    }else{
         tkdestroy(WinSuppr)
     }

    return(res)
}






### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
