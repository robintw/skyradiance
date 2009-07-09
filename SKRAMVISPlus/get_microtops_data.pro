@READ_NEODC_AMES_FILE

; This function reads in the AOT data from a Microtops file in NEODC Ames format given
; a filename, wavelength and datetime
FUNCTION GET_MICROTOPS_DATA, filename, given_wavelength, given_datetime
  ; Read the NEODC Ames file
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary
    
  ; Extract the datetimes (the independent variable)
  datetimes = indep.values
  
  ; Find closest wavelength
  wavelengths = [440, 675, 870, 936, 1020]
  distance_away = MIN(ABS(wavelengths - given_wavelength), nearest_index)
  
  ; The wavelengths start at variable 20, so add the index from the array to 20 to find the right index
  array_index = 20 + nearest_index
  
  ; Get the AOTs out of the right variable
  AOTs = primary.values[*, array_index]
  
  ; Choose the nearest AOT value to the datetime which has been given and return it
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  return, AOTs[nearest_index]
END