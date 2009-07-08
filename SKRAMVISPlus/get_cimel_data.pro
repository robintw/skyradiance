FUNCTION GET_CIMEL_DATA, filename, given_wavelength, given_datetime
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary
  
  datetimes = indep.values
  
  wavelengths = [1020, 870, 675, 500, 440, 380, 340]
  
  ; Find closest wavelength
  distance_away = MIN(ABS(wavelengths - given_wavelength), nearest_index)
  
  array_index = nearest_index
  
  AOTs = primary.values[*, array_index]
  
  print, AOTs
  
  print, "IN CIMEL ROUTINE"
  print, "Given Datetime = "
  print, given_datetime, format="(C())"
 
  
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  
  print, "Found Datetime = "
  print, datetimes[nearest_index], format="(C())"
  
  return, AOTs[nearest_index]
END