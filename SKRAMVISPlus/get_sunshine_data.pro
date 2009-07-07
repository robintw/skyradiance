@READ_NEODC_AMES_FILE

PRO GET_SUNSHINE_DATA, filename, datetimes=datetimes, ratio=ratio
  READ_NEODC_AMES_FILE, filename, header=header, indep=indep, primary=primary
  
  datetimes = indep.values
  
  ratio = primary.values[*, 1] / primary.values[*, 0]
END