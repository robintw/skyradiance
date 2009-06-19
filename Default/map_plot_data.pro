PRO MAP_PLOT_DATA, azimuths, zeniths, dns
  ; Convert azimuths to radians
  ;azimuths = azimuths*!dtor
  
  loadct, 0
  
  t3d
  
  MAP_SET, /ORTHOGRAPHIC, 90, 0, /GRID, /ISOTROPIC, title="Sky Spectra Test"
  
  range = MAX(dns) - MIN(dns)
  levels = indgen(100) * (range/100)
  
  loadct, 13
  
  contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /cell_fill
  
  ;range = MAX(dns) - MIN(dns)
  ;levels = indgen(10) * (range/10)
  
  ;contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /follow
  
  map_grid, /grid, londel=45, latdel=20, color=0
  
  ;plots, azimuths, zeniths, psym=1, color=0
  
  plots, [90], [10], psym=1, color=0  
END