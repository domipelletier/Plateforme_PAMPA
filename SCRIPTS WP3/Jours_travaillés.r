#-*- coding: latin-1 -*-

### File: dates.R
### Time-stamp: <2011-07-13 11:52:36 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Calcul des nombres de jours travaill�s et ch�m�s par mois en fonction de l'ann�e/ann�e
### de campagne.
####################################################################################################

library(timeDate)

########################################################################################################################
## Holidays :
FRHolidays <- function(year=getRmetricsOptions("currentYear"))
{
    ## Purpose: Retourne un objet avec les dates des jours f�ri�s pour la
    ##          France (et l'OM).
    ## ----------------------------------------------------------------------
    ## Arguments: year : l'ann�e
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 juil. 2011, 16:57

    res <- as.timeDate(                 # n�cessaire pour l'utilisation avec isBizday().
                       c(
                         ## Jours f�ri�s communs en France :
                         as.Date(sapply(c(listHolidays("FR"), # Liste des jours f�ri�s FR.
                                          "NewYearsDay",     #
                                          "EasterMonday",    # Jours non list�s
                                          "Ascension",       # par la fonction
                                          "PentecostMonday", # ci-dessus.
                                          "ChristmasDay"),   #
                                        function(x, year) as.Date(do.call(x, list(year=year))),
                                        year=year),
                                 origin="1970-01-01"),
                         ## Jours sp�cifiques � l'Outre-mer (� compl�ter) :
                         if(siteEtudie == "NC"){as.Date(paste(year, "-09-24", sep=""))}else{NULL},
                         if(siteEtudie == "NC" && year == 2008){as.Date(paste(year, "-06-26", sep=""))}else{NULL},
                         if(siteEtudie == "RUN"){as.Date(paste(year, "-12-20", sep=""))}else{NULL}))
}


########################################################################################################################
nbBizDays <- function(years=getRmetricsOptions("currentYear"),
                      inverse=FALSE)
{
    ## Purpose: Compte du nombre de jours travaill�s/ch�m�s
    ##          par mois par ann�e
    ## ----------------------------------------------------------------------
    ## Arguments: years : les ann�es.
    ##            inverse : (logical) inversion ? (TRUE => jours ch�m�s).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 juil. 2011, 17:03

    mat <- sapply(X=years,              # ...pour chaque ann�e...
                  FUN=function(year)
              {
                  sapply(1:12,          # ...pour chaque mois...
                         function(month, year)
                     {
                         ## Liste de jours du mois :
                         x <- na.omit(as.Date(paste(year, "-", month, "-", 1:31, sep="")))

                         ## Jours travaill�s ? (Biz pour "business" ; logical) :
                         res <- isBizday(as.timeDate(x), holiday=FRHolidays(year=year))

                         ## R�sultats chiffr�s :
                         if(inverse)
                         {
                             return(sum(!res)) # NON travaill�s.
                         }else{
                             return(sum(res)) # Travaill�s.
                         }
                     },
                         year=year)     # second argument de la fonction dans second sapply.
              }
                  )

    ## On nomme les colonnes et les lignes pour plus de lisibilit� :
    colnames(mat) <- as.character(years)
    row.names(mat) <- as.character(1:12)

    return(mat)
}

########################################################################################################################
## Exemples sur des donn�es WP2 (adapter les noms d'objets, de colonnes, etc.) :

## Nombre de jours travaill�s :
nbTrav <- nbBizDays(years=unique(as.numeric(as.character(freqtot$annee))),
                    inverse=FALSE)

## Nombre de jours ch�m�s :
nbChom <- nbBizDays(years=unique(as.numeric(as.character(freqtot$annee))),
                    inverse=TRUE)

## V�rif. :
nbTot <- nbTrav + nbChom

## Jours travaill�s et ch�m�s pour le mois de chaque unit� d'observation :
travailles <- sapply(1:nrow(freqtot),
                     function(i)
                 {
                     nbTrav[freqtot[i, "mois"], as.character(freqtot[i, "annee"])]
                 })

chomes <- sapply(1:nrow(freqtot),
                 function(i)
                 {
                     nbChom[freqtot[i, "mois"], as.character(freqtot[i, "annee"])]
                 })

## On peut d�s lors recalculer les nombres de jours travaill�s et ch�m�s par mois, en fonction
## de l'ann�e de campagne/p�riode �chantillonn�es (si un m�me mois sur deux ann�es => moyenne) :

## Travaill�s :
tapply(travailles, list(freqtot$mois, freqtot$periodEchant), mean, na.rm=TRUE)

## Ch�m�s :
tapply(chomes, list(freqtot$mois, freqtot$periodEchant), mean, na.rm=TRUE)

## Total :
tapply(chomes + travailles, list(freqtot$mois, freqtot$periodEchant), mean, na.rm=TRUE)

## D'�ventuels NAs correspondent � des mois non �chantillonn�s !

### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
