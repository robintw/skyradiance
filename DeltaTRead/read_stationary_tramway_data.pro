PRO READ_STATIONARY_TRAMWAY_DATA
  READ_DELTA_T_FILE, "D:\UserData\Robin Wilson\OutsideDTSunshine.dat", " 2009", header=header, ch_header=ch_header, datetimes=datetimes, data=data
  
  print, datetimes, format="(C())"
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I")
  
  DtoG = data[*, 1] / data[*, 0]
  
  plot, datetimes, dtog, xtickformat='label_date'
END