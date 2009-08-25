PRO READ_MOBILE_TRAMWAY_DATA, filename, band, station, data=out_data, datetimes=out_datetimes, calibrate=calibrate

  READ_DELTA_T_FILE, filename, " 2009", header=header, ch_header=ch_header, datetimes=datetimes, data=data
  
  result = size(data)
  
  n_readings = result[1]
  
  indices = intarr(n_readings)

  
  station_indices = [1, 2, 3, 4, 3, 2, 1]
  
  stations = reform(rebin(station_indices, 7, n_readings), n_readings*7)

  indices = WHERE(stations EQ station)
  
  ; Calibrate the data if asked to do so
  IF KEYWORD_SET(calibrate) THEN BEGIN
    FOR i=0, n_readings DO BEGIN
      ; If we're dealing with station 4 then the interpolated reference value
      ; is half-way between the two measured reference values
      IF stations[i] EQ 4 THEN BEGIN
        first_ref = data[i-2, band]
        last_ref = data[i+2, band]
        
        difference = last_ref - first_ref
        
        interpolated_ref = first_ref + (difference / 2)
        
        data[i, band] = data[i, band] / interpolated_ref
      ENDIF
      
      ; It's more complicated if we're dealing with station 3, as there
      ; are two of them. So we first check which one we are, and then do
      ; the right calculations
      IF stations[i] EQ 3 THEN BEGIN
        ; If the station before this one is 2 then it's the outward-bound
        ; measurement of station 3.
        IF stations[i-1] EQ 2 THEN BEGIN
            first_ref = data[i-1, band]
            last_ref = data[i+3, band]
            
            difference = last_ref - first_ref
            
            step = difference / 4
            
            interpolated_ref = first_ref + step
            
            data[i, band] = data[i, band] / interpolated_ref
        ENDIF ELSE BEGIN
            first_ref = data[i-3, band]
            last_ref = data[i+1, band]
            
            difference = last_ref - first_ref
            
            step = difference / 4
            
            interpolated_ref = first_ref + (3 * step)
            
            data[i, band] = data[i, band] / interpolated_ref
        ENDELSE
      ENDIF
    ENDFOR
  ENDIF
  
  out_data = data[indices, band]
  out_datetimes = datetimes[indices] 
END