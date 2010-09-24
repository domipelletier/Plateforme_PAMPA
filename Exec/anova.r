## fonctions n�cessaires pour anova

infoAnova<-print("R�sultats de l'analyse de variance (aov)")
infoModel<-print("R�sultats de la s�lection du mod�le")
infoTukey<-print("R�sultats de la comparaison multiple (Tukey)")

## fonction de choix des r�sidus � exclure
ChoixResidus.f = function (pourExclure, model1)
{
    if (length(pourExclure$out)==0)
    {
        tkmessageBox(message="Le boxplot des r�sidus ne pr�sentent pas de valeurs extr�mes.
    Les r�sultats seront donc pr�sent�s sans transformation. \n Choisissez une autre transformation si vous le d�sirez.")
    }else{
        tt<-tktoplevel()
        tkwm.title(tt,"Selection r�sidus")
        scr <- tkscrollbar(tt, repeatinterval=5, command=function(...)tkyview(tl,...))
        tl<-tklistbox(tt,height=30,width=30,selectmode="multiple",background="white")
        tkgrid(tklabel(tt,text="Choix des r�sidus � exclure"))
        tkgrid(tl,scr)
        tkgrid.configure(scr,rowspan=5,sticky="nsw")
        ordre<-order(pourExclure$out,decreasing=T)
        residus <- names(pourExclure$out)[ordre]
        unitobsResidus<-unitbis$unitobs[!is.na(match(rownames(unitbis),names(pourExclure$out)))][ordre]
        for (i in (1:length(pourExclure$out))) {
            tkinsert(tl,"end",c(residus[i],"->",unitobsResidus[i]))
        }
        tkselection.set(tl,0)
        OnOK <- function()
        {
            residusChoisis <- residus[as.numeric(tkcurselection(tl))+1]
            assign("residusChoisis",residusChoisis,envir=.GlobalEnv)
            tkdestroy(tt)
        }
        OK.but <-tkbutton(tt,text="   OK   ",command=OnOK)
        tkgrid(OK.but)
        tkfocus(tt)
        tkwait.window(tt)
        Aexclure<-match(residusChoisis,rownames(unitbis))
        unitbis<-unitbis[-Aexclure,]
        assign("unitbis",unitbis,envir=parent.frame())
    }
}

## fonction effectuant l'anova et le tukey
anovaTukey.f <- function(formule,unitbis,transfo)
{
    ## pr enregistrement des donn�es en txt
    nomFichier <- if (length(fa)==1)
    {
        paste("_",fa,sep="")
    } else{
        if (length(fa)==2)
        {
            paste("_",fa[1],fa[2],sep="")
        }else{
            paste("_",fa[1],fa[2],fa[3],sep="")
        }
    }
    ## plot des r�sidus apr�s la transformation
    graphics.off() # ferme les graphs d'avant la transformation
    model1 = lm(as.formula(formule),singular.ok=T)
    x11(width=50,height=30,pointsize=10)
    par(mfrow=c(2,3))
    plot(model1,which = c(1:6),
         caption = list("R�sidus vs valeurs pr�dites",
         "Quantile-quantile des r�sidus standardises vs les quantiles th�oriques",
         "Racine carr�e des r�sidus standardis�s vs valeurs pr�dites",
         "Distance de Cook","R�sidus standardis�s vs leverage","Distance de Cook vs Leverage") )  #leverage=levier de l'observation???
    X11()
    hist(model1$residuals, main="Histogramme des r�sidus")
    ## aov sur une s�lection de mod�le (step) permettant d'avoir uniquement les facteurs significatifs
    stepModel<-step(model1,test="F",direction = c("both"))   #scope=model1$call,scale = summary.lm(model1)$sigma^2,
    print(stepModel)
    print(summary(stepModel))
    aovModel<-aov(as.formula(stepModel$call))
    print(aovModel)
    assign("aovModel",aovModel,envir=parent.frame())
    print(summary(aovModel))
    ## comparaison multiple Tukey
    hsdModel<-TukeyHSD(aovModel)
    print(hsdModel)
    x11(width=50,height=30,pointsize=10)
    if (length(names(hsdModel)) ==1)
    {
        par(mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))
    }else{
        par(mfrow=c(2,length(names(hsdModel))/1.5),mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))
    }
    plot(hsdModel,las=2,cex=0.5)
    capture.output(infoModel,step(model1,test="F",direction = c("both")),infoAnova,summary(aovModel),infoTukey,print(hsdModel), file=paste(nameWorkspace,"/FichiersSortie/aov et Tukey_",transfo,me,nomFichier,".txt",sep=""))
    tkmessageBox(message="Les r�sultats de l'analyse de variance sont enregistr�s en fichier texte dans votre dossier FichiersSortie")
}


## fonction des choix de transformation (enlever r�sidus ou transformer log)
Transformations.f = function(formule)
{

    ## fonction extraction des extr�mes
    pressedExtremes.f = function ()
    {
        print(formule)
        tkdestroy(choixTransfo)
        model1 = lm(as.formula(formule),singular.ok=T)
        X11()
        pourExclure<-boxplot(model1$residuals, main="Boxplot des r�sidus du mod�le lin�aire")
        text(1,pourExclure$out,labels=names(pourExclure$out),col="blue")
        ChoixResidus.f(pourExclure,model1$residuals)
        anovaTukey.f(formule,unitbis,"sans r�sidus extr�mes_")
    }
    ## fonction transformation logarithmique
    pressedLog.f = function ()
    {
        tkdestroy(choixTransfo)
        model1 = lm(as.formula(formule),singular.ok=T)
        unitbis[,me]<-log(unitbis[,me]+((min(unitbis[,me],na.rm=T)+1)/1000))
        assign("unitbis",unitbis,envir=parent.frame())
        formule1= formule
        anovaTukey.f(formule1,unitbis,"transformation log_")
    }
    ## fonction extraction et transformation
    pressedlesDeux.f = function ()
    {
        tkdestroy(choixTransfo)
        model1 = lm(as.formula(formule),singular.ok=T)
        pourExclure<-boxplot(model1$residuals, main="Boxplot des r�sidus du mod�le lin�aire")
        ChoixResidus.f(pourExclure,model1$residuals)
        unitbis[,me]<-log(unitbis[,me]+((min(unitbis[,me],na.rm=T)+1)/1000))
        assign("unitbis",unitbis,envir=parent.frame())
        formule1= formule
        anovaTukey.f(formule1,unitbis,"transfo log et sans r�sidus extr�mes_")
    }
    ## aucune transformation
    pressedAucune.f = function ()
    {
        tkmessageBox(message="Aucune transformation n'est effectu�e")
        tkdestroy(choixTransfo)
        formule1<-formule
        anovaTukey.f(formule1,unitbis,"sans transformation")
    }

    choixTransfo<-tktoplevel(height=200,width=400,background="lightyellow")
    tkwm.title(choixTransfo,"Transformations souhait�es")
    extreme.but<-tkbutton(choixTransfo,text="Extraire r�sidus extr�mes",background="lightyellow2",command=pressedExtremes.f)
    log.but<-tkbutton(choixTransfo,text="Transformation logarithmique",background="lightyellow2",command=pressedLog.f)
    lesDeux.but<-tkbutton(choixTransfo,text="Extraire r�sidus extr�mes \n et transformation logarithmique",background="lightyellow2",command=pressedlesDeux.f)
    aucune.but<-tkbutton(choixTransfo,text="Aucune transformation souhait�e",background="lightyellow2",command=pressedAucune.f)
    tkgrid(tklabel(choixTransfo,text="Au regard des graphiques pr�sent�s, \n quelle transformation souhaitez-vous apporter � vos donn�es ?",background="lightyellow"))   # placer le texte
    tkgrid(extreme.but)
    tkgrid(log.but)
    tkgrid(lesDeux.but)
    tkgrid(aucune.but)
    tkfocus(choixTransfo)
}

## ################################################################################
## Nom     : anova1.f
## Objet   : anova d'une m�trique de la table "unit" en fonction de 1 facteur
##           s�lectionn� dans la table "unitobs"
## Input   : tables "unit" et "unitobs" + liste des facteurs de + 2 modalit�s
## Output  : sorties brutes des fonctions lm() et anova()
## ################################################################################
anova1.f = function()
{
    unitSauvegarde<-unit
    ## Choix m�trique � analyser
    affichageMetriques.f()
    ## S�lection du facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"S�lection du facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Liste des facteurs"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac1 <- sort(names(unitobs))
    ## cr�ation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac1)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac1[i]])))>1)
        {
            listeFacteursOK[j] = fac1[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b))
    {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)

    OnOK <- function()
    {
        fa <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        assign("fa",fa,envir=.GlobalEnv)
        tkdestroy(bb)
        unit[,fa]=as.factor(unitobs[,fa][match(unit$unitobs,unitobs$unite_observation)])
        unit<-unit[!is.na(unit[,fa]),]
        unit[,me][is.na(unit[,me])]=0
        assign("unitbis",unit,envir=.GlobalEnv)
        ## message d'information sur les donn�es disponibles selon le facteur choisi
        tkmessageBox(message=paste("Le facteur choisi est renseign� pour ",nrow(unitbis)," donn�es.",sep=""))
        table(unitbis[,fa])
        ## info <- tktoplevel(height=600,width=800,background="white")
        ## textInfo<-tklabel(info,text=paste("Le facteur choisi est renseign� pour ",nrow(unit)," donn�es.",sep=""))
        ## infoFrame <- tktext(info,bg="white",width=71,height=3,borderwidth=2)
        ## tkgrid(textInfo," \n",table(unit[,fa]))
        formule1= "unitbis[,me] ~ as.factor(unitbis[,fa])"
        model1 = lm(as.formula(formule1),singular.ok=T)
        ## plot des r�sidus pour v�rification de la normalit� et de l'homosc�dasticit� des r�sidus
        x11(width=50,height=30,pointsize=10)
        par(mfrow=c(2,3))
        plot(model1,which = c(1:6),
             caption = list("R�sidus vs valeurs pr�dites",
             "Quantile-quantile des r�sidus standardises vs les quantiles th�oriques",
             "Racine carr�e des r�sidus standardis�s vs valeurs pr�dites",
             "Distance de Cook","R�sidus standardis�s vs leverage","Distance de Cook vs Leverage") )  #leverage=levier de l'observation???
        X11()
        hist(model1$residuals, main="Histogramme des r�sidus")
        ## � partir des graphiques des r�sidus, proposer d'enlever les r�sidus extr�mes, ou de transformer en log ou les 2.
        Transformations.f(formule1)  # fonction de transformation et lance �galement les tests (aov et tukey)
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)
    unit<-unitSauvegarde
    assign("unit",unit,envir=.GlobalEnv)
}


## ################################################################################
## Nom     : anova2.f
## Objet   : anova d'une m�trique de la table "unit" en fonction de 2 facteurs
##           s�lectionn�s dans la table "unitobs"
## Input   : tables "unit" et "unitobs" + liste des facteurs de + 2 modalit�s
## Output  : sorties brutes des fonctions lm() et anova()
## ################################################################################

anova2.f = function()
{
    unitSauvegarde<-unit
    ## Choix metrique � analyser
    affichageMetriques.f()

    ## Selection du premier facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"Selection du PREMIER facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Selection du PREMIER facteur explicatif"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac1 <- sort(names(unitobs))
    ## creation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac1)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac1[i]])))>1)
        {
            listeFacteursOK[j] = fac1[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b)) {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)

    OnOK <- function()
    {
        fa1 <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        assign("fa1",fa1,envir=.GlobalEnv)
        tkdestroy(bb)
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)

    ## s�lection du deuxi�me facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"Selection du SECOND facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Selection du SECOND facteur explicatif"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac2 <- sort(names(unitobs))
    ## creation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac2)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac2[i]])))>1)
        {
            listeFacteursOK[j] = fac2[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b)) {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)
    OnOK <- function()
    {
        fa2 <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        fa<-c(fa1,fa2)
        assign("fa",fa,envir=.GlobalEnv)
        tkdestroy(bb)
        unitSauvegarde<-unit
        assign("unitSauvegarde",unitSauvegarde,envir=.GlobalEnv)
        unit[,fa[1]]=as.factor(unitobs[,fa[1]][match(unit$unitobs,unitobs$unite_observation)])
        unit[,fa[2]]=as.factor(unitobs[,fa[2]][match(unit$unitobs,unitobs$unite_observation)])
        unit<-unit[!is.na(unit[,fa[1]]),]
        unit<-unit[!is.na(unit[,fa[2]]),]
        unit[,me][is.na(unit[,me])]=0
        assign("unitbis",unit,envir=.GlobalEnv)
        tkmessageBox(message=paste("Les facteurs choisis sont renseign�s pour ",nrow(unitbis)," donn�es.",sep=""))
        formule1= "unitbis[,me] ~ (as.factor(unitbis[,fa[1]])+as.factor(unitbis[,fa[2]]))^2"
        ## interactgion plot entre les facteurs s�lectionn�s
        x11(width=50,height=30,pointsize=10)
        interaction.plot(unitbis[,fa[1]],unitbis[,fa[2]],unitbis[,me],type="b",col=1:length(fa),main=paste("Interaction plot pour les facteurs :",fa[1],"et",fa[2]))
        savePlot(filename=paste(nameWorkspace,"/FichiersSortie/interaction plot pour ",me,fa[1],fa[2],sep=""),type =c("bmp"))
        model1 = lm(as.formula(formule1),singular.ok=T)
        ## plot des r�sidus
        x11(width=50,height=30,pointsize=10)
        par(mfrow=c(2,3))
        plot(model1,which = c(1:6),
             caption = list("R�sidus vs valeurs pr�dites",
             "Quantile-quantile des r�sidus standardises vs les quantiles th�oriques",
             "Racine carr�e des r�sidus standardis�s vs valeurs pr�dites",
             "Distance de Cook","R�sidus standardis�s vs leverage","Distance de Cook vs Leverage") )  #leverage=levier de l'observation???
        X11()
        hist(model1$residuals, main="Histogramme des r�sidus")
        ## � partir des graphiques des r�sidus, proposer d'enlever les r�sidus extr�mes, ou de transformer en log ou les 2.
        Transformations.f("unitbis[,me] ~ (as.factor(unitbis[,fa[1]])+as.factor(unitbis[,fa[2]]))^2")
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)
    unit<-unitSauvegarde
    assign("unit",unit,envir=.GlobalEnv)
}

## ################################################################################
## Nom     : anova3.f
## Objet   : anova d'une m�trique de la table "unit" en fonction de 3 facteurs
##           s�lectionn�s dans la table "unitobs"
## Input   : tables "unit" et "unitobs" + liste des facteurs de + 2 modalit�s
## Output  : sorties brutes des fonctions lm() et anova()
## ################################################################################

anova3.f = function()
{
    unitSauvegarde<-unit
    ## Choix metrique � analyser
    affichageMetriques.f()

    ## Selection du premier facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"Selection du PREMIER facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Selection du PREMIER facteur explicatif"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac1 <- sort(names(unitobs))
    ## creation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac1)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac1[i]])))>1)
        {
            listeFacteursOK[j] = fac1[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b))
    {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)

    OnOK <- function()
    {
        fa1 <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        assign("fa1",fa1,envir=.GlobalEnv)
        tkdestroy(bb)
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)

    ## s�lection du deuxi�me facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"Selection du SECOND facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Selection du SECOND facteur explicatif"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac2 <- sort(names(unitobs))
    ## creation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac2)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac2[i]])))>1)
        {
            listeFacteursOK[j] = fac2[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b))
    {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)
    OnOK <- function()
    {
        fa2 <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        assign("fa2",fa2,envir=.GlobalEnv)
        tkdestroy(bb)
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)

    ## s�lection du troisi�me facteur explicatif
    bb<-tktoplevel(width = 80)
    tkwm.title(bb,"Selection du TROISIEME facteur explicatif")
    scr <- tkscrollbar(bb, repeatinterval=5, command=function(...)tkyview(tl,...))
    tl<-tklistbox(bb,height=20,width=30,selectmode="single",yscrollcommand=function(...)tkset(scr,...),background="white")
    tkgrid(tklabel(bb,text="Selection du TROISIEME facteur explicatif"))
    tkgrid(tl,scr)
    tkgrid.configure(scr,rowspan=4,sticky="nsw")
    fac3 <- sort(names(unitobs))
    ## creation de la liste des facteurs de + 2 modalites
    listeFacteursOK <-"pas de facteur"
    a = length(fac3)
    j = 1
    for (i in (1:a))
    {
        if (length(unique(na.exclude(unitobs[,fac3[i]])))>1)
        {
            listeFacteursOK[j] = fac3[i]
            j= j+1
        }
    }
    b = length(listeFacteursOK)
    for (i in (1:b))
    {
        tkinsert(tl,"end",listeFacteursOK[i])
    }
    tkselection.set(tl,0)
    OnOK <- function()
    {
        fa3 <- listeFacteursOK[as.numeric(tkcurselection(tl))+1]
        fa<-c(fa1,fa2,fa3)
        assign("fa",fa,envir=.GlobalEnv)
        tkdestroy(bb)
        unitSauvegarde<-unit
        assign("unitSauvegarde",unitSauvegarde,envir=.GlobalEnv)
        unit[,fa[1]]=as.factor(unitobs[,fa[1]][match(unit$unitobs,unitobs$unite_observation)])
        unit[,fa[2]]=as.factor(unitobs[,fa[2]][match(unit$unitobs,unitobs$unite_observation)])
        unit[,fa[3]]=as.factor(unitobs[,fa[3]][match(unit$unitobs,unitobs$unite_observation)])
        unit<-unit[!is.na(unit[,fa[1]]),]
        unit<-unit[!is.na(unit[,fa[2]]),]
        unit<-unit[!is.na(unit[,fa[3]]),]
        unit[,me][is.na(unit[,me])]=0
        assign("unitbis",unit,envir=.GlobalEnv)
        tkmessageBox(message=paste("Les facteurs choisis sont renseign�s pour ",nrow(unitbis)," donn�es.",sep=""))
        formule1= "unitbis[,me] ~ (as.factor(unitbis[,fa[1]])+as.factor(unitbis[,fa[2]])+as.factor(unitbis[,fa[3]]))^2"
        model1 = lm(as.formula(formule1),singular.ok=T)
        ## plot des r�sidus
        x11(width=50,height=30,pointsize=10)
        par(mfrow=c(2,3))
        plot(model1,which = c(1:6),
             caption = list("R�sidus vs valeurs pr�dites",
             "Quantile-quantile des r�sidus standardises vs les quantiles th�oriques",
             "Racine carr�e des r�sidus standardis�s vs valeurs pr�dites",
             "Distance de Cook","R�sidus standardis�s vs leverage","Distance de Cook vs Leverage") )  #leverage=levier de l'observation???
        X11()
        hist(model1$residuals, main="Histogramme des r�sidus")
        ## � partir des graphiques des r�sidus, proposer d'enlever les r�sidus extr�mes, ou de transformer en log ou les 2.
        Transformations.f("unitbis[,me] ~ (as.factor(unitbis[,fa[1]])+as.factor(unitbis[,fa[2]])+as.factor(unitbis[,fa[3]]))^2")
    }
    OK.but <-tkbutton(bb,text="OK",command=OnOK)
    tkgrid(OK.but)
    tkfocus(bb)
    tkwait.window(bb)
    unit<-unitSauvegarde
    assign("unit",unit,envir=.GlobalEnv)
}
