## ################################################################################
## Nom                  : interface.r
## Objet                : interface du Programme de calcul des m�triques biodiversit� et ressources
## Input                : TXT
## Output               : CSV
## Toutes les fonctions appel�es dans ce fichier � partir de widjet devront appartenir au fichier "command.r"
## Auteurs               : Bastien Preuss / J�r�mie Habasque / Romain David
## R version            : 2.10.1
## Date de cr�ation     : F�vrier 2008
## Date de modification : Avril 2010
## ################################################################################

test.f <- function ()
{
    tkmessageBox(message="En cours de programation, patience")
}

## #################################################################################
## FEN�TRE PRINCIPALE
## #################################################################################

tm <- tktoplevel(height=600, width=800, background="#FFFFFF")

tkwm.title(tm, "Indicateurs relatifs � la biodiversit� et aux ressources")

tkwm.maxsize(tm,
             tkwinfo("screenwidth", tm),
             as.numeric(tclvalue(tkwinfo("screenheight", tm))) - 30)             # taille maximale de la fenetre
tkwm.minsize(tm, 800, 500)              # taille minimale de la fenetre

## Couleurs :
.MenuBackground <- "#FFFBCF"
.FrameBackground <- "#FFF6BF"
.TopMenueBackground <- "#CBDDED"

########################################################################################################################
## Menus :

F.menu <- tkframe(tm, background=.TopMenueBackground)

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
arbreRegression <- tkmenu(analyse, tearoff=FALSE)
modelesInferentiels <- tkmenu(analyse, tearoff=FALSE)
analysesExplo <- tkmenu(analyse, tearoff=FALSE)

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
                        quitConfirm.f(tm)
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


## Remplissage des menus :

########################################
## Menu deroulant des Donn�es :

## Imports :
tkadd(import, "command", label="Choix des dossiers et fichiers de donn�es...",
      accelerator="CTRL+N", command = {openfile.f},
      background=.MenuBackground)

tkadd(import, "command", label="Dossiers et fichiers par defaut", accelerator="CTRL+A",
      command = function()
  {
      rm(fileName1, fileName2, fileName3, envir=.GlobalEnv)
      eval(source("./Scripts_Biodiv/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.

      testVar.f(requiredVar=get("requiredVar", envir=.GlobalEnv), env = .GlobalEnv)

      ## chargement (conditionnel) des donn�es :
      if (all(sapply(get("requiredVar", envir=.GlobalEnv), exists)))
      {
          opendefault.f()
      }else{}
  },
      background=.MenuBackground)

## Informations sur les donn�es :
tkadd(import, "separator", background=.MenuBackground)

tkadd(import, "command", label="Test du r�f�rentiel (esp�ces concern�es)", underline=9, accelerator="CTRL+R",
      state="disabled", command = testfileref.f,
      background=.MenuBackground)

## tkadd(import, "command", label="Test des donn�es import�es", underline=0,
##       accelerator="CTRL+T", state="disabled")  ## [sup] [yr: 13/01/2011]

## tkadd(import, "command", label="Champs de 'TableMetrique' et TableBiodiv", underline=0, accelerator="CTRL+M",
##       state="disabled")

tkadd(import, "command", label="Plan d'�chantillonnage basique", accelerator="CTRL+P", state="disabled",
      command = VoirPlanEchantillonnage.f,
      background=.MenuBackground)

tkadd(import, "command", label="Info donn�es par esp�ces", state="disabled", accelerator="CTRL+E",
      command = VoirInformationsDonneesEspeces.f,
      background=.MenuBackground)

tkadd(import, "command", label="Info donn�es par unit� d'observation",
      state="disabled", accelerator="CTRL+U",
      command = VoirInformationsDonneesUnitobs.f,
      background=.MenuBackground)

########################################
## S�lection et recalcul :

tkadd(selection, "command", label="Selon un champ du r�f�rentiel esp�ce...",
      background=.MenuBackground,
      command = function ()
  {
      SelectionUnCritereEsp.f()
      winRaise.f(tm)
  })

tkadd(selection, "command", label="Selon un champ des unit�s d'observation...",
      background=.MenuBackground,
      command = function ()
  {
      SelectionUnCritereUnitobs.f()
      winRaise.f(tm)
  })

tkadd(selection, "separator", background=.MenuBackground)
tkadd(selection, "checkbutton", label="Par liste d'esp�ces (fichier)",
      background=.MenuBackground,
      ## variable=SelectListEsp, # � quoi sert cette variable ? [???]
      ## onvalue=1, offvalue=0,
      command = choixespeces.f, state="disabled")

## Restauration des donn�es :
tkadd(selection, "separator", background=.MenuBackground)
tkadd(selection, "command", label="Restaurer les donn�es originales",
      background=.MenuBackground,
      state="disabled",
      command = function ()
  {
      RestaurerDonnees.f()
      winRaise.f(tm)
  })

########################################
## Graphiques :

## Info :
tkadd(traitement, "separator", background=.MenuBackground)

tkadd(traitement, "command", label="Par esp�ce ou classe de taille d'esp�ce :",
      foreground="darkred", background="#dadada",
      font=tkfont.create(weight="bold", size=8),
      state="normal")

## Boxplots esp�ces :
tkadd(traitement, "command", label="Boxplots, m�trique /esp�ce/unit� d'observation...",
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("boxplot.esp")
      winRaise.f(tm)
  })

## Barplots esp�ces :
tkadd(traitement, "command", label="Fr�quences d'occurrence (/esp�ce sur des unit� d'observation)...",
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("freq_occurrence")
      winRaise.f(tm)
  })

## Info :
tkadd(traitement, "separator", background=.MenuBackground)

tkadd(traitement, "command", label="Plusieurs esp�ces ou classes de taille, agr�g�es par unit� d'observation :",
      foreground="darkred", background="#dadada",
      font=tkfont.create(weight="bold", size=8),
      state="normal")

## Boxplots unitobs :
tkadd(traitement, "command", label="Boxplots, m�trique /unit� d'observation (dont biodiversit�)...",
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("boxplot.unitobs")
      winRaise.f(tm)
  })

## Barplots unitobs :
tkadd(traitement, "command", label="Fr�quences d'occurrence (/facteurs d'unit� d'observation)...",
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("freq_occurrence.unitobs")
      winRaise.f(tm)
  })

########################################
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
      selectionVariables.f("modele_lineaire")
      winRaise.f(tm)
  })

## MRT esp�ces :
tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                      " m�trique / esp�ces / unit� d'observation...", sep=""),
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("MRT.esp")
      winRaise.f(tm)
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
      selectionVariables.f("modele_lineaire.unitobs")
      winRaise.f(tm)
  })

## MRT unitobs :
tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                      " m�trique /unit� d'observation (dont biodiversit�)...", sep=""),
      background=.MenuBackground,
      command=function ()
  {
      selectionVariables.f("MRT.unitobs")
      winRaise.f(tm)
  })


########################################
## Menu deroulant des outils :

tkadd(outils, "command", label="Options graphiques...", command = choixOptionsGraphiques.f, state="normal",
      background=.MenuBackground)
tkadd(outils, "separator", background=.MenuBackground)

tkadd(outils, "command", label="�diter le fichier de configuration",
      background=.MenuBackground,
      command=function()
  {
      shell.exec(paste(basePath, "/Scripts_Biodiv/config.r", sep=""))
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


########################################
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


########################################################################################################################
## Ajout des autres �l�ments :

## Frame principale :
## topFrame <- tkframe(tm, relief="groove", borderwidth=2)

## Logo :
imageAMP <- tclVar()
tcl("image", "create", "photo", imageAMP, file=fileimage) # cr�e un objet Tk image pour l'interface.

F.aide <- tkframe(tm, background="white")

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

## tkgrid(tklabel(tm, text="", background="white"))
## tkgrid(imgAsLabel, topFrame)

tkgrid.configure(imgAsLabel, sticky="nsew", rowspan=2,
                 padx=7) # L'image fait trois lignes de haut. [!!!]

## ## puis on place les 3 objets � cot� de l'image :
tkgrid.configure(titreAideContextuelle, columnspan=1, row=0, column=1, sticky="ws", padx=5)
tkgrid.configure(helpframe, columnspan=1, row=1, column=1, sticky="ewn", padx=5)

tkgrid(F.aide, columnspan=4, sticky="ew", pady=5)

########################################################################################################################



########################################################################################################################


####################################
## Frame d'info sur les fichiers et s�lections :
frameOverall <- tkframe(tm, background=.FrameBackground, borderwidth=2)

## Zone d'information sur l'espace de travail :
tkgrid(ResumerEspaceTravail <-
       tklabel(frameOverall,
               text=paste("Espace de travail : ", "non s�lectionn�."),
               background=.FrameBackground,
               width=117,
               font=tkfont.create(size=9)))

tkgrid(ResumerAMPetType <-
       tklabel(frameOverall,
               text="Aucun jeu de donn�es charg� pour l'instant !",
               background=.FrameBackground,
               font=tkfont.create(size=9)))

tkgrid.configure(ResumerEspaceTravail, sticky="ew", columnspan=3)
tkgrid.configure(ResumerAMPetType, sticky="ew", columnspan=3)


gestionMSGaide.f("etapeImport") ## [???]

F.titreSelect <- tkframe(frameOverall, relief="groove", borderwidth=0, background="#FFEE70")
## tkgrid.propagate(frameOverall, "1")

## Restauration des donn�es originales :
B.DataRestore <- tkbutton(F.titreSelect, text="Restaurer les donn�es", command=RestaurerDonnees.f)

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



## Placement des �l�ments d'info sur les s�lections :

## S�parateur :
tkgrid(ttkseparator(frameOverall, orient="horizontal"), columnspan=3, sticky="ew")

## Placement du titre de s�lection (frame)
tkgrid(F.titreSelect, sticky="ew", columnspan=3)

tkgrid(MonCritere)

tkgrid(frameUpper, columnspan=3, pady=5)

tkgrid(frameOverall)
tkgrid.configure(frameOverall, columnspan=4, padx=5, pady=10, sticky="ew")


###############################################################
## Zone d'information sur les donn�es et s�lections (tableau) :

## Cr�ation d'un tableau tcl :
ArrayEtatFichier <- matrix(c("Type de fichier", "Nom de fichier", "Nb champs", "Nb enregistrements", "",
                             "Fichier d'unit�s d'observations", "non s�lectionn�", "NA", "NA", "NA",
                             "Fichier d'observations ", "non s�lectionn�", "NA", "NA", "NA",
                             "R�f�rentiel esp�ce ", "non s�lectionn�", "NA", "NA", "NA"),
                           nrow=4, ncol=5, byrow=TRUE)

tclarray <- tclArray()

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
                  rows=4, cols=4, titlerows=1, # seulement 4 colonnes au d�part => ajout ult�rieur.
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


########################################################################################################################

## Suivi des op�rations :

F.log <- tkframe(tm, bg="white")
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

tkfocus(tm)

##############################
## Boutons de bas de fen�tre :

## tkgrid(button.widgetOFF, column=2,
##        row=tkObj.gridInfo.f(button.DataRestore)["row"], # m�me ligne que la restauration des donn�es
##        columnspan=2, sticky="e", pady=5, padx=5)

####################################################################################################
## Gestion des �v�nements dans la fen�tre tm (toplevel) => raccourcis claviers :
tkbind(tm, "<Control-a>",
       function()
   {
       eval(source("./Scripts_Biodiv/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.

       testVar.f(requiredVar=get("requiredVar", envir=.GlobalEnv), env = .GlobalEnv)

       if (all(sapply(get("requiredVar", envir=.GlobalEnv), exists)))
       {
           opendefault.f()
       }else{}
   })
tkbind(tm, "<Control-A>", function()
   {
       eval(source("./Scripts_Biodiv/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.

       testVar.f(requiredVar=get("requiredVar", envir=.GlobalEnv), env = .GlobalEnv)

       if (all(sapply(get("requiredVar", envir=.GlobalEnv), exists)))
       {
           opendefault.f()
       }else{}
   })

tkbind(tm, "<Control-n>", openfile.f)
tkbind(tm, "<Control-N>", openfile.f)

tkbind(tm, "<Control-r>", testfileref.f)
tkbind(tm, "<Control-R>", testfileref.f)

## tkbind(tm, "<Control-F1>", aide.f)
## tkbind(tm, "<Control-?>", aide.f)
tkbind(tm, "<Control-p>", VoirPlanEchantillonnage.f)
tkbind(tm, "<Control-P>", VoirPlanEchantillonnage.f)

tkbind(tm, "<Control-e>", VoirInformationsDonneesEspeces.f)
tkbind(tm, "<Control-E>", VoirInformationsDonneesEspeces.f)

tkbind(tm, "<Control-u>", VoirInformationsDonneesUnitobs.f)
tkbind(tm, "<Control-U>", VoirInformationsDonneesUnitobs.f)

tkbind(tm, "<Control-o>", test.f)
tkbind(tm, "<Control-O>", test.f)

tkbind(tm, "<Control-q>", function()
   {
       quitConfirm.f(tm)
   })
tkbind(tm, "<Control-Q>", function()
   {
       quitConfirm.f(tm)
   })


## Largeur des colonnes:
ColAutoWidth.f(table1)

## Placement de la fen�tre :
winSmartPlace.f(tm)
