FUNCTION READ_NUMBERED_LINE, filename, line_number
  openr, lun, filename, /GET_LUN
  
  FOR i=0, line_number DO BEGIN
    readf, lun, line, format="(a)"
  ENDFOR
  
  FREE_LUN, lun
  
  return, line
END

PRO TestPolarPlot
; Get a list of all the angle.txt files under the specified directory
angle_files = FILE_SEARCH("D:\UserData\Robin Wilson\AlteredData\ncaveo\16-June\scan1_high", "angles.txt")

line = ""

; This line number will depend on the wavelength you want to look at
line_number = 268

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
    
    ; Calculate the azimuth given that the zenith scanning goes all the way from 0 to 180 degrees    
    zenith = FLOAT(splitted[2])
    IF zenith GT 90 THEN BEGIN
      real_azimuth = azimuth + 180
      real_zenith = zenith - 90
    ENDIF ELSE BEGIN
      real_azimuth = azimuth
      real_zenith = zenith
    ENDELSE
    
    ; Insert the values into the arrays
    azimuths[array_index] = real_azimuth
    dns[array_index] = dn
    zeniths[array_index] = real_zenith
    
    j = j + 1
  ENDWHILE
ENDFOR

print, "Done playing with files"

; Convert azimuths to radians
azimuths = azimuths*!dtor

; Label all the contour levels
c_labels = replicate(1, 15)

;levels = [MIN(dns), 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]

; Generate 15 equally spaced levels to contour
range = MAX(dns) - MIN(dns)
levels = indgen(15) * (range/15)

; Order of z, theta, r
;POLAR_CONTOUR, dns, zeniths, azimuths, levels=levels, c_labels=c_labels, /IRREGULAR

;bottom = 16
;loadct, 13, bottom=bottom
;shades = bytscl(dns, top=!d.table_size -1 - bottom) + byte(bottom)

;LoadCT, 4, NColors=100, Bottom=100
;SET_SHADING, Values=[100,199]

SURFACE, POLAR_SURFACE(dns, zeniths, azimuths)
;ncolors = N_ELEMENTS(levels) + 1
;bottom = 1
;c_colors = indgen(ncolors) + bottom
;loadct, 33, ncolors=ncolors, bottom=bottom 

;device, decomposed=0
loadct, 0

;axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9, /save
;axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9, /save

;POLAR_CONTOUR, reverse(dns), azimuths, zeniths, $
  ;levels=levels, c_labels=c_labels, $
  ;ystyle=4, xstyle=4, $
  ;/IRREGULAR, /FILL, /ISOTROPIC, /OVERPLOT

;axis, 0, 0, XAX=0, xrange=[-90, 90], xstyle=1, xticks=9
;axis, 0, 0, YAX=0, yrange=[-90, 90], ystyle=1, yticks=9

;POLAR_CONTOUR, reverse(dns), /IRREGULAR, /fill, azimuths, zeniths, levels=levels, c_labels=c_labels, nlevels=10, xstyle=4, ystyle=4
;POLAR_CONTOUR, reverse(dns), /IRREGULAR, /overplot, azimuths, zeniths, levels=levels, c_labels=c_labels, nlevels=10, xstyle=4, ystyle=4


;plot, zeniths, azimuths, /polar, PSYM=1, /ISOTROPIC, xstyle=4, ystyle=4


;oplot, [10], [120*!dtor], /polar, PSYM=4
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