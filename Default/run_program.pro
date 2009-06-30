@Polar_Plot_Data
@Get_Sky_Data
@Map_Plot_Data
@Polar_Surface_Plot

PRO RUN_PROGRAM
  ; Get the sky data from the text files into a usable form
  GET_SKY_DATA, "D:\UserData\Robin Wilson\AlteredData\ncaveo\17-June\scan1_high", 268, azimuths=azimuths, zeniths=zeniths, dns=dns, datetime=datetime
  
  ; --- Visualisation routines are below: uncomment the appropriate one ---
  
  ;Polar_Plot_Data, azimuths, zeniths, dns
  
  MAP_PLOT_DATA, azimuths, zeniths, dns, "Sky Radiance Distribution: scan3_high, 440nm"
  
  ;POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  
  ;ANIMATE_SKY_DATA, azimuths, zeniths, dns
  
  values = fltarr(12)
  
  i=0
  
  for angle=0, 330, 30 DO BEGIN
    indexes = WHERE(azimuths eq angle)
    value = max(dns[indexes])
    values[i] = value
    i++
  ENDFOR
  
  print, values
  help, values
  print, max(values)
  
  
END