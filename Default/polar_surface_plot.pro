; Plots the given azimuths, zeniths and dns (provided in an irregularly gridded format
; (ie. dns is one dimensional) in a polar surface plot.
PRO POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ; Convert the azimuths to radians
  azimuths = azimuths*!dtor
  
  ; Plot the data as a surface  
  SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)
END