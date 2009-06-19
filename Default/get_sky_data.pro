; Reads the given filename and extracts the specified line number (first line = line 1 not line 0)
; and returns it as a string
FUNCTION READ_NUMBERED_LINE, filename, line_num
  openr, lun, filename, /GET_LUN
  
  FOR i=0, line_num DO BEGIN
    readf, lun, line, format="(a)"
  ENDFOR
  
  FREE_LUN, lun
  
  return, line
END

; Gets the data from the Sky Radiance Mapper (SKRAM) files. At the moment, paths are hardcoded to the
; paths used on the ncaveo PC at the University of Southampton
PRO GET_SKY_DATA, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns
  ; Get a list of all the angle.txt files under the specified directory
  angle_files = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June\scan1_high", "angles.txt")
  
  line = ""
  
  ; Set up blank arrays ready for data to be inserted
  azimuths = intarr(N_ELEMENTS(angle_files)*11)
  dns = fltarr(N_ELEMENTS(angle_files)*11)
  zeniths = fltarr(N_ELEMENTS(angle_files)*11)
  
  ; For each angle.txt file
  FOR i=0, N_ELEMENTS(angle_files)-1 DO BEGIN
  
    ; Open the angle.txt file
    openr, lun, angle_files[i], /GET_LUN
    
    ; Store the azimuth from the folder name
    folders_string = FILE_DIRNAME(angle_files[i])
    azimuth = FILE_BASENAME(folders_string)
    
    ; Initialise the j loop variable, which is incremented for every line read from the file
    j = 0
    
    ; While not end of file...
    WHILE (eof(lun) ne 1) DO BEGIN
      ; Read the next line from the file and split in by ;'s
      readf, lun, line, format="(a)"
      splitted = STRSPLIT(line, ";", /EXTRACT)
      
      ; Get's a string of the entire line of the filename at the line number given in angles.txt
      line_string = READ_NUMBERED_LINE(splitted[0], line_number)
      
      ; Read the value in from that string into the float variable dn
      reads, line_string, dn, format="(f)"
      
      ; Calculate which index in the array to put it in
      array_index = (11*i) + j
      
      ; Calculate the azimuth given that the zenith scanning goes all the way from 0 to 180 degrees    
      zenith = FLOAT(splitted[2])
      IF zenith GT 90 THEN BEGIN
        real_azimuth = azimuth + 180
        real_zenith = zenith - 90
      ENDIF ELSE BEGIN
        real_azimuth = azimuth
        real_zenith = zenith
      ENDELSE
      
      ; Insert the values into the arrays
      azimuths[array_index] = real_azimuth
      dns[array_index] = dn
      zeniths[array_index] = real_zenith
      
      j = j + 1
    ENDWHILE
    FREE_LUN, lun
  ENDFOR
  
  ; Close all files
  close, /all
END