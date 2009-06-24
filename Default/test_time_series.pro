PRO Test_Time_Series
  GET_TIME_SERIES, datetimes=datetimes, values=values
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  plot, datetimes, values, psym=1, xtickformat='LABEL_DATE'
END