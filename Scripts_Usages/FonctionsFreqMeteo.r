################################################################################
# Nom               : FonctionsFreqMeteo.r
# Type              : Programme
# Objet             : Fonctions pour le calcul et le lancement des graphiques 
#                     des m�triques de fr�quentation selon les facteurs m�t�o
#                     choisis dans l'interface par l'utilisateur.
# Input             : data import�es en txt
# Output            : tableaux et graphs
# Auteur            : Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : janvier 2012
# Sources
################################################################################


####################################################################################################
listeFactMeteo.f <- function()
{
    ## Purpose: Retourne la liste des diff�rents facteurs m�t�o disponibles 
    ##          pour le site Etudie.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, janvier 2012

    ## Niveaux spatiaux disponibles dans le r�f�rentiel spatial
    listeMeteo <- c("meteo" , "nebulosite" , "directionVent" , 
                    "forceVent" , "etatMer" , "lune")


    ## Identification des champs non vides dans les relev�s de fr�quentation
    champsVide <- ! sapply(freqtot,
                          function(x){all(is.na(x))})

    listFactMeteo <- c(listeMeteo[is.element(listeMeteo,names(champsVide)[champsVide])])

    return(listFactMeteo)          # ne prend que les facteurs de s�paration renseign�s

}


########################################################################################################################
listeVariablesM.f <- function()
{
    ## Purpose: retourne un vecteur de caract�res donnant les variables
    ##          disponibles
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## Niveaux spatiaux disponibles dans le r�f�rentiel spatial
    listeVariableM <- c("nbBat" , "nbPers" , "nbLigne")


    ## Identification des champs non vides dans les relev�s de fr�quentation
    champsVide <- ! sapply(freqtot,
                          function(x){all(is.na(x))})

    listVariable <- c(listeVariableM[is.element(listeVariableM,names(champsVide)[champsVide])])

    return(listVariable)
}


########################################################################################################################
BoxplotMeteo.f <- function (facteurMet, variable) 
{
    ## Purpose: fonction de calcul et de lancement du graphique de la fr�quentation 
    ##          selon le facteur m�t�o choisi
    ## ----------------------------------------------------------------------
    ## Arguments: facteurMet : facteur m�t�o choisi
    ##            variable : variable choisie
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    # calcul du nombre de sorties r�alis�es pour chaque niveau du facteur m�t�o
    nbSortieMeteo <- apply(tapply(freqtot$immat,
                                  list(freqtot$numSortie,freqtot[, facteurMet]),
                                  lengthnb.f),
                           2, sum, na.rm=TRUE)
    
    # niveaux du facteur disponibles
    listeMeteo <- unique(freqtot[, facteurMet])
    freqMeteo <- tapply(freqtot[, variable],
                        list(freqtot$numSortie, factor(freqtot[, facteurMet])), 
                        sum, na.rm=T)      
    
    # tableau r�capitulatif des statistiques descriptives                           
    tabFreqMeteo <- StatDescriptivesMeteo.f(freqMeteo, nbSortieMeteo, listeMeteo)    
    write.csv(tabFreqMeteo ,file = paste("C:/PAMPA/Resultats_Usages/meteo/nombre de ", variable, " selon ", facteurMet, ".csv",sep=""),row.names = T)

    # graphique 
    x11(width=50,height=30,pointsize=10)
    par(mar=c(7, 6, 6, 2), mgp=c(4.5, 0.5, 0), font.main=4, font.lab=4, cex.lab=2, cex.main= 2, cex.axis=1.5)

    boxplot(as.data.frame(freqMeteo), xlab = facteurMet, ylab = paste("nombre de", variable),
            main = paste("Nombre de ", variable," par sortie et selon ",facteurMet, sep=""))
    text(1 : ncol(tabFreqMeteo), max(tabFreqMeteo["maximum",]), 
         labels = round(tabFreqMeteo["moyenne",], digits=1), col="red", cex=1.5)
    savePlot(filename = paste("C:/PAMPA/Resultats_Usages/meteo/boxplot nombre de ", variable," selon ", facteurMet, sep=""), type = c("bmp"))

}


########################################################################################################################
StatDescriptivesMeteo.f <- function (freqMeteo, nbSortieMeteo, listeMeteo)
{
    ## Purpose: fonction de calcul des statistiques descriptives pour les facteurs m�t�o 
    ## ----------------------------------------------------------------------
    ## Arguments: freqMeteo : le tableau de fr�quentation par sortie et niveau du facteur
    ##            nbSortieMeteo : nombre de sorties r�alis�es par niveau du facteur
    ##            listeMeteo : niveaux disponibles pour le facteur m�t�o choisi
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    tableau <- matrix(NA, 8, ncol(freqMeteo))
    colnames (tableau) <- colnames(freqMeteo)
    rownames(tableau) <- c("minimum", "maximum", "moyenne", "mediane", "variance", "nb sorties", "IC-", "IC+")
    tableau["minimum", ] <- apply(freqMeteo, 2, min, na.rm=T)
    tableau["maximum", ] <- apply(freqMeteo, 2, max, na.rm=T)
    tableau["moyenne", ] <- apply(freqMeteo, 2, mean, na.rm=T) 
    tableau["mediane", ] <- apply(freqMeteo, 2, median, na.rm=T)    
    tableau["variance", ] <- apply(freqMeteo, 2, var, na.rm=T)    
    tableau["nb sorties", ] <- nbSortieMeteo [match(colnames(tableau), names(nbSortieMeteo))]       
    tableau["IC-", ] <- tableau["moyenne", ] + qt(0.025, (tableau["nb sorties", ]-1)) * sqrt(tableau["variance", ]/(tableau["nb sorties", ]-1))
    tableau["IC-", ][which(tableau["IC-", ] < 0)] <- 0                           # �vite les IC n�gatif
    tableau["IC+", ] <- tableau["moyenne", ] + qt(0.975, (tableau["nb sorties", ]-1)) * sqrt(tableau["variance", ]/(tableau["nb sorties", ]-1))

    return (tableau)
}


########################################################################################################################
interfaceMeteo.f <- function()
{
    ## Purpose: cr�er l'interface pour les graphs de fr�quentation selon la m�t�o
    ##          et lancer les fonctions graphiques
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date: janvier 2012

    ## Variables :
    env <- environment()                    # Environnement courant
    Done <- tclVar(0)                       # Statut d'ex�cution

    ## Liste des facteurs m�t�o
    listFactMeteo <- listeFactMeteo.f()
    FactMeteo <- tclVar(listFactMeteo[1])             

    ## Liste des variables disponibles
    listVariable <- listeVariablesM.f()
    Variable <- tclVar(listVariable[1])

    ## ########################
    ## �l�ments graphiques fen�tre principale
    WinMeteo <- tktoplevel()          # Fen�tre principale
    tkwm.title(WinMeteo, "S�lections pour l'�tude de la fr�quentation selon la m�t�o")

    F.main1 <- tkframe(WinMeteo, width=30)       # facteur m�t�o
    F.main2 <- tkframe(WinMeteo, width=30)       # variable

    ## �l�ments graphiques des choix
    CB.meteo <- ttkcombobox(F.main1, value=listFactMeteo, textvariable=FactMeteo,
                            state="readonly")
    
    CB.variable <- ttkcombobox(F.main2, value=listVariable, textvariable=Variable,
                               state="readonly")
    

    ## barre de boutons
    FrameBT <- tkframe(WinMeteo)
    B.OK <- tkbutton(FrameBT, text="  Lancer  ", command=function(){tclvalue(Done) <- 1})
    B.Cancel <- tkbutton(FrameBT, text=" Quitter ", command=function(){tclvalue(Done) <- 2})

    ## D�finition des actions
    tkbind(WinMeteo, "<Destroy>", function(){tclvalue(Done) <- 2})

    ## Placement des �l�ments sur l'interface
    tkgrid(tklabel(F.main1, text="Choix du facteur m�t�o"),
           CB.meteo, sticky="w", padx=5, pady=5)
           
    tkgrid(tklabel(F.main2, text="Choix de la variable"),
           CB.variable, sticky="w", padx=5, pady=5)
           
    tkgrid(F.main1, padx=10, pady=10)
    tkgrid(F.main2, padx=10, pady=10)

       ## Barre de boutons :
    tkgrid(FrameBT, column=0, columnspan=1, padx=2, pady=5)
    tkgrid(B.OK, tklabel(FrameBT, text="      "), B.Cancel,
            tklabel(FrameBT, text="\n"))
            
    winSmartPlace.f(WinMeteo)
    ## Update des fen�tres :
    tcl("update")


        ## Tant que l'utilisateur ne ferme pas la fen�tre
    repeat
    {
        tkwait.variable(Done)           # attente d'une modification de statut.

        if (tclvalue(Done) == "1")      # statut ex�cution OK.
        {
            facteurMeteoCh <- tclvalue(FactMeteo)
            variableCh <- tclvalue(Variable)
            
            ## V�rifications des variables (si bonnes, le statut reste 1) :
            tclvalue(Done) <- verifVariablesEnquete.f(facteurMeteoCh,
                                                      variableCh,
                                                      ParentWin = WinMeteo)

            if (tclvalue(Done) != "1") {next()} # traitement en fonction du statut : it�ration
                                                # suivante si les variables ne sont pas bonnes.

            ## ##################################################
            ## Fonctions pour la cr�ation du graphique

             BoxplotMeteo.f (facteurMet = facteurMeteoCh, 
                             variable = variableCh) 
             

            ## ##################################################

            ## Fen�tre de s�lection ramen�e au premier plan une fois l'�tape finie
            winSmartPlace.f(WinMeteo)
        } else {}

        if (tclvalue(Done) == "2") {break()} # statut d'ex�cution 'abandon' : on sort de la boucle.
    }


    tkdestroy(WinMeteo)             # destruction de la fen�tre.

}


########################################################################################################################

