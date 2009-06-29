; Function to calculate the value which will be returned for each timestamped scan
; This can easily be changed for different situations, at the moment it uses a simple range
; calculation.
FUNCTION CALCULATE_VALUE, dns, azimuths, zeniths
  return_value = MAX(dns) - MIN(dns)
  return, return_value
END


PRO GET_TIME_SERIES, datetimes=datetimes, values=values
  line_number = 268

  dirs = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June", "scan*_high", /TEST_DIRECTORY)

  calculated_datetimes = strarr(N_ELEMENTS(dirs))
  calculated_values = fltarr(N_ELEMENTS(dirs))
  
  ; For every directory returned
  FOR i=0, N_ELEMENTS(dirs)-1 DO BEGIN
    scan_num = STREGEX(FILE_BASENAME(dirs[i]), "[1234567890]+", /EXTRACT)

    
    ; If it is an odd-numbered scan (ie. it is a full scan)
    IF scan_num MOD 2 eq 1 THEN BEGIN
      GET_SKY_DATA, dirs[i], line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, datetime=datetime
      
      MAP_PLOT_DATA, azimuths, zeniths, dns
      
      calculated_datetimes[i] = datetime
      
      ; HERE IS WHERE THE VALUE IS SET - CHANGE AS NEEDED
      calculated_values[i] = CALCULATE_VALUE(dns, azimuths, zeniths)
    ENDIF
  ENDFOR
  
  nonzero_indices = WHERE(calculated_values)
  
  new_datetimes = calculated_datetimes[nonzero_indices]
  new_values = calculated_values[nonzero_indices]
  
  julian_datetimes = dblarr(N_ELEMENTS(new_datetimes))
    
  reads, new_datetimes, julian_datetimes, format='(C(CDI2, 1X, CMOI2, 1X, CYI4, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  datetimes = julian_datetimes
  values = new_values
END
  