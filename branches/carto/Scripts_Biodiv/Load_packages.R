#-*- coding: latin-1 -*-
# Time-stamp: <2013-02-12 11:25:34 Yves>

## Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
##   Copyright (C) 2008-2013 Ifremer - Tous droits r�serv�s.
##
##   Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
##   modifier suivant les termes de la "GNU General Public License" telle que
##   publi�e par la Free Software Foundation : soit la version 2 de cette
##   licence, soit (� votre gr�) toute version ult�rieure.
##
##   Ce programme est distribu� dans l'espoir qu'il vous sera utile, mais SANS
##   AUCUNE GARANTIE : sans m�me la garantie implicite de COMMERCIALISABILIT�
##   ni d'AD�QUATION � UN OBJECTIF PARTICULIER. Consultez la Licence G�n�rale
##   Publique GNU pour plus de d�tails.
##
##   Vous devriez avoir re�u une copie de la Licence G�n�rale Publique GNU avec
##   ce programme ; si ce n'est pas le cas, consultez :
##   <http://www.gnu.org/licenses/>.

### File: test_load_packages.R
### Created: <2010-09-03 12:58:00 yves>
###
### Author: Yves Reecht
###
####################################################################################################
### Description:
###
### Scripts pour le chargement des packages et leur installation si besoin.
####################################################################################################


installPack.f <- function(pack)
{
    ## Purpose: Installation des packages manquants
    ## ----------------------------------------------------------------------
    ## Arguments: pack : liste des packages manquants (cha�ne de caract�res).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  3 sept. 2010, 13:43

    ## Packages disponibles en ligne :
    ## (si aucun d�p�t n'est d�fini, le choix est donn� � l'utilisateur).
    packDispo <- available.packages()[ , "Package"]

    ## Avertissement si des packages manquants ne sont pas disponibles :
    if (any(!is.element(pack, packDispo)))
    {
        tkmessageBox(message=paste("Le(s) package(s) : \n\n    * '",
                                   paste(pack[!is.element(pack, packDispo)], collapse="'\n    * '"),
                                   "'\n\nn'est (ne sont) pas disponible(s) !", sep=""),
                     icon="warning")

        res <- "error"
    }else{
        res <- "ok"
    }

    ## Installation des packages disponibles :
    if (any(is.element(pack, packDispo)))
    {
        install.packages(pack[is.element(pack, packDispo)], dependencies="Depends")
    }else{}

    return(res)
}

loadPackages.f <- function()
{
    ## Purpose: Charger les packages n�cessaires et proposer l'installation
    ##          de ceux qui sont manquants.
    ## ----------------------------------------------------------------------
    ## Arguments: aucun
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  3 sept. 2010, 12:58


    require(tcltk)

    ## Pour r�gler un bug sur certaines versions de R (e.g. 2.11.1)
    ## (chemin des packages avec une installation dans les dossiers utilisateurs)
    ## ...soue Windows uniquement :
    if (.Platform$OS.type == "windows")
    {
        env <- environment(.libPaths)
        assign(".lib.loc", shortPathName(get(".lib.loc", envir=env)), envir=env)
        ##  -> tous les chemins en format court !
    }else{}                             # rien sinon.

    ## Packages n�cessaires au bon fonctionnement de la plateforme PAMPA WP2 :
    requiredPack <- c("R.utils", "tcltk", "tkrplot", "vegan", "MASS",
                      "mvpart", "multcomp", "gamlss", "maps", "maptools", ## "Hmisc"
                      "TeachingDemos", "rgeos", "sp", "rgdal", "geosphere")

    ## Packages install�s :
    installedPack <- installed.packages()[ , "Package"]

    if (any(!is.element(requiredPack, installedPack)))
    {
        on.exit(tkdestroy(WinInstall))

        Done <- tclVar("0")             # Statut d'action utilisateur.

        ## Packages manquants :
        packManquants <- requiredPack[!is.element(requiredPack, installedPack)]

        ## �l�ments d'interface :
        WinInstall <- tktoplevel()
        tkwm.title(WinInstall, "Packages manquants")

        B.Install <- tkbutton(WinInstall, text="   Installer   ", command=function(){tclvalue(Done) <- "1"})
        B.Cancel <- tkbutton(WinInstall, text="   Annuler   ", command=function(){tclvalue(Done) <- "2"})

        tkgrid(tklabel(WinInstall, text=" "))
        tkgrid(tklabel(WinInstall,
                       text=paste("Le(s) package(s) suivant(s) est (sont) manquant(s) :\n\    * '",
                                  paste(packManquants, collapse="'\n    * '"),
                                  "'\n\n Vous pouvez lancer leur installation \n",
                                  "(connection internet active et droits d'administration requis).", sep=""),
                       justify="left"),
               column=1, columnspan=3, sticky="w")

        tkgrid(tklabel(WinInstall, text=" "))

        tkgrid(B.Install, column=1, row=3, sticky="e")
        tkgrid(tklabel(WinInstall, text="       "), column=2, row=3)
        tkgrid(B.Cancel, column=3, row=3, sticky="w")

        tkgrid(tklabel(WinInstall, text=" "), column=4)

        tkbind(WinInstall, "<Destroy>", function(){tclvalue(Done) <- "2"})

        ## Attente d'une action de l'utilisateur :
        tkwait.variable(Done)

        if (tclvalue(Done) == "1")
        {
            tkdestroy(WinInstall)

            ## Installation des packages manquants :
            res <- installPack.f(pack=packManquants)
        }else{
            res <- "abord"
        }

    }else{
        ## Rien � faire, tous les packages requis sont install�s.
        res <- "ok"
    }


    ## Traitement en fonction du statut de sortie :
    switch(res,
           ok = invisible(sapply(requiredPack, library, character.only=TRUE)),
           stop(paste("Vous devez installer manuellement le(s) package(s) :\n\n    * '",
                      paste(requiredPack[!is.element(requiredPack, installed.packages()[ , "Package"])],
                            collapse="\n    * '"),
                      "'", sep="")))
}

## On lance le chargement :
loadPackages.f()



### Local Variables:
### ispell-local-dictionary: "english"
### fill-column: 120
### End:
