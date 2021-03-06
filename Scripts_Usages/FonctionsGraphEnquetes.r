################################################################################
# Nom               : FonctionsGraphEnquetes.r
# Type              : Programme
# Objet             : Fonctions n�cessaires pour les calculs et le lancement des 
#                     graphiques relatifs aux donn�es des enqu�tes. 
#                     Ces fonctions seront appel�es par l'interface de traitement 
#                     des donn�es d'enqu�tes.
# Input             : data import�es en txt
# Output            : tableaux et graphs
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : septembre 2011
# Sources
################################################################################


########################################################################################################################
BarplotParticulier.f <- function (tableau, nomTable, facteur, metrique, periode)
{
    ## Purpose: Fonction de calcul des tableux descriptifs et graphiques 
    ##          correspondants pour les questions � choix multiples
    ## ----------------------------------------------------------------------
    ## Arguments: tableau : table de donn�es (data.frame)
    ##            nomTable ; nom de la table de donn�es (character)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ##            periode : choix de s�parer ou non les p�riodes d'�chantillonnage
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011

    periodeEchant <- unique(tableau[,periode])
    ## recup�ration du nomp des champs
    casParticulier <- casParticulier.f()

    champMultiple <- casParticulier[grep(metrique, casParticulier)]

    liste1 <- sapply(seq(1:length(champMultiple)),FUN=function(x){unique(tableau[,champMultiple[x]])})
    liste <- levels(as.factor(liste1))
### calcul de la proportion de r�ponse par modalit� (plusieurs r�ponses donc >100%)
    TabMulti <- t(sapply(seq(1:length(champMultiple)),
                         FUN=function(x)
                     {
                         table(tableau[,champMultiple[x]])[match(liste, names(table(tableau[ , champMultiple[1]])))]
                     }))   # nb de r�ponses

    rownames(TabMulti) <- champMultiple
    TabPropMulti <- round(apply(TabMulti,2,sum, na.rm=T)*100/lengthnna.f(tableau[,champMultiple[1]]),digits=2)   # proportions
    TauxReponse <- c(round(lengthnna.f(tableau[,champMultiple[1]])*100/nrow(tableau),digits=2),NA,NA)
    ICinfRslt <- round((TabPropMulti/100+qnorm(0.025)*sqrt(TabPropMulti/100*(1-TabPropMulti/100)/nrow(tableau)))*100,digits=2)
    ICsupRslt <- round((TabPropMulti/100+qnorm(0.975)*sqrt(TabPropMulti/100*(1-TabPropMulti/100)/nrow(tableau)))*100,digits=2)
    TableauResultat <- cbind(rbind(ICinfRslt,TabPropMulti,ICsupRslt),TauxReponse)
    sink(paste("C:/PAMPA/Resultats_Usages/enquetes/", metrique, "selon", nomTable, facteur, "en", periodeEchant, ".txt"))
    print(TableauResultat)
    sink()

    ## graphique
    x11(width=50,height=30,pointsize=6)
    par(oma=c(0, 0, 3, 0))    # agrandissement de la marge externe sup�rieure (pour titre g�n�ral)
    graphB <- barplot(TabPropMulti, beside=T, ylim=c(0,max(ICsupRslt,na.rm=T)),
                     main = paste("En", periodeEchant, metrique, "pour l'activit�",
                     nomTable),  #, "selon le facteur", facteur),
                     cex.main = 3,cex.axis=2.5, cex.names=2.5) #legend.text=rownames(TabRslt$proportionReponse),args.legend=list(x="topleft")
    arrows(graphB, ICinfRslt, graphB, ICsupRslt, code = 3, col = "red", angle = 90, length = .1)
    savePlot(filename=paste("C:/PAMPA/Resultats_Usages/enquetes/barplotProp",metrique,"selon",nomTable,facteur, "en", periodeEchant), type =c("png"))
}


########################################################################################################################
###   FONCTIONS CALCUL TABLEAUX DESCRIPTIFS QUALI ET GRAPHS CORRESPONDANTS   ###

    ## Purpose: Fonction de calcul des tableux descriptifs et graphiques 
    ##          correspondants pour les questions qualitatives
    ## ----------------------------------------------------------------------
    ## Arguments: tableau : table de donn�es (data.frame)
    ##            nomTable ; nom de la table de donn�es (character)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ##            periodEchant : p�riode d'�chantillonnage consid�r�e
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011


### Tableau descriptif qualitatif  (pour barplotProp et pie)
TabDescripQuali.f <- function(tableau, nomTable, facteur, metrique, periodeEchant) {
    nbRep <- table(tableau[,metrique],tableau[,facteur])
    total <- apply(nbRep,2,sum)
    propRslt <- round(prop.table(nbRep,2)*100,digits=2)    # proportion de chaque r�ponse
    tauxReponse <- round(total*100/as.numeric(table(tableau[,facteur])),digits=2)    # taux de r�ponse
    
    # calcul des IC bootstrap
    estimIC <- BootstrapOpinionQuali.f (tableau = tableau, 
                                        facteur = facteur, 
                                        metrique = metrique)
    ICinfRslt <- round(estimIC[,,"ICInf"] ,digits=2)
    ICinfRslt[which(ICinfRslt < 0)] <- 0
    ICsupRslt <- round(estimIC[,,"ICSup"] ,digits=2)
    ICsupRslt[which(ICsupRslt > 100)] <- 100
    TableauResultat <- list("tauxReponse"=tauxReponse,"proportionReponse"=propRslt,"ICinf"=ICinfRslt,"ICsup"=ICsupRslt)
    sink(paste("C:/PAMPA/Resultats_Usages/enquetes/",metrique,"selon",nomTable,facteur,"en", periodeEchant, ".txt"))
                                        #  print(tauxReponse)
    print(TableauResultat)
    sink()
    return (TableauResultat)
}

  # graphiques qualitatif : barplot
BarplotPropEnquetes.f <- function(tableau, nomTable, facteur, metrique, periode) {
    periodeEchant <- unique(tableau[,periode])
    TabRslt <- TabDescripQuali.f(tableau, nomTable, facteur, metrique, periodeEchant)
    OptGraph <- OptionGraph.f(TabRslt$proportionReponse, graph="barplot")    #lay (r�partition des graphs) et hauteur (hauteur des portions de fen�tre graphique)
                                        #  couleur <- color.choice (nrow(TabRslt$proportionReponse), list(rownames(TabRslt$proportionReponse)))
    couleur <- grey.colors(nrow(TabRslt$proportionReponse))
    x11(width=50,height=30,pointsize=6)
    layout(OptGraph[[1]], height=OptGraph[[2]])
    par(oma=c(0, 0, 5, 0))    # agrandissement de la marge externe sup�rieure (pour titre g�n�ral)
    graphB <- barplot(TabRslt$proportionReponse, beside=T, ylim=c(0,max(TabRslt$ICsup,na.rm=T)), 
                      col=couleur, main = paste("En", periodeEchant, metrique, "selon le facteur", facteur),
                      cex.main = 3,cex.axis=2.5, cex.names=2.5) #legend.text=rownames(TabRslt$proportionReponse),args.legend=list(x="topleft")
    arrows(graphB, TabRslt$ICinf, graphB, TabRslt$ICsup, code = 3, col = "red", angle = 90, length = .1)
    ## Affichage de la l�gence 1) graphique qui n'affiche rien
    plot(1:2, 1:2, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n")
### 2) l�gende dans le graph vide
    legend("center",
           title="L�gende des couleurs",
           legend=rownames(TabRslt$proportionReponse), col=couleur, pch=15, ncol=2, xpd=NA, cex = 3)
    savePlot(filename=paste("C:/PAMPA/Resultats_Usages/enquetes/barplotProp",metrique,"selon",nomTable,facteur, "en", periodeEchant), type =c("png"))
}


  # graphiques qualitatif : camembert
CamembertEnquetes.f <- function(tableau, nomTable, facteur, metrique, periode)
{
    periodeEchant <- unique(tableau[,periode])
    TabRslt <- TabDescripQuali.f(tableau, nomTable, facteur, metrique, periodeEchant)
    graphNb <- TabRslt$proportionReponse[,apply(TabRslt$proportionReponse,2,sum,na.rm=T)!=0,drop=F]    # enl�ve les colonnes sans r�ponse
                                        #  couleur <- color.choice (nrow(graphNb), list(rownames(graphNb)))
    couleur <- grey.colors(nrow(graphNb))
    OptGraph <- OptionGraph.f(graphNb, graph="camembert")    #lay (r�partition des graphs) et hauteur (hauteur des portions de fen�tre graphique)
    x11(width=50,height=30,pointsize=6)
    layout(OptGraph[[1]], height=OptGraph[[2]])
    par(oma=c(0, 0, 9, 0))    # agrandissement de la marge externe sup�rieure (pour titre g�n�ral)
    graphNb <- TabRslt$proportionReponse[,apply(TabRslt$proportionReponse,2,sum,na.rm=T)!=0,drop=F]    # enl�ve les colonnes sans r�ponse
    graphP <- sapply(seq(1:ncol(graphNb)),FUN=function(x) {pie(graphNb[,x],main=colnames(graphNb)[x],
                                         labels=paste(graphNb[,x],"%"),
                                         ,cex=3.5,cex.main = 3.5, col=couleur)})
    mtext(paste("En", periodeEchant, metrique, "selon le facteur", facteur),line=2, outer=TRUE, cex = 3.5)
    ## Affichage de la l�gence 1) graphique qui n'affiche rien
    plot(1:2, 1:2, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n")
### 2) l�gende dans le graph vide
    legend("center",
           title="L�gende des couleurs",
           legend=rownames(graphNb), col=couleur, pch=15, ncol=2, xpd=NA, cex = 3.5)
    savePlot(filename=paste("C:/PAMPA/Resultats_Usages/enquetes/camembert",metrique,"selon",nomTable,facteur, "en", periodeEchant), type =c("png"))
}

########################################################################################################################
###   FONCTIONS CALCUL TABLEAUX DESCRIPTIFS QUANTI ET GRAPHS CORRESPONDANTS  ###

    ## Purpose: Fonction de calcul des tableux descriptifs et graphiques 
    ##          correspondants pour les questions quantitatives
    ## ----------------------------------------------------------------------
    ## Arguments: tableau : table de donn�es (data.frame)
    ##            nomTable ; nom de la table de donn�es (character)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ##            periodEchant : p�riode d'�chantillonnage consid�r�e
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011


### Tableau descriptif quantitatif  (pour barplotMoy et boxplot)
TabDescripQuanti.f <- function(tableau, nomTable, facteur, metrique, periodeEchant) {

    nbTot <-  as.numeric(table(tableau[,facteur]))
    Mini <- tapply(tableau[,metrique],tableau[,facteur],min, na.rm=T)
    Maxi <- tapply(tableau[,metrique],tableau[,facteur],max, na.rm=T)
    Mediane <- tapply(tableau[,metrique],tableau[,facteur],median, na.rm=T)
    Moyenne <- tapply(tableau[,metrique],tableau[,facteur],mean, na.rm=T)
    EcartType <- tapply(tableau[,metrique],tableau[,facteur],sd, na.rm=T)
    Variance <- tapply(tableau[,metrique],tableau[,facteur],var, na.rm=T)
    TauxReponse <- tapply(tableau[,metrique],tableau[,facteur],lengthnna.f)*100/nbTot
    # calcul des IC bootstrap
    estimIC <- BootstrapOpinionQuanti.f (tableau = tableau, 
                                         facteur = facteur, 
                                         metrique = metrique)
    ICinf <- round(estimIC[,,"ICInf"] ,digits=2)
    ICinf[which(ICinf < 0)] <- 0
    ICsup <- round(estimIC[,,"ICSup"] ,digits=2)
    TableauResultat <- round(rbind(Mini, Maxi, Mediane, Moyenne, EcartType, Variance, TauxReponse, ICinf, ICsup), digits=2)
    sink(paste("C:/PAMPA/Resultats_Usages/enquetes/",metrique,"selon",nomTable,facteur,"en", periodeEchant, ".txt"))
                                        #  print(tauxReponse)
    print(TableauResultat)
    sink()
    return (TableauResultat)
}


  ## graphiques quantitatifs : boxplot
BoxplotEnquetes.f <- function (tableau, nomTable, facteur, metrique, periode){

    periodeEchant <- unique(tableau[,periode])
    
    TabRslt <- TabDescripQuanti.f(tableau, nomTable, facteur, metrique, periodeEchant)
    OptGraph <- OptionGraph.f(TabRslt$proportionReponse, graph="boxplot")    #lay (r�partition des graphs) et hauteur (hauteur des portions de fen�tre graphique)
    x11(width=50,height=30,pointsize=6)
    layout(OptGraph[[1]], height=OptGraph[[2]])
    par(oma=c(0, 0, 4, 0))
    graphBo <- boxplot(tableau[,metrique]~tableau[,facteur], 
                      main=paste("En", periodeEchant, metrique, "selon le facteur", facteur),
                      cex.main = 3,cex.axis=2.5, cex.names=2.5)
    TabRsltNonNul <- as.data.frame(TabRslt[,graphBo$names])
    text(1:ncol(TabRsltNonNul),max(TabRsltNonNul["Maxi",],na.rm=T),labels=round(TabRsltNonNul["Moyenne",],digits=1),col="red",cex=2)
    ## Affichage de la l�gence 1) graphique qui n'affiche rien
    plot(1:2, 1:2, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n")
### 2) l�gende dans le graph vide
    legend("center",
           title="Pr�cisions",
           legend=paste("La valeur des moyennes pour chaque valeur de",facteur,"sont rajout�es en haut du graphique"), cex = 2)
    savePlot(filename=paste("C:/PAMPA/Resultats_Usages/enquetes/boxplot",metrique,"selon",nomTable,facteur, "en", periodeEchant), type =c("png"))
}


  ## graphiques quantitatifs : barplot
BarplotMoyenneEnquetes.f <- function (tableau, nomTable, facteur, metrique, periode){
    periodeEchant <- unique(tableau[,periode])
    TabRslt <- TabDescripQuanti.f(tableau, nomTable, facteur, metrique, periodeEchant)
    OptGraph <- OptionGraph.f(TabRslt$proportionReponse, graph="barplot")    #lay (r�partition des graphs) et hauteur (hauteur des portions de fen�tre graphique)
    x11(width=50,height=30,pointsize=6)
    layout(OptGraph[[1]], height=OptGraph[[2]])
    par(oma=c(0, 0, 4, 0))
    graphB <- barplot(TabRslt["Moyenne",], 
                     main=paste("En", periodeEchant, metrique, "selon le facteur", facteur),
                     cex.main = 3,cex.axis=2.5, cex.names=2.5,ylim=c(0,max(TabRslt["ICsup",],na.rm=T)))
    arrows(graphB, TabRslt["ICinf",],graphB, TabRslt["ICsup",], code = 3, col = "red", angle = 90, length = .1)
    ## Affichage de la l�gence 1) graphique qui n'affiche rien
    plot(1:2, 1:2, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n")
### 2) l�gende dans le graph vide
    legend("center",
           title="Pr�cisions",
           legend=paste("Les intervalles de confiance sont rajout�s pour chaque valeur de ",facteur), cex = 2)
    savePlot(filename=paste("C:/PAMPA/Resultats_Usages/enquetes/barplotMoy",metrique,"selon",nomTable,facteur, "en", periodeEchant), type =c("png"))
}


########################################################################################################################
OptionGraph.f <- function (proportionReponse, graph) 
{       

    ## Purpose: d�finition de la fen�tre graphique (disposition des graphs  
    ##          et de la l�gende)
    ## ----------------------------------------------------------------------
    ## Arguments: proportionReponse : tableau de r�sultats � la question (quali ou quanti)
    ##            graph : type de graph choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011

    if (graph =="barplot" | graph =="boxplot"){
        lay = matrix(c(1,2),ncol=1)     # cr�ation de la matrice de d�coupage de la fen�tre  1 = graph, 2 = l�gende
        hauteur = c(10,3)
    } else {
        nbColTab <- ncol(proportionReponse)  # nb de graph � pr�voir
        if (nbColTab == 2) {
            lay = matrix(c(1, 2, 3, 3), ncol=2, byrow=TRUE)
            hauteur = c(10,3)
        } else {
            div = nbColTab%/%2          # 2 = nb de lignes sur lesquels se r�partissent les graphs
            modulo = nbColTab%%2        # est-ce qu'il reste des graphs en plus ?
            nbColGraph = div+modulo     # d�finit le nombre de colonnes de la zone graphique
            if (modulo == 1) {
                                        #            nbLigGraph = 2      # modulo = 1 donc il reste une place pour la l�gende
                lay = matrix (seq (1 : (nbColTab+1)), ncol=nbColGraph,byrow=TRUE)  # pas n�cessaire de d�finir le nombre de ligne car d�finit par la matrice)
                hauteur = c(10,10)
            } else {
                                        #            nbLigGraph = 3      # modulo = 0, il n'y a plus de place pour la l�gende donc je rajoute une ligne
                lay = matrix (c(seq (1 : nbColTab),rep(nbColTab+1,nbColGraph)), ncol=nbColGraph,byrow=TRUE) # pas n�cessaire de d�finir le nombre de ligne car d�finit par la matrice)
                hauteur = c(10,10,5)
            }
        }
    }
    return(list(lay,hauteur))
}


########################################################################################################################

