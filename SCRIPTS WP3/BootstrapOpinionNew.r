################################################################################
# Nom               : BootstrapOpinion.r
# Type              : Programme
# Objet             : Fonctions bootstrap des m�triques d'opinion � partir 
#                     des questionnaires des diff�rents usagers
# Input             : data import�es en txt
# Output            : tableaux et graphs
# Auteur            : Elodie Gamp
# R version         : 2.8.1
# Date de cr�ation  : novembre 2011
# Sources
################################################################################


########################################################################################################################
BootstrapOpinionQuali.f <- function(tableau, facteur, metrique)
{
    ## Purpose: Lance le calcul des intervalles de confiance pour les questions
    ##          d'enqu�tes qualitatives et retourne les IC estim�s
    ## ----------------------------------------------------------------------
    ## Arguments: tableau : table de donn�es (data.frame)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011

  # variables n�cessaires pour le bootstrap
    Nboot = 1000  # taille du bootstrap (nb de r�plications)
    activiteDispo <- unique( tableau [ , facteur ] )
    nbActivite <- length(activiteDispo)
    tableau [ , facteur ] <- as.factor(tableau [ , facteur ])
    
  ## d�claration du tableau de stockage pour les r�sultats bootstrap
    questBoot <- array(NA,c(nlevels(tableau [ , metrique ]),nlevels(tableau [ , facteur ]),Nboot), 
                       dimnames=list(levels(tableau [ , metrique ]),levels(tableau [ , facteur ]),c(1:Nboot)))
  
  # fonction de r��chantillonnage toutes activit�s confondues : calcul des proportions par activit� et par m�triques
  for (b in 1 : Nboot) {
      QuestTire <- sample(tableau$quest,replace=T,size=nrow(tableau))
      QuestEchant <- tableau[match(QuestTire,tableau$quest),]
      rsltEchant <- table(QuestEchant[,metrique],QuestEchant[, facteur])
      propRsltEchant <- round(prop.table(rsltEchant,2)*100,digits=2)
    
      questBoot [,,b] <- propRsltEchant
  }
  
  ### estimation existence de l'AMP
  moyboot <- apply(questBoot,c(1,2),mean,na.rm=T)
  ICinfboot <- apply(questBoot,c(1,2),quantile,probs=0.025,na.rm=T)
  ICsupboot <- apply(questBoot,c(1,2),quantile,probs=0.975,na.rm=T)
  estim <- array(c(ICinfboot,moyboot,ICsupboot),
                 c(nlevels(tableau[, metrique]),nlevels(tableau[, facteur]),3))
  dimnames(estim) <- list (rownames(moyboot),colnames(moyboot),c("ICInf","Moy","ICSup"))
  return(estim)
  
}


################################################################################################################################
BootstrapOpinionQuanti.f <- function(tableau, facteur, metrique)
{
    ## Purpose: Lance le calcul des intervalles de confiance pour les questions
    ##          d'enqu�tes quantitatives et retourne les IC estim�s
    ## ----------------------------------------------------------------------
    ## Arguments: tableau : table de donn�es (data.frame)
    ##            facteur : nom du facteur de s�paration (character)
    ##            metrique : nom de la m�trique (character)
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: 16 novembre 2011

  # variables n�cessaires pour le bootstrap
    Nboot = 1000  # taille du bootstrap (nb de r�plications)
    activiteDispo <- unique( tableau [ , facteur ] )
    nbActivite <- length(activiteDispo)
    
  ## d�claration du tableau de stockage pour les r�sultats bootstrap
    questBoot <- array(NA,c(1,nlevels(tableau [ , facteur ]),Nboot), 
                       dimnames=list("valeur",levels(tableau [ , facteur ]),c(1:Nboot)))
  
  # fonction de r��chantillonnage toutes activit�s confondues : calcul des proportions par activit� et par m�triques
  for (b in 1 : Nboot) {
      QuestTire <- sample(tableau$quest,replace=T,size=nrow(tableau))
      QuestEchant <- tableau[match(QuestTire,tableau$quest),]
      rsltEchant <- tapply(QuestEchant[,metrique],QuestEchant[, facteur],mean,na.rm=T)    
      questBoot [,,b] <- rsltEchant
  }
  
  ### estimation existence de l'AMP
  moyboot <- apply(questBoot,c(1,2),mean,na.rm=T)
  ICinfboot <- apply(questBoot,c(1,2),quantile,probs=0.025,na.rm=T)
  ICsupboot <- apply(questBoot,c(1,2),quantile,probs=0.975,na.rm=T)
  estim <- array(c(ICinfboot,moyboot,ICsupboot),
                 c(1,nlevels(tableau[, facteur]),3))
  dimnames(estim) <- list (rownames(moyboot),colnames(moyboot),c("ICInf","Moy","ICSup"))
  return(estim)
  
}


################################################################################################################################
