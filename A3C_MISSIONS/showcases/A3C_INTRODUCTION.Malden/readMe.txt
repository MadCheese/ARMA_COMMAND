A3C Tutorial Mission – Repository Layout and Editor Setup

This tutorial mission is stored inside the main ARMA_COMMAND_DEV.Altis Git repository so that all addon source files, missions, scripts, and shared identifiers can be maintained from one location.

The repository layout works as follows:

* The mission.sqm located directly inside ARMA_COMMAND_DEV.Altis belongs to the A3C_Core development mission.
* Other unpacked addon projects are placed inside ARMA_COMMAND_DEV.Altis so the entire project can be edited and versioned as one coherent repository.
* The tutorial mission is stored at:

C:\Users\Rafik\Documents\Arma 3\missions\ARMA_COMMAND_DEV.Altis\A3C_MISSIONS\showcases\A3C_INTRODUCTION.Malden

Arma 3 only discovers editable missions that appear directly inside the profile’s missions folder. To make the nested tutorial mission visible to Eden Editor, create a Windows directory junction at:

C:\Users\Rafik\Documents\Arma 3\missions\A3C_INTRODUCTION.Malden

Open PowerShell and run:

New-Item -ItemType Junction -Path 'C:\Users\Rafik\Documents\Arma 3\missions\A3C_INTRODUCTION.Malden' -Target 'C:\Users\Rafik\Documents\Arma 3\missions\ARMA_COMMAND_DEV.Altis\A3C_MISSIONS\showcases\A3C_INTRODUCTION.Malden'

The junction does not create a duplicate copy. Both paths refer to the same underlying mission files. Changes made through Eden Editor, Visual Studio Code, or either folder path therefore modify the version stored inside the Git repository.

To verify the junction, run:

Get-Item -LiteralPath 'C:\Users\Rafik\Documents\Arma 3\missions\A3C_INTRODUCTION.Malden' -Force | Format-List FullName,LinkType,Target

The result should show:

LinkType : Junction
