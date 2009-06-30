PRO Simple_Soil_Model, solar_azimuth, a, b, c

; Initialise arrays
azimuths = indgen(360)
zeniths = indgen(90)
values = fltarr(360, 90)

  FOR view_azimuth=0, 360-1 DO BEGIN
    FOR view_zenith=0, 90-1 DO BEGIN

      value = (a * view_zenith^2) + (b * view_zenith * cos(view_azimuth - solar_azimuth)) + c
      
      values[view_azimuth, view_zenith] = value
    ENDFOR
  ENDFOR
  
  print, values
  
  ;new_values = values + min(values)
  polar_contour, values, azimuths, zeniths, c_labels=[1, 1, 1, 1, 1, 1]
  SURFACE, POLAR_SURFACE(transpose(values), zeniths, azimuths, /grid)
END