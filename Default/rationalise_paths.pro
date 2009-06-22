PRO RATIONALISE_PATHS
  angle_files = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\17-June", "angles.txt")
  
  print, angle_files
  
  FOR i=0, N_ELEMENTS(angle_files)-1 DO BEGIN
    ; Open the angle.txt file
    openr, lun, angle_files[i], /GET_LUN
    
    ; Calculate path for new file
    new_name = FILE_DIRNAME(angle_files[i]) + "\" + "new_angles.txt"
    
    print, new_name
    
    ; Open the newangle.txt file
    openw, lun2, new_name, /GET_LUN
    
    line = ""
    
    ; While not end of file...
    WHILE (eof(lun) ne 1) DO BEGIN
      ; Read the next line from the file and split in by ;'s
      readf, lun, line, format="(a)"
      
      splitted = STRSPLIT(line, ";", /EXTRACT)
      
      splitted[0] = FILE_BASENAME(splitted[0])
      
      new_line = STRJOIN(splitted, ";")
      
      print, new_line
      
      printf, lun2, new_line
    ENDWHILE
    
    free_lun, lun
    free_lun, lun2
    
    FILE_DELETE, angle_files[i]
    FILE_MOVE, new_name, angle_files[i]
  ENDFOR
  
  close, /all
END