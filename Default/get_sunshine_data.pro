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
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  ;plot, times, ratio, /nodata, ystyle=4, xtickformat='LABEL_DATE'
  
  ;axis, yaxis=0, yrange=[0, 5], /save
  
  ;oplot, times, ratio
  
  ;GET_TIME_SERIES, datetimes=datetimes, values=values
 
  ;print, datetimes
 
  ;axis, yaxis=1, yrange=[3000,5000], /save
  ;oplot, datetimes, values, psym=1
END