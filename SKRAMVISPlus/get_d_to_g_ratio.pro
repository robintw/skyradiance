@GET_SUNSHINE_DATA

FUNCTION GET_D_TO_G_RATIO, given_datetime, sunshine_file
  GET_SUNSHINE_DATA, sunshine_file, datetimes=datetimes, ratio=ratio
  
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  
  print, "Getting D:G ratio"
  
  print, "Given datetime is"
  print, given_datetime, FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  print, "Found datetime is"
  print, datetimes[nearest_index], FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  print, "Distance away = "
  print, distance_away
  
  print, "D:G ratio = "
  print, ratio[nearest_index]
  
  ;IF distance_away le 0.01 THEN return, string(ratio[nearest_index]) ELSE return, "NO MEASUREMENTS"
  return, STRTRIM(string(ratio[nearest_index]))
END