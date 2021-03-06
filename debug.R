#-*- coding: latin-1 -*-

### File: debug.R
### Time-stamp: <2015-11-30 01:02:22 yreecht>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
###
####################################################################################################


init.debug.f <- function(loadMain=FALSE)
{
    ## Purpose:
    ## ----------------------------------------------------------------------
    ## Arguments:
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 d�c. 2011, 13:53


    if (.Platform$OS.type == "windows")
    {
        setwd("C:/PAMPA/")
        devDir <- "y:/Ifremer/PAMPA/Scripts/packPAMPA-WP2/Exec/"
    }else{
        devDir <- "/media/ifremer/PAMPA/PAMPA/Scripts/packPAMPA-WP2/Exec/"
    }

    if (loadMain) source("./Scripts_Biodiv/Main.R", encoding="latin1")

    ## source(paste(devDir, "Scripts_Biodiv/Agregations_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Arbres_regression_esp_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Arbres_regression_unitobs_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Barplots_occurrence.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Barplots_occurrence_unitobs.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Boxplots_esp_generiques.R", sep=""), encoding="latin1")
    source(paste(devDir, "Scripts_Biodiv/Boxplots_unitobs_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Calcul_poids.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Calcul_tables_metriques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Calcul_tables_metriques_LIT.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Calcul_tables_metriques_SVR.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Chargement_fichiers.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Chargement_manuel_fichiers.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Fonctions_base.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Fonctions_graphiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Gestionmessages.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Graphiques_carto.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Initialisation.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Interface_fonctions.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Interface_principale.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Load_packages.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Modeles_lineaires_esp_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Modeles_lineaires_unitobs_generiques.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Nombres_SVR.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Selection_donnees.R", sep=""), encoding="latin1")
    source(paste(devDir, "Scripts_Biodiv/Selection_variables_fonctions.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Selection_variables_interface.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Variables_carto.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/View.R", sep=""), encoding="latin1")
    ## source(paste(devDir, "Scripts_Biodiv/Agregations_generiques.R", sep=""), encoding="latin1")
}


debug.in.env.f <- function()
{
    ## Purpose: D�marrer une nouvelle fonction (avec son environnement
    ##          propre) et donner la main � l'utilisateur pour �valuer des
    ##          expressions dans cet environnement. Permet de tester la
    ##          port�e de variables non-globales.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 d�c. 2011, 13:51

    browser()
}


traceBrowse.f <- function(what, skip=0L,...)
{
    ## Purpose: initie le tracking d'une fonction avec un browser au d�but.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de trace().
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 12 d�c. 2011, 11:56


    tmp <- as.list(sys.call(0))

    if (is.function(what))
    {
        if (any(grepl("what", names(tmp))))
        {
            whattmp <- tmp$what
        }else{
            whattmp <- tmp[[2]]
        }
    }else{
        whattmp <- as.character(what)
    }

    ## browser()
    eval(substitute(trace(what=whattmp,
                          tracer=quote(browser(skipCalls=skip)),
                          ...),
                    list(whattmp=whattmp, skip=skip)))
}

traceBrowse.once.f <- function(what, skip=0L,...)
{
    ## Purpose: initie le tracking d'une fonction avec un browser au d�but et
    ##          stoppe le tracking � la fin.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de trace().
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 13 d�c. 2011, 10:25

    tmp <- as.list(sys.call(0))

    if (is.function(what))
    {
        if (any(grepl("what", names(tmp))))
        {
            whattmp <- tmp$what
        }else{
            whattmp <- tmp[[2]]
        }
    }else{
        whattmp <- as.character(what)
    }

    ## browser()
    eval(substitute(trace(what=whattmp,
                          tracer=quote(browser(skipCalls=skip)),
                          exit=quote(untrace(what=whattmp)),
                          ...),
                    list(whattmp=whattmp, skip=skip)))
}




findGlobalsNotFUN <- function(fun, inverse=FALSE)
{
    ## Purpose: trouver les objets (non-fonctions) globeaux
    ##          utilis�s par une fonction.
    ## ----------------------------------------------------------------------
    ## Arguments: fun : une fonction.
    ##            inverse : inversion (logical) : renvoie uniquement les
    ##                      fonctions si TRUE.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  4 janv. 2012, 12:18

    require(codetools)

    obj <- findGlobals(fun=fun, merge=FALSE)

    if (inverse)
    {
        return(obj$functions)
    }else{
        return(obj$variables)
    }
}


## block <- function()
## checkUsage




### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 140
### End:
