@READ_NEODC_AMES_FILE

; This reads the data from the Sunshine Sensor datafile, and is called by GET_D_TO_G_RATIO
PRO GET_SUNSHINE_DATA, filename, datetimes=datetimes, ratio=ratio, error=returned_error
  ; Read the NEODC Ames file
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary, error=error
  
  returned_error = error
  
  ; Check the error code returned and if it's non-zero then return an AOT of 0
  if error ne 0 then begin
    return
  endif
  
  ; Get the datetimes from the independent variable
  datetimes = indep.values
  
  ; Calculate the ratio of diffuse to global
  ratio = primary.values[*, 1] / primary.values[*, 0]
END