#-*- coding: latin-1 -*-
# Time-stamp: <2013-02-11 18:12:15 yves>

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

### File: Interface_principale.R
### Created: <2012-01-18 17:45:47 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Cr�ation de l'interface principale "Ressources & Biodiversit�"
####################################################################################################

mainInterface.create.f <- function()
{
    ## Purpose: Lancement de l'interface principale "Ressources et
    ##          Biodiversit�"
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  6 d�c. 2011, 13:40

    require(tcltk)

    ## #########################################################################
    ## Environnements :
    .baseEnv <- environment()           # ...courant.
    .dataEnv <- new.env()               # ...pour la sauvegarde des tables de donn�es.

    assign(".baseEnv", .baseEnv, .GlobalEnv)
    assign(".dataEnv", .dataEnv, .GlobalEnv)

    ## #########################################################################
    ## FEN�TRE PRINCIPALE
    ## #########################################################################

    W.main <- tktoplevel(height=600, width=800, background="#FFFFFF")

    tkwm.title(W.main, "Indicateurs relatifs � la biodiversit� et aux ressources")

    tkwm.maxsize(W.main,
                 tkwinfo("screenwidth", W.main),
                 as.numeric(tclvalue(tkwinfo("screenheight", W.main))) - 30)             # taille maximale de la fenetre
    ## tkwm.minsize(W.main, 800, 500)              # taille minimale de la fenetre

    ## Couleurs :
    .MenuBackground <- "#FFFBCF"
    .FrameBackground <- "#FFF6BF"
    .TopMenueBackground <- "#CBDDED"

    ## #########################################################################
    ## Menus :

    F.menu <- tkframe(W.main, background=.TopMenueBackground)

    ## initialisation des entr�es de menu d�chirables (i.e. qui donne acc�s � un sous menu)

    ## Boutons de menus :
    MB.import <- tkmenubutton(F.menu, text="Donn�es", state="normal")
    MB.selection <- tkmenubutton(F.menu, text="S�lection et recalcul", state="disabled")
    MB.traitement <- tkmenubutton(F.menu, text="Graphiques", state="disabled")
    MB.analyse <- tkmenubutton(F.menu, text="Statistiques", state="disabled")
    MB.outils <- tkmenubutton(F.menu, text="Outils", state="normal")
    MB.pampainfos <- tkmenubutton(F.menu, text="Aide", state="normal")


    ## Menus associ�s :
    import <- tkmenu(MB.import, tearoff=FALSE)
    selection <- tkmenu(MB.selection, tearoff=FALSE)
    traitement <- tkmenu(MB.traitement, tearoff=FALSE)
    analyse <- tkmenu(MB.analyse, tearoff=FALSE)
    outils <- tkmenu(MB.outils, tearoff=FALSE)
    pampainfos <- tkmenu(MB.pampainfos, tearoff=FALSE)

    ## Sous menus :
    speciesMetrics <- tkmenu(traitement, tearoff=FALSE)
    unitobsMetrics <- tkmenu(traitement, tearoff=FALSE)
    speciesMaps <- tkmenu(traitement, tearoff=FALSE)
    unitobsMaps <- tkmenu(traitement, tearoff=FALSE)
    ## arbreRegression <- tkmenu(analyse, tearoff=FALSE)
    ## modelesInferentiels <- tkmenu(analyse, tearoff=FALSE)
    ## analysesExplo <- tkmenu(analyse, tearoff=FALSE)

    ## Association des boutons et menus :
    tkconfigure(MB.import, menu=import, activebackground="#81a5dc", background=.TopMenueBackground)
    tkconfigure(MB.selection, menu=selection, activebackground="#81a5dc", background=.TopMenueBackground)
    tkconfigure(MB.traitement, menu=traitement, activebackground="#81a5dc", background=.TopMenueBackground)
    tkconfigure(MB.analyse, menu=analyse, activebackground="#81a5dc", background=.TopMenueBackground)
    tkconfigure(MB.outils, menu=outils, activebackground="#81a5dc", background=.TopMenueBackground)
    tkconfigure(MB.pampainfos, menu=pampainfos, activebackground="#81a5dc", background=.TopMenueBackground)

    ## Bouton pour quitter :
    B.quit.main <- tkbutton(F.menu, text=" Quitter... ",
                            command=function()
                        {
                            quitConfirm.f(W.main)
                        },
                            activebackground="#81a5dc")


    ## Fermeture de tous les graphiques :
    B.graphicsOFF <- tkbutton(F.menu, text="Fermer les graphiques", command=graphics.off,
                              activebackground="#81a5dc")


    ## Placement des menus :
    tkpack(MB.import, MB.selection, MB.traitement, MB.analyse, MB.outils, MB.pampainfos,
           side="left")
    tkpack(B.quit.main, B.graphicsOFF, side="right", padx=5, pady=2)

    tkgrid(F.menu, sticky="ew", columnspan=4)

    ## ######################################
    ## Menu deroulant des Donn�es :

    ## Imports :
    tkadd(import, "command", label="Choix des dossiers et fichiers de donn�es...",
          accelerator="CTRL+N",
          command = function()
      {
          tryCatchLoad.f(expr=loadManual.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                         baseEnv=.baseEnv)
      },
          background=.MenuBackground)

    tkadd(import, "command", label="Dossiers et fichiers par d�faut", accelerator="CTRL+A",
          command = function()
      {
          tryCatchLoad.f(expr=loadDefault.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                         baseEnv=.baseEnv)
      },
          background=.MenuBackground)

    ## Informations sur les donn�es :
    tkadd(import, "separator", background=.MenuBackground)

    tkadd(import, "command", label="Test du r�f�rentiel (esp�ces concern�es)", underline=9, accelerator="CTRL+R",
          state="disabled", command = function(){testfileref.f(dataEnv=.dataEnv, baseEnv=.baseEnv)},
          background=.MenuBackground)

    ## tkadd(import, "command", label="Test des donn�es import�es", underline=0,
    ##       accelerator="CTRL+T", state="disabled")  ## [sup] [yr: 13/01/2011]

    ## tkadd(import, "command", label="Champs de 'TableMetrique' et TableBiodiv", underline=0, accelerator="CTRL+M",
    ##       state="disabled")

    tkadd(import, "command", label="Plan d'�chantillonnage basique", accelerator="CTRL+P", state="disabled",
          command = function()
      {
          VoirPlanEchantillonnage.f(dataEnv=.dataEnv)
      },
          background=.MenuBackground)

    tkadd(import, "command", label="Info donn�es par esp�ces", state="disabled", accelerator="CTRL+E",
          command = function()
       {
           VoirInformationsDonneesEspeces.f(dataEnv=.dataEnv, image=imageAMP)
       },
          background=.MenuBackground)

    tkadd(import, "command", label="Info donn�es par unit� d'observation",
          state="disabled", accelerator="CTRL+U",
          command = function()
      {
          VoirInformationsDonneesUnitobs.f(dataEnv=.dataEnv, image=imageAMP)
      },
          background=.MenuBackground)

    ## ######################################
    ## S�lection et recalcul :

    tkadd(selection, "command", label="Selon un champ du r�f�rentiel esp�ce...",
          background=.MenuBackground,
          command = function ()
      {
          selectionOnRefesp.f(dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    tkadd(selection, "command", label="Selon un champ des unit�s d'observation...",
          background=.MenuBackground,
          command = function ()
      {
          selectionOnUnitobs.f(dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    tkadd(selection, "separator", background=.MenuBackground)
    tkadd(selection, "checkbutton", label="Par liste d'esp�ces (fichier)",
          background=.MenuBackground,
          ## variable=SelectListEsp, # � quoi sert cette variable ? [???]
          ## onvalue=1, offvalue=0,
          command = function() message("En d�veloppement !"), state="disabled")

    ## Restauration des donn�es :
    tkadd(selection, "separator", background=.MenuBackground)
    tkadd(selection, "command", label="Restaurer les donn�es originales",
          background=.MenuBackground,
          state="disabled",
          command = function ()
      {
          restoreData.f(baseEnv=.baseEnv, dataEnv=.dataEnv)
          winRaise.f(W.main)
      })

    ## ######################################
    ## Graphiques :

    ## Info :
    tkadd(traitement, "separator", background=.MenuBackground)

    tkadd(traitement, "command", label="Par esp�ce ou classe de taille d'esp�ce :",
          foreground="darkred", background="#dadada",
          font=tkfont.create(weight="bold", size=8),
          state="normal")

    ## tkadd(traitement, "cascade", label="M�trique /esp�ce/unit� d'observation",
    ##       menu=speciesMetrics,
    ##       background=.MenuBackground)

    ## Boxplots esp�ces :
    tkadd(traitement, "command", label="Graphiques en \"bo�tes � moustaches\" (boxplots)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="boxplot.esp", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Barplots esp�ces :
    tkadd(traitement, "command", label="Graphiques en barres (barplots)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="barplot.esp", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Barplots d'occurrence par esp�ces :
    tkadd(traitement, "command", label="Fr�quences d'occurrence (/esp�ce sur des unit� d'observation)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="freq_occurrence", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    tkadd(traitement, "cascade", label="Cartes",
          menu=speciesMaps, background=.MenuBackground)

    tkadd(speciesMaps, "command", label="Graphiques en barres ou bo�tes � moustaches, par zone...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.carto.f(nextStep="spBarBoxplot.esp", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Info :
    tkadd(traitement, "separator", background=.MenuBackground)

    tkadd(traitement, "command", label="Plusieurs esp�ces ou classes de taille, agr�g�es par unit� d'observation :",
          foreground="darkred", background="#dadada",
          font=tkfont.create(weight="bold", size=8),
          state="normal")

    ## tkadd(traitement, "cascade", label="M�trique /unit� d'observation (dont biodiversit�)",
    ##       menu=unitobsMetrics,
    ##       background=.MenuBackground)

    ## Boxplots unitobs :
    tkadd(traitement, "command", label="Graphiques en \"bo�tes � moustaches\" (boxplots)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="boxplot.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Barplots unitobs :
    tkadd(traitement, "command", label="Graphiques en barres (barplots)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="barplot.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Barplots d'occurrence par unitobs :
    tkadd(traitement, "command", label="Fr�quences d'occurrence (/facteurs d'unit� d'observation)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="freq_occurrence.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    tkadd(traitement, "cascade", label="Cartes",
          menu=unitobsMaps, background=.MenuBackground)

    tkadd(unitobsMaps, "command", label="Graphiques en barres ou bo�tes � moustaches, par zone...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.carto.f(nextStep="spBarBoxplot.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })
    ## ######################################
    ## Analyses :

    ## Menus d�chirables...

    ## ## ...mod�les inf�rentiels :
    ## tkadd(analyse, "cascade", label="Mod�les inf�rentiels", menu=modelesInferentiels,
    ##       background=.MenuBackground)

    ## ## ...mod�les exploratoires (� faire) :
    ## tkadd(analyse, "cascade", label="Analyses exploratoires", menu=analysesExplo, state="disabled")

    modelesInferentiels <- analyse

    ## Mod�les inf�rentiels :

    ## Info :
    tkadd(modelesInferentiels, "command", label="Par esp�ce ou classe de taille d'esp�ce :",
          foreground="darkred", background="#dadada",
          font=tkfont.create(weight="bold", size=8),
          state="normal")

    ## (G)LMs esp�ces
    tkadd(modelesInferentiels, "command", label="Mod�les lin�aires, m�trique /esp�ce/unit� d'observation...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="modele_lineaire", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## MRT esp�ces :
    tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                          " m�trique / esp�ces / unit� d'observation...", sep=""),
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="MRT.esp", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## Info :
    tkadd(modelesInferentiels, "separator", background=.MenuBackground)

    tkadd(modelesInferentiels, "command", label="Plusieurs esp�ces ou classes de taille, agr�g�es par unit� d'observation :",
          foreground="darkred", background="#dadada",
          font=tkfont.create(weight="bold", size=8),
          state="normal")

    ## (G)LMs unitobs :
    tkadd(modelesInferentiels, "command", label="Mod�les lin�aires, m�trique /unit� d'observation (dont biodiversit�)...",
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="modele_lineaire.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })

    ## MRT unitobs :
    tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                          " m�trique /unit� d'observation (dont biodiversit�)...", sep=""),
          background=.MenuBackground,
          command=function ()
      {
          selectionVariables.f(nextStep="MRT.unitobs", dataEnv=.dataEnv, baseEnv=.baseEnv)
          winRaise.f(W.main)
      })


    ## ######################################
    ## Menu deroulant des outils :

    tkadd(outils, "command", label="Options d'export...", command = generalOptions.f, state="normal",
          background=.MenuBackground)

    tkadd(outils, "command", label="Options graphiques...", command = tuneGraphOptions.f, state="normal",
          background=.MenuBackground)
    tkadd(outils, "separator", background=.MenuBackground)

    tkadd(outils, "command", label="Lier les unit�s d'observations et le r�f�rentiel spatial...",
          command=function()
      {
          unitobsTmp <- mergeSpaUnitobs.f(unitobs=get(".unitobsSmall", envir=.dataEnv),
                                   refspa=get("refspa", envir=.dataEnv),
                                   type="manual")

          ## Sauvegard� uniquement si pas d'abandon :
          if (ncol(unitobsTmp) > (ncol(get(".unitobsSmall", envir=.dataEnv)) + 1))
          {
              assign("unitobs", unitobsTmp, envir=.dataEnv)
          }else{}
      },
          state="disabled", background=.MenuBackground)

    tkadd(outils, "command", label="R�organiser des facteurs des unit�s d'observation...",
          state="disabled", background=.MenuBackground,
          command=function()
      {
          assign("unitobs",
                 change.levelsOrder.f(Data=get("unitobs", envir=.dataEnv)),
                 envir=.dataEnv)
      })

    tkadd(outils, "command", label="R�organiser des facteurs du r�f�rentiel esp�ces...",
          state="disabled", background=.MenuBackground,
          command=function()
      {
          assign("refesp",
                 change.levelsOrder.f(Data=get("refesp", envir=.dataEnv)),
                 envir=.dataEnv)
      })
    tkadd(outils, "separator", background=.MenuBackground)

    tkadd(outils, "command", label="�diter le fichier de configuration",
          background=.MenuBackground,
          command=function()
      {
          shell.exec(paste(basePath, "/Scripts_Biodiv/Config.R", sep=""))
      })
    tkadd(outils, "separator", background=.MenuBackground)

    tkadd(outils, "command", label="Cr�er un rapport de bug", state="normal",
          background=.MenuBackground,
          command = function()
      {
          shell.exec(paste(basePath, "/Scripts_Biodiv/Doc/Rapport_bug_PAMPA-WP2.dot", sep=""))
      })
    tkadd(outils, "separator", background=.MenuBackground)

    tkadd(outils, "command", label="mise � jour (site de t�l�chargement)", state="normal",
          background=.MenuBackground,
          command = function()
      {
          browseURL("http://www.projet-pampa.fr/wiki/doku.php/wp2:telechargement")
      })

    ## tkadd(outils, "command", label="Langue", state="disabled", command = test.f)

    ## tkadd(outils, "command", label="Export de donnees", state="disabled", command = test.f)


    ## ######################################
    ## Menu deroulant de l'aide

    ## Acc�s aux documentations :
    tkadd(pampainfos, "command", label="Documentation en ligne",
          background=.MenuBackground,
          command = function()
      {
          browseURL("http://www.projet-pampa.fr/wiki/doku.php/wp2:wp2#documentation")
      })

    tkadd(pampainfos, "command", label="Documentation (locale)",
          background=.MenuBackground,
          command = function()
      {
          shell.exec(dir(paste(basePath, "/Scripts_Biodiv/Doc", sep=""),
                         full.names=TRUE)[grep("^Guide",
                         dir(paste(basePath, "/Scripts_Biodiv/Doc", sep="")), perl=TRUE)])
      })

    tkadd(pampainfos, "command", label="Forum d'entraide",
          background=.MenuBackground,
          command = function()
      {
          browseURL("http://www.projet-pampa.fr/forum/viewforum.php?id=2")
      })


    ## � propos... :
    tkadd(pampainfos, "separator", background=.MenuBackground)
    tkadd(pampainfos, "command", label="� propos de la plateforme...", command = apropos.f,
          background=.MenuBackground)

    ## #########################################################################
    ## Ajout des autres �l�ments :

    ## Frame principale :
    ## topFrame <- tkframe(W.main, relief="groove", borderwidth=2)

    ## Logo :
    imageAMP <- tclVar()
    tcl("image", "create", "photo", imageAMP, file=.fileimage) # cr�e un objet Tk image pour l'interface.

    F.aide <- tkframe(W.main, background="white")

    ## Dans la r�partition d'espace entre les deux colonne,
    ## on attribue tout l'espace suppl�mentaire � la premi�re
    tkgrid.columnconfigure(F.aide, 0, minsize=1, weight=0)
    tkgrid.columnconfigure(F.aide, 1, weight=9)

    imgAsLabel <- tklabel(F.aide, image=imageAMP, bg="white") # -> label avec image.

    ## Frames d'aide :
    titreAideContextuelle <- tklabel(F.aide, #width=106,
                                     text="Vous pouvez...",
                                     background="#FFF07F", justify="left",
                                     font=tkfont.create(family="arial", size=10))

    helpframe <- tktext(F.aide, bg=.FrameBackground, font=tkfont.create(family="arial", size=10),
                        ## width=95,
                        height=3, # taille.
                        relief="groove", borderwidth=2)


    ## tkgrid(imgAsLabel, sticky="w")
    tkgrid(imgAsLabel,
           titreAideContextuelle## , ## columnspan=4, sticky="w",
           ## padx=5
           )

    tkgrid(imgAsLabel,
           helpframe## , ## columnspan=4, sticky="ew",
           ## padx=5
           )

    ## tkgrid(tklabel(W.main, text="", background="white"))
    ## tkgrid(imgAsLabel, topFrame)

    tkgrid.configure(imgAsLabel, sticky="nsew", rowspan=2,
                     padx=7)

    ## ## puis on place les 3 objets � cot� de l'image :
    tkgrid.configure(titreAideContextuelle, columnspan=1, row=0, column=1, sticky="ws", padx=5)
    tkgrid.configure(helpframe, columnspan=1, row=1, column=1, sticky="ewn", padx=5)

    tkgrid(F.aide, columnspan=4, sticky="ew", pady=5)

    ## ##################################
    ## Frame d'info sur les fichiers et s�lections :
    frameOverall <- tkframe(W.main, background=.FrameBackground, borderwidth=2)

    ## Zone d'information sur l'espace de travail :
    tkgrid(ResumerEspaceTravail <-
           tklabel(frameOverall,
                   text=paste("Espace de travail : ", "non s�lectionn�."),
                   background=.FrameBackground,
                   width=117,
                   font=tkfont.create(size=9)))
    tkbind(ResumerEspaceTravail, "<Button-1>",
           expression(tryCatch(browseURL(.dataEnv$filePathes["ws"]),
                               error=function(e){})))
    tkbind(ResumerEspaceTravail,  "<Enter>",
           expression(tkconfigure(ResumerEspaceTravail, cursor="hand2")))
    tkbind(ResumerEspaceTravail,  "<Leave>",
           expression(tkconfigure(ResumerEspaceTravail, cursor="arrow")))

    tkgrid(ResumerAMPetType <-
           tklabel(frameOverall,
                   text="Aucun jeu de donn�es charg� pour l'instant !",
                   background=.FrameBackground,
                   font=tkfont.create(size=9)))

    tkgrid.configure(ResumerEspaceTravail, sticky="ew", columnspan=3)
    tkgrid.configure(ResumerAMPetType, sticky="ew", columnspan=3)


    gestionMSGaide.f("etapeImport", env=.baseEnv) ## [???]

    F.titreSelect <- tkframe(frameOverall, relief="groove", borderwidth=0, background="#FFEE70")
    ## tkgrid.propagate(frameOverall, "1")

    ## Bouton de restauration des donn�es originales :
    B.DataRestore <- tkbutton(F.titreSelect, text="Restaurer les donn�es",
                              command=function()
                          {
                              restoreData.f(baseEnv=.baseEnv, dataEnv=.dataEnv)
                          })

    ## Titre des crit�res de s�lection :
    L.criteres <- tklabel(F.titreSelect, text="       Crit�re(s) de s�lection :", background="#FFEE70",
                          font=tkfont.create(size=8), foreground="darkred"## , width=110
                          )


    ## Affichage/placement du titre et du bouton:
    tkpack(B.DataRestore, side="right", pady=2, padx=5)
    tkpack(L.criteres, pady=2)

    tkconfigure(B.DataRestore, state="disabled") # Bouton de restauration d�sactiv� en premier lieu.


    ## Info sur les crit�res de s�lection :
    frameUpper <- tkframe(frameOverall, relief="groove", borderwidth=0)

    MonCritere <- tklabel(frameUpper, text="Tout",
                          wraplength=750, justify="left",
                          background=.FrameBackground)

    ## #########################################################################
    ## Placement des �l�ments d'info sur les s�lections :

    ## S�parateur :
    tkgrid(ttkseparator(frameOverall, orient="horizontal"), columnspan=3, sticky="ew")

    ## Placement du titre de s�lection (frame)
    tkgrid(F.titreSelect, sticky="ew", columnspan=3)

    tkgrid(MonCritere)

    tkgrid(frameUpper, columnspan=3, pady=5)

    tkgrid(frameOverall)
    tkgrid.configure(frameOverall, columnspan=4, padx=5, pady=10, sticky="ew")


    ## #############################################################
    ## Zone d'information sur les donn�es et s�lections (tableau) :

    ## Matrice pour remplire un tclarray (pour convenance) :
    ArrayEtatFichier <- matrix(c("Type de fichier", "Nom de fichier", "Nb champs", "Nb enregistrements", "",
                                 " Fichier d'unit�s d'observations ", "non s�lectionn�", "NA", "NA", "NA",
                                 " Fichier d'observations ", "non s�lectionn�", "NA", "NA", "NA",
                                 " R�f�rentiel esp�ce g�n�ral ", "non s�lectionn�", "NA", "NA", "NA",
                                 " R�f�rentiel esp�ce local (optionnel) ", "non s�lectionn�", "NA", "NA", "NA",
                                 " R�f�rentiel spatial (optionnel) ", "non s�lectionn�", "NA", "NA", "NA"),
                               nrow=6, ncol=5, byrow=TRUE)

    ## Cr�ation d'un tableau tcl :
    tclarray <- tclArray()

    ## ...et remplissage de celui-ci :
    for (i in 0:(nrow(ArrayEtatFichier) - 1))
    {
        for (j in 0:(ncol(ArrayEtatFichier) - 1))
        {
            tclarray[[i, j]] <- ArrayEtatFichier[i+1, j+1] # !!! d�calage de 1 dans les indices.
        }
    }

    ## Cr�ation d'une table tk utilisant ce tableau :
    tclRequire("Tktable")

    table1 <-tkwidget(frameOverall, "table", variable=tclarray,
                      rows=6, cols=4, titlerows=1, # seulement 4 colonnes au d�part => ajout ult�rieur.
                      selectmode="extended",
                      colwidth=15, background="white")

    ## Affichage et placement de la table :
    tkgrid(table1, columnspan=3, sticky="ew")

    ## Nombres effectifs "d'esp�ces" et d'unit�s d'observation :
    ResumerSituationEspecesSelectionnees <-
        tklabel(frameOverall,
                text="-> Nombre de codes esp�ce dans le fichier d'observation : NA",
                background=.FrameBackground, state="disabled")

    ResumerSituationUnitobsSelectionnees <-
        tklabel(frameOverall,
                text="-> Nombre d'unit�s d'observation dans le fichier d'observation : NA",
                background=.FrameBackground, state="disabled")

    tkgrid(ResumerSituationEspecesSelectionnees, columnspan=3, sticky="w", padx=5)

    tkgrid(ResumerSituationUnitobsSelectionnees, sticky="w", columnspan=3, padx=5)

    ## #########################################################################
    ## Suivi des op�rations :

    F.log <- tkframe(W.main, bg="white")
    ## tkgrid.propagate(F.log, 1)

    tkgrid(F.log, sticky="ew", columnspan=4, padx=5, pady=5)

    TitreSuiviOperation <- tklabel(F.log, text="Rapport de chargement/s�lection/export :", background="#FFFFFF",
                                   anchor="w")

    ## ... zone de texte d�di�e avec son "ascenceur" :
    scr <- tkscrollbar(F.log, repeatinterval=2,
                       command=function(...)tkyview(txt.w, ...))

    txt.w <- tktext(F.log, bg="white",  height=9,
                    yscrollcommand=function(...)tkset(scr, ...),
                    wrap="word")            # �viter les coupures de mots.

    ## Dans la r�partition d'espace entre les deux colonne,
    ## on attribue tout l'espace suppl�mentaire � la premi�re
    tkgrid.columnconfigure(F.log, 1, minsize=1, weight=0)
    tkgrid.columnconfigure(F.log, 0, weight=9)

    tkgrid(TitreSuiviOperation, columnspan=2, sticky="ew")

    tkgrid(txt.w, scr, sticky="nsew")

    tcl("update")
    tkfocus(txt.w)

    runLog.f(msg=c("Chargement de l'interface :"))

    tkfocus(W.main)

    ## ##############################################################################
    ## Gestion du redimentionnement de la fen�tre principale :
    w.old <- as.numeric(tkwinfo("width", W.main))

    tkbind(W.main, "<Configure>",
            function(w, W)
           {
               w <- as.numeric(w)

               if ((w.tmp <- get("w.old", envir=.baseEnv)) != w &&
                   W == as.character(tkwinfo("parent", F.menu)))
               {
                   assign("w.old", as.numeric(w), envir=.baseEnv)

                   ## Largeur de ResumerEspaceTravail (d�fini la largeur des autres �l�ments) en caract�res :
                   textWidthChar <- as.numeric(tail(unlist(strsplit(tclvalue(tkconfigure(ResumerEspaceTravail,
                                                                                         width=NULL)),
                                                                    " ")),
                                                    1))

                   ## Largeur de ResumerEspaceTravail en pixels :
                   textwidthPix <- as.numeric(tkwinfo("width", ResumerEspaceTravail))

                   ## Rapport de conversion pixels/caract�res :
                   ratioPixChar <- textwidthPix / textWidthChar

                   ## Ajout du nombre de caract�res n�cessaires � la largeur de ResumerEspaceTravail pour
                   ## correctement fitter la largeur de fen�tre :
                   tkconfigure(ResumerEspaceTravail, width=textWidthChar + floor((w - w.tmp) / ratioPixChar))

                   tcl("update")

                   ## Ajout d'un caract�re suppl�mentaire s'il y a (encore) de la place :
                   if (w - (as.numeric(tkwinfo("width", ResumerEspaceTravail)) + ratioPixChar) >= 14)
                   {
                       tkconfigure(ResumerEspaceTravail,
                                   width=textWidthChar + 1 + floor((w - w.tmp) / ratioPixChar))
                   }else{}


                   tcl("update")
               }
           })

    ## Gestion des �v�nements dans la fen�tre W.main (toplevel) => raccourcis claviers :
    tkbind(W.main, "<Control-a>",
           function()
       {
           tryCatchLoad.f(assign("Data",            # [!!!] temporaire  [yr: 13/12/2011]
                                 loadDefault.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                                 envir=.GlobalEnv),
                          baseEnv=.baseEnv)
       })

    tkbind(W.main, "<Control-A>", function()
       {
           tryCatchLoad.f(assign("Data",            # [!!!] temporaire  [yr: 13/12/2011]
                                 loadDefault.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                                 envir=.GlobalEnv),
                          baseEnv=.baseEnv)
       })

    tkbind(W.main, "<Control-n>",
           function()
       {

           tryCatchLoad.f(assign("Data",            # [!!!] temporaire  [yr: 13/12/2011]
                                 loadManual.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                                 envir=.GlobalEnv),
                          baseEnv=.baseEnv)
       })

    tkbind(W.main, "<Control-N>",
           function()
       {

           tryCatchLoad.f(assign("Data",            # [!!!] temporaire  [yr: 13/12/2011]
                                 loadManual.f(baseEnv=.baseEnv, dataEnv=.dataEnv),
                                 envir=.GlobalEnv),
                          baseEnv=.baseEnv)
       })

    tkbind(W.main, "<Control-r>", function(){testfileref.f(dataEnv=.dataEnv, baseEnv=.baseEnv)})
    tkbind(W.main, "<Control-R>", function(){testfileref.f(dataEnv=.dataEnv, baseEnv=.baseEnv)})

    ## tkbind(W.main, "<Control-F1>", aide.f)
    ## tkbind(W.main, "<Control-?>", aide.f)
    tkbind(W.main, "<Control-p>",
           function()
       {
           VoirPlanEchantillonnage.f(dataEnv=.dataEnv)
       })
    tkbind(W.main, "<Control-P>",
           function()
       {
           VoirPlanEchantillonnage.f(dataEnv=.dataEnv)
       })

    tkbind(W.main, "<Control-e>",
           function()
       {
           VoirInformationsDonneesEspeces.f(dataEnv=.dataEnv, image=imageAMP)
       })
    tkbind(W.main, "<Control-E>",
           function()
       {
           VoirInformationsDonneesEspeces.f(dataEnv=.dataEnv, image=imageAMP)
       })

    tkbind(W.main, "<Control-u>",
           function()
       {
           VoirInformationsDonneesUnitobs.f(dataEnv=.dataEnv, image=imageAMP)
       })
    tkbind(W.main, "<Control-U>",
           function()
       {
           VoirInformationsDonneesUnitobs.f(dataEnv=.dataEnv, image=imageAMP)
       })

    ## tkbind(W.main, "<Control-o>", test.f)
    ## tkbind(W.main, "<Control-O>", test.f)

    tkbind(W.main, "<Control-q>", function()
       {
           quitConfirm.f(W.main)
       })
    tkbind(W.main, "<Control-Q>", function()
       {
           quitConfirm.f(W.main)
       })

    ## Largeur des colonnes:
    ColAutoWidth.f(table1)

    ## Placement de la fen�tre :
    tcl("update")
    winSmartPlace.f(W.main)
}








### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
