;+
; NAME:
; READ_NUMBERED_LINE 
;
; PURPOSE:
; This procedure reads a certain line from a file, selected by a line number
; 
; CALLING SEQUENCE:
;
; READ_NUMBERED_FILE, Filename, Line_num
;
; INPUTS:
; Filename: A string containing the filepath to read from.
; 
; Line_num: The line number to read. NB: This starts from 1 not 0.
;
;-
FUNCTION READ_NUMBERED_LINE, filename, line_num
  openr, lun, filename, /GET_LUN
  
  FOR i=0, line_num DO BEGIN
    readf, lun, line, format="(a)"
  ENDFOR
  
  FREE_LUN, lun
  
  return, line
END

;+
; NAME:
; GET_SKY_DATA 
;
; PURPOSE:
; This procedure gets data from the McGonigle data files produced by the NCAVEO Field Campaign during June 2006.
; 
; CALLING SEQUENCE:
;
; GET_SKY_DATA, dir_path, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns
;
; INPUTS:
; Dir_path: A string containing the directory to read the data from. This must be a scanX_high or scanX_low directory.
; 
; Line_number: The line number to read from this file. This represents the wavelength. For example 440nm = line 268
; 
; OUTPUTS:
; Azimuths: The azimuth data, in a format ready for displaying using MAP_PLOT_DATA.
; 
; Zeniths: The zenith data, in a format ready for displaying using MAP_PLOT_DATA.
; 
; DNs: The DN data, in a format ready for displaying using MAP_PLOT_DATA.
; 
; Datetime: The timestamp of the scan.
; 
; KEYWORD PARAMETERS:
; NORMALISE: This normalises the data before the data is returned, which involves dividing each value by the value at
;   the centre of the sky (a zenith of 90 degrees).
;
;-
PRO GET_SKY_DATA, dir_path, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, datetime=datetime, normalise=normalise
  ; Get a list of all the angle.txt files under the specified directory
  angle_files = FILE_SEARCH(dir_path, "angles.txt")
  
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
    
    if STREGEX(azimuth, "[1234567890]{3}", /BOOLEAN) eq 0 THEN GOTO, end_of_loop
    
    ; Initialise the j loop variable, which is incremented for every line read from the file
    j = 0
    
    ; While not end of file...
    WHILE (eof(lun) ne 1) DO BEGIN
      ; Read the next line from the file and split in by ;'s
      readf, lun, line, format="(a)"
      splitted = STRSPLIT(line, ";", /EXTRACT)
      
      ;print, FILE_BASENAME(angle_files[i])
      
      spectrum_filename = FILE_DIRNAME(angle_files[i]) + "\" + splitted[0]
      
      datetime = double(0.0)
      
      reads, splitted[1], datetime, format='(C(CDI2, 1X, CMOI2, 1X, CYI4, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
      print, "GET_SKY_DATA says datetime is: "
      print, splitted[1]
      print, "or (converted to julian)
      print, datetime, FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
      
      
      ; Get's a string of the entire line of the filename at the line number given in angles.txt
      line_string = READ_NUMBERED_LINE(spectrum_filename, line_number)
      
      ; Read the value in from that string into the float variable dn
      reads, line_string, dn, format="(f)"
      
      ; Calculate which index in the array to put it in
      array_index = (11*i) + j
      
      zenith = FLOAT(splitted[2])
      
      ; Calculate the azimuth given that the zenith scanning goes all the way from 0 to 180 degrees    
      IF zenith GT 90 THEN BEGIN
        real_azimuth = uint(azimuth) + 180
        real_zenith = zenith - 90
      ENDIF ELSE BEGIN
        real_azimuth = uint(azimuth)
        real_zenith = zenith
      ENDELSE
      
      ; Reverse zenith's to get it to plot correctly
      real_zenith = 90 - real_zenith
      
       ; Corrects the data as the instrument was aligned S-N rather than N-S. TODO: Check with Ted!
      IF real_azimuth LT 180 THEN real_azimuth = real_azimuth + 180 ELSE real_azimuth = real_azimuth - 180
     
      
      ; Insert the values into the arrays
      azimuths[array_index] = real_azimuth
      dns[array_index] = dn
      zeniths[array_index] = real_zenith
      
      j = j + 1
    ENDWHILE
    
    end_of_loop:
    FREE_LUN, lun
  ENDFOR
  
  
  IF KEYWORD_SET(normalise) THEN BEGIN
    ; Normalise data
    centre_indexes = WHERE(zeniths EQ 90)
    average_centre = MEAN(dns[centre_indexes])    
    dns = float(dns) / average_centre
  ENDIF
  
  ; Close all files
  close, /all
END