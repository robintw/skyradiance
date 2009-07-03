

PRO GET_SUNSHINE_DATA, filename, datetimes=datetimes, ratio=ratio
  RESTORE, "Sunshine_Data_Template.sav"
  
  data = READ_ASCII(filename, TEMPLATE=Sunshine_Data_Template)
  
  datetime_string = data.date + " " + data.time
  
  times = dblarr(N_ELEMENTS(data.date))
  
  reads, datetime_string, times, format='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  ratio = dblarr(N_ELEMENTS(data.global))
  
  ratio = data.diffuse / float(data.global)
  
  print, data.global
  print, data.diffuse
  
  print, "Diffuse[250] = "
  print, data.diffuse[250]
  
  print, "Global[250] = "
  print, data.global[250]
  
  print, "Ratio[250] = "
  print, ratio[250]
  
  datetimes = times
  
  
  ;date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  ;plot, times, ratio, /nodata, ystyle=4, xtickformat='LABEL_DATE'
  
  ;axis, yaxis=0, yrange=[0, 5], /save
  
  ;oplot, times, ratio
  
  ;GET_TIME_SERIES, datetimes=datetimes, values=values
 
  ;print, datetimes
 
  ;axis, yaxis=1, yrange=[3000,5000], /save
  ;oplot, datetimes, values, psym=1
END