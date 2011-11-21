################################################################################
# Nom               : TopMenu.r
# Type              : Programme
# Objet             : Constitution du menu d'interface g�n�ral d'o� l'on acc�de � toutes les fonctions de calculs
#                     Rajout de tableaux et de messages d'information sur les donn�es import�es
#                     Ce programme commence par l'appel des diff�rents scripts contenant les fonctions de calcul
# Input             : clic souris
# Output            : lancement de fonctions
# Auteur            : Elodie Gamp
# R version         : 2.8.1
# Date de cr�ation  : Avril 2011
# Sources
################################################################################

## ** Version **
options(versionPAMPA = "1.0-0")

# Script de chargement des packages
source("C:/PAMPA/SCRIPTS WP3/PackagesManquants.r")

### packages n�cessaires pour les scripts
require(tcltk)
#library("maptools")     # pour la catographie (apparemment non validie dans les versions r�centes de R, � voir)
library(mvpart)
library(TeachingDemos)
library(plotrix)
# pr les stats
library(tkrplot)
library(MASS)
library(gamlss)
library(nnet)

### Appel des diff�rents scripts pour le calcul des m�triques
# Script des fonctions pour l'interface
source("C:/PAMPA/SCRIPTS WP3/InterfaceFonctions.r")
# Script des fonctions graphique d'enqu�tes
source("C:/PAMPA/SCRIPTS WP3/fonctionsGraphEnquete.R")
# script des fonctions d'interface des donn�es d'enqu�tes
source("C:/PAMPA/SCRIPTS WP3/InterfaceOpinion.r")
# Script des fonctions graphique de fr�quentation
source("C:/PAMPA/SCRIPTS WP3/fonctionsGraphFrequentation.r")
# script des fonctions d'interface des donn�es de fr�quentation
source("C:/PAMPA/SCRIPTS WP3/InterfacePression.r")
# Script des fonctions g�n�riques d'extrapolation
source("C:/PAMPA/SCRIPTS WP3/ExtrapolationFonctions.r")
# Script des fonctions d'interface d'extrapolation
source("C:/PAMPA/SCRIPTS WP3/InterfaceExtrapolation.r")
# Script des fonctions bootstrap (enqu�tes)
source("C:/PAMPA/SCRIPTS WP3/BootstrapOpinionNew.r")

# Script de choix de l'utilisateur
source("C:/PAMPA/SCRIPTS WP3/ChoixUtilisateur.r")
### Scripts des bootstrap opinion et extrapolation � rajouter une fois finalis�s

### cr�ation du message d'aide
  # D�finit les informations � renseigner dans l'interface selon les cas rencontr�s 
  # (importation, s�lection, restitution, poolage)
gestionMSGaide.f  = function(namemsg) {
  MGS="message � renseigner"
  if (namemsg=="etapeImport")
    MGS="\n Importez vos donn�es pour pouvoir calculer les m�triques"  
  if (namemsg=="Selection")
    MGS=paste("Vous avez restreint vos donn�es selon le crit�re : ",critereSelection, "\n Pour r�cup�rer la totalit� de vos donn�es, cliquez sur 'Restitution Donn�es'.")  
  if (namemsg=="traitements")
    MGS="\n Les donn�es sont import�es vous pouvez calculer les m�triques que vous souhaitez" 
  if (namemsg=="restitution")
    MGS=" \n Les donn�es initiales ont �t� restitu�es. Les m�triques seront calcul�es sur l'ensembre de vos donn�es."   
  if (namemsg=="Poolage")
    MGS = "\n Toutes les p�riodes d'�chantillonnage ont �t� pool�es entre elles. \n Les m�triques sont calcul�es sans prendre en consid�ration les diff�rences temporelles."
  tkinsert(helpframe,"end",paste(MGS,"\n"))
  tkyview.moveto(helpframe,1)
}

### mise � jour du tableau d'�chantillonnage
  # R�sume dans un tableau le nombre d'enregistrements pr�sents dans chacune des tables de donn�es.
  # Mise � jour de ces informations en cas de s�lection/restitution de la part de l'utilisateur.
MiseajourTableau.f = function(tclarray) {
  tclarray[[1,1]] <- "freqtot"        # fr�quentation
  tclarray[[1,2]] <- dim(freqtot)[1]  # nb d'enregistrements
  tclarray[[1,3]] <- dim(freqtot)[2]  # nb de champs
  tclarray[[2,1]] <- "peche"          # p�che r�cr�ative
  tclarray[[2,2]] <- dim(peche)[1]
  tclarray[[2,3]] <- dim(peche)[2]
  tclarray[[3,1]] <- "captures"       # captures du jour
  tclarray[[3,2]] <- dim(captures)[1]
  tclarray[[3,3]] <- dim(captures)[2]
  tclarray[[4,1]] <- "capturesAn"     # captures annuelles (principales esp�ces p�ch�es d�clar�es)
  tclarray[[4,2]] <- dim(capturesAn)[1]
  tclarray[[4,3]] <- dim(capturesAn)[2]
  tclarray[[5,1]] <- "plaisance"       # plaisance
  tclarray[[5,2]] <- dim(plaisance)[1]
  tclarray[[5,3]] <- dim(plaisance)[2]
  tclarray[[6,1]] <- "plongee"         # plong�e
  tclarray[[6,2]] <- dim(plongee)[1]
  tclarray[[6,3]] <- dim(plongee)[2]
  tclarray[[7,1]] <- "excursion"       # PMT SSM
  tclarray[[7,2]] <- dim(excursion)[1]
  tclarray[[7,3]] <- dim(excursion)[2]
  tclarray[[8,1]] <- "refSpatial"      # r�f�rentiel spatial du site
  tclarray[[8,2]] <- dim(refSpatial)[1]
  tclarray[[8,3]] <- dim(refSpatial)[2]
  tclarray[[9,1]] <- "refEspeces"       # r�f�rentiel esp�ces (M�diterran�e ou outremer)
  tclarray[[9,2]] <- dim(refEspeces)[1]
  tclarray[[9,3]] <- dim(refEspeces)[2]
  tclarray[[10,1]] <- "refEngin"       # r�f�rentiel engin
  tclarray[[10,2]] <- dim(refEngin)[1]
  tclarray[[10,3]] <- dim(refEngin)[2]
  tclarray[[11,1]] <- "tousQuest"       # table form�e par R rassemblant l'ensemble des questionnaires (tous usagers)
  tclarray[[11,2]] <- dim(tousQuest)[1]
  tclarray[[11,3]] <- dim(tousQuest)[2]
}

### mise � jour du tableau d'info enqu�tes p�che
  # Pour les enqu�tes de p�che r�cr�ative, r�sume dans un tableau le nombre 
  # de refus, de d�j� enqu�t�s et de questionnaires avec captures.
MiseajourTableauInfo.f = function(tclarray2) {
  tclarray2[[1,1]] <- length(peche$refus[which(peche$refus=="oui")])
  tclarray2[[1,2]] <- length(peche$dejaEnq[which(peche$dejaEnq=="oui")])
  tclarray2[[1,3]] <- length(peche$capture[which(peche$capture=="non")])
}

# construction du menu d'interface
tm <- tktoplevel(height=500,width=1500,bg="lightyellow")
winSmartPlace.f(tm)
topMenu <- tkmenu(tm)
tkconfigure(tm,menu=topMenu)
tkwm.title(tm,"INDICATEURS RELATIFS AUX USAGES")
tkwm.maxsize(tm,1500,768) #taille maximale de la fenetre
tkwm.minsize(tm,1500,600) #taille minimale de la fenetre

topFrame <- tkframe(tm,relief="groove",borderwidth=2)  
imageAMP <- tclVar()    #cr�e un objet Tk image pour l'interface
tcl("image","create","photo",imageAMP,file="C:/PAMPA/SCRIPTS WP3/img/pampa2.GIF")
imgAsLabel <- tklabel(tm,image=imageAMP,bg="white")
helpframe <- tktext(tm,bg="skyblue3",font="arial",width=120,height=3,relief="groove",borderwidth=2)
titreAideContextuelle<-tklabel(tm,width=106,text=" \n Informations donn�es ",background="lightyellow")

# on place les �l�ments dans un espace en trois colonnes avec tkgrid.configure -column, -columnspan, -in, -ipadx, -ipady, -padx, -pady, -row, -rowspan, et -sticky.
tkgrid(imgAsLabel,titreAideContextuelle)
tkgrid(imgAsLabel,helpframe)
tkgrid.configure(imgAsLabel,sticky="w",rowspan=3)  #L'image fait trois lignes de haut
# puis on place les 3 objets � cot� de l'image
tkgrid.configure(titreAideContextuelle,columnspan=3,row=1,column=2,sticky="n")
tkgrid.configure(helpframe,sticky="e",columnspan=3,row=2,column=2,sticky="n")
button.widgetRESTIT <- tkbutton(tm,text="Restituer les donn�es",background="yellow",command=function () RestitutionDonnees.f())
button.widgetOFF <- tkbutton(tm,text="Fermer les graphiques",background="purple",command=graphics.off)
button.widgetQUIT <- tkbutton(tm,text="Quitter",background="deeppink3",command=function() tkdestroy(tm))

espace<-tklabel(tm,width=106,text="  ",background="lightyellow")
tkgrid.configure(espace,columnspan=3,column=2,sticky="n")
tkgrid(button.widgetRESTIT,button.widgetOFF,button.widgetQUIT)
tkgrid.configure(button.widgetRESTIT,columnspan=1,sticky="e")
tkgrid.configure(button.widgetOFF,columnspan=2,column=1,sticky="e")
tkgrid.configure(button.widgetQUIT,columnspan=3,column=2,sticky="e")

#tkgrid.configure(ResumerEspaceTravail<-tklabel(tm,background="lightyellow",text=paste("\n Espace de travail : ","non s�lectionn�"),width="200"))
tkgrid.configure(ResumerAMP<-tklabel(tm,background="lightyellow",text="\n Actuellement aucun jeu de donn�es n'a �t� import�. \n \n",width="200"))
#tkgrid.configure(ResumerEspaceTravail,sticky="w",columnspan=4)
tkgrid.configure(ResumerAMP,sticky="w",columnspan=4)

ResumerSituationFreq<-tklabel(tm,text=paste("Fr�quentation : ","non s�lectionn�"))
ResumerSituationPeche<-tklabel(tm,text=paste("Enqu�tes P�che : ","non s�lectionn�"))
ResumerSituationCaptures<-tklabel(tm,text=paste("Captures associ�es : ","non s�lectionn�"))
ResumerSituationCapturesAn<-tklabel(tm,text=paste("Captures annuelles : ","non s�lectionn�"))
ResumerSituationPlaisance<-tklabel(tm,text=paste("Enqu�tes Plaisance : ","non s�lectionn�"))
ResumerSituationPlong�e<-tklabel(tm,text=paste("Enqu�tes Plong�e : ","non s�lectionn�"))
ResumerSituationExcursion<-tklabel(tm,text=paste("Enqu�tes Excursion : ","non s�lectionn�"))
ResumerSituationRefSpatial<-tklabel(tm,text=paste("R�f�rentiel Spatial : ","non s�lectionn�"))
ResumerSituationRefEspeces<-tklabel(tm,text=paste("R�f�rentiel Esp�ces : ","non s�lectionn�"))
ResumerSituationRefEngin<-tklabel(tm,text=paste("R�f�rentiel Engin : ","non s�lectionn�"))

gestionMSGaide.f("etapeImport")
var1=0
var2=0
### tableau d'�chantillonnage
ArrayEtatFichier <- c("Jeu_de_donn�es","Nom_du_tableau","Nb_enregistrements","Nb_champs",
              "Comptages_de_la_Fr�quentation","�_importer","NA","NA",
              "Enqu�tes_P�che_R�cr�ative","�_importer","NA","NA",
              "Captures_du_jour_associ�es","�_importer","NA","NA",
              "Captures_annuelles_d�clar�es","�_importer","NA","NA",
              "Enqu�tes_Plaisance","�_importer","NA","NA",
              "Enqu�tes_Plong�e","�_importer","NA","NA",
              "Enqu�tes_PMT_SSM","�_importer","NA","NA",
              "R�f�rentiel_Spatial","�_importer","NA","NA",
              "R�f�rentiel_Esp�ces","�_importer","NA","NA",
              "R�f�rentiel_Engin","�_importer","NA","NA",
              "Tous_Questionnaires","�_construire_par_R","NA","NA")
tclarray <- tclArray()
dim(ArrayEtatFichier) <- c(4,12)
for (i in (0:11))
  for (j in (0:3))
     tclarray[[i,j]] <- ArrayEtatFichier[j+1,i+1]
tclRequire("Tktable")
table1 <-tkwidget(tm,"table",variable=tclarray,rows=12,cols=4,titlerows=1,selectmode="extended",colwidth=33,background="white")

### info enqu�tes
ArrayInfo <- c("Jeu_de_donn�es","Nb_refus","Nb_d�j�_enqu�t�","Nb_sans_capture",
              "Enqu�tes_P�che","NA","NA","NA")
tclarray2 <- tclArray()
dim(ArrayInfo) <- c(4,2)
for (i in (0:1))
  for (j in (0:3))
     tclarray2[[i,j]] <- ArrayInfo[j+1,i+1]
tclRequire("Tktable")
table2 <-tkwidget(tm,"table",variable=tclarray2,rows=2,cols=4,titlerows=1,selectmode="extended",colwidth=20,background="white")

# position des tableaux
tkgrid(table1)
tkgrid.configure(table1,columnspan=4,column=2,sticky="w")
tkgrid.configure(espace,columnspan=4,column=2,row=1,sticky="n")
tkgrid(table2)
tkgrid.configure(table2,columnspan=4,column=2,sticky="w")


#################    cr�ation de la barre de menu   ############################

# d�claration de toutes les variables interm�diaires (sous-menus)
ChoixUtilisateur <- tkmenu(topMenu,tearoff=FALSE,bg="lightsalmon")

################################################################################

####      Appel des fonctions
  
# Menu d�roulant des choix disponibles pour l'utilisateur
#  tkadd(ChoixUtilisateur,"command",label="Choix de la surface/du lin�aire", command = ChoixSurface.f)
#  tkadd(ChoixUtilisateur,"command",label="Choix de l'ann�e en cours", command = ChoixAnnee.f)
  tkadd(ChoixUtilisateur,"command",label="Pooler toutes les p�riodes d'�chantillonnage pour les calculs", command = ChoixPoolerAnnees.f)
  tkadd(ChoixUtilisateur,"command",label="Restreindre les donn�es � certaines p�riode d'�chantillonnage", command = ChoixPeriodEchant.f)
  tkadd(ChoixUtilisateur,"command",label="Restreindre les donn�es selon la caract�ristique : r�sident", command = ChoixResident.f)
  tkadd(ChoixUtilisateur,"command",label="Restreindre les donn�es � certais usagers", command = ChoixUsagers.f)
  tkadd(ChoixUtilisateur,"command",label="Restituer les donn�es", command = function () RestitutionDonnees.f())

######################## Premier niveau de menu ################################

  tkadd(topMenu,"command",label="Import des donn�es",command = function() source("C:/PAMPA/SCRIPTS WP3/ImportDonnees.r"))
  tkadd(topMenu,"cascade",label="Etude de la fr�quentation", command = interfaceFrequentation.f)
  tkadd(topMenu,"cascade",label="Etude des enqu�tes", command = interfaceEnquete.f)
  tkadd(topMenu,"cascade",label="Extrapolation de la fr�quentation", command = interfaceExtrapolation.f)
  tkadd(topMenu,"command",label="Indices composites", command = function() tkmessageBox(message="Cette fonction n'est pas encore disponible",icon="warning",type="ok")) #IndiceCompo)   
  tkadd(topMenu,"command",label="Bootstrap", command = function() tkmessageBox(message="Cette fonction n'est pas encore disponible",icon="warning",type="ok")) #Bootstrap)   
#  tkadd(topMenu,"cascade",label="Choix de l'utilisateur", menu = ChoixUtilisateur)
################################################################################

tkfocus(tm)
