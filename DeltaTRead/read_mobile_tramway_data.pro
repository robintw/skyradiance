PRO READ_MOBILE_TRAMWAY_DATA
  READ_DELTA_T_FILE, "D:\UserData\Robin Wilson\Tramway\Data\CFARR09-19-08_removed night.dat", " 2009", header=header, ch_header=ch_header, datetimes=datetimes, data=data
  
  result = size(data)
  
  n_readings = result[1]
  
  indices = intarr(n_readings)

  
  station_indices = [1, 2, 3, 4, 3, 2, 1]
  
  stations = reform(rebin(station_indices, 7, n_readings), n_readings*7)
  
  
  
 
  
  indices = WHERE(stations EQ 3)
  
  ref_indices = WHERE(stations EQ 2)
  
  FOR i=0,N_ELEMENTS(ref_indices)-1,2 DO BEGIN
    first_ref_value = ref_indices[i]
    last_ref_value = ref_indices[i+1]
    
    difference = first_ref_value - last_ref_value
    
    step = float(difference) / 4
    
    real_ref_value = first_ref_value + (2 * step)
    
    real_ref_values[i]
  END
  
  to_plot = data[indices, 0] / data[ref_indices, 0]
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I")
  
  plot, datetimes[indices], to_plot, xtickformat='label_date'
END