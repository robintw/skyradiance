PRO CONVERT_SINGLE_FILE, filename, tiff_directory
  GDAL_bin_directory = "C:\program files\gdalwin32-1.6\bin"
  
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

PRO CONVERT_NM_DATA
  TIFF_directory = "J:\Geography Research\Research & Collaboration\NCAVEO\NEXTMap data\TIFFs"
  Root_directory = "J:\Geography Research\Research & Collaboration\NCAVEO\NEXTMap data\"

  ; Look for all the Arc GRID files in the root directory
  files = FILE_SEARCH(Root_directory, "w001001.adf")
  
  FOR i = 0, N_ELEMENTS(files)-1 DO BEGIN
    CONVERT_SINGLE_FILE, files[i], TIFF_directory
  ENDFOR
END