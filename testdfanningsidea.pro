FUNCTION READ_NUMBERED_LINE, filename, line_number
  openr, lun, filename, /GET_LUN
  
  FOR i=0, line_number DO BEGIN
    readf, lun, line, format="(a)"
  ENDFOR
  
  FREE_LUN, lun
  
  return, line
END

PRO TestDFanningsIdea
; Get a list of all the angle.txt files under the specified directory
angle_files = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June\scan1_high", "angles.txt")

line = ""

; This line number will depend on the wavelength you want to look at
line_number = 1000

azimuths = intarr(N_ELEMENTS(angle_files)*11)
dns = fltarr(N_ELEMENTS(angle_files)*11)
zeniths = fltarr(N_ELEMENTS(angle_files)*11)

; For each angle.txt file
FOR i=0, N_ELEMENTS(angle_files)-1 DO BEGIN
  ; Open the angle.txt file
  openr, lun, angle_files[i], /GET_LUN
  
  
  ; Store the azimuth from the folder name
  folders_string = FILE_DIRNAME(angle_files[i])
  azimuth = FILE_BASENAME(folders_string)
  
  j = 0
  
  ; While not end of file read the lines from the file
  WHILE (eof(lun) ne 1) DO BEGIN
    readf, lun, line, format="(a)"
    splitted = STRSPLIT(line, ";", /EXTRACT)
    
    ; Get's a string of the entire line of the filename at the line number given
    line_string = READ_NUMBERED_LINE(splitted[0], line_number)
    
    ; Reads the value in from that string into the float variable dn
    reads, line_string, dn, format="(f)"
    
    ; Calculate which index in the array to put it in
    array_index = (11*i) + j
    
    ; Insert the values into the arrays
    
    zenith = FLOAT(splitted[2])
    
    IF zenith GT 90 THEN real_azimuth = azimuth + 180 ELSE real_azimuth = azimuth
    
    azimuths[array_index] = real_azimuth
    dns[array_index] = dn
    zeniths[array_index] = zenith
    
    j = j + 1
  ENDWHILE
ENDFOR

print, "Done playing with files"

; ------------------- New Bit ----------------------

TRIANGULATE, azimuths, zeniths, triangles, boundary_points

grid_data = TriGrid(azimuths, zeniths, dns, triangles, XGRID=xvector, YGRID=yvector)

;Surface, grid_data, xvector, yvector

;c_labels = [1, 1, 1, 1, 1, 1, 1, 1, 1]

;map_set, 0, 0, /orthographic, /isotropic, /horizon


;contour, dns, azimuths, zeniths, nlevels=10, c_labels=c_labels, /overplot, /irregular


POLAR_CONTOUR, grid_data, yvector, xvector, c_labels=c_labels, nlevels=10

; ------------------- Old Bit ----------------------





;c_labels = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

;levels = [0, 100, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]

; Order of z, theta, r
;POLAR_CONTOUR, dns, zeniths, azimuths, /fill, levels=levels, c_labels=c_labels, /IRREGULAR

;bottom = 16
;loadct, 13, bottom=bottom
;shades = bytscl(dns, top=!d.table_size -1 - bottom) + byte(bottom)

;LoadCT, 4, NColors=100, Bottom=100
;SET_SHADING, Values=[100,199]

;SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)

;POLAR_CONTOUR, reverse(dns), /IRREGULAR, azimuths, zeniths, c_labels=c_labels 

;plot, zeniths, azimuths, /polar, PSYM=1

;
;maxrec = 2050
;
;openr, lun, "D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June\scan1_high\OLDDNandZenith.txt", /GET_LUN
;
;record = {azimuth:0L, dn:0.0, zenith:0.0}
;
;data = replicate(record, maxrec)
;
;nrecords = 0L
;
;while (eof(lun) ne 1) do begin
;  readf, lun, record, format="(i3, f7.3, f4.1)"
;  
;  print, record.azimuth
;  
;  data[nrecords] = record
;  nrecords = nrecords + 1L
;;endwhile
;
;; Create a vector of radii:  
;r = data.zenith
;  
;; Create a vector of Thetas:  
;theta = data.azimuth
;  
;; Create some data values to be contoured:  
;z = data.dn
;
;; Create the polar contour plot:  
;POLAR_CONTOUR, z, theta, r, xrange=[-10, 10], xstyle=1, yrange=[-10,10], ystyle=1, NLEVELS=20

close, /all


END