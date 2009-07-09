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
  ; Open the file
  openr, lun, filename, /GET_LUN
  
  ; Loop through to the correct line number and read the data into a string
  FOR i=0, line_num DO BEGIN
    readf, lun, line, format="(a)"
  ENDFOR
  
  ; Close the file
  FREE_LUN, lun
  
  ; Return the data as a string
  return, line
END

; This function calculates the offset due to the dark current. At the moment it is hardcoded to work
; only on the NCAVEO PC at the University of Southampton.
FUNCTION CALCULATE_OFFSET, dns, line_number
  ; Get a list of all the dark spectra files
  dark_files = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\rad\dark", "*spectrum*")
  
  dark_values = fltarr(N_ELEMENTS(dark_files))
  
  ; For each spectrum file
  FOR i=0, N_ELEMENTS(dark_files)-1 DO BEGIN
    ; Read the right line as a float
    line_string = READ_NUMBERED_LINE(dark_files[i], line_number)
    reads, line_string, dn, format="(f)"
    
    dark_values[i] = dn
  ENDFOR
  
  ; Calculate the dark value from the array of dark values measured at different times.
  ; At the moment the minimum value is taken, but this could easily be changed to the mean, max
  ; or any other function.
  dark_value = MIN(dark_values)
  
  return, dark_value
END

; This function calibrates the data which is obtained by GET_SKY_DATA
FUNCTION CALIBRATE_DATA, azimuths, zeniths, dns, line_number
  ; The commented code below is used for testing that there are no zeroes in the array
  ; This has been because of problems in the past with arrays being larger than they need to be
  ; It should not need to be used, but has been left in here in case
  ;indices = WHERE(dns EQ 0)
  ;print, "Indices = ", indices
  ;print, "Azimuths = ", azimuths[indices]
  ;print, "Zeniths = ", zeniths[indices]

  ; Calculate the offset for the calibration, due to the dark current
  offset = CALCULATE_OFFSET(dns, line_number)
  
  ; If it's wavelength 870nm
  IF line_number GE 1523 THEN offset = 115
  
  ; Manually set the gain to be 1 at the moment. To get actual gain from the calibration spectra files
  ; just replace the line below with a call to a function to get the right gain information
  gain = 1
  
  ; Perform the calibration using the standard formula
  calibrated_dns = (dns - offset) * gain
  
  return, calibrated_dns
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
PRO GET_SKY_DATA, dir_path, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, datetime=datetime, normalise=normalise, sun_azimuth=sun_azimuth, sun_zenith=sun_zenith
  ; Get a list of all the angle.txt files under the specified directory
  angle_files = FILE_SEARCH(dir_path, "angles.txt")
  
  ; Set up a blank string variable to read lines into
  line = ""
  
  ; Set up blank arrays ready for data to be inserted
  array_size = N_ELEMENTS(angle_files)*11
  
  azimuths = intarr(array_size)
  dns = fltarr(array_size)
  zeniths = fltarr(array_size)
  
  ; For each angle.txt file
  FOR i=0, N_ELEMENTS(angle_files)-1 DO BEGIN
  
    ; Open the angle.txt file
    openr, lun, angle_files[i], /GET_LUN
    
    ; Store the azimuth from the folder name
    folders_string = FILE_DIRNAME(angle_files[i])
    azimuth = FILE_BASENAME(folders_string)
    
    ; If the azimuth isn't a 3 digit number then skip to the end of the loop
    if STREGEX(azimuth, "[1234567890]{3}", /BOOLEAN) eq 0 THEN GOTO, end_of_loop
    
    ; Initialise the j loop variable, which is incremented for every line read from the file
    j = 0
    
    ; While not end of file...
    WHILE (eof(lun) ne 1) DO BEGIN
      ; Read the next line from the file and split in by ;'s
      readf, lun, line, format="(a)"
      splitted = STRSPLIT(line, ";", /EXTRACT)
  
      ; Extract the spectrum filename
      spectrum_filename = FILE_DIRNAME(angle_files[i]) + "\" + splitted[0]
      
      ; Initialise the datetime variable and then read in the datetime data to a float (stored as julian datetime)
      datetime = double(0.0)
      reads, splitted[1], datetime, format='(C(CDI2, 1X, CMOI2, 1X, CYI4, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
      
      ; Gets a string of the entire line of the filename at the line number given in angles.txt
      line_string = READ_NUMBERED_LINE(spectrum_filename, line_number)
      
      ; Read the value in from that string into the float variable dn
      reads, line_string, dn, format="(f)"
      
      ; Calculate which index in the array to put it in
      array_index = (11*i) + j
      
      ; Get the zenith from the angle_file
      zenith = FLOAT(splitted[2])
      
      ; Calculate the azimuth given that the zenith scanning goes all the way from 0 to 180 degrees    
      IF zenith GT 90 THEN BEGIN
        real_azimuth = uint(azimuth) + 180
        real_zenith = zenith - 90
      ENDIF ELSE BEGIN
        real_azimuth = uint(azimuth)
        real_zenith = zenith
      ENDELSE
      
      ; Reverse zenith's to get it to plot correctly (otherwise it would plot inside out!)
      real_zenith = 90 - real_zenith
      
       ; Corrects the data as the instrument was aligned S-N rather than N-S.
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
  
  
  ; The commented line below will perform the calibration of the data. This leads to problems with
  ; negative values at the moment, so it is not in use.
  ;dns = CALIBRATE_DATA(azimuths, zeniths, dns, line_number)
  
  ; If the normalise keyword has been set then normalise the data by dividing every value by the max value
  IF KEYWORD_SET(normalise) THEN BEGIN
    dns = float(dns) / MAX(dns)
  ENDIF
  
  ; Calculate the sun azimuth and zenith from the data (takes the mean of the maximum azimuths and zeniths)
  sun_array_index = WHERE(dns EQ MAX(dns))
  sun_azimuth = MEAN(azimuths[sun_array_index])
  sun_zenith = MEAN(zeniths[sun_array_index])
  
  
  ; Close all files
  close, /all
END