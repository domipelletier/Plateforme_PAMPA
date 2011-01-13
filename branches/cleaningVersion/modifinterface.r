
ModifierMenuApresImport.f = function()
{

    print("fonction ModifierMenuApresImport activ�e")

    ## R�activation des menus qui n�cessitent le chargement pr�alable :
    tkentryconfigure(topMenu,1,state="normal")
    tkentryconfigure(topMenu,2,state="normal")
    tkentryconfigure(topMenu,3,state="normal")
    tkentryconfigure(topMenu,4,state="normal")
    tkentryconfigure(topMenu,5,state="normal")

    ## R�activation des entr�es du menu "Donn�es" qui n�cessitent le chargement pr�alable :
    tkentryconfigure(import,3,state="normal")
    tkentryconfigure(import,7,state="normal")
    tkentryconfigure(import,8,state="normal")

    NbEsp<-length(unique(obs$code_espece))
    tkconfigure(ResumerSituationEspecesSelectionnees,text=paste("-> Nombre d'esp�ces concern�es : ",NbEsp))
    Nbunitobs<-length(unique(obs$unite_observation))
    tkconfigure(ResumerSituationUnitobsSelectionnees,text=paste("-> Nombre  d'unit�s d'observations concern�es : ",Nbunitobs))

    winRaise.f(tm)
}

MiseajourTableau.f = function(tclarray)
{
    ## ############# Mise � jour des valeurs dans le tableau #############
    tclarray[[1,1]] <- sub(paste(nameWorkspace,"/Data/",sep=""),'',fileName1)
    tclarray[[1,2]] <- dim(unitobs)[1]
    tclarray[[1,3]] <- dim(unitobs)[2]
    tclarray[[2,1]] <- sub(paste(nameWorkspace,"/Data/",sep=""),'',fileName2)
    tclarray[[2,2]] <- dim(obs)[1]
    tclarray[[2,3]] <- dim(obs)[2]
    tclarray[[3,1]] <- sub(paste(nameWorkspace,"/Data/",sep=""),'',fileName3)
    tclarray[[3,2]] <- dim(especes)[1]
    tclarray[[3,3]] <- dim(especes)[2]
}

ModifierInterfaceApresSelection.f = function(Critere,Valeur)
{
    print("fonction ModifierInterfaceApresSelection activ�e")

    tkinsert(table1,"cols","end",1)
    tclarray[[0,4]] <- "S�lection"
    tclarray[[2,4]] <- dim(obs)[1]
    tkconfigure(MonCritere,text=Critere)
    tkconfigure(MesEnregistrements,text=Valeur)
    NbEsp<-length(unique(obs$code_espece))
    tkconfigure(ResumerSituationEspecesSelectionnees, text = paste("-> Nombre d'esp�ces concern�es : ",
                                                      NbEsp))
    Nbunitobs<-length(unique(obs$unite_observation))
    tkconfigure(ResumerSituationUnitobsSelectionnees,text=paste("-> Nombre d'unit�s d'observations dans le fichier d'observations : ",Nbunitobs))
    if (Jeuxdonnescoupe==1)
    {
        tkconfigure(button.DataRestore, state="normal")
    }
    ## tkconfigure(frameLower,text=paste(length(obs$code_espece[obs$code_espece==fa])," enregistrements
    ## concern�s",sep=""))

    eval(winRaise.f(tm), envir=.GlobalEnv)
}

ModifierInterfaceApresRestore.f = function(Critere="Aucun",Valeur="NA")
{
    print("fonction ModifierInterfaceApresRestore.f activ�e")


    tkdelete(table1,"cols","end",1)

    tclarray[[0,4]] <- "S�lection"
    tclarray[[2,4]] <- dim(obs)[1]
    tkconfigure(MonCritere,text=Critere)
    tkconfigure(MesEnregistrements,text=Valeur)
    NbEsp<-length(unique(obs$code_espece))
    tkconfigure(ResumerSituationEspecesSelectionnees,text=paste("-> Nombre d'esp�ces concern�es : ",NbEsp))
    Nbunitobs<-length(unique(obs$unite_observation))
    tkconfigure(ResumerSituationUnitobsSelectionnees,text=paste("-> Nombre d'unit�s d'observations dans le fichier d'observations : ",Nbunitobs))
    tkconfigure(button.DataRestore, state="disabled")

    winRaise.f(tm)
}

########################################################################################################################
statutPresAbs.f <- function()
{
    ## Purpose: Activer/d�sactiver les entr�es du menu qui permettent de
    ##          travailler sur les pr�sences/absences et fr�quences
    ##          d'occurrence, en fonction du contexte.
    ## !!! � mettre � jour � chaque modification des menus (en particulier si
    ## des entr�es intercall�es sont ajout�es ou supprim�es).
    ## ----------------------------------------------------------------------
    ## Arguments: aucun.
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 18 oct. 2010, 11:33

    if (is.null(TablePresAbs))
    {
        ## Plus utile : � v�rifier (non utilisation de la table ??) [!!!]
        ## tkentryconfigure(modelesInferentiels, 2, state="disabled")
        ## tkentryconfigure(traitement, 11, state="disabled")
        ## Ajouter le benthos [yr: 18/10/2010] [!!!]
    }else{
        tkentryconfigure(modelesInferentiels, 2, state="normal")
        tkentryconfigure(traitement, 11, state="normal") # La position d�bute � 0 et tient compte des s�parateurs.
        ## Ajouter le benthos [yr: 18/10/2010] [!!!]
    }
}

