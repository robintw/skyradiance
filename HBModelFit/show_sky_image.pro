PRO DISPLAY_IMAGE, image_path
  image = READ_IMAGE(image_path)
  
  ; Calculate aspect ratio
  result = size(image)
  aspect_ratio = float(result[3]) / float(result[2])

  ; Resize image for display (they are huge by default!)
  image = congrid(image, 3, 600, 600*aspect_ratio)
  
  ; Display image
  tv, image, /true
END

PRO SHOW_SKY_IMAGE, given_datetime, directory
  openr, lun, FILEPATH("timestamp_sky_conditions.txt", ROOT_DIR=directory), /GET_LUN
  
  datetimes = dblarr(40)
  filenames = strarr(40)
  
  i = 0
  
  line = ""
  
  WHILE (eof(lun) ne 1) DO BEGIN
    readf, lun, line, format="(a)"
    splitted = STRSPLIT(line, " ", /EXTRACT)
    
    datetime_string = STRJOIN(splitted[0:1], " ")
    filename = splitted[2]
    
    julian_datetime = double(0.0)
    
    ; Reads a date in the format 2006:06:17 10:00:35
    reads, datetime_string, julian_datetime, format='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
    
    ; Put into arrays
    datetimes[i] = julian_datetime
    filenames[i] = FILEPATH(filename, ROOT_DIR=directory)
    
    i++
  ENDWHILE
  
  ; Find closest datetime in array to the one passed in to the procedure
  
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  
;  print, "Distance away is "
;  print, distance_away
;  print, "or (converted)"
;  print, distance_away, FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
;  
;  print, filenames[nearest_index]
;  print, datetimes[nearest_index], FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
;  print, given_datetime, FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  ; Only dispay the iamge if it is less than 0.01 julian days away (around 14.4 minutes)
  IF distance_away LE 0.01 THEN DISPLAY_IMAGE, filenames[nearest_index]
END