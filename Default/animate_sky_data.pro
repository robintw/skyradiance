PRO ANIMATE_SKY_DATA
  FOR i=1, 2027 DO PolarPlotData, i
  
  
  ; --- Old xinteranimate code, doesn't work with large numbers of images ---
  ; 
  ;xinteranimate, set=[1000, 1000, 2027], /showload
  
  ;for i=1, 50 DO BEGIN
    ;PolarPlotData, i
    ;xinteranimate, frame=i, win=0
  ;endfor
  
  ;xinteranimate
END