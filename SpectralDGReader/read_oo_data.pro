PRO READ_OO_DATA_FILE, filename, wavelengths=wavelengths, dns=dns, datetime=datetime
  openr, lun, filename, /GET_LUN
  
  line = ""
  
  ; Initialise arrays
  wavelengths = fltarr(2047) ; 2047 not 2048 because first value is always zero
  dns = fltarr(2047) ; 2047 not 2048 because first value is always zero
  
  junk = ""
  
  ; Read the first two lines of the file
  readf, lun, junk
  readf, lun, junk
  
  date_line = ""
  
  ; Read the next line in - which is in the following format "Date: 06-17-2006, 09:44:35"
  readf, lun, date_line
  ; Just get the actual date bit of it
  datetime_string = strmid(date_line, 6)
  
  j_datetime = double(0.0)
  
  reads, datetime_string, j_datetime, format='(C(CDwA, X, CMoA, X, CDI, X, CHI, X, CMI, X, CSI, 4X, CYI5))'
  
  
  ; Read the 19 comment lines at the beginning of the file
  FOR i=0,14 DO BEGIN
    readf, lun, line
  ENDFOR
  
  i = 0
  
  readf, lun, line
  
  WHILE line NE ">>>>>End Processed Spectral Data<<<<<" DO BEGIN
    
    splitted = STRSPLIT(line, /EXTRACT)
    wavelengths[i] = float(splitted[0])
    dns[i] = float(splitted[1])
    
    readf, lun, line
    i++
  ENDWHILE
  
  datetime = j_datetime
  
  FREE_LUN, lun
END

PRO PLOT_OO_DATA_BY_WAVELENGTH, data, datetimes, wavelengths, given_wavelength
  distance_away = MIN(ABS(wavelengths - given_wavelength), nearest_index)

  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  plot, datetimes, data[*, nearest_index], xtickformat='LABEL_DATE', title="NFC OO Data: " + string(given_wavelength) + "nm"
END


PRO READ_OO_DATA
  data_files = FILE_SEARCH("D:\UserData\Robin Wilson\Data from Ext HDD\NCAVEO\060616\OO cosine head", "*.scope", /FULLY_QUALIFY_PATH)
  
  print, data_files
  
  data = fltarr(N_ELEMENTS(data_files), 2048)
  
  datetimes = dblarr(N_ELEMENTS(data_files))
  
  FOR i=0, N_ELEMENTS(data_files)-1 DO BEGIN
    READ_OO_DATA_FILE, data_files[i], wavelengths=wavelengths, dns=dns, datetime=datetime
    data[i, *] = dns
    datetimes[i] = datetime
  ENDFOR
  
  help, data
  
  ;plot, wavelengths, data[0, *]
 
  
  PLOT_OO_DATA_BY_WAVELENGTH, data, datetimes, wavelengths, 675
  
;  array = data[*, 1236]
;  
;  average_array = SMOOTH(array, 3, /EDGE_TRUNCATE)
;      
;  squared_array = array^2
;    
;  average_squared_array = SMOOTH(squared_array, 3, /EDGE_TRUNCATE)
;    
;  CVOutput = temporary(average_squared_array) - (average_array^2)
;    
;  variance_array = CVOutput * (double(3)/(3-1))
;    
;  sd_array = sqrt(variance_array)
;  
;  ratio_array = sd_array / average_array
;  
;  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
;  
;  plot, datetimes, ratio_array, xtickformat='LABEL_DATE'
;  
;  oplot, datetimes, replicate(0.03, N_ELEMENTS(datetimes))
;  
;  indices = WHERE(ratio_array GT 0.03)
;  
;  print, datetimes[indices], format='(C(CHI2.2, ":", CMI2.2, ":", CSI2.2))'
END
