@READ_DELTA_T_FILE

PRO READ_WEATHER_DATA
  READ_DELTA_T_FILE, "D:\UserData\Robin Wilson\Delta-T\WStation.dat", " 2009", " 2009", header=header, ch_header=ch_header, datetimes=datetimes, data=data
  
  print, datetimes, format="(C())"
  
  date_label = LABEL_DATE(DATE_FORMAT="%D/%N %H:%I")
  
  plot, datetimes, data[*, 3], xtickformat='label_date'
END
