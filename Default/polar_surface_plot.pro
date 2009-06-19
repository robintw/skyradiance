PRO POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ; Convert the azimuths to radians
  azimuths = azimuths*!dtor
  
  ; Plot the data as a surface
  SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)
END