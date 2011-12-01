################################################################################
# Nom               : BootstrapFr�quentationExtrapol�e.r
# Type              : Programme
# Objet             : Fonctions Bootstrap des m�triques de fr�quentation extrapol�es
# Input             : data import�es en txt
# Output            : tableaux et graphs
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : novembre 2011
# Sources
################################################################################
BootstrapExtrapolation.f <- function () {
      
    #Apr�s avoir r�alis� un tri sur freqtot, � savoir :
    #- Soit 6 mois de fr�quentation maximale (avril-sept pour CB et oct-mars pour NC)
    #- Soit 2 mois de fr�quentation maximale (juillet-ao�t pour CB et dec � fev pour NC)
    #- Soit tous les mois (pas de tri)
    #Les simulations par bootstrap ne seront faites que par cat�gorie d'activit� ou toutes activit�s confondues.
     
    Sys.time()  ### affiche la date et l'heure
      
      categExtrapol="plongee"
      actExtrapol="PL"
      
      FreqAnneeChoisie <- subset(freqtot, freqtot$periodEchant==anneeChoisie)
    
    # rajout d'une colonne pour le num�ro sortie*tirage (si tirage en doublon)
      FreqAnneeChoisie$numBootstrap <- FreqAnneeChoisie$num_sortie
      SAUVFreqAnneeChoisie <- FreqAnneeChoisie
      
      niveauTemporel <- "mois"
      Nboot = 500  # taille du bootstrap (nb de r�plications)
      temporelDispo <- unique( FreqAnneeChoisie [ , niveauTemporel ] )
      nbTemporel <- length(temporelDispo)
    
    # construction des matrices nbTemporel (ou nbSpatial) * nb de r�plications pour chaque m�trique � tester avec le bootstrap
    #(pour stocker la valeur estim�e par l'extrapolation pour chaque it�ration)
    
    # en nombre de bateaux
    ########################## TOUTES ACTIVITES CONFONDUES
    FreqEstimee <- matrix(NA,ncol=length(unique(FreqAnneeChoisie[, niveauTemporel])),nrow=Nboot)               #  Nombre de bateaux extrapol� par mois
    colnames(FreqEstimee) <- unique(FreqAnneeChoisie$mois) 
    ### BOUCLE BOOTSTRAP ###
        
    for (z in 1 : Nboot)  {               ## boucle en [z] pour les 1 000  it�rations
      FreqBoot = NULL       # Re_echant
      FreqAnneeChoisie <- SAUVFreqAnneeChoisie       # �vite de prendre un tableau modifi� pour effectuer une nouvelle it�ration
      
      for (i in 1: nbTemporel) {          ## boucle en [i] pour s�lectionner chaque trimestre
          
          freqTrimestre <- FreqAnneeChoisie[which(FreqAnneeChoisie[,niveauTemporel]==temporelDispo[i]),]
      # fr�quentation pour le trimestre i (y compris les z�ros pour les zonesXdate o� aucun bateau)
          TypeJ <- unique( freqTrimestre$typeJsimp)  # types de jours vus durant ce trimestre    
      
          for (j in 1 : length(TypeJ)) {   ## boucle en [j] pour s�lectionner chaque type de jour vus ce trimestre i
              freqTJ <- freqTrimestre[which(freqTrimestre$typeJsimp == TypeJ[j]),] 
      # ensemble des bateaux vus durant le trimestre i et le type de jour j (y compris les z�ros pour les zonesXdate o� aucun bateau)
      # (tableau � 36 colonnes)
              Sortie <- unique(freqTJ$num_sortie)   # liste des sorties du tri i et type de jour j
              TirageSortie <- sample(Sortie,replace=T,size=length(Sortie))
      # �chantillonne avec remise une proportion prop_ech des jours de sorties du trimestre i et du type_J j
    
    # reconstitution du tableau de fr�quentation r�-�chantillonn�
              FreqEchant <- FreqAnneeChoisie[1,]
    #          FreqEchant$numBootstrap <- NA
              for (S in 1 : length(TirageSortie)) {
                FreqSortie <- subset(FreqAnneeChoisie,FreqAnneeChoisie$num_sortie==TirageSortie[S])
                FreqSortie$numBootstrap <- paste(FreqSortie$num_sortie,S,sep="_")         # permet de distinguer les sorties tir�es plusieurs fois
                FreqEchant <- rbind(FreqEchant,FreqSortie)
              }
              FreqEchant <- FreqEchant[-1,]
    # tableau � 36 colonnes des bateaux r��chantillon�s pour le trimestre i et le type de jour j
                if (is.null(FreqBoot)) { FreqBoot <- FreqEchant         # n�cessaire pour le premier passage sinon rbind marche pas
                } else { FreqBoot <- rbind(FreqBoot,FreqEchant) }          # colle les lignes de bateaux r��chantillonn�s pour (i,j)
          
          } ## fin de la boucle en type de jour (j)
      } # fin de la boucle du trimestre i
      #### le tableau de fr�quentation r�_�chantillonn� pour 1 it�ration est termin�
      ### toutes les m�triques sont recalcul�es sur ce nouveau tableau  FreqBoot
     # pour les m�triques d'extrapolation, on utilise les fonctions d�finies dans l'extrapolation
    
     # 6secondes pour effectuer le tri
    # certaines sorties ont �t� tir�es plusieurs fois, FreqBoot$numBootstrap permet de notifier � R 
    # qu'il faut les consid�rer comme 2sorties diff�rentes (=deux tirages)
    FreqBoot$num_sortie <- FreqBoot$numBootstrap  
    FreqAnneeChoisie <- FreqBoot   
    
    ### Formation des gros tableau 3D qui serviront pour l'ensemble des extrapolations
    TabEchant <- TabEchant.f ()
    # En nombre de bateaux
    TabMoyVarBat <- CalculMoyenneVariance.f ()
    TabMoyVarActBat <- CalculMoyenneVarianceAct.f (niveauAct="act1", categ_act=actExtrapol,nombre="nb_bat")
    TabMoyVarCategActBat <- CalculMoyenneVarianceAct.f (niveauAct="categ_act1", categ_act=categExtrapol,nombre="nb_bat")
    # En nombre de personnes
    TabMoyVarPers <- CalculMoyenneVariance.f (nombre="nb_pers")
    TabMoyVarActPers <- CalculMoyenneVarianceAct.f (niveauAct="act1", categ_act=actExtrapol,nombre="nb_pers")
    TabMoyVarCategActPers <- CalculMoyenneVarianceAct.f (niveauAct="categ_act1", categ_act=categExtrapol,nombre="nb_pers")
    
    
    ###### Calculs des extrapolations pour l'it�ration z
    ### toutes activit�s confondues en bateaux
      estimBootNbBatMoisAMP <- FreqBootExtraMois.f()              #  Nombre de bateaux extrapol� par mois
      FreqEstimeeBatMoisAMP [z,] <- estimBootNbBatMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatMoisAMP),rownames(estimBootNbBatMoisAMP))]
    
      estimBootNbBatTrimestreAMP <- FreqBootExtraTrim.f()         #  Nombre de bateaux extrapol� par trimestre
      FreqEstimeeBatTrimestreAMP [z,] <- estimBootNbBatTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatTrimestreAMP),rownames(estimBootNbBatTrimestreAMP))]
    
      estimBootNbBatSemestreAMP <- FreqBootExtraSem.f()         #  Nombre de bateaux extrapol� par semestre
      FreqEstimeeBatSemestreAMP [z,] <- estimBootNbBatSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatSemestreAMP),rownames(estimBootNbBatSemestreAMP))]
    
      estimBootNbBatAnneeAMP <- FreqBootExtraAn.f()             # Nombre de bateaux extrapol�s � l'ann�e sur l'AMP
      FreqEstimeeBatAnneeAMP [z,] <- estimBootNbBatAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatAnneeAMP),rownames(estimBootNbBatAnneeAMP))]
    
    
      estimBootNbBatAnneeZone <- FreqBootExtraZone.f()            #  Nombre de bateaux extrapol� � l'ann�e par zone
      FreqEstimeeBatAnneeZone [z,] <- estimBootNbBatAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeeBatAnneeZone),rownames(estimBootNbBatAnneeZone))]
    
      estimBootNbBatAnneeGroupe <- FreqBootExtraGroupe.f()          #  Nombre de bateaux extrapol� � l'ann�e par groupe de zones
      FreqEstimeeBatAnneeGroupe [z,] <- estimBootNbBatAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeeBatAnneeGroupe),rownames(estimBootNbBatAnneeGroupe))]
    
      estimBootNbBatAnneeZonage <- FreqBootExtraStatut.f()           #  Nombre de bateaux extrapol� � l'ann�e par zonage PAMPA
      FreqEstimeeBatAnneeZonage [z,] <- estimBootNbBatAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeeBatAnneeZonage),rownames(estimBootNbBatAnneeZonage))]
    
    ### type d'activit� en bateaux
      estimBootNbBatTypActMoisAMP <- FreqBootExtraMoisCatAct.f()              #  Nombre de bateaux extrapol� par type d'activit� par mois
      FreqEstimeeBatTypActMoisAMP [z,] <- estimBootNbBatTypActMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActMoisAMP),rownames(estimBootNbBatTypActMoisAMP))]
    
      estimBootNbBatTypActTrimestreAMP <- FreqBootExtraTrimCatAct.f()         #  Nombre de bateaux extrapol� par type d'activit� par trimestre
      FreqEstimeeBatTypActTrimestreAMP [z,] <- estimBootNbBatTypActTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActTrimestreAMP),rownames(estimBootNbBatTypActTrimestreAMP))]
    
      estimBootNbBatTypActSemestreAMP <- FreqBootExtraSemCatAct.f()         #  Nombre de bateaux extrapol� par type d'activit� par semestre
      FreqEstimeeBatTypActSemestreAMP [z,] <- estimBootNbBatTypActSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActSemestreAMP),rownames(estimBootNbBatTypActSemestreAMP))]
    
      estimBootNbBatTypActAnneeAMP <- FreqBootExtraAnCatAct.f()             # Nombre de bateaux extrapol�s par type d'activit� � l'ann�e sur l'AMP
      FreqEstimeeBatTypActAnneeAMP [z,] <- estimBootNbBatTypActAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActAnneeAMP),rownames(estimBootNbBatTypActAnneeAMP))]
    
    
      estimBootNbBatTypActAnneeZone <- FreqBootExtraZoneCatAct.f()            #  Nombre de bateaux extrapol� par type d'activit� � l'ann�e par zone
      FreqEstimeeBatTypActAnneeZone [z,] <- estimBootNbBatTypActAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActAnneeZone),rownames(estimBootNbBatTypActAnneeZone))]
    
      estimBootNbBatTypActAnneeGroupe <- FreqBootExtraGroupeCatAct.f()          #  Nombre de bateaux extrapol� par type d'activit� � l'ann�e par groupe de zones
      FreqEstimeeBatTypActAnneeGroupe [z,] <- estimBootNbBatTypActAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActAnneeGroupe),rownames(estimBootNbBatTypActAnneeGroupe))]
    
      estimBootNbBatTypActAnneeZonage <- FreqBootExtraStatutCatAct.f()           #  Nombre de bateaux extrapol� par type d'activit� � l'ann�e par zonage PAMPA
      FreqEstimeeBatTypActAnneeZonage [z,] <- estimBootNbBatTypActAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeeBatTypActAnneeZonage),rownames(estimBootNbBatTypActAnneeZonage))]
    
    ### activit� en bateaux
      estimBootNbBatActMoisAMP <- FreqBootExtraMoisAct.f()              #  Nombre de bateaux extrapol� par activit� par mois
      FreqEstimeeBatActMoisAMP [z,] <- estimBootNbBatActMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatActMoisAMP),rownames(estimBootNbBatActMoisAMP))]
    
      estimBootNbBatActTrimestreAMP <- FreqBootExtraTrimAct.f()         #  Nombre de bateaux extrapol� par activit� par trimestre
      FreqEstimeeBatActTrimestreAMP [z,] <- estimBootNbBatActTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatActTrimestreAMP),rownames(estimBootNbBatActTrimestreAMP))]
    
      estimBootNbBatActSemestreAMP <- FreqBootExtraSemAct.f()         #  Nombre de bateaux extrapol� par activit� par semestre
      FreqEstimeeBatActSemestreAMP [z,] <- estimBootNbBatActSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatActSemestreAMP),rownames(estimBootNbBatActSemestreAMP))]
    
      estimBootNbBatActAnneeAMP <- FreqBootExtraAnAct.f()             # Nombre de bateaux extrapol�s par activit� � l'ann�e sur l'AMP
      FreqEstimeeBatActAnneeAMP [z,] <- estimBootNbBatActAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeeBatActAnneeAMP),rownames(estimBootNbBatActAnneeAMP))]
    
    
      estimBootNbBatActAnneeZone <- FreqBootExtraZoneAct.f()            #  Nombre de bateaux extrapol� par activit� � l'ann�e par zone
      FreqEstimeeBatActAnneeZone [z,] <- estimBootNbBatActAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeeBatActAnneeZone),rownames(estimBootNbBatActAnneeZone))]
    
      estimBootNbBatActAnneeGroupe <- FreqBootExtraGroupeAct.f()          #  Nombre de bateaux extrapol� par activit� � l'ann�e par groupe de zones
      FreqEstimeeBatActAnneeGroupe [z,] <- estimBootNbBatActAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeeBatActAnneeGroupe),rownames(estimBootNbBatActAnneeGroupe))]
    
      estimBootNbBatActAnneeZonage <- FreqBootExtraStatutAct.f()           #  Nombre de bateaux extrapol� par activit� � l'ann�e par zonage PAMPA
      FreqEstimeeBatActAnneeZonage [z,] <- estimBootNbBatActAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeeBatActAnneeZonage),rownames(estimBootNbBatActAnneeZonage))]
    
    
      ### toutes activit�s confondues en personnes
      estimBootNbPersMoisAMP <- FreqPersBootExtraMois.f()              #  Nombre de personnes extrapol� par mois
      FreqEstimeePersMoisAMP [z,] <- estimBootNbPersMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersMoisAMP),rownames(estimBootNbPersMoisAMP))]
    
      estimBootNbPersTrimestreAMP <- FreqPersBootExtraTrim.f()         #  Nombre de personnes extrapol� par trimestre
      FreqEstimeePersTrimestreAMP [z,] <- estimBootNbPersTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersTrimestreAMP),rownames(estimBootNbPersTrimestreAMP))]
    
      estimBootNbPersSemestreAMP <- FreqPersBootExtraSem.f()         #  Nombre de personnes extrapol� par semestre
      FreqEstimeePersSemestreAMP [z,] <- estimBootNbPersSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersSemestreAMP),rownames(estimBootNbPersSemestreAMP))]
    
      estimBootNbPersAnneeAMP <- FreqPersBootExtraAn.f()             # Nombre de personnes extrapol�s � l'ann�e sur l'AMP
      FreqEstimeePersAnneeAMP [z,] <- estimBootNbPersAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersAnneeAMP),rownames(estimBootNbPersAnneeAMP))]
    
    
      estimBootNbPersAnneeZone <- FreqPersBootExtraZone.f()            #  Nombre de personnes extrapol� � l'ann�e par zone
      FreqEstimeePersAnneeZone [z,] <- estimBootNbPersAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeePersAnneeZone),rownames(estimBootNbPersAnneeZone))]
    
      estimBootNbPersAnneeGroupe <- FreqPersBootExtraGroupe.f()          #  Nombre de personnes extrapol� � l'ann�e par groupe de zones
      FreqEstimeePersAnneeGroupe [z,] <- estimBootNbPersAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeePersAnneeGroupe),rownames(estimBootNbPersAnneeGroupe))]
    
      estimBootNbPersAnneeZonage <- FreqPersBootExtraStatut.f()           #  Nombre de personnes extrapol� � l'ann�e par zonage PAMPA
      FreqEstimeePersAnneeZonage [z,] <- estimBootNbPersAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeePersAnneeZonage),rownames(estimBootNbPersAnneeZonage))]
    
    ### type d'activit� en personnes
      estimBootNbPersTypActMoisAMP <- FreqPersBootExtraMoisCatAct.f()              #  Nombre de personnes extrapol� par type d'activit� par mois
      FreqEstimeePersTypActMoisAMP [z,1:nrow(estimBootNbPersTypActMoisAMP)] <- estimBootNbPersTypActMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersTypActMoisAMP),rownames(estimBootNbPersTypActMoisAMP))]
    
      estimBootNbPersTypActTrimestreAMP <- FreqPersBootExtraTrimCatAct.f()         #  Nombre de personnes extrapol� par type d'activit� par trimestre
      FreqEstimeePersTypActTrimestreAMP [z,] <- estimBootNbPersTypActTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersTypActTrimestreAMP),rownames(estimBootNbPersTypActTrimestreAMP))]
    
      estimBootNbPersTypActSemestreAMP <- FreqPersBootExtraSemCatAct.f()         #  Nombre de personnes extrapol� par type d'activit� par semestre
      FreqEstimeePersTypActSemestreAMP [z,] <- estimBootNbPersTypActSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersTypActSemestreAMP),rownames(estimBootNbPersTypActSemestreAMP))]
    
      estimBootNbPersTypActAnneeAMP <- FreqPersBootExtraAnCatAct.f()             # Nombre de personnes extrapol�s par type d'activit� � l'ann�e sur l'AMP
      FreqEstimeePersTypActAnneeAMP [z,] <- estimBootNbPersTypActAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersTypActAnneeAMP),rownames(estimBootNbPersTypActAnneeAMP))]
    
    
      estimBootNbPersTypActAnneeZone <- FreqPersBootExtraZoneCatAct.f()            #  Nombre de personnes extrapol� par type d'activit� � l'ann�e par zone
      FreqEstimeePersTypActAnneeZone [z,] <- estimBootNbPersTypActAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeePersTypActAnneeZone),rownames(estimBootNbPersTypActAnneeZone))]
    
      estimBootNbPersTypActAnneeGroupe <- FreqPersBootExtraGroupeCatAct.f()          #  Nombre de personnes extrapol� par type d'activit� � l'ann�e par groupe de zones
      FreqEstimeePersTypActAnneeGroupe [z,] <- estimBootNbPersTypActAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeePersTypActAnneeGroupe),rownames(estimBootNbPersTypActAnneeGroupe))]
    
      estimBootNbPersTypActAnneeZonage <- FreqPersBootExtraStatutCatAct.f()           #  Nombre de personnes extrapol� par type d'activit� � l'ann�e par zonage PAMPA
      FreqEstimeePersTypActAnneeZonage [z,] <- estimBootNbPersTypActAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeePersTypActAnneeZonage),rownames(estimBootNbPersTypActAnneeZonage))]
    
    ### activit� en personnes
      estimBootNbPersActMoisAMP <- FreqPersBootExtraMoisAct.f()              #  Nombre de personnes extrapol� par activit� par mois
      FreqEstimeePersActMoisAMP [z,] <- estimBootNbPersActMoisAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersActMoisAMP),rownames(estimBootNbPersActMoisAMP))]
    
      estimBootNbPersActTrimestreAMP <- FreqPersBootExtraTrimAct.f()         #  Nombre de personnes extrapol� par activit� par trimestre
      FreqEstimeePersActTrimestreAMP [z,] <- estimBootNbPersActTrimestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersActTrimestreAMP),rownames(estimBootNbPersActTrimestreAMP))]
    
      estimBootNbPersActSemestreAMP <- FreqPersBootExtraSemAct.f()         #  Nombre de personnes extrapol� par  activit� par semestre
      FreqEstimeePersActSemestreAMP [z,] <- estimBootNbPersActSemestreAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersActSemestreAMP),rownames(estimBootNbPersActSemestreAMP))]
    
      estimBootNbPersActAnneeAMP <- FreqPersBootExtraAnAct.f()             # Nombre de personnes extrapol�s par activit� � l'ann�e sur l'AMP
      FreqEstimeePersActAnneeAMP [z,] <- estimBootNbPersActAnneeAMP[,"FreqEstimee"][match(colnames(FreqEstimeePersActAnneeAMP),rownames(estimBootNbPersActAnneeAMP))]
    
    
      estimBootNbPersActAnneeZone <- FreqPersBootExtraZoneAct.f()            #  Nombre de personnes extrapol� par activit� � l'ann�e par zone
      FreqEstimeePersActAnneeZone [z,] <- estimBootNbPersActAnneeZone [,"FreqEstimee"][match(colnames(FreqEstimeePersActAnneeZone),rownames(estimBootNbPersActAnneeZone))]
    
      estimBootNbPersActAnneeGroupe <- FreqPersBootExtraGroupeAct.f()          #  Nombre de personnes extrapol� par activit� � l'ann�e par groupe de zones
      FreqEstimeePersActAnneeGroupe [z,] <- estimBootNbPersActAnneeGroupe [,"FreqEstimee"][match(colnames(FreqEstimeePersActAnneeGroupe),rownames(estimBootNbPersActAnneeGroupe))]
    
      estimBootNbPersActAnneeZonage <- FreqPersBootExtraStatutAct.f()           #  Nombre de personnes extrapol� par activit� � l'ann�e par zonage PAMPA
      FreqEstimeePersActAnneeZonage [z,] <- estimBootNbPersActAnneeZonage [,"FreqEstimee"][match(colnames(FreqEstimeePersActAnneeZonage),rownames(estimBootNbPersActAnneeZonage))]
    
    } # fin du bootstrap  (boucle sur z it�rations)
    
    
     ## ESTIMATIONS PAR BOOTSTRAP
    
     # nombre de bateaux toutes activit�s confondues
      MoyBootNbBatMoisAMP <- apply(FreqEstimeeBatMoisAMP,2,mean,na.rm=T)
      VarBootNbBatMoisAMP <- apply(FreqEstimeeBatMoisAMP,2,var,na.rm=T)
      InfBootNbBatMoisAMP <- apply(FreqEstimeeBatMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatMoisAMP <- apply(FreqEstimeeBatMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatMoisAMP <- cbind(InfBootNbBatMoisAMP,MoyBootNbBatMoisAMP,SupBootNbBatMoisAMP,VarBootNbBatMoisAMP)
      colnames(EstimBootNbBatMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbBatTrimestreAMP <- apply(FreqEstimeeBatTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbBatTrimestreAMP <- apply(FreqEstimeeBatTrimestreAMP ,2,var,na.rm=T)
      InfBootNbBatTrimestreAMP <- apply(FreqEstimeeBatTrimestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTrimestreAMP <- apply(FreqEstimeeBatTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTrimestreAMP <- cbind(InfBootNbBatTrimestreAMP,MoyBootNbBatTrimestreAMP,SupBootNbBatTrimestreAMP,VarBootNbBatTrimestreAMP)
      colnames(EstimBootNbBatTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatSemestreAMP <- apply(FreqEstimeeBatSemestreAMP ,2,mean,na.rm=T)
      VarBootNbBatSemestreAMP <- apply(FreqEstimeeBatSemestreAMP ,2,var,na.rm=T)
      InfBootNbBatSemestreAMP <- apply(FreqEstimeeBatSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatSemestreAMP <- apply(FreqEstimeeBatSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatSemestreAMP <- cbind(InfBootNbBatSemestreAMP,MoyBootNbBatSemestreAMP,SupBootNbBatSemestreAMP,VarBootNbBatSemestreAMP)
      colnames(EstimBootNbBatSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatAnneeAMP <- apply(FreqEstimeeBatAnneeAMP,2,mean,na.rm=T)
      VarBootNbBatAnneeAMP <- apply(FreqEstimeeBatAnneeAMP,2,var,na.rm=T)
      InfBootNbBatAnneeAMP <- apply(FreqEstimeeBatAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatAnneeAMP <- apply(FreqEstimeeBatAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatAnneeAMP <- cbind(InfBootNbBatAnneeAMP,MoyBootNbBatAnneeAMP,SupBootNbBatAnneeAMP,VarBootNbBatAnneeAMP)
      colnames(EstimBootNbBatAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbBatAnneeZone <- apply(FreqEstimeeBatAnneeZone,2,mean,na.rm=T)
      VarBootNbBatAnneeZone <- apply(FreqEstimeeBatAnneeZone,2,var,na.rm=T)
      InfBootNbBatAnneeZone <- apply(FreqEstimeeBatAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatAnneeZone <- apply(FreqEstimeeBatAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatAnneeZone <- cbind(InfBootNbBatAnneeZone,MoyBootNbBatAnneeZone,SupBootNbBatAnneeZone,VarBootNbBatAnneeZone)
      colnames(EstimBootNbBatAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbBatAnneeGroupe <- apply(FreqEstimeeBatAnneeGroupe,2,mean,na.rm=T)
      VarBootNbBatAnneeGroupe <- apply(FreqEstimeeBatAnneeGroupe,2,var,na.rm=T)
      InfBootNbBatAnneeGroupe <- apply(FreqEstimeeBatAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatAnneeGroupe <- apply(FreqEstimeeBatAnneeGroupe,2,quantile,probs=0.975,na.rm=T)         
      EstimBootNbBatAnneeGroupe <- cbind(InfBootNbBatAnneeGroupe,MoyBootNbBatAnneeGroupe,SupBootNbBatAnneeGroupe,VarBootNbBatAnneeGroupe)
      colnames(EstimBootNbBatAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbBatAnneeZonage <- apply(FreqEstimeeBatAnneeZonage,2,mean,na.rm=T)
      VarBootNbBatAnneeZonage <- apply(FreqEstimeeBatAnneeZonage,2,var,na.rm=T)
      InfBootNbBatAnneeZonage <- apply(FreqEstimeeBatAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatAnneeZonage <- apply(FreqEstimeeBatAnneeZonage,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatAnneeZonage <- cbind(InfBootNbBatAnneeZonage,MoyBootNbBatAnneeZonage,SupBootNbBatAnneeZonage,VarBootNbBatAnneeZonage)
      colnames(EstimBootNbBatAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat par ann�e par zonage estim� par bootstrap.csv")
    
    
    # nombre de bateaux par type d'activit�
      MoyBootNbBatTypActMoisAMP <- apply(FreqEstimeeBatTypActMoisAMP,2,mean,na.rm=T)
      VarBootNbBatTypActMoisAMP <- apply(FreqEstimeeBatTypActMoisAMP,2,var,na.rm=T)
      InfBootNbBatTypActMoisAMP <- apply(FreqEstimeeBatTypActMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActMoisAMP <- apply(FreqEstimeeBatTypActMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActMoisAMP <- cbind(InfBootNbBatTypActMoisAMP,MoyBootNbBatTypActMoisAMP,SupBootNbBatTypActMoisAMP,VarBootNbBatTypActMoisAMP)
      colnames(EstimBootNbBatTypActMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbBatTypActTrimestreAMP <- apply(FreqEstimeeBatTypActTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbBatTypActTrimestreAMP <- apply(FreqEstimeeBatTypActTrimestreAMP ,2,var,na.rm=T)
      InfBootNbBatTypActTrimestreAMP <- apply(FreqEstimeeBatTypActTrimestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActTrimestreAMP <- apply(FreqEstimeeBatTypActTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActTrimestreAMP <- cbind(InfBootNbBatTypActTrimestreAMP,MoyBootNbBatTypActTrimestreAMP,SupBootNbBatTypActTrimestreAMP,VarBootNbBatTypActTrimestreAMP)
      colnames(EstimBootNbBatTypActTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatTypActSemestreAMP <- apply(FreqEstimeeBatTypActSemestreAMP ,2,mean,na.rm=T)
      VarBootNbBatTypActSemestreAMP <- apply(FreqEstimeeBatTypActSemestreAMP ,2,var,na.rm=T)
      InfBootNbBatTypActSemestreAMP <- apply(FreqEstimeeBatTypActSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActSemestreAMP <- apply(FreqEstimeeBatTypActSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActSemestreAMP <- cbind(InfBootNbBatTypActSemestreAMP,MoyBootNbBatTypActSemestreAMP,SupBootNbBatTypActSemestreAMP,VarBootNbBatTypActSemestreAMP)
      colnames(EstimBootNbBatTypActSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatTypActAnneeAMP <- apply(FreqEstimeeBatTypActAnneeAMP,2,mean,na.rm=T)
      VarBootNbBatTypActAnneeAMP <- apply(FreqEstimeeBatTypActAnneeAMP,2,var,na.rm=T)
      InfBootNbBatTypActAnneeAMP <- apply(FreqEstimeeBatTypActAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActAnneeAMP <- apply(FreqEstimeeBatTypActAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActAnneeAMP <- cbind(InfBootNbBatTypActAnneeAMP,MoyBootNbBatTypActAnneeAMP,SupBootNbBatTypActAnneeAMP,VarBootNbBatTypActAnneeAMP)
      colnames(EstimBootNbBatTypActAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbBatTypActAnneeZone <- apply(FreqEstimeeBatTypActAnneeZone,2,mean,na.rm=T)
      VarBootNbBatTypActAnneeZone <- apply(FreqEstimeeBatTypActAnneeZone,2,var,na.rm=T)
      InfBootNbBatTypActAnneeZone <- apply(FreqEstimeeBatTypActAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActAnneeZone <- apply(FreqEstimeeBatTypActAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActAnneeZone <- cbind(InfBootNbBatTypActAnneeZone,MoyBootNbBatTypActAnneeZone,SupBootNbBatTypActAnneeZone,VarBootNbBatTypActAnneeZone)
      colnames(EstimBootNbBatTypActAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbBatTypActAnneeGroupe <- apply(FreqEstimeeBatTypActAnneeGroupe,2,mean,na.rm=T)
      VarBootNbBatTypActAnneeGroupe <- apply(FreqEstimeeBatTypActAnneeGroupe,2,var,na.rm=T)
      InfBootNbBatTypActAnneeGroupe <- apply(FreqEstimeeBatTypActAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActAnneeGroupe <- apply(FreqEstimeeBatTypActAnneeGroupe,2,quantile,probs=0.975,na.rm=T)         
      EstimBootNbBatTypActAnneeGroupe <- cbind(InfBootNbBatTypActAnneeGroupe,MoyBootNbBatTypActAnneeGroupe,SupBootNbBatTypActAnneeGroupe,VarBootNbBatTypActAnneeGroupe)
      colnames(EstimBootNbBatTypActAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbBatTypActAnneeZonage <- apply(FreqEstimeeBatTypActAnneeZonage,2,mean,na.rm=T)
      VarBootNbBatTypActAnneeZonage <- apply(FreqEstimeeBatTypActAnneeZonage,2,var,na.rm=T)
      InfBootNbBatTypActAnneeZonage <- apply(FreqEstimeeBatTypActAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatTypActAnneeZonage <- apply(FreqEstimeeBatTypActAnneeZonage,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatTypActAnneeZonage <- cbind(InfBootNbBatTypActAnneeZonage,MoyBootNbBatTypActAnneeZonage,SupBootNbBatTypActAnneeZonage,VarBootNbBatTypActAnneeZonage)
      colnames(EstimBootNbBatTypActAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatTypActAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat type act par ann�e par zonage estim� par bootstrap.csv")
    
    
    # nombre de bateaux par activit�
      MoyBootNbBatActMoisAMP <- apply(FreqEstimeeBatActMoisAMP,2,mean,na.rm=T)
      VarBootNbBatActMoisAMP <- apply(FreqEstimeeBatActMoisAMP,2,var,na.rm=T)
      InfBootNbBatActMoisAMP <- apply(FreqEstimeeBatActMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActMoisAMP <- apply(FreqEstimeeBatActMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActMoisAMP <- cbind(InfBootNbBatActMoisAMP,MoyBootNbBatActMoisAMP,SupBootNbBatActMoisAMP,VarBootNbBatActMoisAMP)
      colnames(EstimBootNbBatActMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbBatActTrimestreAMP <- apply(FreqEstimeeBatActTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbBatActTrimestreAMP <- apply(FreqEstimeeBatActTrimestreAMP ,2,var,na.rm=T)
      InfBootNbBatActTrimestreAMP <- apply(FreqEstimeeBatActTrimestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActTrimestreAMP <- apply(FreqEstimeeBatActTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActTrimestreAMP <- cbind(InfBootNbBatActTrimestreAMP,MoyBootNbBatActTrimestreAMP,SupBootNbBatActTrimestreAMP,VarBootNbBatActTrimestreAMP)
      colnames(EstimBootNbBatActTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatActSemestreAMP <- apply(FreqEstimeeBatActSemestreAMP ,2,mean,na.rm=T)
      VarBootNbBatActSemestreAMP <- apply(FreqEstimeeBatActSemestreAMP ,2,var,na.rm=T)
      InfBootNbBatActSemestreAMP <- apply(FreqEstimeeBatActSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActSemestreAMP <- apply(FreqEstimeeBatActSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActSemestreAMP <- cbind(InfBootNbBatActSemestreAMP,MoyBootNbBatActSemestreAMP,SupBootNbBatActSemestreAMP,VarBootNbBatActSemestreAMP)
      colnames(EstimBootNbBatActSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbBatActAnneeAMP <- apply(FreqEstimeeBatActAnneeAMP,2,mean,na.rm=T)
      VarBootNbBatActAnneeAMP <- apply(FreqEstimeeBatActAnneeAMP,2,var,na.rm=T)
      InfBootNbBatActAnneeAMP <- apply(FreqEstimeeBatActAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActAnneeAMP <- apply(FreqEstimeeBatActAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActAnneeAMP <- cbind(InfBootNbBatActAnneeAMP,MoyBootNbBatActAnneeAMP,SupBootNbBatActAnneeAMP,VarBootNbBatActAnneeAMP)
      colnames(EstimBootNbBatActAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbBatActAnneeZone <- apply(FreqEstimeeBatActAnneeZone,2,mean,na.rm=T)
      VarBootNbBatActAnneeZone <- apply(FreqEstimeeBatActAnneeZone,2,var,na.rm=T)
      InfBootNbBatActAnneeZone <- apply(FreqEstimeeBatActAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActAnneeZone <- apply(FreqEstimeeBatActAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActAnneeZone <- cbind(InfBootNbBatActAnneeZone,MoyBootNbBatActAnneeZone,SupBootNbBatActAnneeZone,VarBootNbBatActAnneeZone)
      colnames(EstimBootNbBatActAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbBatActAnneeGroupe <- apply(FreqEstimeeBatActAnneeGroupe,2,mean,na.rm=T)
      VarBootNbBatActAnneeGroupe <- apply(FreqEstimeeBatActAnneeGroupe,2,var,na.rm=T)
      InfBootNbBatActAnneeGroupe <- apply(FreqEstimeeBatActAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActAnneeGroupe <- apply(FreqEstimeeBatActAnneeGroupe,2,quantile,probs=0.975,na.rm=T)         
      EstimBootNbBatActAnneeGroupe <- cbind(InfBootNbBatActAnneeGroupe,MoyBootNbBatActAnneeGroupe,SupBootNbBatActAnneeGroupe,VarBootNbBatActAnneeGroupe)
      colnames(EstimBootNbBatActAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbBatActAnneeZonage <- apply(FreqEstimeeBatActAnneeZonage,2,mean,na.rm=T)
      VarBootNbBatActAnneeZonage <- apply(FreqEstimeeBatActAnneeZonage,2,var,na.rm=T)
      InfBootNbBatActAnneeZonage <- apply(FreqEstimeeBatActAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbBatActAnneeZonage <- apply(FreqEstimeeBatActAnneeZonage,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbBatActAnneeZonage <- cbind(InfBootNbBatActAnneeZonage,MoyBootNbBatActAnneeZonage,SupBootNbBatActAnneeZonage,VarBootNbBatActAnneeZonage)
      colnames(EstimBootNbBatActAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbBatActAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb bat act par ann�e par zonage estim� par bootstrap.csv")
    
    
    
     # nombre de personnes toutes activit�s confondues
      MoyBootNbPersMoisAMP <- apply(FreqEstimeePersMoisAMP,2,mean,na.rm=T)
      VarBootNbPersMoisAMP <- apply(FreqEstimeePersMoisAMP,2,var,na.rm=T)
      InfBootNbPersMoisAMP <- apply(FreqEstimeePersMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersMoisAMP <- apply(FreqEstimeePersMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersMoisAMP <- cbind(InfBootNbPersMoisAMP,MoyBootNbPersMoisAMP,SupBootNbPersMoisAMP,VarBootNbPersMoisAMP)
      colnames(EstimBootNbPersMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbPersTrimestreAMP <- apply(FreqEstimeePersTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbPersTrimestreAMP <- apply(FreqEstimeePersTrimestreAMP ,2,var,na.rm=T)
      InfBootNbPersTrimestreAMP <- apply(FreqEstimeePersTrimestreAMP,2,quantile,probs=0.025,na.rm=T)  
      SupBootNbPersTrimestreAMP <- apply(FreqEstimeePersTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTrimestreAMP <- cbind(InfBootNbPersTrimestreAMP,MoyBootNbPersTrimestreAMP,SupBootNbPersTrimestreAMP,VarBootNbPersTrimestreAMP)
      colnames(EstimBootNbPersTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersSemestreAMP <- apply(FreqEstimeePersSemestreAMP ,2,mean,na.rm=T)
      VarBootNbPersSemestreAMP <- apply(FreqEstimeePersSemestreAMP ,2,var,na.rm=T)
      InfBootNbPersSemestreAMP <- apply(FreqEstimeePersSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersSemestreAMP <- apply(FreqEstimeePersSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersSemestreAMP <- cbind(InfBootNbPersSemestreAMP,MoyBootNbPersSemestreAMP,SupBootNbPersSemestreAMP,VarBootNbPersSemestreAMP)
      colnames(EstimBootNbPersSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersAnneeAMP <- apply(FreqEstimeePersAnneeAMP,2,mean,na.rm=T)
      VarBootNbPersAnneeAMP <- apply(FreqEstimeePersAnneeAMP,2,var,na.rm=T)
      InfBootNbPersAnneeAMP <- apply(FreqEstimeePersAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersAnneeAMP <- apply(FreqEstimeePersAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersAnneeAMP <- cbind(InfBootNbPersAnneeAMP,MoyBootNbPersAnneeAMP,SupBootNbPersAnneeAMP,VarBootNbPersAnneeAMP)
      colnames(EstimBootNbPersAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbPersAnneeZone <- apply(FreqEstimeePersAnneeZone,2,mean,na.rm=T)
      VarBootNbPersAnneeZone <- apply(FreqEstimeePersAnneeZone,2,var,na.rm=T)
      InfBootNbPersAnneeZone <- apply(FreqEstimeePersAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersAnneeZone <- apply(FreqEstimeePersAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersAnneeZone <- cbind(InfBootNbPersAnneeZone,MoyBootNbPersAnneeZone,SupBootNbPersAnneeZone,VarBootNbPersAnneeZone)
      colnames(EstimBootNbPersAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbPersAnneeGroupe <- apply(FreqEstimeePersAnneeGroupe,2,mean,na.rm=T)
      VarBootNbPersAnneeGroupe <- apply(FreqEstimeePersAnneeGroupe,2,var,na.rm=T)
      InfBootNbPersAnneeGroupe <- apply(FreqEstimeePersAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersAnneeGroupe <- apply(FreqEstimeePersAnneeGroupe,2,quantile,probs=0.975,na.rm=T)         
      EstimBootNbPersAnneeGroupe <- cbind(InfBootNbPersAnneeGroupe,MoyBootNbPersAnneeGroupe,SupBootNbPersAnneeGroupe,VarBootNbPersAnneeGroupe)
      colnames(EstimBootNbPersAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbPersAnneeZonage <- apply(FreqEstimeePersAnneeZonage,2,mean,na.rm=T)
      VarBootNbPersAnneeZonage <- apply(FreqEstimeePersAnneeZonage,2,var,na.rm=T)
      InfBootNbPersAnneeZonage <- apply(FreqEstimeePersAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersAnneeZonage <- apply(FreqEstimeePersAnneeZonage,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersAnneeZonage <- cbind(InfBootNbPersAnneeZonage,MoyBootNbPersAnneeZonage,SupBootNbPersAnneeZonage,VarBootNbPersAnneeZonage)
      colnames(EstimBootNbPersAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers par ann�e par zonage estim� par bootstrap.csv")
    
    
    # nombre de personnes par type d'activit�
      MoyBootNbPersTypActMoisAMP <- apply(FreqEstimeePersTypActMoisAMP,2,mean,na.rm=T)
      VarBootNbPersTypActMoisAMP <- apply(FreqEstimeePersTypActMoisAMP,2,var,na.rm=T)
      InfBootNbPersTypActMoisAMP <- apply(FreqEstimeePersTypActMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActMoisAMP <- apply(FreqEstimeePersTypActMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActMoisAMP <- cbind(InfBootNbPersTypActMoisAMP,MoyBootNbPersTypActMoisAMP,SupBootNbPersTypActMoisAMP,VarBootNbPersTypActMoisAMP)
      colnames(EstimBootNbPersTypActMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbPersTypActTrimestreAMP <- apply(FreqEstimeePersTypActTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbPersTypActTrimestreAMP <- apply(FreqEstimeePersTypActTrimestreAMP ,2,var,na.rm=T)
      InfBootNbPersTypActTrimestreAMP <- apply(FreqEstimeePersTypActTrimestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActTrimestreAMP <- apply(FreqEstimeePersTypActTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActTrimestreAMP <- cbind(InfBootNbPersTypActTrimestreAMP,MoyBootNbPersTypActTrimestreAMP,SupBootNbPersTypActTrimestreAMP,VarBootNbPersTypActTrimestreAMP)
      colnames(EstimBootNbPersTypActTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersTypActSemestreAMP <- apply(FreqEstimeePersTypActSemestreAMP ,2,mean,na.rm=T)
      VarBootNbPersTypActSemestreAMP <- apply(FreqEstimeePersTypActSemestreAMP ,2,var,na.rm=T)
      InfBootNbPersTypActSemestreAMP <- apply(FreqEstimeePersTypActSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActSemestreAMP <- apply(FreqEstimeePersTypActSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActSemestreAMP <- cbind(InfBootNbPersTypActSemestreAMP,MoyBootNbPersTypActSemestreAMP,SupBootNbPersTypActSemestreAMP,VarBootNbPersTypActSemestreAMP)
      colnames(EstimBootNbPersTypActSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersTypActAnneeAMP <- apply(FreqEstimeePersTypActAnneeAMP,2,mean,na.rm=T)
      VarBootNbPersTypActAnneeAMP <- apply(FreqEstimeePersTypActAnneeAMP,2,var,na.rm=T)
      InfBootNbPersTypActAnneeAMP <- apply(FreqEstimeePersTypActAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActAnneeAMP <- apply(FreqEstimeePersTypActAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActAnneeAMP <- cbind(InfBootNbPersTypActAnneeAMP,MoyBootNbPersTypActAnneeAMP,SupBootNbPersTypActAnneeAMP,VarBootNbPersTypActAnneeAMP)
      colnames(EstimBootNbPersTypActAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbPersTypActAnneeZone <- apply(FreqEstimeePersTypActAnneeZone,2,mean,na.rm=T)
      VarBootNbPersTypActAnneeZone <- apply(FreqEstimeePersTypActAnneeZone,2,var,na.rm=T)
      InfBootNbPersTypActAnneeZone <- apply(FreqEstimeePersTypActAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActAnneeZone <- apply(FreqEstimeePersTypActAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActAnneeZone <- cbind(InfBootNbPersTypActAnneeZone,MoyBootNbPersTypActAnneeZone,SupBootNbPersTypActAnneeZone,VarBootNbPersTypActAnneeZone)
      colnames(EstimBootNbPersTypActAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbPersTypActAnneeGroupe <- apply(FreqEstimeePersTypActAnneeGroupe,2,mean,na.rm=T)
      VarBootNbPersTypActAnneeGroupe <- apply(FreqEstimeePersTypActAnneeGroupe,2,var,na.rm=T)
      InfBootNbPersTypActAnneeGroupe <- apply(FreqEstimeePersTypActAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActAnneeGroupe <- apply(FreqEstimeePersTypActAnneeGroupe,2,quantile,probs=0.975,na.rm=T)        
      EstimBootNbPersTypActAnneeGroupe <- cbind(InfBootNbPersTypActAnneeGroupe,MoyBootNbPersTypActAnneeGroupe,SupBootNbPersTypActAnneeGroupe,VarBootNbPersTypActAnneeGroupe)
      colnames(EstimBootNbPersTypActAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbPersTypActAnneeZonage <- apply(FreqEstimeePersTypActAnneeZonage,2,mean,na.rm=T)
      VarBootNbPersTypActAnneeZonage <- apply(FreqEstimeePersTypActAnneeZonage,2,var,na.rm=T)
      InfBootNbPersTypActAnneeZonage <- apply(FreqEstimeePersTypActAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersTypActAnneeZonage <- apply(FreqEstimeePersTypActAnneeZonage,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersTypActAnneeZonage <- cbind(InfBootNbPersTypActAnneeZonage,MoyBootNbPersTypActAnneeZonage,SupBootNbPersTypActAnneeZonage,VarBootNbPersTypActAnneeZonage)
      colnames(EstimBootNbPersTypActAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersTypActAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers type act par ann�e par zonage estim� par bootstrap.csv")
    
    
    # nombre de personnes par activit�
      MoyBootNbPersActMoisAMP <- apply(FreqEstimeePersActMoisAMP,2,mean,na.rm=T)
      VarBootNbPersActMoisAMP <- apply(FreqEstimeePersActMoisAMP,2,var,na.rm=T)
      InfBootNbPersActMoisAMP <- apply(FreqEstimeePersActMoisAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActMoisAMP <- apply(FreqEstimeePersActMoisAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersActMoisAMP <- cbind(InfBootNbPersActMoisAMP,MoyBootNbPersActMoisAMP,SupBootNbPersActMoisAMP,VarBootNbPersActMoisAMP)
      colnames(EstimBootNbPersActMoisAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActMoisAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par mois pour l'AMP estim� par bootstrap.csv")
        
      MoyBootNbPersActTrimestreAMP <- apply(FreqEstimeePersActTrimestreAMP ,2,mean,na.rm=T)
      VarBootNbPersActTrimestreAMP <- apply(FreqEstimeePersActTrimestreAMP ,2,var,na.rm=T)
      InfBootNbPersActTrimestreAMP <- apply(FreqEstimeePersActTrimestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActTrimestreAMP <- apply(FreqEstimeePersActTrimestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersActTrimestreAMP <- cbind(InfBootNbPersActTrimestreAMP,MoyBootNbPersActTrimestreAMP,SupBootNbPersActTrimestreAMP,VarBootNbPersActTrimestreAMP)
      colnames(EstimBootNbPersActTrimestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActTrimestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par trimestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersActSemestreAMP <- apply(FreqEstimeePersActSemestreAMP ,2,mean,na.rm=T)
      VarBootNbPersActSemestreAMP <- apply(FreqEstimeePersActSemestreAMP ,2,var,na.rm=T)
      InfBootNbPersActSemestreAMP <- apply(FreqEstimeePersActSemestreAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActSemestreAMP <- apply(FreqEstimeePersActSemestreAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersActSemestreAMP <- cbind(InfBootNbPersActSemestreAMP,MoyBootNbPersActSemestreAMP,SupBootNbPersActSemestreAMP,VarBootNbPersActSemestreAMP)
      colnames(EstimBootNbPersActSemestreAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActSemestreAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par semestre pour l'AMP estim� par bootstrap.csv")
    
      MoyBootNbPersActAnneeAMP <- apply(FreqEstimeePersActAnneeAMP,2,mean,na.rm=T)
      VarBootNbPersActAnneeAMP <- apply(FreqEstimeePersActAnneeAMP,2,var,na.rm=T)  
      InfBootNbPersActAnneeAMP <- apply(FreqEstimeePersActAnneeAMP,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActAnneeAMP <- apply(FreqEstimeePersActAnneeAMP,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersActAnneeAMP <- cbind(InfBootNbPersActAnneeAMP,MoyBootNbPersActAnneeAMP,SupBootNbPersActAnneeAMP,VarBootNbPersActAnneeAMP)
      colnames(EstimBootNbPersActAnneeAMP) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActAnneeAMP,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par ann�e pour l'AMP estim� par bootstrap.csv")
    
      
      MoyBootNbPersActAnneeZone <- apply(FreqEstimeePersActAnneeZone,2,mean,na.rm=T)
      VarBootNbPersActAnneeZone <- apply(FreqEstimeePersActAnneeZone,2,var,na.rm=T)
      InfBootNbPersActAnneeZone <- apply(FreqEstimeePersActAnneeZone,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActAnneeZone <- apply(FreqEstimeePersActAnneeZone,2,quantile,probs=0.975,na.rm=T)
      EstimBootNbPersActAnneeZone <- cbind(InfBootNbPersActAnneeZone,MoyBootNbPersActAnneeZone,SupBootNbPersActAnneeZone,VarBootNbPersActAnneeZone)
      colnames(EstimBootNbPersActAnneeZone) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActAnneeZone,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par ann�e par zone estim� par bootstrap.csv")
        
      MoyBootNbPersActAnneeGroupe <- apply(FreqEstimeePersActAnneeGroupe,2,mean,na.rm=T)
      VarBootNbPersActAnneeGroupe <- apply(FreqEstimeePersActAnneeGroupe,2,var,na.rm=T)
      InfBootNbPersActAnneeGroupe <- apply(FreqEstimeePersActAnneeGroupe,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActAnneeGroupe <- apply(FreqEstimeePersActAnneeGroupe,2,quantile,probs=0.975,na.rm=T)         
      EstimBootNbPersActAnneeGroupe <- cbind(InfBootNbPersActAnneeGroupe,MoyBootNbPersActAnneeGroupe,SupBootNbPersActAnneeGroupe,VarBootNbPersActAnneeGroupe)
      colnames(EstimBootNbPersActAnneeGroupe) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActAnneeGroupe,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par ann�e par groupe estim� par bootstrap.csv")
        
      MoyBootNbPersActAnneeZonage <- apply(FreqEstimeePersActAnneeZonage,2,mean,na.rm=T)
      VarBootNbPersActAnneeZonage <- apply(FreqEstimeePersActAnneeZonage,2,var,na.rm=T)
      InfBootNbPersActAnneeZonage <- apply(FreqEstimeePersActAnneeZonage,2,quantile,probs=0.025,na.rm=T)
      SupBootNbPersActAnneeZonage <- apply(FreqEstimeePersActAnneeZonage,2,quantile,probs=0.975,na.rm=T) 
      EstimBootNbPersActAnneeZonage <- cbind(InfBootNbPersActAnneeZonage,MoyBootNbPersActAnneeZonage,SupBootNbPersActAnneeZonage,VarBootNbPersActAnneeZonage)
      colnames(EstimBootNbPersActAnneeZonage) <- c("ICInf", "FreqEstimee", "ICSup","VarianceEstimee")
    #write.csv(EstimBootNbPersActAnneeZonage,file="C:/PAMPA/resultats script R/metriquesWP3/bootstrap/extrapolation/nb Pers act par ann�e par zonage estim� par bootstrap.csv")
    
    
    Sys.time()  ### affiche la date et l'heure
}