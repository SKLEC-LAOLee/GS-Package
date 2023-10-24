# GS-Package
A matlab package for processing sediment grain size and shape with support for Camsizer X2, Coulter LS, and Malvern Mastersizer 2000/3000 instruments.
# Compatible Instruments
- Microtrac Cmasizer X2
- Coulter LS13320
- Coulter LS950
- Malvern MasterSizer 2000
- Malvern MasterSizer 3000

## How to batch export text data in Mastersizer 2000/3000 software?
1. Edit menu>>User grainsize>>Edit grainsize: Load grainsize, select malvernGrainsize.siz
2. Copy malvernExportDataForGSPackage.edf to the following directory:
    - C:\Users\Public\Documents\Malvern Instruments\Mastersizer 2000\Export Templates
4. shift+left click of mouse button to select the data file >> File menu >> Export Data:
    - Use Data Templates = malvernExportDataForGSPackage
    - Format Options = Use tabs as separators, exclude header rows.
    - Export data to file, select text file (*.txt)
    - Check to overwrite files
    - Output filename suffixes only allowed as *.mal