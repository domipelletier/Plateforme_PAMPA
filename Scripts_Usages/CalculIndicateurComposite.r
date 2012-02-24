################################################################################
# Nom               : CalculIndicateurComposite.r
# Type              : Programme
# Objet             : Ensemble des fonctions permettant de calculer les 
#                    indicateurs �l�mentaires et composites � partir des donn�es
#                    d'enqu�tes p�che
# Input             : data import�es en txt
# Output            : tableaux et graphs
# Auteur            : Elodie Gamp (sur la base de Pierre-Olivier Goffard)
# R version         : 2.11.1
# Date de cr�ation  : d�cembre 2011
# Sources
################################################################################

#####################         Indicateurs Composites pour la perception de l'AMP par ses usagers         #######################

# Nettoyage de la table en supprimmant toutes les valeurs manquante#
Nettoyage.f <- function(tab1){
  tab <- subset(tab1,tab1$existenceAMP!="NA" | tab1$suffiInfo!="NA" | 
                tab1$respectReg!="NA" | tab1$adaptReg!="NA" | 
                tab1$effetEcosyst!="NA" |tab1$effetEcono!="NA" |tab1$effetAct!="NA" )
  return(tab)
}
 
# Calcul des indicateurs �l�mentaires par variable
# Indicateurs �l�mentaires permettant le calcul de l'indicateur de Perception/Connaissance 
# par la m�thode INSEE pour calculer l'indice de confiance des m�nages

# Indicateur de connaissance de l'AMP
IndicExistenceAMP.f  <- function(tab2){
  AvisPos <- subset(tab2, tab2$existenceAMP == "oui")
  AvisNeg <- subset(tab2, tab2$existenceAMP == "non")
  IndicIntermed <- (nrow(AvisPos) - nrow(AvisNeg)) / 
                    (nrow(AvisPos) + nrow(AvisNeg))
  IndicElem <- (IndicIntermed/2) + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateur de la suffisance de l'information
IndicSuffiInfo.f <- function(tab2){
  AvisPos <- subset(tab2, tab2$suffiInfo == "oui")
  AvisNeg <- subset(tab2, tab2$suffiInfo == "non")
  IndicIntermed <- (nrow(AvisPos) - nrow(AvisNeg)) / 
                    (nrow(AvisPos) + nrow(AvisNeg))
  IndicElem <- (IndicIntermed/2) + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateur sur le respect de la r�glementation
IndicRespectReg.f   <-  function(tab2){
  AvisPos <- subset(tab2, tab2$respectReg == "oui")
  AvisNeg <- subset(tab2, tab2$respectReg == "non")
  IndicIntermed <- (nrow(AvisPos) - nrow(AvisNeg)) / 
                    (nrow(AvisPos) + nrow(AvisNeg))
  IndicElem  <-  (IndicIntermed/2) + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateur de pertinence de la r�glementation
IndicAdaptReg.f  <- function(tab2){
  AvisBien <- subset(tab2, tab2$adaptReg == "bien")
  AvisInada <- subset(tab2, tab2$adaptReg == "inada")
  AvisTrop <- subset(tab2, tab2$adaptReg == "trop")
  AvisInsu <- subset(tab2, tab2$adaptReg == "insu")
  IndicIntermed <- (nrow(AvisBien) - nrow(AvisInada) - nrow(AvisTrop) - nrow(AvisInsu)) / 
                    (nrow(AvisBien) + nrow(AvisInada) + nrow(AvisTrop) + nrow(AvisInsu))
  IndicElem <- (IndicIntermed/2) + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateurs �l�mentaires permettant le calcul de l'indicateur de Perception/Performance 
# par la m�thode INSEE pour calculer l'indice de confiance des m�nages
# A noter que l'on ne prend pas en compte la modalit� neutre et que ce calcul correspond � la version permettant de faire le distinguo
# plutot positif/tres positif et plutot negatif/tres negatif 

# Indicateur de la perception de l'effet sur l'�cosyst�me
IndicEcosyst.f  <-  function(tab){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
#  AvisPos1 <- subset(tab1, tab1$effetEcosyst == "plutot_positif")
#  AvisNeg1 <- subset(tab1, tab1$effetEcosyst == "plutot_negatif")
  AvisPos2 <- subset(tab1, tab1$effetEcosyst == "tres_positif")
  AvisNeg2 <- subset(tab1, tab1$effetEcosyst == "tres_negatif")
  AvisPos <- subset(tab1, tab1$effetEcosyst == "plutot_positif" | tab1$effetEcosyst == "tres_positif")
  AvisNeg <- subset(tab1, tab1$effetEcosyst == "plutot_negatif" | tab1$effetEcosyst == "tres_negatif")
  AvisTous <- subset(tab1, tab1$effetEcosyst == "plutot_negatif" | tab1$effetEcosyst == "tres_negatif" | 
                              tab1$effetEcosyst == "plutot_positif" | tab1$effetEcosyst == "tres_positif")
  
  IndicIntermed <- ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) - 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg)) /
                   ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) + 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg))
  
  IndicElem <- IndicIntermed/2 + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateur de la perception de l'effet sur l'�conomie locale
IndicEcono.f  <-  function(tab){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
#  AvisPos1 <- subset(tab1, tab1$effetEcno == "plutot_positif")
#  AvisNeg1 <- subset(tab1, tab1$effetEcono == "plutot_negatif")
  AvisPos2 <- subset(tab1, tab1$effetEcono == "tres_positif")
  AvisNeg2 <- subset(tab1, tab1$effetEcono == "tres_negatif")
  AvisPos <- subset(tab1, tab1$effetEcono == "plutot_positif" | tab1$effetEcono == "tres_positif")
  AvisNeg <- subset(tab1, tab1$effetEcono == "plutot_negatif" | tab1$effetEcono == "tres_negatif")
  AvisTous <- subset(tab1, tab1$effetEcono == "plutot_negatif" | tab1$effetEcono == "tres_negatif" | 
                              tab1$effetEcono == "plutot_positif" | tab1$effetEcono == "tres_positif")
  
  IndicIntermed <- ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) - 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg)) /
                   ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) + 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg))
  
  IndicElem <- IndicIntermed/2 + 0.5
  return(round(IndicElem, digits = 2))
}

# Indicateur de la perception de l'effet sur l'activit� de l'usager
IndicAct.f  <-  function(tab){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
#  AvisPos1 <- subset(tab1, tab1$effetAct == "plutot_positif")
#  AvisNeg1 <- subset(tab1, tab1$effetAct == "plutot_negatif")
  AvisPos2 <- subset(tab1, tab1$effetAct == "tres_positif")
  AvisNeg2 <- subset(tab1, tab1$effetAct == "tres_negatif")
  AvisPos <- subset(tab1, tab1$effetAct == "plutot_positif" | tab1$effetAct == "tres_positif")
  AvisNeg <- subset(tab1, tab1$effetAct == "plutot_negatif" | tab1$effetAct == "tres_negatif")
  AvisTous <- subset(tab1, tab1$effetAct == "plutot_negatif" | tab1$effetAct == "tres_negatif" | 
                              tab1$effetAct == "plutot_positif" | tab1$effetAct == "tres_positif")
  
  IndicIntermed <- ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) - 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg)) /
                   ((1 + nrow(AvisPos2) / nrow(AvisTous)) * nrow(AvisPos) + 
                     (1 + nrow(AvisNeg2) / nrow(AvisTous)) * nrow(AvisNeg))
  
  IndicElem <- IndicIntermed/2 + 0.5
  return(round(IndicElem, digits = 2))
}


# Cr�ation de la fonction permettant le calcul � partir des donn�es de l'indice de Perception/Connaissance
IndicConnaissance.f <- function(tab2, Weight){
  IndicElemExistAMP <- IndicExistenceAMP.f(tab = tab2)
  IndicElemSuffiInfo  <- IndicSuffiInfo.f(tab = tab2)
  IndicElemRespectReg <- IndicRespectReg.f(tab = tab2)
  IndicElemAdaptReg  <- IndicAdaptReg.f(tab = tab2)
  IndicComposite <- round(Weight[1]*IndicElemExistAMP + Weight[2]*IndicElemSuffiInfo + Weight[3]*IndicElemRespectReg + Weight[4]*IndicElemAdaptReg, digits=2)
  return(IndicComposite)
}


# Cr�ation de la fonction permettant le calcul � partir des donn�es de l'indice de Perception/Performance#
IndicPerformance.f <- function(tab,Weight){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
  IndicElemEcosyst  <- IndicEcosyst.f(tab = tab1)
  IndicElemEcono  <- IndicEcono.f(tab = tab1)
  IndicElemAct  <- IndicAct.f(tab = tab1)
  IndicComposite <- round(Weight[1]*IndicElemEcosyst + Weight[2]*IndicElemEcono + Weight[3]*IndicElemAct, digits=2)
  return(IndicComposite)
}

# M�thode permettant de calcul� la pond�ration en fonction du taux de NSP
# Pond�ration pour l'indicateur  de Perception/Connaissance
 WeightConnais.f  <-  function (tab){
 NSPexist <- subset(tab, tab$existenceAMP == "nsp" | tab$existenceAMP == "NSP")
 NSPinfo <- subset(tab, tab$suffiInfo == "nsp" | tab$suffiInfo == "NSP")
 NSPrespect <- subset(tab, tab$respectReg == "nsp" | tab$respectReg == "NSP")
 NSPadapt <- subset(tab, tab$adaptReg == "nsp" | tab$adaptReg == "NSP")
 OpinionExist <- length(tab[,1]) - length(NSPexist[,1])
 OpinionInfo <- length(tab[,1]) - length(NSPinfo[,1])
 OpinionRespect <- length(tab[,1]) - length(NSPrespect[,1])
 OpinionAdapt <- length(tab[,1]) - length(NSPadapt[,1])
 
 Weight <- c(OpinionExist / (OpinionExist+OpinionInfo+OpinionRespect+OpinionAdapt),
             OpinionInfo / (OpinionExist+OpinionInfo+OpinionRespect+OpinionAdapt),
             OpinionRespect / (OpinionExist+OpinionInfo+OpinionRespect+OpinionAdapt),
             OpinionAdapt /(OpinionExist+OpinionInfo+OpinionRespect+OpinionAdapt))
 return(Weight)
}
 
# Pond�ration pour l'indicateur de Perception/Performance
 WeightPerfo.f  <-  function (tab){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
  NSPecosyst <- subset(tab1, tab1$effetEcosyst == "nsp" | tab1$effetEcosyst == "NSP")
  NSPecono <- subset(tab1, tab1$effetEcono == "nsp" | tab1$effetEcono == "NSP")
  NSPact <- subset(tab1, tab1$effetAct == "nsp" | tab1$effetAct == "NSP")
  OpinionEcosyst <- length(tab1[,1]) - length(NSPecosyst[,1])
  OpinionEcono <- length(tab1[,1]) - length(NSPecono[,1])
  OpinionAct <- length(tab1[,1]) - length(NSPact[,1])
  
  Weight <- c(OpinionEcosyst / (OpinionEcosyst + OpinionEcono + OpinionAct),
              OpinionEcono / (OpinionEcosyst + OpinionEcono + OpinionAct),
              OpinionAct / (OpinionEcosyst + OpinionEcono + OpinionAct))
  return(Weight)
}

# R�-�chantillonage Bootstrap
AMPboot.f  <-  function(tab){
# Cr�ation d'un dataframe vide disposant des m�mes noms de colonne que la table p�che
  tabVide <- tab[1,][-1,]
  numTirage <- as.numeric(rownames(tab))  # d�finition des num�ros pour le tirage
  # Echantillon bootstrap issu d'un tirage al�atoire avec remise
  echant <- sample(numTirage, length(numTirage), replace = T)
  tabBoot <- rbind.data.frame(tabVide, tab[echant,])
  return(tabBoot)
}

# M�thode permettant de calculer la valeur des indicateurs individuels ainsi que 
# des indicateurs composites pour les �chantillons bootstraps cr��s puis de 
# l'estimation des bornes de l'Intervalle de Confiance
# G�n�ration de 500 �chantillons bootstrap ce qui est suffisant pour l'estimation 
# des centiles de la distribution des indicateurs �l�mentaires et composites
IndicBoot.f  <-  function(tab){
  TabEchant <- as.data.frame(matrix(0,500,9))
  colnames(TabEchant)<-c("existenceAMP","suffiInfo","respectReg","adaptReg","effetEcosyst","effetEcono","effetAct","indicConnais","indicPerf")
    for(i in (1:500)){
      tabBoot  <-  AMPboot.f(tab)
      TabEchant[i, "existenceAMP"]  <-  IndicExistenceAMP.f(tab = tabBoot)
      TabEchant[i, "suffiInfo"]  <-  IndicSuffiInfo.f (tab = tabBoot)
      TabEchant[i, "respectReg"]  <-  IndicRespectReg.f(tab = tabBoot)
      TabEchant[i, "adaptReg"]  <-  IndicAdaptReg.f(tab = tabBoot)
      TabEchant[i, "effetEcosyst"]  <-  IndicEcosyst.f(tab = tabBoot)
      TabEchant[i, "effetEcono"]  <-  IndicEcono.f(tab = tabBoot)
      TabEchant[i, "effetAct"]  <-  IndicAct.f(tab = tabBoot)
      TabEchant[i, "indicConnais"]  <-  IndicConnaissance.f(tab = tabBoot, 
                                                            WeightConnais.f(tab = tabBoot))
      TabEchant[i, "indicPerf"]  <-  IndicPerformance.f(tab = tabBoot,
                                                        WeightPerfo.f(tab = tabBoot))
    }
    return(TabEchant)
}

#M�thode renvoyant la matrice contenant la valeur des indicateurs individuels et composite ainsi que l'�cart tMatrice_Ipe entre les indicateurs individuels#
CalculIndicateurCompo.f  <-  function(tab){

  tkmessageBox(message="Cette fonction met un peu de temps � tourner!\n Soyez patients.",icon="warning",type="ok")

  tab <- Nettoyage.f(tab)
  TabEchantBoot <- IndicBoot.f(tab = tab)
  TabIndicateurs <- as.data.frame(matrix(0,9,2))
  rownames(TabIndicateurs) <- c("ExistenceAMP","SuffiInfo","RespectReg","AdaptReg","EffetEcosyst","EffetEcono","EffetAct","IndicConnaissance","IndicPerformance")
  colnames(TabIndicateurs) <- c("valeurs","IC")
  TabIndicateurs["ExistenceAMP","valeurs"]  <-  IndicExistenceAMP.f(tab = tab)
  TabIndicateurs["SuffiInfo","valeurs"]  <-  IndicSuffiInfo.f (tab = tab)
  TabIndicateurs["RespectReg","valeurs"]  <-  IndicRespectReg.f(tab = tab)
  TabIndicateurs["AdaptReg","valeurs"]  <-  IndicAdaptReg.f(tab = tab)
  TabIndicateurs["EffetEcosyst","valeurs"]  <-  IndicEcosyst.f(tab = tab)
  TabIndicateurs["EffetEcono","valeurs"]  <-  IndicEcono.f(tab = tab)
  TabIndicateurs["EffetAct","valeurs"]  <-  IndicAct.f(tab = tab)
  TabIndicateurs["IndicConnaissance","valeurs"]  <-  IndicConnaissance.f(tab = tab, WeightConnais.f(tab = tab))
  TabIndicateurs["IndicPerformance","valeurs"]  <-  IndicPerformance.f(tab = tab,WeightPerfo.f(tab = tab))  
  TabIndicateurs["ExistenceAMP","IC"]  <-  paste("[",round(quantile(TabEchantBoot$existenceAMP, probs = 0.025),digits = 2), ",",
                                                  round(quantile(TabEchantBoot$existenceAMP, probs = 0.975), digits = 2), "]")
  TabIndicateurs["SuffiInfo","IC"]  <-  paste("[",round(quantile(TabEchantBoot$suffiInfo, probs = 0.025), digits = 2), ",",
                                                round(quantile(TabEchantBoot$suffiInfo, probs = 0.975), digits = 2), "]")
  TabIndicateurs["RespectReg","IC"]  <-  paste("[",round(quantile(TabEchantBoot$respectReg, probs = 0.025), digits=2), ",",
                                                round(quantile(TabEchantBoot$respectReg, probs = 0.975), digits = 2), "]")
  TabIndicateurs["AdaptReg","IC"]  <-  paste("[",round(quantile(TabEchantBoot$adaptReg, probs = 0.025), digits = 2), ",",
                                              round(quantile(TabEchantBoot$adaptReg, probs = 0.975), digits = 2), "]")
  TabIndicateurs["EffetEcosyst","IC"]  <-  paste("[",round(quantile(TabEchantBoot$effetEcosyst, probs = 0.025), digits = 2), ",",
                                                  round(quantile(TabEchantBoot$effetEcosyst, probs = 0.975), digits = 2), "]")
  TabIndicateurs["EffetEcono","IC"]  <-  paste("[",round(quantile(TabEchantBoot$effetEcono, probs = 0.025), digits = 2), ",",
                                                 round(quantile(TabEchantBoot$effetEcono, probs = 0.975), digits = 2), "]")
  TabIndicateurs["EffetAct","IC"]  <-  paste("[",round(quantile(TabEchantBoot$effetAct, probs = 0.025), digits = 2),",",
                                               round(quantile(TabEchantBoot$effetAct, probs = 0.975), digits = 2), "]")
  TabIndicateurs["IndicConnaissance","IC"]  <-  paste("[",round(quantile(TabEchantBoot$indicConnais, probs = 0.025), digits = 2), ",",
                                                       round(quantile(TabEchantBoot$indicConnais, probs = 0.975), digits = 2), "]")
  TabIndicateurs["IndicPerformance","IC"]  <-  paste("[",round(quantile(TabEchantBoot$indicPerf, probs = 0.025), digits = 2), ",",
                                                      round(quantile(TabEchantBoot$indicPerf, probs = 0.975), digits = 2), "]")

  # Radar plot des indicateurs �l�mentaires de connaissance 
  x11(width=60,height=40,pointsize=10)
  radial.plot(TabIndicateurs[1:4, 1], 
              labels = c("Existence de l'AMP","Suffisance de l'information","Respect de la r�glementation","Pertinence de la r�glementation"), 
              rp.type="p", radial.lim=c(0,1), start = 0, clockwise = TRUE, line.col = "light blue",
              main = "Radar plot Indicateurs �l�mentaires de Connaissance de l'AMP et de sa r�glementation", lwd=3, label.prop=1.1)
 savePlot(filename="C:/PAMPA/resultats_Usages/IndicateurComposite/Radar plot indicateurs �l�mentaires Connaissance", type =c("bmp"))

  # Radar plot des indicateurs �l�mentaires de performance 
  x11(width=60,height=40,pointsize=10)
  radial.plot(TabIndicateurs[5:7, 1], 
              labels = c("Effet de l'AMP sur l'�cosyst�me","Effet de l'AMP sur l'�conomie locale","Effet de l'AMP sur leur activit�"), 
              rp.type="p", radial.lim=c(0,1), start = 0, clockwise = TRUE, line.col = "light blue",
              main = "Radar plot Indicateurs �l�mentaires de Performance de l'AMP", lwd=3, label.prop=1.1)
 savePlot(filename="C:/PAMPA/resultats_Usages/IndicateurComposite/Radar plot indicateurs �l�mentaires performance", type =c("bmp"))

  # Tableau contenant les indicateurs �l�mentaires et ainsi que leurs intervalles de confiance respectifs
 write.table(TabIndicateurs,"C:/PAMPA/resultats_Usages/IndicateurComposite/Tableau indicateurs �l�mentaires Connaissance et Performance.csv",sep=";",quote=T)
 return(TabIndicateurs)
}
##### Appel de la fonction : Attention le r�_�chantillonage bootstrap est un processus couteux en temps de calcul#######
# CalculIndicateurCompo.f  (tab = peche)



# Calcul de l'indicateur composite de performance via la m�thode du syst�me de notation : The OCDE way

# M�thode permettant le recodage des variable d'int�r�t dans le cadre du calcul 
# de l'indicateur de performance, Ainsi que le calcul des indicateurs �l�mentaires par individu
note.f <- function(tab){
  tab1 <- subset(tab, tab$existenceAMP == "oui")
    VecteurElementaire <- as.data.frame(matrix(0,length(tab1[,1]),1))
  colnames(Vecteur_I_elementaire) <- c("C")
  
  # recodage des variables de performance, les modalit� deviennent des notes -> Variables qualitatives ordonn�es
  # Nsp = NA par commodit� pour les calculs des indicateurs, 
  # nsp est tout de m�me pris en compte dans la pond�ration
  tab1$ecosystRecod <- NA
  tab1$ecosystRecod[which(tab1$effetEcosyst == "tres_positif")] <- 1 
  tab1$ecosystRecod[which(tab1$effetEcosyst == "plutot_positif")] <- 0.75 
  tab1$ecosystRecod[which(tab1$effetEcosyst == "neutre")] <- 0.5 
  tab1$ecosystRecod[which(tab1$effetEcosyst == "plutot_negatif")] <- 0.25 
  tab1$ecosystRecod[which(tab1$effetEcosyst == "tres_negatif")] <- 0
  
  tab1$econoRecod <- NA
  tab1$econoRecod[which(tab1$effetEcono == "tres_positif")] <- 1 
  tab1$econoRecod[which(tab1$effetEcono == "plutot_positif")] <- 0.75 
  tab1$econoRecod[which(tab1$effetEcono == "neutre")] <- 0.5 
  tab1$econoRecod[which(tab1$effetEcono == "plutot_negatif")] <- 0.25 
  tab1$econoRecod[which(tab1$effetEcono == "tres_negatif")] <- 0
  
  tab1$actRecod <- NA
  tab1$actRecod[which(tab1$effetAct == "tres_positif")] <- 1 
  tab1$actRecod[which(tab1$effetAct == "plutot_positif")] <- 0.75 
  tab1$actRecod[which(tab1$effetAct == "neutre")] <- 0.5 
  tab1$actRecod[which(tab1$effetAct == "plutot_negatif")] <- 0.25 
  tab1$actRecod[which(tab1$effetAct == "tres_negatif")] <- 0
  
  for (i in (1:nrow(tab1))){
    vect <- c(tab1$ecosystRecod[i],tab1$econoRecod[i],tab1$actRecod[i])
    # Calcul de l'indicateur �l�menataire par individu
    VecteurElementaire$C[i] <- round(mean(vect, na.rm=T), digits=2)
  }
  MatriceElementaire <- cbind(tab1, VecteurElementaire)
  return(MatriceElementaire)
}
       
# M�thode renvoyant l'intervalle de confiance pour l'indicateur de 
# perception/Performance en testant la moyenne des indicateurs �l�mentaires
IC_Performance_note.f <- function(tab){
  Matrice_Indicateur_note <- note.f(tab = tab)
  IC <- t.test(Matrice_Indicateur_note$C,conf.level=0.95)$conf.int
  return(IC)
}

#M�thode renvoyant l'intervalle de confiance pour l'indicateur de Perception/Performance en testant la moyenne des indicateurs �l�mentaires#
IC_Ecosyst_note.f <- function(tab){
Matrice_Indicateur_note <- note.f(tab = tab)
IC <- t.test(Matrice_Indicateur_note$ecosystRecod,conf.level=0.95)$conf.int
return(IC)
}
#M�thode renvoyant l'intervalle de confiance pour l'indicateur de Perception/Performance en testant la moyenne des indicateurs �l�mentaires#
IC_Econo_note.f <- function(tab){
Matrice_Indicateur_note <- note.f(tab = tab)
IC <- t.test(Matrice_Indicateur_note$econoRecod,conf.level=0.95)$conf.int
return(IC)
}
#M�thode renvoyant l'intervalle de confiance pour l'indicateur de Perception/Performance en testant la moyenne des indicateurs �l�mentaires#
IC_Peche_note.f <- function(tab){
Matrice_Indicateur_note <- note.f(tab = tab)
IC <- t.test(Matrice_Indicateur_note$actRecod,conf.level=0.95)$conf.int
return(IC)
}

#M�thode permettant le calcul des indicateurs �l�mentaires par variables, de l'indicateur composite ainsi que leur IC respectifs, 
#graphiques pour les indicateurs �l�metaires (Histogramme + boxplot), radar pour les indicateurs �l�mentaires par variables#
 
Matrice_Indicateur_note.f  <-  function(tab){
Matrice_I <- as.data.frame(matrix(0,4,2))
rownames(Matrice_I) <- c("EffetEcosyst","EffetEcono","EffetAct","IndicateurPerformance")
colnames(Matrice_I) <- c("valeurs","IC")
Matrice_Indicateur_note <- note.f(tab = tab)

# Histogramme et boxplot pour les indicateurs �l�mentaires par individu
x11(width=60,height=40,pointsize=10)
par(mfrow= c(1,2))
hist(Matrice_Indicateur_note$C, main="Distribution des indicateurs �l�mentaires par individu",
                                xlab="Indicateur �l�mentaire",col="light blue")
boxplot(Matrice_Indicateur_note$C, data=Matrice_Indicateur_note, ylab="Indicateur �l�mentaire",
                                   main="Boxplot des indicateurs �l�mentaires par individu", col="light blue")
savePlot(filename="C:/PAMPA/resultats_USages/IndicateurComposite/Distribution indicateurs �l�mentaires par individus", type =c("bmp"))

#Calcul des indicateurs �l�mentaires et de l'indicateur composite ainsi que de leurs intervalles de confiance
  Matrice_I["EffetEcosyst", "valeurs"]  <-  round(mean(Matrice_Indicateur_note$ecosystRecod, na.rm=T), digits=2)
  Matrice_I["EffetEcono", "valeurs"]  <-  round(mean(Matrice_Indicateur_note$econoRecod, na.rm=T), digits=2)
  Matrice_I["EffetAct", "valeurs"]  <-  round(mean(Matrice_Indicateur_note$actRecod, na.rm=T), digits=2)
  Matrice_I["IndicateurPerformance", "valeurs"]  <-  round(mean(Matrice_Indicateur_note$C, na.rm=T), digits=2)
  Matrice_I["EffetEcosyst", "IC"]  <-  paste("[",round(IC_Ecosyst_note.f(tab = tab1), digits = 2)[1], ",",
                                                round(IC_Ecosyst_note.f(tab = tab1), digits = 2)[2], "]")
  Matrice_I["EffetEcono", "IC"]  <-  paste("[",round(IC_Econo_note.f(tab = tab1), digits = 2)[1], ",",
                                              round(IC_Econo_note.f(tab = tab1), digits = 2)[2], "]")
  Matrice_I["EffetAct", "IC"]  <-  paste("[",round(IC_Peche_note.f(tab = tab1), digits = 2)[1], ",",
                                            round(IC_Peche_note.f(tab = tab1), digits = 2)[2], "]")
  Matrice_I["IndicateurPerformance", "IC"]  <-  paste("[",round(IC_Performance_note.f(tab = tab1), digits = 2)[1], ",",
                                                         round(IC_Performance_note.f(tab = tab1), digits = 2)[2], "]")

# Diagramme en radar des indicateurs �l�mentaires par variable
  x11(width=60,height=40,pointsize=10) 
  radial.plot(Matrice_I[1:3, 1], labels = c("Effet sur l'�cosyst�me","Effet sur l'�conomie locale","Effet sur la p�che"), 
              rp.type="p", radial.lim=c(0,1), start = 0, clockwise = TRUE, line.col = "light blue", 
              main = "Radar plot Indicateurs �l�mentaires (notes)",lwd=3,label.prop=1.21)
 savePlot(filename="C:/PAMPA/resultats_Usages/IndicateurComposite/Radar plot indicateurs �l�mentaires notes", type =c("bmp"))
 # Tableau contenant les indicateurs �l�mentaires et ainsi que leur intervalle de confiance respectifs
 write.table(Matrice_I,"C:/PAMPA/resultats_USages/IndicateurComposite/Tableau indicateurs �l�mentaires Performance Note.csv",sep=";",quote=T)
  
  return(Matrice_I)
}

######Appel de la fonction######
# Matrice_Indicateur_note.f(tab=peche)


#####Appel des fonctions avec une distinction r�alis�e entre les p�cheurs, les plongeurs et les plaisanciers#######

#Calcul des indicateurs de connaissance de l'AMP et de sa r�glementation#
Indicateur_Connaissance_TypeActivite.f  <-  function(tableau,acti){
tableau_TypeActivite <- subset(tableau,tableau$activite == "acti")
Matrice_Indicateur <- Matrice_Indicateur2.f(tableau_TypeActivite)
return( Matrice_Indicateur)
}

#Calcul des indicateurs de performance#
Indicateur_Performance_TypeActivite.f  <-  function(tableau,acti){
tableau_TypeActivite <- subset(tableau,tableau$activite == "acti")
Matrice_Indicateur <- Matrice_Indicateur_note.f(tableau_TypeActivite)
return(Matrice_Indicateur)
}

#####Appel des fonctions avec une distinction r�alis�e entre les r�sidents et les non r�sidents#######
#Pour les r�sidents#
#Calcul des indicateurs de connaissance de l'AMP et de sa r�glementation#
Indicateur_Connaissance_Resident.f  <-  function(tableau,acti){
tableau_Resident <- subset(tableau,tableau$resident == "resident")
Matrice_Indicateur <- Matrice_Indicateur2.f(tableau_Resident)
return( Matrice_Indicateur)
}

#Calcul des indicateurs de performance#
Indicateur_Performance_Resident  <-  function(tableau,acti){
tableau_Resident <- subset(tableau,tableau$resident == "resident")
Matrice_Indicateur <- Matrice_Indicateur_note.f(tableau_Resident)
return(Matrice_Indicateur)
}

#Pour les non r�sidents#
#Calcul des indicateurs de connaissance de l'AMP et de sa r�glementation#
Indicateur_Connaissance_nonresident.f  <-  function(tableau,acti){
tableau_nonresident <- subset(tableau,tableau$resident == "non-resident")
Matrice_Indicateur <- Matrice_Indicateur2.f(tableau_nonresident)
return( Matrice_Indicateur)
}

#Calcul des indicateurs de performance#
Indicateur_Performance_nonresident  <-  function(tableau,acti){
tableau_nonresident <- subset(tableau,tableau$resident == "non-resident")
Matrice_Indicateur <- Matrice_Indicateur_note.f(tableau_nonresident)
return(Matrice_Indicateur)
}
