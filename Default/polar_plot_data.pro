PRO Polar_Plot_Data, azimuths, zeniths, dns
  ; Convert azimuths to radians
  azimuths = azimuths*!dtor
  
  ; Label all the contour levels
  c_labels = replicate(1, 15)
  
  ;levels = [MIN(dns), 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]
  
  ; Generate 15 equally spaced levels to contour
  range = MAX(dns) - MIN(dns)
  levels = indgen(15) * (range/15)
  
  ; Order of z, theta, r
  ;POLAR_CONTOUR, dns, zeniths, azimuths, levels=levels, c_labels=c_labels, /IRREGULAR
  
  ;bottom = 16
  ;loadct, 13, bottom=bottom
  ;shades = bytscl(dns, top=!d.table_size -1 - bottom) + byte(bottom)
  
  ;LoadCT, 4, NColors=100, Bottom=100
  ;SET_SHADING, Values=[100,199]
  
  SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)
  ;ncolors = N_ELEMENTS(levels) + 1
  ;bottom = 1
  ;c_colors = indgen(ncolors) + bottom
  ;loadct, 33, ncolors=ncolors, bottom=bottom 
  
  ;device, decomposed=0
  ;loadct, 0
  
  ;axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9, /save
  ;axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9, /save
  
  ;POLAR_CONTOUR, reverse(dns), azimuths, zeniths, $
    ;levels=levels, c_labels=c_labels, $
    ;ystyle=4, xstyle=4, $
    ;/IRREGULAR, /FILL, /ISOTROPIC, /OVERPLOT
  
  ;axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9
  ;axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9
  
  
  ; Will plot all the points (no z values) on a polar plot
  ;plot, zeniths, azimuths, /polar, PSYM=1, /ISOTROPIC, xstyle=4, ystyle=4
  
  close, /all
END