PRO Test_Simple_Soil_Model
  solar_azimuth = 45

  ; Constants for Rough Soil
  a = 5.05
  b = 8.86
  c = 8.43
  
  ;FOR c=6, 13 DO BEGIN
  Simple_Soil_Model, solar_azimuth, a, b, c
  ;ENDFOR
END