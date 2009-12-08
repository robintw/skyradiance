PRO CONVERT_SINGLE_FILE, filename, tiff_directory
  ; The directory that has gdal_translate in it
  GDAL_bin_directory = "J:\Geography Research\Research & Collaboration\NCAVEO\NEXTMap data\gdal\bin"
  
  TileName = STRMID(filename, strlen(filename) - 19, 7)
  
  print, "Processing " + TileName
  Output_TIFF_Location = TIFF_directory + "\" +  TileName + ".tiff"
  
  ; If the file already exists then don't bother converting it
  IF FILE_TEST(Output_TIFF_Location) EQ 1 THEN return
  
  command_string = '"' + GDAL_bin_directory + '\gdal_translate.exe" ' + '"' + files[i] + '" "' + Output_TIFF_Location + '"'
  
  spawn, command_string, result, ErrResult, /NOSHELL
  ;print, result
  ;print, ErrResult
END

PRO CONVERT_NM_DATA, argument
  TIFF_directory = "J:\Geography Research\Research & Collaboration\NCAVEO\NEXTMap data\TIFFs"
  Root_directory = "J:\Geography Research\Research & Collaboration\NCAVEO\NEXTMap data\"

  ENVI_REPORT_INIT, "Converting NextMAP files", base=report_base

  ; Look for all the Arc GRID files in the root directory
  files = FILE_SEARCH(Root_directory, "w001001.adf")
  
  ENVI_REPORT_STAT, report_base, 0, N_ELEMENTS(files) - 1
  
  FOR i = 0, N_ELEMENTS(files)-1 DO BEGIN
    CONVERT_SINGLE_FILE, files[i], TIFF_directory
    ENVI_REPORT_STAT, report_base, i, N_ELEMENTS(files) - 1
  ENDFOR
  
  ENVI_REPORT_INIT, base=report_base, /finish
END