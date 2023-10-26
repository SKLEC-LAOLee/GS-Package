# GS-Package
A matlab package for processing sediment grain size and shape with support for Camsizer X2, Coulter LS, and Malvern Mastersizer 2000/3000 instruments.
# Compatible Instruments
- Microtrac Cmasizer X2
- Coulter LS13320
- Coulter LS950
- Malvern MasterSizer 2000
- Malvern MasterSizer 3000
# How to use GS-Package
- see demo.m
  all the settings are integrated in a structure variable "userSettings". 
- Definitions of "userSettings"
``userSettings.``
  - ``sampleSettingFileName``: sample settings information file
  - ``dataPath``: full path of the raw data files
  - ``outputPath``: full path of the output files
  - ``prefixString``: prefixes for archive file names
  - ``instrumentId``: 
      - = ``1``, coulter LS Serials; 
      - =``11``, camsizer X2; 
      - =``21``, malvern MasterSizer Serials
  - ``forceReadRawData``:
    - = ``true``, allways read data from raw files;
    - = ``false``, load the rawData.mat if exists in the dataPath; otherwise, read data from raw files
  - ``MIN_CHANNEL_SIZE_UM``: lower limit of instrument detection (um), should be greater than 0, default is 0.01um
  - ``MAX_CHANNEL_SIZE_UM``: upper limit of instrument detection (um), default is 10mm
  - ``GradationCurveFigWidth``: figure width of the gradation curve, in unit of cm
  - ``GradationCurveFigHeight``: figure height of the gradation curve, in unit of cm
  - ``language``: 
    - =``'cn'``, particle grading curves are labeled in Chinese;
    - =``'en'``, particle grading curves are labeled in English
  - ``userChannelSize``=``load('200ChannelOf8000.txt','-ascii')``, Specify uniform channel boundaries (samples are measured with several types of instruments with different channel-size definition), in um, example values [0.1,1,2,10:10:5000].
  - ``exportGBT12763``: output GBT12763-format report, =``true`` or ``false``
  - ``exportGradingCurve``: output particle grading curve figures, =``true`` or ``false``
  - ``exportMetadata``: output metadata report, =``true`` or ``false``
  - ``exportAllData``: output all the statistical parameters, =``true`` or ``false``
  - ``exportUserComponent``: output statistical parameters of the user-speicified components, =``true`` or ``false``
  - ``componentDownSize``: upper size of the user components (um), =``true`` or ``false``
  - ``componentUpSize``: lower size of the user components (um), =``true`` or ``false``
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