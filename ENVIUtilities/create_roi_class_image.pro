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

PRO CREATE_ROI_CLASS_IMAGE
  percentage = 0.2

  ; Use the ENVI dialog box to select a file
  ENVI_SELECT, fid=fid,dims=dims,pos=pos
  
  ; If the dialog box was cancelled then stop the procedure
  IF fid[0] EQ -1 THEN RETURN
  
  roi_ids=lonarr(n_elements(pos))
  
  print, pos
  
  FOR i=0, N_ELEMENTS(pos)-1 DO BEGIN
    name = "Band " + STRCOMPRESS(STRING(i)) + " " + STRCOMPRESS(STRING(percentage, FORMAT="(f5.3)")) + "%"
  
    roi_id = ROI_PERCENTILE_THRESHOLD(percentage, name, 2+i, fid=fid, dims=dims, pos=pos[i])
    roi_ids[i] = roi_id
  ENDFOR
END