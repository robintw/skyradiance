; Plots the given azimuths, zeniths and dns (provided in an irregularly gridded format
; (ie. dns is one dimensional) in a polar surface plot.
PRO POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ; Convert the azimuths to radians
  azimuths = azimuths*!dtor
  
  ; Load colours into colortable
  device, decomposed=0
  loadct, 13
  TVLCT, 0, 0, 0, 1        ; Drawing colour
  TVLCT, 255, 255, 255, 0                 ; Background colour
  
  ; Plot the data as a surface  
  SURFACE, POLAR_SURFACE(dns, zeniths, azimuths), color=1
END