PRO Polar_Plot_Data, azimuths, zeniths, dns
  ; Convert azimuths to radians
  azimuths = azimuths*!dtor
  
  ; Label all the contour levels
  c_labels = replicate(1, 15)
  
  ; Generate 15 equally spaced levels to contour
  range = MAX(dns) - MIN(dns)
  levels = indgen(100) * (range/100)
  
  device, decomposed=0
  loadct, 0
  
  ; Create the axes to set the appropriate scaling
  axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9, /save
  axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9, /save
  
  ; Plot the contour data
  POLAR_CONTOUR, reverse(dns), azimuths, zeniths, $
    levels=levels, c_labels=c_labels, $
    ystyle=4, xstyle=4, $
    /IRREGULAR, /FILL, /ISOTROPIC, /OVERPLOT
  
  ; Draw the axis over the data (they get overplotted by the data)
  axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9
  axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9
  
  
  ; Will plot all the points (no z values) on a polar plot
  ;plot, zeniths, azimuths, /polar, PSYM=1, /ISOTROPIC, xstyle=4, ystyle=4
  
  close, /all
END