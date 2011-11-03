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

tkwm.title(tm, "Calcul d'indicateurs PAMPA WP2")

tkwm.maxsize(tm, 1000, 768)             # taille maximale de la fenetre
tkwm.minsize(tm, 800, 550)              # taille minimale de la fenetre

########################################################################################################################
## Menus :

F.menu <- tkframe(tm)

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
tkconfigure(MB.import, menu=import, activebackground="#81a5dc")
tkconfigure(MB.selection, menu=selection, activebackground="#81a5dc")
tkconfigure(MB.traitement, menu=traitement, activebackground="#81a5dc")
tkconfigure(MB.analyse, menu=analyse, activebackground="#81a5dc")
tkconfigure(MB.outils, menu=outils, activebackground="#81a5dc")
tkconfigure(MB.pampainfos, menu=pampainfos, activebackground="#81a5dc")

## Bouton pour quitter :
B.quit.main <- tkbutton(F.menu, text=" Quitter... ",
                        command=function()
                    {
                        quitConfirm.f(tm)
                    },
                        activebackground="#81a5dc")

## Placement des menus :
tkpack(MB.import, MB.selection, MB.traitement, MB.analyse, MB.outils, MB.pampainfos,
       side="left")
tkpack(B.quit.main, side="right", padx=2, pady=2)

tkgrid(F.menu, sticky="ew", columnspan=4)


## Remplissage des menus :

########################################
## Menu deroulant des Donn�es :

## Imports :
tkadd(import, "command", label="Choix des dossiers et fichiers de donn�es...",
      accelerator="CTRL+N", command = {openfile.f})

tkadd(import, "command", label="Dossiers et fichiers par defaut", accelerator="CTRL+A",
      command = function()
  {
      rm(fileName1, fileName2, fileName3, envir=.GlobalEnv)
      eval(source("./Exec/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.
      opendefault.f()                                                      # chargement des donn�es.
  })

## Informations sur les donn�es :
tkadd(import, "separator")

tkadd(import, "command", label="Test du r�f�rentiel (esp�ces concern�es)", underline=9, accelerator="CTRL+R",
      state="disabled", command = testfileref.f)

## tkadd(import, "command", label="Test des donn�es import�es", underline=0,
##       accelerator="CTRL+T", state="disabled")  ## [sup] [yr: 13/01/2011]

## tkadd(import, "command", label="Champs de 'TableMetrique' et TableBiodiv", underline=0, accelerator="CTRL+M",
##       state="disabled")

tkadd(import, "command", label="Voir le plan d'�chantillonnage", accelerator="CTRL+P", state="disabled",
      command = VoirPlanEchantillonnage.f)

tkadd(import, "command", label="Info donn�es par esp�ces", state="disabled", accelerator="CTRL+E",
      command = VoirInformationsDonneesEspeces.f)

tkadd(import, "command", label="Info donn�es par unit� d'observation",
      state="disabled", accelerator="CTRL+U",
      command = VoirInformationsDonneesUnitobs.f)

########################################
## S�lection et recalcul :

tkadd(selection, "command", label="Selon un champ du r�f�rentiel esp�ce...",
      command = function ()
  {
      SelectionUnCritereEsp.f()
      winRaise.f(tm)
  })

tkadd(selection, "command", label="Selon un champ des unit�s d'observation...",
      command = function ()
  {
      SelectionUnCritereUnitobs.f()
      winRaise.f(tm)
  })

tkadd(selection, "separator")
tkadd(selection, "checkbutton", label="Par liste d'esp�ces (fichier)",
      ## variable=SelectListEsp, # � quoi sert cette variable ? [???]
      ## onvalue=1, offvalue=0,
      command = choixespeces.f, state="disabled")

## Restauration des donn�es :
tkadd(selection, "separator")
tkadd(selection, "command", label="Restaurer les donn�es originales",
      state="disabled",
      command = function ()
  {
      RestaurerDonnees.f()
      winRaise.f(tm)
  })

########################################
## Graphiques :

## Info :
tkadd(traitement, "separator")

tkadd(traitement, "command", label="Repr�sentation par esp�ce ou  classe de taille d'esp�ce :",
      foreground="darkred", background="#dadada",
      state="normal")

## Boxplots esp�ces :
tkadd(traitement, "command", label="Boxplots m�trique /esp�ce/unit� d'observation...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("boxplot.esp")
      winRaise.f(tm)
  })

## Barplots esp�ces :
tkadd(traitement, "command", label="Fr�quences d'occurrence (/esp�ce sur des unit� d'observation)...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("freq_occurrence")
      winRaise.f(tm)
  })

## Info :
tkadd(traitement, "separator")

tkadd(traitement, "command", label="Agr�gation de plusieurs esp�ces ou classes de taille par unit� d'observation :",
      foreground="darkred", background="#dadada",
      state="normal")

## Boxplots unitobs :
tkadd(traitement, "command", label="Boxplots m�trique /unit� d'observation (dont biodiversit�)...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("boxplot.unitobs")
      winRaise.f(tm)
  })

## Barplots unitobs :
tkadd(traitement, "command", label="Fr�quences d'occurrence (/facteurs d'unit� d'observation)...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("freq_occurrence.unitobs")
      winRaise.f(tm)
  })

########################################
## Analyses :

## Menus d�chirables...

## ...mod�les inf�rentiels :
tkadd(analyse, "cascade", label="Mod�les inf�rentiels", menu=modelesInferentiels,
      background="#FFFBCF")

## ...mod�les exploratoires (� faire) :
tkadd(analyse, "cascade", label="Analyses exploratoires", menu=analysesExplo, state="disabled")

## Mod�les inf�rentiels :

## Info :
tkadd(modelesInferentiels, "command", label="Analyse par esp�ce ou classe de taille d'esp�ce :",
      foreground="darkred", background="#dadada",
      state="normal")

## (G)LMs esp�ces
tkadd(modelesInferentiels, "command", label="Mod�les lin�aires m�trique /esp�ce/unit� d'observation...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("modele_lineaire")
      winRaise.f(tm)
  })

## MRT esp�ces :
tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                      " m�trique / esp�ces / unit� d'observation...", sep=""),
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("MRT.esp")
      winRaise.f(tm)
  })

## Info :
tkadd(modelesInferentiels, "separator")

tkadd(modelesInferentiels, "command", label="Agr�gation de plusieurs esp�ces ou classes de taille par unit� d'observation :",
      foreground="darkred", background="#dadada",
      state="normal")

## (G)LMs unitobs :
tkadd(modelesInferentiels, "command", label="Mod�les lin�aires m�trique /unit� d'observation (dont biodiversit�)...",
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("modele_lineaire.unitobs")
      winRaise.f(tm)
  })

## MRT unitobs :
tkadd(modelesInferentiels, "command", label=paste("Arbres de r�gression multivari�e,",
                                      " m�trique /unit� d'observation (dont biodiversit�)...", sep=""),
      background="#FFFBCF",
      command=function ()
  {
      selectionVariables.f("MRT.unitobs")
      winRaise.f(tm)
  })


########################################
## Menu deroulant des outils :

tkadd(outils, "command", label="Options graphiques...", command = choixOptionsGraphiques.f, state="normal")
tkadd(outils, "separator")

tkadd(outils, "command", label="�diter le fichier de configuration",
      command=function()
  {
      shell.exec(paste(basePath, "/Exec/config.r", sep=""))
  })
tkadd(outils, "separator")

tkadd(outils, "command", label="Cr�er un rapport de bug", state="normal",
      command = function()
  {
      shell.exec(paste(basePath, "/Exec/Doc/Rapport_bug_PAMPA-WP2.dot", sep=""))
  })
tkadd(outils, "separator")

tkadd(outils, "command", label="mise � jour (site de t�l�chargement)", state="normal",
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
      command = function()
  {
      browseURL("http://www.projet-pampa.fr/wiki/doku.php/wp2:wp2#documentation")
  })

tkadd(pampainfos, "command", label="Documentation (locale)",
      command = function()
  {
      shell.exec(dir(paste(basePath, "/Exec/Doc", sep=""),
                     full.names=TRUE)[grep("^Guide",
                                           dir(paste(basePath, "/Exec/Doc", sep="")), perl=TRUE)])
  })

tkadd(pampainfos, "command", label="Forum d'entraide",
      command = function()
  {
      browseURL("http://www.projet-pampa.fr/forum/viewforum.php?id=2")
  })

## tkadd(pampainfos, "command", label="Nouveaut�s de la plateforme (locale)",
##       command = function()
##   {
##       shell.exec(dir(paste(basePath, "/Exec/Doc", sep=""),
##                      full.names=TRUE)[grep("^Annexe_Guide",
##                                            dir(paste(basePath, "/Exec/Doc", sep="")), perl=TRUE)])
##   })

## � propos... :
tkadd(pampainfos, "separator")
tkadd(pampainfos, "command", label="� propos de la plateforme...", command = apropos.f)


########################################################################################################################
## Ajhout des autres �l�ments :

## Frame principale :
## topFrame <- tkframe(tm, relief="groove", borderwidth=2)

## Logo :
imageAMP <- tclVar()
tcl("image", "create", "photo", imageAMP, file=fileimage) # cr�e un objet Tk image pour l'interface.

imgAsLabel <- tklabel(tm, image=imageAMP, bg="white") # -> label avec image.

## Frames d'aide :
titreAideContextuelle <- tklabel(tm, width=106,
                                 text=" Ci dessous l'aide contextuelle",
                                 background="#FFFFFF")

helpframe <- tktext(tm, bg="yellow", font="arial",
                    width=71, height=3, # taille.
                    relief="groove", borderwidth=2)


tkgrid(imgAsLabel, titreAideContextuelle)
tkgrid(imgAsLabel, helpframe)
## tkgrid(imgAsLabel, topFrame)

tkgrid.configure(imgAsLabel, sticky="w", rowspan=3) # L'image fait trois lignes de haut. [!!!]

## puis on place les 3 objets � cot� de l'image :
tkgrid.configure(titreAideContextuelle, columnspan=2, row=1, column=1, sticky="n")
tkgrid.configure(helpframe, sticky="e", columnspan=2, row=2, column=1, sticky="n")

## Suivi des op�rations :
TitreSuiviOperation <- tklabel(tm, text="Suivi des op�rations")

tkgrid(TitreSuiviOperation, columnspan=1, sticky="w")

## ... zone de texte d�di�e avec son "ascenceur" :
scr <- tkscrollbar(tm, repeatinterval=2,
                   command=function(...)tkyview(txt.w, ...))

txt.w <- tktext(tm, bg="white", width=90, height=15,
                yscrollcommand=function(...)tkset(scr, ...),
                wrap="word")            # �viter les coupures de mots.

tkgrid.configure(txt.w, scr)            # [???]

tkgrid.configure(txt.w, sticky="nsew", columnspan=3) # Faire bien co�ncider les bords de la zone de texte
tkgrid.configure(scr, sticky="nsw", column=3)        # et de l'ascenceur.

## Zone d'information sur l'espace de travail :
tkgrid.configure(ResumerEspaceTravail <-
                 tklabel(tm,
                         text=paste("Espace de travail : ", "non s�lectionn�"),
                         width="134"))

tkgrid.configure(ResumerAMPetType <-
                 tklabel(tm,
                         text="Aucun jeu de donn�e s�lectionn� pour le moment",
                         width="134"))

tkgrid.configure(ResumerEspaceTravail, sticky="w", columnspan=4)
tkgrid.configure(ResumerAMPetType, sticky="w", columnspan=4)


gestionMSGaide.f("etapeImport") ## [???]

###############################################################
## Zone d'information sur les donn�es et s�lections (tableau) :

## Cr�ation d'un tableau tcl :
ArrayEtatFichier <- matrix(c("Type de fichier", "Source", "Nb enregistrements", "Nb champs", "",
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

table1 <-tkwidget(tm, "table", variable=tclarray,
                  rows=4, cols=4, titlerows=1, # seulement 4 colonnes au d�part => ajout ult�rieur.
                  selectmode="extended",
                  colwidth=15, background="white")

## Affichage et placement de la table :
tkgrid(table1)
tkgrid.configure(table1, columnspan=3, sticky="ew")

########################################################################################################################
gestionMSGinfo.f("start")

runLog.f(msg=c("Chargement de l'interface :"))

tkfocus(tm)

####################################
## Frame d'info sur les s�lections :
frameOverall <- tkframe(tm)

tkgrid(tklabel(frameOverall, text="Crit�res de s�lection",
               relief="groove", borderwidth=2, width=135))

tkgrid.configure(frameOverall, columnspan=4)

frameUpper <- tkframe(frameOverall, borderwidth=2)

## Info sur les crit�res de s�lection :
MonCritere <- tklabel(frameUpper, text="Tout",
                      wraplength=750, justify="left")
tkgrid(MonCritere)

tkgrid(frameUpper)
tkgrid(frameOverall)

ResumerSituationEspecesSelectionnees <-
    tklabel(frameOverall,
            text="-> Nombre d'esp�ces dans le fichier d'observation : NA")

tkgrid(ResumerSituationEspecesSelectionnees)
tkgrid.configure(ResumerSituationEspecesSelectionnees, columnspan=3, sticky="w")

ResumerSituationUnitobsSelectionnees <-
    tklabel(frameOverall,
            text="-> Nombre d'unit�s d'observation dans le fichier d'observation : NA")

tkgrid(ResumerSituationUnitobsSelectionnees)
tkgrid.configure(ResumerSituationUnitobsSelectionnees, columnspan=3, sticky="w")

##############################
## Boutons de bas de fen�tre :

## Restauration des donn�es originales :
button.DataRestore <- tkbutton(tm, text="Restaurer les donn�es", command=RestaurerDonnees.f)
tkgrid(button.DataRestore, pady=5, padx=5, sticky="w")

tkconfigure(button.DataRestore, state="disabled")

## Fermeture de tous les graphiques :
button.widgetOFF <- tkbutton(tm, text="Fermer les graphiques", command=graphics.off)

tkgrid(button.widgetOFF, column=2,
       row=tkObj.gridInfo.f(button.DataRestore)["row"], # m�me ligne que la restauration des donn�es
       columnspan=2, sticky="e", pady=5, padx=5)

####################################################################################################
## Gestion des �v�nements dans la fen�tre tm (toplevel) => raccourcis claviers :
tkbind(tm, "<Control-a>",
       function()
   {
       eval(source("./Exec/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.
       opendefault.f()
   })
tkbind(tm, "<Control-A>", function()
   {
       eval(source("./Exec/config.r", encoding="latin1"), envir=.GlobalEnv) # rechargement de la configuration.
       opendefault.f()
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
