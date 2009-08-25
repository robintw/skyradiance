PRO TEST_READ_MOBILE_TRAMWAY_DATA
  READ_MOBILE_TRAMWAY_DATA, "D:\UserData\Robin Wilson\Tramway\Data\CFARR09-19-08_removed night.dat", 0, 4, /CALIBRATE, data=data, datetimes=datetimes

  date_label = LABEL_DATE(DATE_FORMAT="%H:%I")
  
  plot, datetimes, data, xtickformat='label_date', yrange=[0,0.2]
  
  READ_MOBILE_TRAMWAY_DATA, "D:\UserData\Robin Wilson\Tramway\Data\CFARR09-19-08_removed night.dat", 0, 3, /CALIBRATE,  data=data_new, datetimes=datetimes_new
  
  oplot, datetimes_new, data_new
  
  print, VARIANCE(data)
END