;+
; NAME:
; MAP_PLOT_DATA 
;
; PURPOSE:
; This function produces a contour plot of the data passed to it, using the
; map plotting functions in IDL (hence the name). The resulting plot contains
; the contour plot itself, a colour bar on the right hand side, and a title.
; 
; CALLING SEQUENCE:
;
; MAP_PLOT_DATA, Azimuths, Zeniths, DNs, Title
;
; INPUTS:
; Azimuths: A 1D array containing the azimuths of all the data to be plotted.
; 
; Zeniths: A 1D array containing the zeniths of all the data to be plotted.
;
; DNs: A 1D array containing the digital number to plot (ie. the z value for
;      the contour plot) for each of the azimuths and zeniths passed in the previous
;      array. That is, the value of DNs[i] is the DN for azimuth[i] and zenith[i].
;
; Title: A string containing the title to be displayed over the plot.
;
;-
PRO MAP_PLOT_DATA, azimuths, zeniths, dns, title
  ; Set positions for drawing the plot and the colourbar
  draw_position = [.10, .07, .80, .90]
  cbar_position = [.85, .07, .88, .90]
  
  ; Load rainbow colortable in from colors 1-100
  LoadCT, 13, NCOLORS=100, BOTTOM=1
  
  ; Load in black at index 253 and white at index 254
  TVLCT, 0, 0, 0, 253       ; black 
  TVLCT, 255, 255, 255, 254 ; white 
  
  ; Set the map projection to orthographic, looking down from the north pole
  ; The REVERSE=1 and the third numeric parameter (180) ensure that N, E, S and W are at the appropriate locations
  MAP_SET, /ORTHOGRAPHIC, 90, 0, 180, REVERSE=1, /ISOTROPIC, title=title, position=draw_position, color=253
  
  ; Calculate 100 levels for the contouring
  range = MAX(dns) - MIN(dns)
  levels = indgen(100) * (range/100)
  
  ; Plot the contours from the irregular data
  contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /cell_fill, position=draw_position, color=253, c_colors=INDGEN(100)+1
  
  ; The commented lines below can be uncommented if you want contour lines plotted over the top of the colored
  ; contours.
  ;range = MAX(dns) - MIN(dns)
  ;levels = indgen(10) * (range/10)
  ;contour, dns, azimuths, zeniths, /irregular, /overplot, levels=levels, /follow
  
  ; Plot the grid over the top of the data
  map_grid, /grid, londel=45, latdel=20, color=253, position=draw_position
  
  ; The lines of code below are used to plot points at certain locations for testing purposes
  ; to check the rotation of the plot. They have been left here in case they are needed again.
  ;plots, [0], [10], psym=1, color=0
  ;plots, [90], [10], psym=4, color=0  
  
  colorbar, /vertical, /right, range=[min(dns), max(dns)], position=cbar_position, title="Digital Number", color=253, ncolors=100, bottom=1
END