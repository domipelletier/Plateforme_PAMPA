################################################################################
## Nom                  : interface.r
## Objet                : interface du Programme de calcul des m�triques biodiversit� et ressources
## Input                : TXT
## Output               : CSV
## Toutes les fonctions appel�es dans ce fichier � partir de widjet devront appartenir au fichier "command.r"
## Auteurs               : Bastien Preuss / J�r�mie Habasque / Romain David
## R version            : 2.10.1
## Date de cr�ation     : F�vrier 2008
## Date de modification : Avril 2010
################################################################################

test.f = function() {
   tkmessageBox(message="En cours de programation, patience")
}

#################################################################################
## FONCTION PRINCIPALE
## Constitution du menu d'interface
#################################################################################

tm <- tktoplevel(height=600,width=800,background="#FFFFFF")
topMenu <- tkmenu(tm)
tkconfigure(tm,menu=topMenu)
tkwm.title(tm,"CALCULS INDICATEURS PAMPA")
tkwm.maxsize(tm,1000,768) #taille maximale de la fenetre
tkwm.minsize(tm,800,600) #taille minimale de la fenetre

topFrame <- tkframe(tm,relief="groove",borderwidth=2)
imageAMP <- tclVar()  #cr�e un objet Tk image pour l'interface
tcl("image","create","photo",imageAMP,file=fileimage)
imgAsLabel <- tklabel(tm,image=imageAMP,bg="white")
helpframe <- tktext(tm,bg="yellow",font="arial",width=71,height=3,relief="groove",borderwidth=2)
titreAideContextuelle<-tklabel(tm,width=106,text=" Ci dessous l'aide contextuelle",background="#FFFFFF")
#tklabel(topFrame,text="Bienvenue sur l'interface TCL TK de PAMPA",background="#FFFFFF")

# on place les �l�ments dans un espace en trois colonnes avec tkgrid.configure -column, -columnspan, -in, -ipadx, -ipady, -padx, -pady, -row, -rowspan, et -sticky.
tkgrid(imgAsLabel,titreAideContextuelle)
tkgrid(imgAsLabel,helpframe)
#tkgrid(imgAsLabel,topFrame)
tkgrid.configure(imgAsLabel,sticky="w",rowspan=3)  #L'image fait trois lignes de haut
# puis on place les 3 objets � cot� de l'image
tkgrid.configure(titreAideContextuelle,columnspan=2,row=1,column=1,sticky="n")
tkgrid.configure(helpframe,sticky="e",columnspan=2,row=2,column=1,sticky="n")
TitreSuiviOperation<-tklabel(tm,text="Suivi des op�rations")
button.widgetOFF <- tkbutton(tm,text="Fermer les graphiques",command=graphics.off)

tkgrid(TitreSuiviOperation,button.widgetOFF)
tkgrid.configure(TitreSuiviOperation,columnspan=1,sticky="w")
tkgrid.configure(button.widgetOFF,columnspan=2,column=2,sticky="e")

scr <- tkscrollbar(tm, repeatinterval=2, command=function(...)tkyview(txt.w,...))
txt.w <- tktext(tm,bg="white",width=90,height=15,yscrollcommand=function(...)tkset(scr,...))
tkgrid.configure(txt.w,scr)
tkgrid.configure(txt.w,sticky="nsew",columnspan=3)
tkgrid.configure(scr,sticky="nsw",column=3)

tkgrid.configure(ResumerEspaceTravail<-tklabel(tm,text=paste("Espace de travail : ","non s�lectionn�"),width="134"))
tkgrid.configure(ResumerAMPetType<-tklabel(tm,text="Aucun jeu de donn�e s�lectionn� pour le moment",width="134"))
tkgrid.configure(ResumerEspaceTravail,sticky="w",columnspan=4)
tkgrid.configure(ResumerAMPetType,sticky="w",columnspan=4)

ResumerSituationFichierUnitesObs<-tklabel(tm,text=paste("Fichier d'unit�s d'observations : ","non s�lectionn�"))
ResumerSituationFichierObs<-tklabel(tm,text=paste("Fichier d'observations : ","non s�lectionn�"))
ResumerSituationReferencielEspece<-tklabel(tm,text=paste("R�f�rentiel esp�ce : ","non s�lectionn�"))

gestionMSGaide.f("etapeImport")

var1=0
var2=0
ArrayEtatFichier <- c("Type de fichier","Source","Nb Enr","Nb Champs","S�lections",
              "Fichier d'unit�s d'observations","non s�lectionn�","NA","NA","NA",
              "Fichier d'observations ","non s�lectionn�s","NA","NA","NA",
              "R�f�rentiel esp�ce ","non s�lectionn�","NA","NA","NA")
tclarray <- tclArray()
dim(ArrayEtatFichier) <- c(5,4)
for (i in (0:3))
  for (j in (0:4))
     tclarray[[i,j]] <- ArrayEtatFichier[j+1,i+1]

tclRequire("Tktable")
table1 <-tkwidget(tm,"table",variable=tclarray,rows=4,cols=4,titlerows=1,selectmode="extended",colwidth=25,background="white")
tkgrid(table1)
tkgrid.configure(table1,columnspan=3,sticky="w")
#button.widget1 <- tkbutton(tm,text="changer les Tables Unitobs et Obs",command=changerUnitobs.f)
#button.widget2 <- tkbutton(tm,text="changer la Table Obs",command=changerObservations.f)
#button.widget3 <- tkbutton(tm,text="changer le R�f�rentiel especes",command=changerListespeces.f)
#tkgrid(button.widget1,button.widget3,sticky="w")
#tkgrid.configure(button.widget1,column=0,sticky="w")
#tkgrid.configure(button.widget2,column=1,sticky="ew")
#tkgrid.configure(button.widget3,column=2,sticky="e")

  #d�claration et mise � 0 de toutes les variables de s�lection dans les menus
  SelectListEsp <- tclVar(0)
  SelectFam <- tclVar(0)
  SelectBenth <- tclVar(0)
  SelectBiot  <- tclVar(0)
  SelectPhylum  <- tclVar(0)
  SelectOrdre  <- tclVar(0)
  SelectClasse  <- tclVar(0)
  SelectEndem <- tclVar(0)
  SelectEmble <- tclVar(0)
  SelectMenace <- tclVar(0)
  SelectIUCN <- tclVar(0)
  SelectAutreStatut <- tclVar(0)
  SelectCB  <- tclVar(0)
  GraphBiomasse <- tclVar(0)
  GraphDensite <- tclVar(0)
  GraphDensiteEsp  <- tclVar(0)
  GraphDensiteFam  <- tclVar(0)
  GraphHill <- tclVar(0)
  GraphPielou <- tclVar(0)
  GraphL.simpson <- tclVar(0)
  GraphSimpson <- tclVar(0)
  GraphRichesse_specifique <- tclVar(0)

#############initialisation des entr�es de menu d�chirables (ie qui donne acc�s � un sous menu)
importPeche <- tkmenu(topMenu,tearoff=FALSE)
Anova <- tkmenu(topMenu,tearoff=FALSE)
arbreRegression <- tkmenu(topMenu,tearoff=FALSE)
analyseGrpUnit <- tkmenu(topMenu,tearoff=FALSE)
analyseUnit <- tkmenu(topMenu,tearoff=FALSE)
analyse <- tkmenu(topMenu,tearoff=FALSE)
import <- tkmenu(topMenu,tearoff=FALSE)
selection <- tkmenu(topMenu,tearoff=FALSE)
statut <- tkmenu(topMenu,tearoff=FALSE)
traitement <- tkmenu(topMenu,tearoff=FALSE)
benthos <- tkmenu(topMenu,tearoff=FALSE)
regroupements  <- tkmenu(topMenu,tearoff=FALSE)
benthosUneEspece <- tkmenu(topMenu,tearoff=FALSE)
importManu <- tkmenu(topMenu,tearoff=FALSE)
traitementNbObs   <- tkmenu(topMenu,tearoff=FALSE)
traitementNbEspeces  <- tkmenu(topMenu,tearoff=FALSE)
traitementDensiteAbondance  <- tkmenu(topMenu,tearoff=FALSE)
traitementBiomasse   <- tkmenu(topMenu,tearoff=FALSE)
traitementIndicesHill   <- tkmenu(topMenu,tearoff=FALSE)
traitementIndicesPielou   <- tkmenu(topMenu,tearoff=FALSE)
traitementIndicesL.simpson   <- tkmenu(topMenu,tearoff=FALSE)
traitementIndicesSimpson   <- tkmenu(topMenu,tearoff=FALSE)
traitementIndicesRichesse_specifique    <- tkmenu(topMenu,tearoff=FALSE)
pampainfos   <- tkmenu(topMenu,tearoff=FALSE)
outils <- tkmenu(topMenu,tearoff=FALSE)
traitementIndices  <- tkmenu(topMenu,tearoff=FALSE)
NbEspeceParUnitobs  <- tkmenu(topMenu,tearoff=FALSE)
NbEspeceParAn  <- tkmenu(topMenu,tearoff=FALSE)
NbEspeceParUnitobsbenthos <- tkmenu(topMenu,tearoff=FALSE)
NbEspeceParAnbenthos <- tkmenu(topMenu,tearoff=FALSE)
benthosrecouvrement  <- tkmenu(topMenu,tearoff=FALSE)
benthoscolonie  <- tkmenu(topMenu,tearoff=FALSE)
## Ajout [yr: 25/08/2010] :
modelesInferentiels <- tkmenu(topMenu,tearoff=FALSE)
analysesExplo <- tkmenu(topMenu,tearoff=FALSE)

##Troisieme niveau de menu

  # Menu deroulant de "Analyse / Par groupe d'unites d'observation"
  tkadd(analyseGrpUnit,"command",label="Toutes especes confondues", command = grpunitobs.f)

  #tkadd(analyseGrpUnit,"command",label="Par groupe d'especes",command= grpunitobsGrpEspece.f) # Pas encore operationnel
  tkadd(analyseGrpUnit,"command",label="Une espece au choix",command = graphuneespece.f)

  # Menu deroulant de "Analyse"
  tkadd(analyseUnit,"command",label="Toutes especes confondues",command = graphIndicesDiv.f)
  tkadd(analyseUnit,"command",label="En fonction de groupes d'especes", command = grpesp.f)
  tkadd(analyseUnit,"command",label="Une espece au choix",command = graphNbreParEsp.f)

  # Menu deroulant de "ANOVA"
  tkadd(Anova,"command",label="1 facteur",command=anova1.f)
  tkadd(Anova,"command",label="2 facteurs",command=anova2.f)
  tkadd(Anova,"command",label="3 facteurs",command=anova3.f)

  # Menu deroulant de "arbre de regression"
  tkadd(arbreRegression,"command",label="1 facteur",command=arbre1.f)
  tkadd(arbreRegression,"command",label="2 facteurs",command=arbre2.f)
  tkadd(arbreRegression,"command",label="3 facteurs",command=arbre3.f)

  #Menu deroulant "Peche"
  tkadd(importPeche,"command",label="Tremail",command=importTremail.f)
  tkadd(importPeche,"command",label="Chasse fusil",command=importChasseFusil.f)
  tkadd(importPeche,"command",label="Ligne sans canne",command=importLigneSansCanne.f)
  tkadd(importPeche,"command",label="Ligne avec canne",command=importLigneAvecCanne.f)

    # Menu deroulant de "Selection + espece + par statut"
      #on ne peut pas passer d'arguments directement
  #r�cup�rer la variable  =  tclvalue(SelectEndem)
  tkadd(statut,"checkbutton",label="Endemique",variable=SelectEndem,onvalue=1,offvalue=0,command={selectionEspeceStatut.f})
  tkadd(statut,"checkbutton",label="Embl�matique",onvalue=1,offvalue=0,variable=SelectEmble,command={selectionEspeceStatut.f})
  tkadd(statut,"checkbutton",label="Menac� localement",variable=SelectMenace,onvalue=1,offvalue=0,command=selectionEspeceStatut.f)
  tkadd(statut,"checkbutton",label="statut UICN",variable=SelectIUCN,onvalue=1,offvalue=0,command=selectionEspeceStatut.f)
  tkadd(statut,"checkbutton",label="Autres statuts",variable=SelectAutreStatut,onvalue=1,offvalue=0,command=selectionEspeceStatut.f)

    # Menu deroulant de "benthosUneEspece"
  tkadd(benthosUneEspece,"command",label="Recouvrement total",command=GraphRecouvrementPourUneEspece.f)
  tkadd(benthosUneEspece,"command",label="Recouvrement en fonction des habitats",command=CalculRecouvrement.f)
  tkadd(benthosUneEspece,"command",label="Recouvrement en fonction des familles",command=CalculRecouvrement.f)
  tkadd(benthosUneEspece,"command",label="Recouvrement en fonction des annees",command=CalculRecouvrement.f)

        # Menu deroulant de "traitementNbEspeces"
  tkadd(traitementNbEspeces,"cascade",label=" en fonction des unite d'observation",menu=NbEspeceParUnitobs)
  tkadd(traitementNbEspeces,"command",label=" en fonction des habitats",command=GraphNbEspeceParHabitat.f)
  #manque par biotope et par statut + combinaisons
  tkadd(traitementNbEspeces,"command",label=" en fonction des familles",command=GraphNbEspeceParFamille.f)
  tkadd(traitementNbEspeces,"cascade",label=" en fonction des annees",menu=NbEspeceParAn)
  tkadd(NbEspeceParUnitobs,"command",label="pour toutes esp�ces",command=GraphNbEspeceParUnitobs.f)
  tkadd(NbEspeceParUnitobs,"command",label="avec choix d'esp�ces",command=GraphchoixNbEspeceParUnitobs.f)
  tkadd(NbEspeceParAn,"command",label="pour toutes esp�ces",command=GraphNbEspeceParAn.f)
  tkadd(NbEspeceParAn,"command",label="avec choix d'esp�ces",command=GraphchoixNbEspeceParAn.f)

            # Menu deroulant de "traitementNbObs"
  tkadd(traitementNbObs,"command",label=" en fonction des sites",command=GraphNbObsParSite.f)
  tkadd(traitementNbObs,"command",label=" en fonction des esp�ces",command=GraphNbObsParEspece.f)
  tkadd(traitementNbObs,"command",label="pour 1 esp�ce",command=GraphNbObsPourUneEspece.f)
  tkadd(traitementNbObs,"separator")
  tkadd(traitementNbObs,"command",label=" en fonction des biotopes",command=GraphNbObsParbiotope.f)
  tkadd(traitementNbObs,"command",label=" en fonction des habitats",command=GraphNbObsParhabitat1.f)
  tkadd(traitementNbObs,"command",label=" en fonction des familles",command=GraphNbObsParfamille.f)
  tkadd(traitementNbObs,"command",label=" en fonction des ann�es",command=GraphNbObsParAn.f)
  tkadd(traitementNbObs,"command",label=" en fonction des statuts",command=GraphNbObsParStatut.f)
  tkadd(traitementNbObs,"command",label=" en fonction des ann�es puis statuts",command=GraphNbObsParAnStatut.f)

        # Menu deroulant de "traitementDensiteAbondance"
  tkadd(traitementDensiteAbondance,"checkbutton",label="Totale",variable=GraphDensite,onvalue=1,offvalue=0,command=GraphDensiteParUnitObs.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Totale en fonction des ann�es",variable=GraphDensite,onvalue=2,offvalue=0,command=GraphDensiteParUnitObs.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Totale en fonction des statuts",variable=GraphDensite,onvalue=3,offvalue=0,command=GraphDensiteParUnitObs.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Totale en fonction des ann�es puis des statuts",variable=GraphDensite,onvalue=4,offvalue=0,command=GraphDensiteParUnitObs.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Totale / en fonction des biotopes puis statuts puis ann�es",variable=GraphDensiteEsp,onvalue=5,offvalue=0,command=GraphDensiteParUnitObs.f)
  tkadd(traitementDensiteAbondance,"separator")
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour un choix d'esp�ces",variable=GraphDensiteEsp,onvalue=1,offvalue=0,command=GraphDensiteParEspece.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour un choix d'esp�ces, par statut ",variable=GraphDensiteEsp,onvalue=2,offvalue=0,command=GraphDensiteParEspece.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour un choix d'esp�ces, par an ",variable=GraphDensiteEsp,onvalue=3,offvalue=0,command=GraphDensiteParEspece.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour un choix d'esp�ces, par an et par statut",variable=GraphDensiteEsp,onvalue=4,offvalue=0,command=GraphDensiteParEspece.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour un choix d'esp�ces / par biotope / statut / an",variable=GraphDensiteEsp,onvalue=5,offvalue=0,command=GraphDensiteParEspece.f)
  tkadd(traitementDensiteAbondance,"separator")
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour une famille",variable=GraphDensiteFam,onvalue=1,offvalue=0,command=GraphDensiteParFamille.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour une famille, par statut ",variable=GraphDensiteFam,onvalue=2,offvalue=0,command=GraphDensiteParFamille.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour une famille, par an ",variable=GraphDensiteFam,onvalue=3,offvalue=0,command=GraphDensiteParFamille.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour une famille, par an et par statut ",variable=GraphDensiteFam,onvalue=4,offvalue=0,command=GraphDensiteParFamille.f)
  tkadd(traitementDensiteAbondance,"checkbutton",label="Pour une famille / par biotope / statut / an",variable=GraphDensiteFam,onvalue=5,offvalue=0,command=GraphDensiteParFamille.f)

        # Menu deroulant de "traitementBiomasse"
  tkadd(traitementBiomasse,"checkbutton",label="Totale",variable=GraphBiomasse,onvalue=1,offvalue=0,command=GraphBiomasseParUnitObs.f)
  tkadd(traitementBiomasse,"checkbutton",label="Totale en fonction des ann�es",variable=GraphBiomasse,onvalue=2,offvalue=0,command=GraphBiomasseParUnitObs.f)
  tkadd(traitementBiomasse,"checkbutton",label="Totale en fonction des statuts",variable=GraphBiomasse,onvalue=3,offvalue=0,command=GraphBiomasseParUnitObs.f)
  tkadd(traitementBiomasse,"checkbutton",label="Totale en fonction des ann�es puis des statuts",variable=GraphBiomasse,onvalue=4,offvalue=0,command=GraphBiomasseParUnitObs.f)
  tkadd(traitementBiomasse,"checkbutton",label="Totale  / en fonction des biotopes / statuts / ans",variable=GraphBiomasse,onvalue=5,offvalue=0,command=GraphBiomasseParUnitObs.f)
  tkadd(traitementBiomasse,"separator")
  tkadd(traitementBiomasse,"checkbutton",label="Pour un choix d'esp�ces",variable=GraphBiomasse,onvalue=1,offvalue=0,command=GraphBiomasseParEspece.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour un choix d'esp�ces / statut",variable=GraphBiomasse,onvalue=2,offvalue=0,command=GraphBiomasseParEspece.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour un choix d'esp�ces / an",variable=GraphBiomasse,onvalue=3,offvalue=0,command=GraphBiomasseParEspece.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour un choix d'esp�ces / statut / an",variable=GraphBiomasse,onvalue=4,offvalue=0,command=GraphBiomasseParEspece.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour un choix d'esp�ces / par biotope / statut / an",variable=GraphBiomasse,onvalue=5,offvalue=0,command=GraphBiomasseParEspece.f)
  tkadd(traitementBiomasse,"separator")
  tkadd(traitementBiomasse,"checkbutton",label="Pour une famille",variable=GraphBiomasse,onvalue=1,offvalue=0,command=GraphBiomasseParFamille.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour une famille, par statut ",variable=GraphBiomasse,onvalue=2,offvalue=0,command=GraphBiomasseParFamille.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour une famille, par an ",variable=GraphBiomasse,onvalue=3,offvalue=0,command=GraphBiomasseParFamille.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour une famille, par an et par statut ",variable=GraphBiomasse,onvalue=4,offvalue=0,command=GraphBiomasseParFamille.f)
  tkadd(traitementBiomasse,"checkbutton",label="Pour une famille / par biotope / statut / an",variable=GraphBiomasse,onvalue=5,offvalue=0,command=GraphBiomasseParFamille.f)


        # Menu deroulant de "traitementIndices"  DEFINI UNE SEULE FOIS POUR LE BENTHOS ET LES TRAITEMENTS STANDARDS
  tkadd(traitementIndices,"command",label="Delta",command=GraphDelta.f)
  tkadd(traitementIndices,"command",label="Delta*",command=GraphDeltaEtoile.f)
  tkadd(traitementIndices,"command",label="Delta+",command=GraphDeltaPlus.f)
  tkadd(traitementIndices,"command",label="SDelta+",command=GraphSDeltaPlus.f)
  tkadd(traitementIndices,"command",label="Lambda+",command=GraphLambdaPlus.f)
  tkadd(traitementIndices,"cascade",label="Hill",menu=traitementIndicesHill)
  tkadd(traitementIndicesHill,"checkbutton",label="Total",variable=GraphHill,onvalue=1,offvalue=0,command=GraphHillParUnitObs.f)
  tkadd(traitementIndicesHill,"checkbutton",label="Total en fonction des ann�es",variable=GraphHill,onvalue=2,offvalue=0,command=GraphHillParUnitObs.f)
  tkadd(traitementIndicesHill,"checkbutton",label="Total en fonction des statuts",variable=GraphHill,onvalue=3,offvalue=0,command=GraphHillParUnitObs.f)
  tkadd(traitementIndicesHill,"checkbutton",label="Total en fonction des ann�es puis des statuts",variable=GraphHill,onvalue=4,offvalue=0,command=GraphHillParUnitObs.f)
  tkadd(traitementIndices,"cascade",label="Pielou",menu=traitementIndicesPielou)
  tkadd(traitementIndicesPielou,"checkbutton",label="Total",variable=GraphPielou,onvalue=1,offvalue=0,command=GraphPielouParUnitObs.f)
  tkadd(traitementIndicesPielou,"checkbutton",label="Total en fonction des ann�es",variable=GraphPielou,onvalue=2,offvalue=0,command=GraphPielouParUnitObs.f)
  tkadd(traitementIndicesPielou,"checkbutton",label="Total en fonction des statuts",variable=GraphPielou,onvalue=3,offvalue=0,command=GraphPielouParUnitObs.f)
  tkadd(traitementIndicesPielou,"checkbutton",label="Total par an et par statut",variable=GraphPielou,onvalue=4,offvalue=0,command=GraphPielouParUnitObs.f)
  tkadd(traitementIndices,"cascade",label="L.simpson",menu=traitementIndicesL.simpson)
  tkadd(traitementIndicesL.simpson,"checkbutton",label="Total",variable=GraphL.simpson,onvalue=1,offvalue=0,command=GraphL.simpsonParUnitObs.f)
  tkadd(traitementIndicesL.simpson,"checkbutton",label="Total en fonction des ann�es",variable=GraphL.simpson,onvalue=2,offvalue=0,command=GraphL.simpsonParUnitObs.f)
  tkadd(traitementIndicesL.simpson,"checkbutton",label="Total en fonction des statuts",variable=GraphL.simpson,onvalue=3,offvalue=0,command=GraphL.simpsonParUnitObs.f)
  tkadd(traitementIndicesL.simpson,"checkbutton",label="Total en fonction des ann�es puis des statuts",variable=GraphL.simpson,onvalue=4,offvalue=0,command=GraphL.simpsonParUnitObs.f)
  tkadd(traitementIndices,"cascade",label="Simpson",menu=traitementIndicesSimpson)
  tkadd(traitementIndicesSimpson,"checkbutton",label="Total",variable=GraphSimpson,onvalue=1,offvalue=0,command=GraphSimpsonParUnitObs.f)
  tkadd(traitementIndicesSimpson,"checkbutton",label="Total en fonction des ann�es",variable=GraphSimpson,onvalue=2,offvalue=0,command=GraphSimpsonParUnitObs.f)
  tkadd(traitementIndicesSimpson,"checkbutton",label="Total en fonction des statuts",variable=GraphSimpson,onvalue=3,offvalue=0,command=GraphSimpsonParUnitObs.f)
  tkadd(traitementIndicesSimpson,"checkbutton",label="Total en fonction des ann�es puis des statuts",variable=GraphSimpson,onvalue=4,offvalue=0,command=GraphSimpsonParUnitObs.f)
  tkadd(traitementIndices,"cascade",label="Richesse sp�cifique",menu=traitementIndicesRichesse_specifique)
  tkadd(traitementIndicesRichesse_specifique,"checkbutton",label="Totale",variable=GraphRichesse_specifique,onvalue=1,offvalue=0,command=GraphRichesse_specifiqueParUnitObs.f)
  tkadd(traitementIndicesRichesse_specifique,"checkbutton",label="Totale en fonction des ann�es",variable=GraphRichesse_specifique,onvalue=2,offvalue=0,command=GraphRichesse_specifiqueParUnitObs.f)
  tkadd(traitementIndicesRichesse_specifique,"checkbutton",label="Totale en fonction des statuts",variable=GraphRichesse_specifique,onvalue=3,offvalue=0,command=GraphRichesse_specifiqueParUnitObs.f)
  tkadd(traitementIndicesRichesse_specifique,"checkbutton",label="Totale en fonction des ann�es puis des statuts",variable=GraphRichesse_specifique,onvalue=4,offvalue=0,command=GraphRichesse_specifiqueParUnitObs.f)

    # Menu deroulant de "importManu"
  tkadd(importManu,"command",label="UVC", command = import.donnees.f)
  tkadd(importManu,"cascade",label="P�che", menu = importPeche)
  tkadd(importManu,"command",label="STAVIRO", command = import.donnees.f)
  tkadd(importManu,"command",label="LIT", command = import.donnees.f)
  tkadd(importManu,"command",label="Photo recouvrement", command = import.donnees.f)
##Second niveau de menu

    # Menu deroulant de "traitement"

  tkadd(traitement,"cascade",label="Nombre d'observations",menu = traitementNbObs)
  tkadd(traitement,"cascade",label="Nombre d'esp�ces",menu = traitementNbEspeces)
  tkadd(traitement,"cascade",label="Densit� d'abondance",menu = traitementDensiteAbondance)
  tkadd(traitement,"cascade",label="Biomasse",menu = traitementBiomasse)
  tkadd(traitement,"cascade",label="Indices de diversit�",menu = traitementIndices)
  tkadd(traitement,"separator")
  tkadd(traitement,"cascade",label="M�triques regroup�es en fonction de",menu=regroupements)
  tkadd(traitement,"command",label="M�trique par facteur esp�ce",command=GraphMetriqueParFacteurEspece.f)
  tkadd(traitement,"command",label="M�trique par facteur unit�s d'observation",command=GraphMetriqueParFacteurUnitobs.f)
## Ajout [yr: 11/08/2010]
tkadd(traitement, "command", label="Boxplots \"� la carte\"...", command=function(){selectionVariables.f("boxplot")})

         # Menu deroulant de "regroupements"
  tkadd(regroupements,"command",label="1 Facteur du r�f�rentiel esp�ce",command=GraphGroup1factEsp.f)
  tkadd(regroupements,"command",label="2 Facteurs du r�f�rentiel esp�ce",command=GraphGroup2factEsp.f)
  tkadd(regroupements,"command",label="1 Facteur de l'unit� d'observation",command=RegroupementUnFactUnitobs.f)
  tkadd(regroupements,"command",label="2 Facteurs de l'unit� d'observation",command=RegroupementDeuxFactUnitobs.f)
  tkadd(regroupements,"command",label="2 Facteurs : 1 unit� d'obs et 1 r�f�rentiel esp�ce",command=GraphGroup2factEspUnitobs.f)
  tkadd(regroupements,"command",label="Toutes especes confondues par classe de taille (petits, moyens, grands)", command = grpunitobsCT.f)

     # Menu deroulant de "Benthos"
  tkadd(benthos,"cascade",label="Recouvrement",menu = benthosrecouvrement)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Unitobs choisis",command=GraphRecouvrementParUnitobs.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Stations choisies",command=GraphRecouvrementParStation.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Sites choisis",command=GraphRecouvrementParSite.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Cat�gories Benthiques choisies",command=GraphColonieParCathegorieBenthique.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Familles choisies",command=GraphColonieParFamille.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Genres choisis",command=GraphRecouvrementParGenre.f)
  tkadd(benthosrecouvrement,"cascade",label=" en fonction des Especes choisis",command=GraphRecouvrementParEspece.f)
  tkadd(benthos,"cascade",label="Occurence de colonies",menu = benthoscolonie)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Unitobs choisis",command=GraphColonieParUnitobs.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Stations choisies",command=GraphRecouvrementParStation.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Sites choisis",command=GraphRecouvrementParSite.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Cat�gories Benthiques choisies",command=GraphColonieParCathegorieBenthique.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Familles choisies",command=GraphColonieParFamille.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Genres choisis",command=GraphRecouvrementParGenre.f)
  tkadd(benthoscolonie,"cascade",label=" en fonction des Esp�ces choisies",command=GraphRecouvrementParEspece.f)
  tkadd(benthos,"cascade",label="M�triques regroup�es en fonction de",menu=regroupements)

  tkadd(import,"separator")
  #tkadd(benthos,"cascade",label="par unite d'observation",menu=NbEspeceParUnitobsbenthos)
  #tkadd(benthos,"cascade",label="par annees",menu=NbEspeceParAnbenthos)
  #tkadd(benthos,"command",label="par habitat",command=GraphNbEspeceParHabitat.f)
  #tkadd(benthos,"command",label="par famille",command=GraphNbEspeceParFamille.f)
  #tkadd(benthos,"command",label="pour toutes esp�ces",command=GraphNbEspeceParUnitobs.f)
  #tkadd(benthos,"command",label="Calcul % de recouvrement",command=CalculRecouvrement.f)
  #tkadd(benthos,"command",label="Totaux par unitobs",command=PartRecouvrementUnitobs.f)
  tkadd(benthos,"command",label="typologie",command=test.f)
  #tkadd(NbEspeceParUnitobsbenthos,"command",label="avec choix d'esp�ces",command=GraphchoixNbEspeceParUnitobs.f)
  #tkadd(NbEspeceParUnitobsbenthos,"command",label="pour toutes esp�ces",command=GraphNbEspeceParAn.f)
  #tkadd(NbEspeceParAnbenthos,"command",label="avec choix d'esp�ces",command=GraphchoixNbEspeceParAn.f)
  #tkadd(NbEspeceParAnbenthos,"cascade",label="Pour une esp�ce",menu=benthosUneEspece)
  tkadd(benthos,"cascade",label="Indices",menu=traitementIndices)
  tkadd(benthos,"separator")
  tkadd(benthos,"command",label="M�trique par facteur esp�ce",command=GraphMetriqueParFacteurEspece.f)
  tkadd(benthos,"command",label="M�trique par facteur unit�s d'observation",command=GraphMetriqueParFacteurUnitobs.f)
## Ajout [yr: 18/08/2010]
tkadd(benthos, "command", label="Boxplots \"� la carte\"...",
      command=function(){selectionVariables.f("boxplot") ; winRaise.f(tm)})


  # Menu deroulant de "Import de donnees"
  tkadd(import,"command",label="Choix des dossiers et fichiers de donn�es...", accelerator="CTRL+N", command = {openfile.f})
  tkadd(import,"command",label="Dossiers et fichiers par defaut", accelerator="CTRL+A", command = {opendefault.f})
  tkadd(import,"separator")
  tkadd(import,"command",label="Test du r�f�rentiel (esp�ces concern�es)",underline=9,accelerator="CTRL+R", command = testfileref.f)
  tkadd(import,"command",label="Test des donn�es import�es",underline=0, accelerator="CTRL+T", command = testdonnees.f)
  tkadd(import,"command",label="Champs de 'TableMetrique' et TableBiodiv",underline=0, accelerator="CTRL+M", command = MontrerTableMetrique.f)
  tkadd(import,"cascade",label="Ancienne importation manuelle", menu = importManu)

  # Menu deroulant de "S�lection d'esp�ce"
   #cascade, checkbutton, command, radiobutton, or separator.
  tkadd(selection,"checkbutton",label="Liste d'esp�ces (fichier)",variable=SelectListEsp,onvalue=1,offvalue=0, command = choixespeces.f)
  tkadd(selection,"checkbutton",label="Par famille",variable=SelectFam,onvalue=1,offvalue=0,command = SelectionUneFamille.f)
  tkadd(selection,"checkbutton",label="Par biotope",variable=SelectBiot,onvalue=1,offvalue=0,command = SelectionUnBiotope.f)
  tkadd(selection,"checkbutton",label="Par cat�gorie Benthique ",variable=SelectCB,onvalue=1,offvalue=0, state="disabled",command = SelectionUneCatBenth.f)
  tkadd(selection,"checkbutton",label="Par phylum ",variable=SelectPhylum,onvalue=1,offvalue=0,command = SelectionUnPhylum.f)
  tkadd(selection,"checkbutton",label="Par ordre ",variable=SelectOrdre,onvalue=1,offvalue=0,command = SelectionUnOrdre.f)
  tkadd(selection,"checkbutton",label="Par classe ",variable=SelectClasse,onvalue=1,offvalue=0,command = SelectionUneClasse.f)
  tkadd(selection,"cascade",label="Par statut", menu=statut)
  tkadd(selection,"separator")
  tkadd(selection,"command",label="Autre crit�re (r�f�rentiel esp�ce)",command = SelectionUnCritereEsp.f)
  tkadd(selection,"command",label="Autre crit�re (unit� d'observation)",command = SelectionUnCritereUnitobs.f)

  # Menu deroulant de "Statistiques"
  tkadd(analyse,"cascade",label="ANOVA",menu=Anova)
  tkadd(analyse,"cascade",label="Arbre de regression multivariee",menu = arbreRegression)
  tkadd(analyse,"cascade",label=" en fonction des unit�s d'observation", menu=analyseUnit)
  tkadd(analyse,"cascade",label=" en fonction des groupes d'unit�s d'observation", menu=analyseGrpUnit)
## Ajout [yr: 25/08/2010] :
tkadd(analyse,"separator")
tkadd(analyse, "cascade", label="Analyses exploratoires", menu=analysesExplo)
tkadd(analyse, "cascade", label="Mod�les inf�rentiels", menu=modelesInferentiels)

tkadd(modelesInferentiels, "command", label="Mod�les lin�aires",
      command=function(){selectionVariables.f("modele_lineaire") ; winRaise.f(tm)})


  #Menu deroulant de "Outils"
  tkadd(outils,"command",label="Aide", accelerator="CTRL+?", command = aide.f)
  tkadd(outils,"command",label="mise � jour", state="disabled", command = test.f)
  #tkadd(outils,"command",label="Options", state="disabled", command = test.f)
  tkadd(outils,"command",label="Langue", state="disabled", command = test.f)
  tkadd(outils,"command",label="Export de donnees", state="disabled", command = test.f)
  tkadd(outils,"command",label="Tous les graphes par esp�ce en PDF", command = ChaqueEspeceDansPDF.f)
  tkadd(outils,"separator")
  tkadd(outils,"command",label="Principaux graphes pour une famille en PDF", command = UneFamilleDansPDF.f)
  tkadd(outils,"command",label="Principaux graphes pour une esp�ce en PDF", command = UneEspeceDansPDF.f)

  #Menu deroulant de "Infos"
  tkadd(pampainfos,"command",label="A propos de Pampa", command = test.f)
  tkadd(pampainfos,"command",label="Notice utilisateur", command = test.f)
  tkadd(pampainfos,"command",label="Voir le plan d'�chantillonnage", accelerator="CTRL+P", state="disabled", command = VoirPlanEchantillonnage.f)
  tkadd(pampainfos,"command",label="Info donn�es par esp�ces", state="disabled", accelerator="CTRL+E", command = VoirInformationsDonneesEspeces.f)
  tkadd(pampainfos,"command",label="Info donn�es par unit� d'observation", state="disabled", accelerator="CTRL+U", command = VoirInformationsDonneesUnitobs.f)

# Premier niveau de menu
  tkadd(topMenu,"cascade",label="Importation",menu=import)
  tkadd(topMenu,"cascade",label="Selection et recalcul", state="disabled", menu=selection)
  tkadd(topMenu,"cascade",label="Graphiques", state="disabled",menu=traitement)
  tkadd(topMenu,"cascade",label="Graphiques Benthos", state="disabled",menu=benthos)
  tkadd(topMenu,"cascade",label="Statistiques", state="disabled",menu=analyse)
  tkadd(topMenu,"cascade",label="Outils", menu=outils)
  tkadd(topMenu,"cascade",label="Infos", menu=pampainfos)
  tkadd(topMenu,"command",label="Quitter", command=function() tkdestroy(tm))

  gestionMSGinfo.f("start")
  print("fonction interface activ�e")
tkfocus(tm)

# Frame des s�lections
frameOverall <- tkframe(tm)
tkgrid(tklabel(frameOverall,text="Crit�res de s�lection",relief="groove",borderwidth=2,width=135))
tkgrid.configure(frameOverall,columnspan=5)
frameUpper <- tkframe(frameOverall,borderwidth=2)
MonCritere<-tklabel(frameUpper,text="Aucun")
tkgrid(MonCritere)
frameLower <- tkframe(frameOverall,relief="groove",borderwidth=2)
MesEnregistrements<-tklabel(frameLower,text="NA")
tkgrid(MesEnregistrements)
tkgrid(frameUpper,frameLower)
tkgrid(frameOverall)
ResumerSituationEspecesSelectionnees<-tklabel(frameOverall,text="-> Nombre d'esp�ces concern�es : NA")
tkgrid(ResumerSituationEspecesSelectionnees)
tkgrid.configure(ResumerSituationEspecesSelectionnees,columnspan=3,sticky="w")
ResumerSituationUnitobsSelectionnees<-tklabel(frameOverall,text="-> Nombre d'unit�s d'observation concern�es : NA")
tkgrid(ResumerSituationUnitobsSelectionnees)
tkgrid.configure(ResumerSituationUnitobsSelectionnees,columnspan=3,sticky="w")
button.DataRestore <- tkbutton(tm,text="Restaurer les donn�es",command=RestaurerDonnees.f)
tkgrid(button.DataRestore)
tkconfigure(button.DataRestore, state="disabled")

# Gestion des �v�nements dans la fen�tre tm (toplevel)

 tkbind(tm, "<Control-a>", opendefault.f)
 tkbind(tm, "<Control-A>", opendefault.f)
 tkbind(tm, "<Control-n>", openfile.f)
 tkbind(tm, "<Control-N>", openfile.f)
 tkbind(tm, "<Control-r>", testfileref.f)
 tkbind(tm, "<Control-R>", testfileref.f)
 tkbind(tm, "<Control-t>", testdonnees.f)
 tkbind(tm, "<Control-T>", testdonnees.f)
 tkbind(tm, "<Control-F1>", aide.f)
 ## tkbind(tm, "<Control-?>", aide.f)
 tkbind(tm, "<Control-p>", VoirPlanEchantillonnage.f)
 tkbind(tm, "<Control-P>", VoirPlanEchantillonnage.f)
 tkbind(tm, "<Control-e>", VoirInformationsDonneesEspeces.f)
 tkbind(tm, "<Control-E>", VoirInformationsDonneesEspeces.f)
 tkbind(tm, "<Control-u>", VoirInformationsDonneesUnitobs.f)
 tkbind(tm, "<Control-U>", VoirInformationsDonneesUnitobs.f)
 tkbind(tm, "<Control-o>", test.f)
 tkbind(tm, "<Control-O>", test.f)
 tkbind(tm, "<Control-q>", function() tkdestroy(tm))
 tkbind(tm, "<Control-Q>", function() tkdestroy(tm))

## Placement de la fen�tre :
winSmartPlace.f(tm)
