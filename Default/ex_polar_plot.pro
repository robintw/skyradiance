pro ex_polar_plot

 on_error, 1

 levels = 100
 band_index = 440

 draw_position = [.10, .07, .80, .90]
 cbar_position = [.85, .07, .88, .90]

 ;
 ; Read data
 ;
 scan_num = 'Scan 1'
 lib_directory = 'D:\UserData\Robin Wilson\McGonigle_Data\Spectral libraries\' + scan_num + '\'
 
 print, lib_directory

 fnames = file_search(lib_directory, 'mcgonigle_*.hdr', /fold_case)
 if fnames[0] eq '' then message, 'No input files were found. Returning...'

 ; Check if data exists, which matches *.HDR
 increment = 0L
 for jj=0,n_elements(fnames)-1 do begin
   file = strmid(fnames[jj],0,strlen(fnames[jj])-4)
   f = file_info(file)
   if f.exists then begin
    case increment of
     0: begin
        lib_filename = file
        increment = 1L
        end
     else: begin
        lib_filename = [lib_filename, file]
        increment = increment + 1L
        end
    endcase
   endif
 endfor
 nf = increment

 ; 6 azimuth angles * 2
 ; 11 zenith angles (5 + 1 + 5)
 ;
 ;   0   1   2   3   4   5   6   7   8   9   10  11  <- number
 ;   0  30  60  90  120 150 180 210 240 270 300 330  <- azimuth
 ;   0  30  60  90  120 150  0  30  60  90  120 150  <- file id
 ; 
 ; 90                       (90)
 ; 72                       108
 ; 54                       126
 ; 36                       144
 ; 18                       162
 ;  0                       180

 ;
 ; Get file query
 ;
 ENVI_OPEN_FILE, lib_filename[0], r_fid=lib_fid, /NO_REALIZE
 ENVI_FILE_QUERY, lib_fid, ns=ns, nl=nl, nb=nb, pos=pos, data_type=data_type, $
   data_ignore_value=data_ignore_value, spec_names=spec_names
 if lib_fid eq -1 or nl lt 11 then message, 'Input data has problem. Returning...'
 val = fltarr(nf*2 + 1, 6, ns) 

 for ii=0,nf-1 do begin

   split = strsplit( file_basename(lib_filename[ii]), '_.', /extract)
   if n_elements(split) ne 6 then goto, skip_this_file

   ENVI_OPEN_FILE, lib_filename[ii], r_fid=lib_fid, /NO_REALIZE
   ENVI_FILE_QUERY, lib_fid, ns=ns, nl=nl, nb=nb, pos=pos, data_type=data_type, $
     data_ignore_value=data_ignore_value, spec_names=spec_names, wl=wl
   if lib_fid ne -1 then print, 'Successfully opened, ' + file_basename(lib_filename[ii])

   scan_azm = long(split[3])

   dims = [0, 0, ns-1, 0, nl-1]
   d = ENVI_GET_DATA(fid=lib_fid, dims=dims, pos=0)
   help, d
   d = reform( transpose( temporary(d[*,0:10]) ), 11, ns)
   ncol = scan_azm / 30

   val[   ncol,  indgen(6),*] = [ d[   indgen(6),*] ]
   val[nf+ncol,  indgen(6),*] = [ d[10-indgen(6),*] ]
   
   help, val

   skip_this_file:
 endfor

 val[nf*2, *, *] = val[0, *, *]

 for jj=0,nf-1 do if jj eq 0 then x = (findgen(2) * 6 + jj) * 30 else x = [x, (findgen(2) * 6 + jj) * 30]
 x = [x[sort(x)], x[0]] & x = x - 360. * (x gt 180.)
 gridAzm = (azm = rebin( x, nf*2+1, 6) )
 gridZen = (zen = rebin( transpose([0.,18.,36.,54.,72.,90.]), nf*2+1, 6) )

 gridData = (val = val[*,*,band_index] / 4095.)
 xrange = [min(gridAzm), max(gridAzm)]
 yrange = [min(gridZen), max(gridZen)]
 zrange = [min(gridData), max(gridData)]

  print, gridData

 IF !D.NAME NE 'PS' THEN BEGIN
   DEVICE, DECOMPOSED=0, GET_DECOMPOSED=currentState
   window, 0, xsize=640, ysize=480
 ENDIF


 LoadCT, 39, /silent, bottom=1, ncolors=levels
 TVLCT, 0, 0, 0, !D.TABLE_SIZE-1         ; Drawing colour
 TVLCT, 255, 255, 255, 0                 ; Background colour

 ; Set the 3D coordinate space with axes.
 ; Translate to move center of cube to origin. 
 T3D, /reset, rot=[0,0,0], trans = [0,0,0]


 MAP_SET, Cylindrical=0, ORTHOGRAPHIC=1, SINUSOIDAL=0, TRANSVERSE_MERCATOR=0, MOLLWEIDE=0, 90, 0, $
   GRID=1, color=!D.TABLE_SIZE-1, isotropic=1, noerase=1, /t3d, position=draw_position, $
   title='Sky Spectra, ' + scan_num + ' ' + string(wl(band_index),format='(F6.1)') + 'nm'

 contour, gridData, gridAzm, gridZen, /cell_fill, /follow, $
   nlevel=levels, c_colors=indgen(levels)+0, min_value=zrange[0], max_value=zrange[1], $
   xstyle=1, ystyle=1, /overplot, /t3d, background=0, color=!D.TABLE_SIZE-1
 contour, gridData, gridAzm, gridZen, /follow, nlevel=10, min_value=zrange[0], max_value=zrange[1], /overplot, /t3d

 plots, azm, zen, psym=1, /t3d

 map_grid, /grid, londel=45, latdel=15, color=0, /t3d

 colorbar, position=cbar_position, division=10, /vertical, /right, title='Norm [/sr]', $
    bottom=1b, ncolors=levels-1, range=zrange, format='(F3.1)'

 ; Set color decomposition back to default.

 IF !D.NAME NE 'PS' THEN BEGIN
   DEVICE, DECOMPOSED=currentState
 ENDIF
 
end