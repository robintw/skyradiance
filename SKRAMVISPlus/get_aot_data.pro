FUNCTION GET_AOT_DATA, filename, given_wavelength, given_datetime
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary
    
  datetimes = indep.values

  
  wavelengths = [440, 675, 870, 936, 1020]
  
  ; Find closest wavelength
  distance_away = MIN(ABS(wavelengths - given_wavelength), nearest_index)
  
  array_index = 20 + nearest_index
  
  AOTs = primary.values[*, array_index]
  
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  
  return, AOTs[nearest_index]
END