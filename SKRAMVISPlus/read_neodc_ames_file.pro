PRO READ_NEODC_AMES_FILE, filename, header=out_header, indep=out_indep, primary=out_primary
  openr, lun, filename, /GET_LUN
   
  ;; READ HEADER SECTION 
  
  nlhead = 0
  ffi = 0
  oname = ""
  org = ""
  sname = ""
  mname = "" 
  ivol = 0
  nvol = 0
  date = 0.0
  rdate = 0.0
  
  readf, lun, nlhead, ffi
  readf, lun, oname
  readf, lun, org
  readf, lun, sname
  readf, lun, mname
  readf, lun, ivol, nvol
  
  readf, lun, date, rdate, format='(C(CYI4, 1X, CMOI2, 1X, CDI2), C(1X, CYI4, 1X, CMOI2, 1X, CDI2))'
  
  header = {nlhead:nlhead,$
            ffi:ffi,$
            oname:oname,$
            org:org,$
            sname:sname,$
            mname:mname,$
            ivol:ivol,$
            nvol:nvol,$
            date:date,$
            rdate:rdate}
  

  
  ;; READ INDEP VARIABLE INFO SECTION
  dx = 0.0
  name = ""
  
  readf, lun, dx
  readf, lun, name
  
  indep = {dx:dx,$
           name:name}
  
  ;; READ PRIMARY VARIABLES INFO SECTION
  nv = 0
  
  readf, lun, nv
  
  vscal = fltarr(nv)
  readf, lun, vscal
  
  vmiss = fltarr(nv)
  readf, lun, vmiss
  
  vname = strarr(nv)
  readf, lun, vname
  
  primary = {nv:nv,$
             vscal:vscal,$
             vmiss:vmiss,$
             vname:vname}
             
  ;; READ SPECIAL AND NORMAL COMMENT LINES
  nscoml = 0
  readf, lun, nscoml
  
  special_comment_lines = strarr(nscoml)
  readf, lun, special_comment_lines
  
  ; Join the array to produce a single string with newlines in the right places
  special_comments = STRJOIN(special_comment_lines, String(13B))
  
  nncoml = 0
  readf, lun, nncoml
  
  normal_comment_lines = strarr(nncoml)
  readf, lun, normal_comment_lines
  
  normal_comments = STRJOIN(normal_comment_lines, String(13B))
  
  ; Add the comment fields into the header structure
  header = create_struct(header, 'scom', special_comments, 'ncom', normal_comments)
  
  ;; READ THE ACTUAL DATA
  
  read_array = fltarr(nv)
  
  x = double(0.0)
  
  indep_var = dblarr(1000)
  dep_var = fltarr(1000, nv)
  
  i = 0
  
  WHILE NOT EOF(lun) DO BEGIN
    ; Read the whole line into a string
    line_string = ""
    readf, lun, line_string
    
    ; Get the date out of it and read that into a float
    date_string = strmid(line_string, 0, 20)
    reads, date_string, x, format="(C(CYI4, 1X, CMOI2, 1X, CDI2, 2X, CHI2, 1X, CMI2, 1X, CSI2))"
    
    rest_of_line = strmid(line_string, 21)
    reads, rest_of_line, read_array
    
    ; Put values into array
    indep_var[i] = x
    dep_var[i, *] = read_array
    
    i++
  ENDWHILE
  
  indep_var = indep_var[0:i-1]
  dep_var = dep_var[0:i-1, *]

  ; Add the data into the structures created above
  indep = create_struct(indep, 'values', indep_var)
  primary = create_struct(primary, 'values', dep_var)
  
  out_header = header
  out_indep = indep
  out_primary = primary
END