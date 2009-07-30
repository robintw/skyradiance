@READ_OO_DATA

PRO GET_SPECTRAL_DG_DATA, dir_path, prefix, wavelengths=wavelengths, data=data, datetimes=datetimes
  spectra_files = FILE_SEARCH(dir_path, prefix+"*")
  
  data = dblarr(2047, N_ELEMENTS(spectra_files) / 2)
  datetimes = dblarr(N_ELEMENTS(spectra_files) / 2)
  
  print, "N_ELEMENTS = ", N_ELEMENTS(spectra_files)

  FOR i=0, N_ELEMENTS(spectra_files)-1,2 DO BEGIN
    print, "I = ", i
    diffuse_datetime = double(0)
    global_datetime = double(0)
  
    READ_OO_DATA_FILE, spectra_files[i], wavelengths=wavelengths, dns=diffuse_dns, datetime=diffuse_datetime
    READ_OO_DATA_FILE, spectra_files[i+1], wavelengths=wavelengths, dns=global_dns, datetime=global_datetime
    
    data[*, i/2] = diffuse_dns / global_dns
    datetimes[i/2] = global_datetime
  ENDFOR
  
  help, data
END

PRO SPECTRALDGREADER
  wavelength = 750

  GET_SPECTRAL_DG_DATA, "D:\UserData\Robin Wilson\spectra\actual spectra", "outside_test", wavelengths=wavelengths, data=data, datetimes=datetimes
  
  distance_away = MIN(ABS(wavelengths - wavelength), nearest_index)
  
  date_label = LABEL_DATE(DATE_FORMAT="%H:%I:%S")
  
  plot, datetimes, data[nearest_index, *], xtickformat='LABEL_DATE'
  
  help, data
END