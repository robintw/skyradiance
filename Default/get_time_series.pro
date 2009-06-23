@GET_SKY_DATA

PRO GET_TIME_SERIES
  line_number = 268

  dirs = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June", "scan*_high", /TEST_DIRECTORY)

  datetimes = strarr(N_ELEMENTS(dirs))
  values = fltarr(N_ELEMENTS(dirs))
  
  ; For every directory returned
  FOR i=0, N_ELEMENTS(dirs)-1 DO BEGIN
    scan_num = STREGEX(FILE_BASENAME(dirs[i]), "[1234567890]+", /EXTRACT)

    
    ; If it is an odd-numbered scan (ie. it is a full scan)
    IF scan_num MOD 2 eq 1 THEN BEGIN
      GET_SKY_DATA, dirs[i], line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, datetime=datetime
      
      datetimes[i] = datetime
      
      ; HERE IS WHERE THE VALUE IS SET - CHANGE AS NEEDED
      values[i] = MAX(dns) - MIN(dns)
    ENDIF
  ENDFOR
  
  nonzero_indices = WHERE(values)
  
  new_datetimes = datetimes[nonzero_indices]
  new_values = values[nonzero_indices]
  
  julian_datetimes = dblarr(N_ELEMENTS(new_datetimes))
    
  reads, new_datetimes, julian_datetimes, format='(C(CDI2, 1X, CMOI2, 1X, CYI4, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
   
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  plot, julian_datetimes, new_values, psym=1, xtickformat='LABEL_DATE'
END