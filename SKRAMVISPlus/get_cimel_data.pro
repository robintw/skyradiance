@READ_NEODC_AMES_FILE

; This function reads in the AOT data from a Cimel file in NEODC Ames format given
; a filename, wavelength and datetime
FUNCTION GET_CIMEL_DATA, filename, given_wavelength, given_datetime
  ; Read the NEODC Ames file
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary, error=error
  
  ; Check the error code returned and if it's non-zero then return an AOT of 0
  if error ne 0 then return, 0
  
  ; Extract the datetimes from the independent variables
  datetimes = indep.values
  
  ; Find closest wavelength
  wavelengths = [1020, 870, 675, 500, 440, 380, 340]
  distance_away = MIN(ABS(wavelengths - given_wavelength), nearest_index)
  
  ; Get the AOT data out of the right variable (the AOT data starts from the first variable)
  array_index = nearest_index 
  AOTs = primary.values[*, array_index]
  
  ; Find the closest AOT value to the datetime which was given, and return it
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  return, AOTs[nearest_index]
END