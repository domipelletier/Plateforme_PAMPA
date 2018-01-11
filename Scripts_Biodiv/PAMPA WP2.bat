:: -*- coding: latin-1 -*-
:: Time-stamp: <2018-01-11 13:07:20 yreecht>

:: Plateforme PAMPA de calcul d'indicateurs de ressources & biodiversit�
::   Copyright (C) 2008-2017 Ifremer - Tous droits r�serv�s.
::
::   Ce programme est un logiciel libre ; vous pouvez le redistribuer ou le
::   modifier suivant les termes de la "GNU General Public License" telle que
::   publi�e par la Free Software Foundation : soit la version 2 de cette
::   licence, soit (� votre gr�) toute version ult�rieure.
::
::   Ce programme est distribu� dans l'espoir qu'il vous sera utile, mais SANS
::   AUCUNE GARANTIE : sans m�me la garantie implicite de COMMERCIALISABILIT�
::   ni d'AD�QUATION � UN OBJECTIF PARTICULIER. Consultez la Licence G�n�rale
::   Publique GNU pour plus de d�tails.
::
::   Vous devriez avoir re�u une copie de la Licence G�n�rale Publique GNU avec
::   ce programme ; si ce n'est pas le cas, consultez :
::   <http://www.gnu.org/licenses/>.

@echo off

rem R version can be easily forced uncommenting/adapting the set command.
rem   For example, forcing R 2.15.3 (must be installed, loading fails otherwise):

rem set R_VER=R-2.15.3
set R_PROFILE=Scripts_Biodiv/Rprofile.site
cmd /c  .\Scripts_Biodiv\R.bat path ^& start "PAMPA WP2" Rgui.exe --no-restore --no-save --sdi
