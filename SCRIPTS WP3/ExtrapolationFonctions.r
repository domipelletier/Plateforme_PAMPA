# FONCTION 1 : tableau de r�f�rence utilis� dans toutes les fonctions suivantes (en gardant les m�mes niveaux spatial et temporel)
### Fonction de calcul des nombres de jours par mois, des taux d'�chantillonnage
TabEchant.f <- function(FreqAnneeChoisie, niveauSpatial) {

  spatialDispo <- sort(as.character(unique(FreqAnneeChoisie[,niveauSpatial])))    # ttes zones dispo dans FreqAnneeChoisie 
  temporelDispo <- sort(unique(FreqAnneeChoisie$mois))    # tous les mois avec sortie dans FreqAnneeSortie
  nbSpatial <- length(spatialDispo)
  nbTemporel <- length(temporelDispo)

  # pr�liminaires pour certaines calculs de la table d'�chantillonnage
  CaracSortie <- unique(FreqAnneeChoisie[,c("numSortie","jour","saison","typeJ","typeJsimp","mois",niveauSpatial)])   # caract�ristique sortie
  assign("CaracSortie",CaracSortie,envir=.GlobalEnv)   
  
##########  tkmessagebox info si niveau spatial ou niveau temporel manquant (� mettre dans fichier de sortie)
############## r�gler la question de la validit� de l'extrapolation en cas de strates vides.

  InfoProtocoleEchant <- array (0,c(nbTemporel, nbSpatial, 6),
                  list(temporelDispo, spatialDispo, c("JS","JW","TJ","NbJSAnnee","NbJWAnnee","NbTJAnnee")))

  InfoProtocoleEchant [,,"JS"] <- table(CaracSortie$typeJsimp,
                                        factor(CaracSortie$mois),
                                        factor(CaracSortie[,niveauSpatial]))["JS",,] # nb de JS �chantillonn�s
  InfoProtocoleEchant [,,"JW"] <- table(CaracSortie$typeJsimp,
                                        factor(CaracSortie$mois),
                                        factor(CaracSortie[,niveauSpatial]))["JW",,] # idem pour les JW
  InfoProtocoleEchant [,,"TJ"] <- InfoProtocoleEchant [,,"JS"] + InfoProtocoleEchant [,,"JW"]
  
  InfoProtocoleEchant[,,"NbJSAnnee"] <- rep(tapply(calendrier$JS,
                                                   calendrier$mois,
                                                   sum,na.rm=T),
                                            nbSpatial)       # nb JS dispo dans le calendrier
  InfoProtocoleEchant[,,"NbJWAnnee"] <- rep(tapply(calendrier$JW,
                                                   calendrier$mois,
                                                   sum,na.rm=T),
                                            nbSpatial)       # idem en JW
  InfoProtocoleEchant[,,"NbTJAnnee"] <- InfoProtocoleEchant[,,"NbJSAnnee"] + InfoProtocoleEchant[,,"NbJWAnnee"]
  return(InfoProtocoleEchant)
}


#########################################################################################################################################################################################
# FONCTION 2 : Fonction du calcul de la moyenne et de la variance par mois, zone, et type de jour 
CalculMoyenneVariance.f <- function(FreqAnneeChoisie, variable, niveauSpatial) {

    # tableau en 4D : somme de la fr�quentation par mois, zone, type de jour et sortie
    FreqJour <- tapply(FreqAnneeChoisie[,variable],list(FreqAnneeChoisie$mois,
                                                      factor(FreqAnneeChoisie[,niveauSpatial]),
                                                      factor(FreqAnneeChoisie$typeJsimp),
                                                      factor(FreqAnneeChoisie$numSortie)),
                        sum,na.rm=T)
    # tableau 3D : fr�quentation moyenne par mois, zone, et type de jour 
    MoyFreqJour <- apply(FreqJour,c(1,2,3),mean,na.rm=T)
    # tableau 3D : variance de la fr�quentation par mois, zone, et type de jour
    VarFreqJour <- apply(FreqJour,c(1,2,3),var,na.rm=T)
    
    FreqMoyVar <- list(MoyFreqJour,VarFreqJour)
    return(FreqMoyVar)   # la fonction donne une liste comportant 2 tableaux 3D  : un contenant la moyenne de la fr�quentation, l'autre la variance de la fr�quentation
                                # par mois, zone, et type de jour
}


#########################################################################################################################################################################################
# FONCTION 3 : calcul de l'estimation de la fr�quentation par mois et zone (types de jour confondus)
FreqTempSpatial.f <- function(InfoProtocoleEchant=InfoProtocoleEchant, FreqMoyVar=FreqMoyVar)  {
                                        # rappel : InfoProtocoleEchant = tableau en 3D , 1=mois, 2=zone et 3 = type de jour
   spatialDispo <- dimnames(InfoProtocoleEchant)[[2]]
   nbSpatial <- length(spatialDispo)
   temporelDispo <- dimnames(InfoProtocoleEchant)[[1]]
   nbTemporel <- length(temporelDispo)

   FreqMoy <- FreqMoyVar[[1]]     # tableau en 3D : 1=mois, 2=zone et 3 = type de jour
   FreqVar <- FreqMoyVar[[2]]     # tableau en 3D : 1=mois, 2=zone et 3 = type de jour

### etimation fr�quentation spatiale/mois*typeJour
  matcheJS <- match(dimnames(as.matrix(FreqMoy[,,"JS"]))[[1]],dimnames(as.matrix(InfoProtocoleEchant[,,"NbJSAnnee"]))[[1]]) 
  matcheJW <- match(dimnames(as.matrix(FreqMoy[,,"JW"]))[[1]],dimnames(as.matrix(InfoProtocoleEchant[,,"NbJWAnnee"]))[[1]]) 

  FreqSpatialMoisJour <- array (0,c(nbTemporel, nbSpatial, 2),
                  list(temporelDispo, spatialDispo, c("FreqJS","FreqJW")))

   FreqSpatialMoisJour[,,"FreqJS"] <- FreqMoy[,,"JS"] * InfoProtocoleEchant[,,"NbJSAnnee"] [matcheJS] 
   FreqSpatialMoisJour[,,"FreqJW"] <- FreqMoy[,,"JW"] * InfoProtocoleEchant[,,"NbJWAnnee"] [matcheJW]  

  return(FreqSpatialMoisJour)  # tableau 3D :  fr�quentation extrapol�e par niveau spatial, mois et typeJ
}


#########################################################################################################################################################################################
### FONCTION 4 (types jours confondus) : Calcul de l'estimateur par niveau temporel 
###                 + graphiques et enregistrements du r�sultats
Estimateur.f <- function (FreqSpatialMoisJour, InfoProtocoleEchant, 
                          niveauTemporel, niveauSpatial, periode, facteurSep = NULL, 
                          modalites=NULL, titre="", nombre, graph=T) {

  # somme de l'estimation sur les deux types de jours
  FreqSpatialMois <- apply(FreqSpatialMoisJour, c(1,2), sum, na.rm=T)
 # somme de l'estimation sur le niveau temporel choisi
  EstimSpatialTemp1 <- as.data.frame(FreqSpatialMois)
  EstimSpatialTemp1$niveau <- calendrier[,niveauTemporel][match(rownames(EstimSpatialTemp1),
                                                                         calendrier$mois)]
  EstimSpatialTemp <- aggregate(EstimSpatialTemp1[,1:(ncol(EstimSpatialTemp1)-1)],
                                list(EstimSpatialTemp1$niveau),
                                sum, na.rm=T)
  rownames(EstimSpatialTemp) <- EstimSpatialTemp[,1]
  EstimSpatialTemp <- as.matrix(EstimSpatialTemp[,-1])
  
    if (graph==T) {   # hors bootstrap
     
        write.csv(EstimSpatialTemp , file = paste("C:/PAMPA/resultats script R/metriquesWP3/extrapolation/EstimExtrapol",periode, nombre,niveauTemporel, "et", niveauSpatial,titre,".csv",sep=""))
  
        ## Barplot de la fr�quentation estim�e
        x11(width=50,height=30,pointsize=6)
        layout(matrix(c(1,2),ncol=1), height=c(10,2))
        par(oma=c(0, 2, 4, 0))
#        par(mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0))
        plotEstimat <- barplot(EstimSpatialTemp, beside=T, cex.lab = 2.5, cex.axis=2.5 ,
                                                 cex.names=2.5,cex.main = 2.6, xlab = niveauTemporel,
                                                 ylab = paste("Nombre de",nombre,"estim� (+- IC 95%)"),
                                                 ylim=c(0,max(EstimSpatialTemp,na.rm=T)), 
                                                 main = paste("En",periode,": Estimation du nombre de",nombre,"extrapol� \n par",niveauTemporel, "et", niveauSpatial, titre))
        
        plot(1:2, 1:2, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n")
        legend("center",
                title="L�gende des couleurs",
                legend=rownames(EstimSpatialTemp), col=grey.colors(nrow(EstimSpatialTemp)), pch=15, ncol=3, xpd=NA, cex = 2.5)

        savePlot (filename=paste("C:/PAMPA/resultats script R/metriquesWP3/extrapolation/EstimExtrapol",periode,nombre,niveauTemporel,niveauSpatial,titre,sep=""), type =c("bmp"))
        return(EstimSpatialTemp)
      
    } else {          # uniquement pour bootstrap
        return(EstimSpatialTemp)
    }
}


#########################################################################################################################################################################################
### FONCTION 4 (types jours distincts) : Calcul de l'estimateur par niveau temporel 
###                 + graphiques et enregistrements du r�sultats
EstimateurJ.f <- function (FreqSpatialMoisJour, InfoProtocoleEchant=InfoProtocoleEchant, 
                           niveauTemporel="mois", niveauSpatial, periode, facteurSep = NULL, 
                           modalites=NULL, titre="",nombre="bateaux",graph=T) {

 # somme de l'estimation sur le niveau temporel choisi
  EstimSpatialTempJ1 <- unlist(apply(FreqSpatialMoisJour, 3, list), recursive = FALSE)
#  EstimSpatialTempJ1 <- FreqSpatialMoisJour
  Estim <- sapply(1:2,FUN = function(i,...) {
                   Estimateur.f(FreqSpatialMoisJour=EstimSpatialTempJ1[[i]],
                                InfoProtocoleEchant=InfoProtocoleEchant, 
                                niveauTemporel=niveauTemporel, 
                                niveauSpatial= niveauSpatial,
                                periode=periode, 
                                titre=paste(titre,"typeJ=",names(EstimSpatialTempJ1)[[i]]),
                                nombre=nombre,
                                graph=graph)
                   }
        )
  EstimSpatialTempJ <-  array(unlist(Estim), dim=c(length(unique(FreqAnneeChoisie[,niveauTemporel])), length(unique(FreqAnneeChoisie[,niveauSpatial])),2), 
                                             dimnames=c(list(unique(FreqAnneeChoisie[,niveauTemporel])), 
                                                        list(as.character(unique(FreqAnneeChoisie[,niveauSpatial]))),
                                                        list(names(EstimSpatialTempJ1))))
  return(EstimSpatialTempJ)       
}

#########################################################################################################################################################################################

### FONCTION 2 ADAPTEE ACTIVITE : Fonction du calcul de la moyenne et de la variance par niveau temporel, niveau spatial, et type de jour ADAPTEE AUX ACTIVITES
CalculMoyenneVarianceAct.f<-function(FreqAnneeChoisie, variable, niveauSpatial, facteurSep, modalites)  {

  spatialDispo <-sort(as.character(unique(FreqAnneeChoisie[,niveauSpatial])))    # ttes zones dispo dans FreqAnneeChoisie (� sortir des fct g�n�rique mais interne au fct interface)
  temporelDispo <- sort(unique(FreqAnneeChoisie$mois))    # tous les mois avec sortie dans FreqAnneeSortie
  nbSpatial <- length(spatialDispo)
  nbTemporel <- length(temporelDispo)

    ## transformation pour r�cup�rer les 0 pour le facteur de s�paration choisi  
     Freq1 <- with(FreqAnneeChoisie,
                tapply(FreqAnneeChoisie[ , variable],
                        as.list(FreqAnneeChoisie[, c("mois", niveauSpatial,                     # �l�ments nomm�s pour avoir les noms de dimensions dans le tableau
                                                     "typeJsimp", "numSortie",
                                        facteurSep)]),                            # facteurSep d�fini le champ du facteur de s�paration
                        sum, na.rm=TRUE))

   ## Indice des ensembles caract�ristiques/sorties  existantes (hors s�lection)
   idx <- with(FreqAnneeChoisie,
              tapply(FreqAnneeChoisie[ , variable],
                        as.list(FreqAnneeChoisie[, c("mois", niveauSpatial,                     # �l�ments nomm�s pour avoir les noms de dimensions dans le tableau
                                                     "typeJsimp", "numSortie")]),                                    # Les m�mes moins le champ de s�lection
                     function(x)ifelse(length(x), TRUE, FALSE)))

   ## Renvoie quand m�me NA si inexistante => on remplace par FALSE
   idx[is.na(idx)] <- FALSE

   # Tableau de fr�quentation par facteurSep (5D), corrig� pour
   ## tenir compte des activit�s non observ�es sur sorties effectives :
    FreqCor1 <- sweep(Freq1,
                 which(is.element(names(dimnames(Freq1)),  # Dimensions de Freq1 communes avec idx
                                  names(dimnames(idx)))), # (caract�ristiques de sorties existantes).
                 idx,
                 function(x, y)
             {
                 x[is.na(x) & y] <- 0     # on ne remplace que les NAs des sorties existantes.
                 return(x)
             })

    # lors d'une s�lection, FreqCor remplace le tableau 4D FreqJour
    # Attention, 1D de plus dans FreqCor. Les fonctions suivantes ne seront appliqu�es que pour la modalit� choisie
    Agarde <- dimnames(FreqCor1)[[5]] [is.element(dimnames(FreqCor1)[[5]] , modalites)]
    FreqCor <- FreqCor1[,,,,Agarde,drop=F]                                      # r�duit le tableau � la modalit� choisie
    
    # tableau 3D : fr�quentation moyenne par mois, niveau spatial et type de jour 
    MoyFreqJour <- apply(FreqCor,c(1,2,3),mean,na.rm=T)
    # tableau 3D : variance de la fr�quentation par mois, niveau spatial et type de jour
    VarFreqJour <- apply(FreqCor,c(1,2,3),var,na.rm=T)
    
    FreqMoyVar <- list(MoyFreqJour,VarFreqJour)
    return(FreqMoyVar)   # la fonction donne une liste comportant 2 tableaux 3D  : un contenant la moyenne de la fr�quentation, l'autre la variance de la fr�quentation
}


####################################################################################################################################################################
