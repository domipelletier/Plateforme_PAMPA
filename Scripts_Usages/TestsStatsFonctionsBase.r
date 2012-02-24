################################################################################
# Nom               : TestsStatsFonctionsBase.r
# Type              : Programme
# Objet             : Fonctions de bases de la plateforme (�galement utilis� pour 
#                     d�finir des fonctions de base r�centes de R lorsqu'elles n'existent pas,
#                     par ex si on travaille sur une version ancienne de R)
# Input             : aucun
# Output            : lancement de fonctions
# Auteur            : Yves Reecht & Elodie Gamp
# R version         : 2.11.1
# Date de cr�ation  : novembre 2011
# Sources
################################################################################


########################################################################################################################
if (!exists("grepl")) {

    grepl <- function(pattern, x,...) {    
        ## Purpose: �mulation des fonctions de 'grepl' (en moins efficace
        ##          probablement) si la fonction n'existe pas.
        ## ----------------------------------------------------------------------
        ## Arguments: pattern : le motif � rechercher.
        ##            x : le vecteur dans lequel chercher le motif.
        ##            ... : arguments suppl�mentaires pour 'grep'
        ## ----------------------------------------------------------------------
        ## Author: Yves Reecht, Date:  janvier 2012

        return(sapply(x,
          function(x2)  {
          ## On teste pour chaque �l�ment s'il contient le motif :
            as.logical(length(grep(as.character(pattern), x2,...)))
          }))
    }
} else {}                                 # Sinon rien � faire


####################################################################################################
### Description:
###
### Interface de comparaison des distributions d'une m�trique :
####################################################################################################
iter.gsub <- function(pattern, replacement, x,...) {

    if (length(pattern) > 0)  {
    
        return(gsub(pattern=pattern[1],
            replacement=replacement[1],
            x=iter.gsub(pattern=pattern[-1], replacement=replacement[-1], x=x),
            ...))
    } else {
        return(x)
    }
}


########################################################################################################################
.my.tkdev <- function (hscale = 1, vscale = 1,...) {
    ## Purpose: �craser la d�finition de .my.tkdev du packages tkrplot pour
    ##          permettre de passer des options suppl�mentaires au
    ##          p�riph�rique graphique + gestion des diff�rents syst�mes
    ##          d'exploitation/versions de R.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de .my.tkdev original + ...
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    if (Sys.info()["sysname"] == "Windows") { # Syst�me Windows
    
        if(R.version$major == 2 && R.version$minor < 3)  {
            win.metafile(width=4*hscale, height=4*vscale,...)
        } else {
            win.metafile(width=4*hscale, height=4*vscale, restoreConsole=FALSE,...)
        }
    } else {                              # Syst�mes Unix(-like).
        if (exists("X11", env=.GlobalEnv)) {        
            X11("XImage", 480*hscale, 480*vscale,...)
        } else {
            stop("tkrplot only supports Windows and X11")
        }
    }
}


########################################################################################################################
tkrplot <- function(parent, fun, hscale = 1, vscale = 1,...) {
    ## Purpose: �craser la d�finition de tkrplot du packages tkrplot pour
    ##          permettre de passer des options suppl�mentaires au
    ##          p�riph�rique graphique.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de tkrplot original + ...
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    image <- paste("Rplot",
                   ifelse(exists(".make.tkindex"),
                          .make.tkindex(),
                          tkrplot:::.make.tkindex()), # n�cessaire si ".make.tkindex" n'a pas �t� export�e.
                   sep = "")

    ## P�riph�rique graphique :
    .my.tkdev(hscale, vscale,...)

    try(fun())
    .Tcl(paste("image create Rplot", image))

    lab <- tklabel(parent, image = image)
    tkbind(lab, "<Destroy>", function() {.Tcl(paste("image delete", image))})
    lab$image <- image
    lab$fun <- fun
    lab$hscale <- hscale
    lab$vscale <- vscale
    return(lab)
}


########################################################################################################################
Capitalize.f <- function(x, words=FALSE) {
    ## Purpose: Mettre en majuscule la premi�re lettre de chaque mot
    ## ----------------------------------------------------------------------
    ## Arguments: x : une cha�ne de caract�res
    ##            words : tous les mots (TRUE), ou juste le premier.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    if (words) {    
        s <- strsplit(x, " ")[[1]]
    } else {
        s <- x
    }
    return(paste(toupper(substring(s, 1,1)), substring(s, 2),
                 sep="", collapse=" "))
}


########################################################################################################################
selRowCoefmat <- function(coefsMat, anovaLM, objLM) {
    ## Purpose: Retourne un vecteur de bool�en donnant les indices de ligne
    ##          de la matrice de coefs correspondant � des facteurs ou
    ##          int�ractions significatifs (les autres coefs n'ont pas
    ##          d'int�ret).
    ## ----------------------------------------------------------------------
    ## Arguments: coefsMat : matrice de coefficients.
    ##            anovaLM : objet correspondant de classe 'anova.lm'.
    ##            objLM : l'objet de classe 'lm' (n�cessaire pour traiter
    ##                    les cas de NAs)
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    if (!is.null(anovaLM))  {
    
        ## Facteurs et int�ractions dont les coefs doivent �tre imprim�s :
        selectedFactInt <- attr(anovaLM, "row.names")[which(anovaLM[[grep("P[r(]", attr(anovaLM, "names"))]] < 0.05)]

        ## Tous les facteurs :
        facts <- attr(anovaLM, "row.names")[!is.na(anovaLM[[grep("P[r(]", attr(anovaLM, "names"))]])]

        ## indices des int�ractions dans "selectedFactInt" :
        has.interactions <- TRUE
        interactions <- grep(":", facts, fixed=TRUE)
        if (length(interactions) == 0)  {        
            interactions <- length(facts) + 1
            has.interactions <- FALSE
        } else {}

        ## Coefficients par facteur (sans compter les int�ractions) :
        if (length(facts) == 1) {        
            factsRows <- list(grep(paste("^", facts, sep=""), row.names(coefsMat), value=TRUE))
            names(factsRows) <- facts
        } else {
            factsRows <- 
                sapply(facts[-c(interactions)],
                       function(fact) {                   
                          selRows <- grep(paste("^", fact, sep=""),
                                       row.names(coefsMat), value=TRUE)
                          return(selRows[! grepl(":",
                                              selRows,
                                              fixed=TRUE)])
                      }, simplify=FALSE)## , as.vector)
        }

        ## type de coef (facteur et int�ractions) par ligne de la matrice de coef :
        rows <- c("(Intercept)",
                  ## facteurs :
                  unlist(sapply(1:length(factsRows),
                        function(i) {
                            rep(names(factsRows)[i], length(factsRows[[i]]))
                        })))

        ## int�ractions :
        if (has.interactions) {        
            ## nombre de r�p�titions par type d'int�raction :

            ## liste des nombres de modalit�s pour chaque facteur d'une int�raction :
            nmod <- sapply(strsplit(facts[interactions], ":"),
                           function(fa) sapply(fa, function(i)length(factsRows[[i]])))

            if (!is.list(nmod)) {        # corrige un bug lorsqu'uniquement 1 type d'int�raction).
                nmod <- list(as.vector(nmod))
            } else {}

            ## Nombres de r�p�titions :
            nrep <- sapply(nmod, prod)

            ## Ajout des types d'int�ractions :
            rows <- c(rows,
                      unlist(sapply(1:length(nrep), function(i)
                                {
                                    rep(facts[interactions][i], nrep[i])
                                })))
        } else {}

        ## Lignes conserv�es :
        return(is.element(rows, c("(Intercept)", selectedFactInt))[!is.na(objLM$coefficients)])
    } else {
        return(rep(TRUE, nrow(coefsMat)))
    }
}


########################################################################################################################
printCoefmat.red <- function(x, digits = max(3, getOption("digits") - 2),
                             signif.stars = getOption("show.signif.stars"),
                             signif.legend = signif.stars, dig.tst = max(1, min(5, digits - 1)),
                             cs.ind = 1:k, tst.ind = k + 1, zap.ind = integer(0),
                             P.values = NULL,
                             has.Pvalue = nc >= 4 &&
                                          substr(colnames(x)[nc], 1, 3) == "Pr(", eps.Pvalue = .Machine$double.eps,
                             na.print = "NA",
                             anovaLM=NULL,
                             objLM=NULL,
                             ...)  {
    ## Purpose: Modification de printCoefmat pour n'afficher que les z-values
    ##          et p-values, et pour les facteurs significatife uniquement.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de printCoefmat
    ##            + anovaLM : r�sultat d'anova globale du mod�le (pour les
    ##                        facteurs et int�ractions significatifs).
    ##            objLM : objet de classe 'lm' ou 'glm'
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    ## S�lection des coefficients � montrer (pour effets/interactions significatifs) :
    x <- x[selRowCoefmat(x, anovaLM, objLM), , drop=FALSE]

    ## D�finitions issues de la fonction originale :
    if (is.null(d <- dim(x)) || length(d) != 2L)
        stop("'x' must be coefficient matrix/data frame")
    nc <- d[2L]
    if (is.null(P.values)) {
        scp <- getOption("show.coef.Pvalues")
        if (!is.logical(scp) || is.na(scp)) {
            warning("option \"show.coef.Pvalues\" is invalid: assuming TRUE")
            scp <- TRUE
        }
        P.values <- has.Pvalue && scp
    }
    else if (P.values && !has.Pvalue)
        stop("'P.values' is TRUE, but 'has.Pvalue' is not")
    if (has.Pvalue && !P.values) {
        d <- dim(xm <- data.matrix(x[, -nc, drop = FALSE]))
        nc <- nc - 1
        has.Pvalue <- FALSE
    }
    else xm <- data.matrix(x)
    k <- nc - has.Pvalue - (if (missing(tst.ind))
        1
    else length(tst.ind))
    if (!missing(cs.ind) && length(cs.ind) > k)
        stop("wrong k / cs.ind")
    Cf <- array("", dim = d, dimnames = dimnames(xm))
    ok <- !(ina <- is.na(xm))
    for (i in zap.ind) xm[, i] <- zapsmall(xm[, i], digits)
    if (length(cs.ind)) {
        acs <- abs(coef.se <- xm[, cs.ind, drop = FALSE])
        if (any(ia <- is.finite(acs))) {
            digmin <- 1 + if (length(acs <- acs[ia & acs != 0]))
                floor(log10(range(acs[acs != 0], finite = TRUE)))
            else 0
            Cf[, cs.ind] <- format(round(coef.se, max(1, digits -
                digmin)), digits = digits)
        }
    }
    if (length(tst.ind))
        Cf[, tst.ind] <- format(round(xm[, tst.ind], digits = dig.tst),
            digits = digits)
    if (any(r.ind <- !((1L:nc) %in% c(cs.ind, tst.ind, if (has.Pvalue) nc))))
        for (i in which(r.ind)) Cf[, i] <- format(xm[, i], digits = digits)
    okP <- if (has.Pvalue)
        ok[, -nc]
    else ok
    x1 <- Cf[okP]
    dec <- getOption("OutDec")
    if (dec != ".")
        x1 <- chartr(dec, ".", x1)
    x0 <- (xm[okP] == 0) != (as.numeric(x1) == 0)
    if (length(not.both.0 <- which(x0 & !is.na(x0)))) {
        Cf[okP][not.both.0] <- format(xm[okP][not.both.0], digits = max(1,
            digits - 1))
    }
    if (any(ina))
        Cf[ina] <- na.print
    if (P.values) {
        if (!is.logical(signif.stars) || is.na(signif.stars)) {
            warning("option \"show.signif.stars\" is invalid: assuming TRUE")
            signif.stars <- TRUE
        }
        if (any(okP <- ok[, nc])) {
            pv <- as.vector(xm[, nc])
            Cf[okP, nc] <- format.pval(pv[okP], digits = dig.tst,
                eps = eps.Pvalue)
            signif.stars <- signif.stars && any(pv[okP] < 0.1)
            if (signif.stars) {
                Signif <- symnum(pv, corr = FALSE, na = FALSE,
                  cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                  symbols = c("***", "**", "*", ".", " "))
                Cf <- cbind(Cf, format(Signif))
            }
        }
        else signif.stars <- FALSE
    }
    else signif.stars <- FALSE

    ## S�lection de colonnes :
    Cf <- Cf[ , ncol(Cf) - c(2:0)]

    print.default(Cf, quote = FALSE, right = TRUE, na.print = na.print,
        ...)
    if (signif.stars && signif.legend)
        cat("---\nSignif. codes: ", attr(Signif, "legend"), "\n")
    invisible(x)
}


################################################################################
plotDist.f <- function(y, family, variable, env=NULL,...)   {
    ## Purpose: Repr�senter l'ajustement de distribution et retourner l'objet
    ##          (contient notamment l'AIC du mod�le).
    ## ----------------------------------------------------------------------
    ## Arguments: y : les donn�es (numeric ou integer).
    ##            family : la loi de distribution, telle que d�fini dans
    ##                     'gamlss.family'.
    ##            variable : nom de la m�trique.
    ##            env : l'environnement de la fonction appelante.
    ##            ... : autres arguments � passer comme
    ##                  param�tres graphiques.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date:  janvier 2012

    ## Seed (je ne sais pas si c'est vraiment n�cessaire) :
    set.seed(as.integer(runif(1, min=1, max=512)))

    ## Noms et fonction de densit� de la loi pour ajouter les titres ainsi qu'ajuster et repr�senter la distribution :
    loi <- switch(family,
                  NO=list(name="Normale", densfunName="normal", densfun="dnorm"),
                  LOGNO=list(name="log-Normale", densfunName="log-normal", densfun="dlnorm"),
                  PO=list(name="de Poisson", densfunName="poisson", densfun="dpois"),
                  NBI=list(name="Binomiale n�gative", densfunName="negative binomial", densfun="dnbinom"))

    ## Traitement des z�ros pour la loi Log-Normale :
    if (family == "LOGNO" & sum(y == 0, na.rm=TRUE)) {    
        y <- y + ((min(y, na.rm=TRUE) + 1) / 1000)
    } else {}

    ## abscisses pour la distribution th�orique.
    if (is.element(family, c("PO", "NBI"))) {
        xi <- seq(from=min(y, na.rm=TRUE), to=max(y, na.rm=TRUE))
    } else {
        xi <- seq(from=min(y, na.rm=TRUE), to=max(y, na.rm=TRUE), length.out=5000)
    }

    ## browser(condition=(family == "NBI"))  ## [!!!] attention, il arrive que les calculs bloquent ici lors du premier
    ## lancement. (origine inconnue)
    ## On ajuste la distribution :
    try(coefLoi <- fitdistr(y, densfun=loi$densfunName))

    ## Calcul des points th�oriques � repr�senter :
    expr <- parse(text=paste(loi$densfun, "(xi, ",       # points � repr�senter.
                             paste(names(coefLoi$estimate), coefLoi$estimate, sep="=", collapse=", "), # coefs estim�s.
                             ")", sep=""))

    yi <- eval(expr)                    # valeurs pour la loi de distribution th�orique ajust�e.

    ## Repr�sentation graphique :
    nbreaks <- 60                       # Nombre de barres.

    histTmp <- hist(y, breaks=nbreaks, plot=FALSE) # pour connaitre la fr�quence maximale de la distribution observ�e.

    par(mar=c(3.4, 3.4, 2.5, 0.1), mgp=c(2.0, 0.7, 0), bg="white", cex=0.8, # Param�tres graphiques.
        ...)

    hist(y, breaks=nbreaks, freq=FALSE, # histogramme (distribution observ�e).
         ylim=c(0, ifelse(max(yi, na.rm=TRUE) > 3 * max(histTmp$density, na.rm=TRUE),
                          3 * max(histTmp$density, na.rm=TRUE),
                          1.05 * max(c(histTmp$density, yi), na.rm=TRUE))),
         xlim=c(min(y, na.rm=TRUE), max(y, na.rm=TRUE)),
         main=paste("Comparaison avec la loi ", loi$name, sep=""),
         ## cex.main=0.9,
         xlab=Capitalize.f(variable),
         ylab="Densit� de la m�trique",
         col="lightgray")

    lines(xi, yi, lwd=2, col="red")     # courbe (distribution th�orique).

    ## Calcul d'AIC (entre autres) :
    FA <- as.gamlss.family(family)      # On proc�de comme dans la fonction histDist.
    fname <- FA$family[1]

    res <- gamlss(y ~ 1, family=fname)

    ## Si un environnement est pr�cis�, la valeur est sauvegard�e dans une liste 'distList' :
    if (!is.null(env)) {
        eval(substitute(evalq(distList[[family]] <- res, envir=env), list(family=eval(family), res=eval(res))))
    } else {}

    ## Retourne le r�sultat :
    return(res)
}


########################################################################################################################
print.anova.fr <- function(x, digits = max(getOption("digits") - 2, 3), signif.stars = getOption("show.signif.stars"),
                           ...) {
    ## Purpose: Hack de la m�thode print.anova pour franciser les sorties et
    ##          supprimer les infos inutiles.
    ## ----------------------------------------------------------------------
    ## Arguments: ceux de print.anova
    ## ----------------------------------------------------------------------
    ## Author: Elodie Gamp, Date:  janvier 2012

    attr(x, "row.names")[attr(x, "row.names") == "Residuals"] <- "R�sidus"

    ## Fran�isation des en-t�tes (gsub it�ratif) :
    attr(x, "heading") <- iter.gsub(pattern=c("Analysis of Deviance Table",
                                              "Analysis of Variance Table",
                                              "Model:",
                                              "Negative Binomial",
                                              "Terms added sequentially \\(first to last\\)",
                                              "Response:",
                                              "link:"),
                                    replacement=c("\n---------------------------------------------------------------------------\nTable d'analyse de la d�viance :",
                                                  "\n---------------------------------------------------------------------------\nTable d'analyse de la variance :",
                                                  "Mod�le :",
                                                  "Binomiale n�gative",
                                                  "Termes ajout�s s�quentiellement (premier au dernier)",
                                                  "R�ponse :",
                                                  "lien :"),
                                    x=attr(x, "heading"), fixed=TRUE)

    ## D�finitions issues de la fonction originale :
    if (!is.null(heading <- attr(x, "heading"))) {
            cat(heading, sep = "\n")
    } else {}

    nc <- dim(x)[2L]
    if (is.null(cn <- colnames(x))) {    
        stop("'anova' object must have colnames")
    } else {}
    has.P <- grepl("^(P|Pr)\\(", cn[nc])
    zap.i <- 1L:(if (has.P)
             {
                 nc - 1
             } else {
                 nc
             })
    i <- which(substr(cn, 2, 7) == " value")
    i <- c(i, which(!is.na(match(cn, c("F", "Cp", "Chisq")))))
    if (length(i)) {    
        zap.i <- zap.i[!(zap.i %in% i)]
    } else {}

    tst.i <- i
    if (length(i <- grep("Df$", cn))) {   
        zap.i <- zap.i[!(zap.i %in% i)]
    } else {}

    printCoefmat(x, digits = digits, signif.stars = signif.stars,
                 signif.legend=FALSE,
                 has.Pvalue = has.P, P.values = has.P, cs.ind = NULL,
                 zap.ind = zap.i, tst.ind = tst.i, na.print = "", ...)
    invisible(x)
}


########################################################################################################################
