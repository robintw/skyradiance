@GET_SUNSHINE_DATA

FUNCTION GET_D_TO_G_RATIO, given_datetime, sunshine_file
  catch, error_status
  if error_status ne 0 then begin
    ;help, /LAST_MESSAGE, output=errtext
    result = ERROR_MESSAGE()
    return, 0
  endif

  ; Get the data from the sunshine data file
  GET_SUNSHINE_DATA, sunshine_file, datetimes=datetimes, ratio=ratio, error=error
  
  ; Return a D:G of 0 if the NEODC Ames file reading routine produced an error
  if error ne 0 then return, 0
  
  ; Find the closest D:G ratio to the given datetime and return it
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  return, ratio[nearest_index]
END