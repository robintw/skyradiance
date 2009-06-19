@Polar_Plot_Data

PRO ANIMATE_SKY_DATA, azimuths, zeniths, dns
  FOR i=1, 2027 DO Polar_Surface_Plot, azimuths, zeniths, dns
  
  
  ; --- Old xinteranimate code, doesn't work with large numbers of images ---
  ; 
  ;xinteranimate, set=[1000, 1000, 2027], /showload
  
  ;for i=1, 50 DO BEGIN
    ;PolarPlotData, i
    ;xinteranimate, frame=i, win=0
  ;endfor
  
  ;xinteranimate
END