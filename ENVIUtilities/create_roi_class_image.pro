FUNCTION ROI_PERCENTILE_THRESHOLD, percentage, name, color, fid=fid, dims=dims, pos=pos, bottom=bottom
  image_data = ENVI_GET_DATA(fid=fid, dims=dims, pos=pos)
  
  if KEYWORD_SET(bottom) THEN sorted_image_indices = SORT(image_data) ELSE sorted_image_indices = REVERSE(SORT(image_data)) 
    
  len = N_ELEMENTS(image_data)
  
  threshold =  image_data[sorted_image_indices[percentage/100 * len]]
  
  print, threshold
  
  ENVI_DOIT, 'ROI_THRESH_DOIT', dims=dims, fid=fid, pos=pos, max_thresh=1, $
    min_thresh=threshold, ROI_ID=roi_id, ROI_NAME=name, ROI_COLOR=color, /NO_QUERY
    
  return, roi_id 
END