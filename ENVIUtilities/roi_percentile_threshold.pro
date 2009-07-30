FUNCTION ROI_PERCENTILE_THRESHOLD, percentage, name, fid=fid, dims=dims, pos=pos, bottom=bottom
  image_data = ENVI_GET_DATA(fid=fid, dims=dims, pos=pos)
  
  if KEYWORD_SET(bottom) THEN sorted_image_indices = REVERSE(SORT(image_data)) else orted_image_indices = SORT(image_data)
    
  len = N_ELEMENTS(image_data)
  
  threshold =  image_data[sorted_image_indices[percentage/100 * len]]
  
  print, threshold
  
  ENVI_DOIT, 'ROI_THRESH_DOIT', dims=dims, fid=fid, pos=pos[i], max_thresh=1, $
    min_thresh=threshold, ROI_ID=roi_id, ROI_NAME=name, ROI_COLOR=1+i, /NO_QUERY
    
  return, roi_id 
END

PRO CREATE_ROI_CLASS_IMAGE
  ; Use the ENVI dialog box to select a file
  ENVI_SELECT, fid=fid,dims=dims,pos=pos
  
  ; If the dialog box was cancelled then stop the procedure
  IF fid[0] EQ -1 THEN RETUR
  
  roi_ids=lonarr(n_elements(pos)-1)
  
  print, pos
  
  FOR i=0, N_ELEMENTS(pos)-1 DO BEGIN
    roi_id = ROI_PERCENTILE_THRESHOLD(percentage, name, fid=fid, dims=dims, pos=pos[i])
    roi_ids[i] = roi_id
  ENDFOR
  
  ENVI_DOIT, 'ENVI_ROI_TO_IMAGE_DOIT', class_values=replicate(long(1), N_ELEMENTS(pos)-1), FID=fid, ROI_IDS=roi_ids, /IN_MEMORY
END