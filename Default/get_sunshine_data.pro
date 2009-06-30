PRO GET_D_TO_G_RATIO, given_datetime
  GET_SUNSHINE_DATA, datetimes=datetimes, ratio=ratio
  
  distance_away = MIN(ABS(datetimes - given_datetime), nearest_index)
  
  print, "D:G ratio is " + string(ratio[nearest_index])
END

PRO GET_SUNSHINE_DATA, datetimes=datetimes, ratio=ratio
  RESTORE, "D:\UserData\Robin Wilson\SVNCheckout\Default\SunshineDataTemplate.sav"
  
  data = READ_ASCII("D:\UserData\Robin Wilson\Sunshine Sensor\AlteredData.txt", TEMPLATE=plottemplate)
  
  times = dblarr(N_ELEMENTS(data.time))
  
  full_dates = data.date + " " + data.time
   
  reads, full_dates, times, format='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2))'
  
  
  ratio = dblarr(N_ELEMENTS(data.global))
  
  ratio = data.diffuse / float(data.global)
  datetimes = times
  
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  ;plot, times, ratio, /nodata, ystyle=4, xtickformat='LABEL_DATE'
  
  ;axis, yaxis=0, yrange=[0, 5], /save
  
  ;oplot, times, ratio
  
  ;GET_TIME_SERIES, datetimes=datetimes, values=values
 
  ;print, datetimes
 
  ;axis, yaxis=1, yrange=[3000,5000], /save
  ;oplot, datetimes, values, psym=1
END