PRO GET_SUNSHINE_DATA
  RESTORE, "D:\UserData\Robin Wilson\SVNCheckout\Default\SunshineDataTemplate.sav"
  
  data = READ_ASCII("D:\UserData\Robin Wilson\Sunshine Sensor\AlteredData.txt", TEMPLATE=plottemplate)
  
  times = dblarr(N_ELEMENTS(data.time))
  
  full_dates = data.date + " " + data.time
  
  print, full_dates
  
  reads, full_dates, times, format='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2))'
  
  help, times
  
  ratio = dblarr(N_ELEMENTS(data.global))
  
  ratio = data.global / float(data.diffuse)
  
  plot, times, ratio
END