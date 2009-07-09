@GET_SUNSHINE_DATA

FUNCTION GET_D_TO_G_RATIO, given_datetime, sunshine_file
  ; Get the data from the sunshine data file
  GET_SUNSHINE_DATA, sunshine_file, datetimes=datetimes, ratio=ratio
  
  ; Find the closest D:G ratio to the given datetime and return it
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  return, ratio[nearest_index]
END