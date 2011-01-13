## fonctions n�cessaires pour anova
## [sup] [yr: 13/01/2011]:
## infoAnova<-print("R�sultats de l'analyse de variance (aov)")
## infoModel<-print("R�sultats de la s�lection du mod�le")
## infoTukey<-print("R�sultats de la comparaison multiple (Tukey)")

## fonction de choix des r�sidus � exclure
## [sup] [yr: 13/01/2011]:
## ChoixResidus.f = function (pourExclure, model1)
## {
##     if (length(pourExclure$out)==0)
##     {
##         tkmessageBox(message="Le boxplot des r�sidus ne pr�sentent pas de valeurs extr�mes.
##     Les r�sultats seront donc pr�sent�s sans transformation. \n Choisissez une autre transformation si vous le d�sirez.")
##     }else{
##         tt<-tktoplevel()
##         tkwm.title(tt,"Selection r�sidus")
##         scr <- tkscrollbar(tt, repeatinterval=5, command=function(...)tkyview(tl,...))
##         tl<-tklistbox(tt,height=30,width=30,selectmode="multiple",background="white")
##         tkgrid(tklabel(tt,text="Choix des r�sidus � exclure"))
##         tkgrid(tl,scr)
##         tkgrid.configure(scr,rowspan=5,sticky="nsw")
##         ordre<-order(pourExclure$out,decreasing=T)
##         residus <- names(pourExclure$out)[ordre]
##         unitobsResidus<-unitbis$unitobs[!is.na(match(rownames(unitbis),names(pourExclure$out)))][ordre]
##         for (i in (1:length(pourExclure$out))) {
##             tkinsert(tl,"end",c(residus[i],"->",unitobsResidus[i]))
##         }
##         tkselection.set(tl,0)
##         OnOK <- function()
##         {
##             residusChoisis <- residus[as.numeric(tkcurselection(tl))+1]
##             assign("residusChoisis",residusChoisis,envir=.GlobalEnv)
##             tkdestroy(tt)
##         }
##         OK.but <-tkbutton(tt,text="   OK   ",command=OnOK)
##         tkgrid(OK.but)
##         tkfocus(tt)
##         tkwait.window(tt)
##         Aexclure<-match(residusChoisis,rownames(unitbis))
##         unitbis<-unitbis[-Aexclure,]
##         assign("unitbis",unitbis,envir=parent.frame())
##     }
## }

## fonction effectuant l'anova et le tukey
## [sup] [yr: 13/01/2011]:
## anovaTukey.f <- function(formule,unitbis,transfo)
## {
##     ## pr enregistrement des donn�es en txt
##     nomFichier <- if (length(fa)==1)
##     {
##         paste("_",fa,sep="")
##     } else{
##         if (length(fa)==2)
##         {
##             paste("_",fa[1],fa[2],sep="")
##         }else{
##             paste("_",fa[1],fa[2],fa[3],sep="")
##         }
##     }
##     ## plot des r�sidus apr�s la transformation
##     graphics.off() # ferme les graphs d'avant la transformation
##     model1 = lm(as.formula(formule),singular.ok=T)
##     x11(width=50,height=30,pointsize=10)
##     par(mfrow=c(2,3))
##     plot(model1,which = c(1:6),
##          caption = list("R�sidus vs valeurs pr�dites",
##          "Quantile-quantile des r�sidus standardises vs les quantiles th�oriques",
##          "Racine carr�e des r�sidus standardis�s vs valeurs pr�dites",
##          "Distance de Cook","R�sidus standardis�s vs leverage","Distance de Cook vs Leverage") )  #leverage=levier de l'observation???
##     X11()
##     hist(model1$residuals, main="Histogramme des r�sidus")
##     ## aov sur une s�lection de mod�le (step) permettant d'avoir uniquement les facteurs significatifs
##     stepModel<-step(model1,test="F",direction = c("both"))   #scope=model1$call,scale = summary.lm(model1)$sigma^2,
##     print(stepModel)
##     print(summary(stepModel))
##     aovModel<-aov(as.formula(stepModel$call))
##     print(aovModel)
##     assign("aovModel",aovModel,envir=parent.frame())
##     print(summary(aovModel))
##     ## comparaison multiple Tukey
##     hsdModel<-TukeyHSD(aovModel)
##     print(hsdModel)
##     x11(width=50,height=30,pointsize=10)
##     if (length(names(hsdModel)) ==1)
##     {
##         par(mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))
##     }else{
##         par(mfrow=c(2,length(names(hsdModel))/1.5),mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))
##     }
##     plot(hsdModel,las=2,cex=0.5)
##     capture.output(infoModel,step(model1,test="F",direction = c("both")),infoAnova,summary(aovModel),infoTukey,print(hsdModel), file=paste(nameWorkspace,"/FichiersSortie/aov et Tukey_",transfo,me,nomFichier,".txt",sep=""))
##     tkmessageBox(message="Les r�sultats de l'analyse de variance sont enregistr�s en fichier texte dans votre dossier FichiersSortie")
## }


