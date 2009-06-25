@COLORBAR

PRO MAP_PLOT_DATA, azimuths, zeniths, dns, title
  draw_position = [.10, .07, .80, .90]
  cbar_position = [.85, .07, .88, .90]
  
  ; Set the map projection to orthographic, looking down from the north pole
  ; The REVERSE=1 and the third numeric parameter (180) ensure that N, E, S and W are at the appropriate locations
  MAP_SET, /ORTHOGRAPHIC, 90, 0, 180, REVERSE=1, /ISOTROPIC, title=title, position=draw_position, color=1
  
  
  device, decomposed=0
  loadct, 13
  TVLCT, 0, 0, 0, 1        ; Drawing colour
  TVLCT, 255, 255, 255, 0                 ; Background colour
  
  ; Calculate 100 levels for the contouring
  range = MAX(dns) - MIN(dns)
  levels = indgen(100) * (range/100)
  
  ; Plot the contours from the irregular data
  contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /cell_fill, position=draw_position, color=1
  
  ; Plot the contour lines over it as a 
  
  ;range = MAX(dns) - MIN(dns)
  ;levels = indgen(10) * (range/10)
  
  ;contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /follow
  
  ; Plot the grid over the top of the data
  map_grid, /grid, londel=45, latdel=20, color=1, position=draw_position
  
  ; Plot the individual points at which the data was collected
  ;plots, azimuths, zeniths, psym=1, color=0
  
  ; Plot points at certain locations for testing purposes
  plots, [0], [10], psym=1, color=0
  plots, [90], [10], psym=4, color=0  
  
  colorbar, /vertical, /right, range=[min(dns), max(dns)], position=cbar_position, title="Digital Number", color=1
END