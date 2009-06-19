PRO MAP_PLOT_DATA, azimuths, zeniths, dns
  loadct, 0
  
  ; Set the map projection to orthographic, looking down from the north pole
  MAP_SET, /ORTHOGRAPHIC, 90, 0, /GRID, /ISOTROPIC, title="Sky Spectra Test"
  
  ; Calculate 100 levels for the contouring
  range = MAX(dns) - MIN(dns)
  levels = indgen(100) * (range/100)
  
  loadct, 13
  
  ; Plot the contours from the irregular data
  contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /cell_fill
  
  ; Plot the contour lines over it as a 
  
  ;range = MAX(dns) - MIN(dns)
  ;levels = indgen(10) * (range/10)
  
  ;contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /follow
  
  ; Plot the grid over the top of the data
  map_grid, /grid, londel=45, latdel=20, color=0
  
  ; Plot the individual points at which the data was collected
  ;plots, azimuths, zeniths, psym=1, color=0
  
  ; Plot points at certain locations for testing purposes
  ;plots, [90], [10], psym=1, color=0  
END