PRO POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  azimuths = azimuths*!dtor
  SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)
END