@PolarPlotData
@Get_Sky_Data

PRO RUN_PROGRAM
  ;Normal FOR loop
  ;FOR i=1, 2027 DO PolarPlotData, i
  
  GET_SKY_DATA, 216, azimuths=azimuths, zeniths=zeniths, dns=dns
  
  PolarPlotData, azimuths, zeniths, dns
  
  ;xinteranimate, set=[1000, 1000, 2027], /showload
  
  ;for i=1, 50 DO BEGIN
    ;PolarPlotData, i
    ;xinteranimate, frame=i, win=0
  ;endfor
  
  ;xinteranimate
    
END