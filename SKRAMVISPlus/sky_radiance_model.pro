FUNCTION CALCULATE_SKY_VALUE, a0, a1, a2, a3, view_theta, view_phi, sun_theta, sun_phi
  ; Angular distance (in rads) from observing direction to solar disc direction
  psi = ACOS(sin(view_theta) * sin(sun_theta) * cos(view_phi - sun_phi) + cos(view_theta) * cos(sun_theta))
  
  ; The three main parts of the formula for I
  I1 = (1 + exp(-a3 * !PI/2))/ (a3^2 + 4)
  
  I2 = (1 - (2 * (1 - exp(-a3 * !PI))) / (!PI * a3 * (1 + exp(-a3 * !PI / 2))))
  
  I3 = (2 * sun_theta * sin(sun_theta) - 0.02 * !PI * sin(2 * sun_theta))
  
  ; Putting the three main parts of I together
  I = I1 * (!PI - I2 * I3)
  
  ; Calculate the final value for this point
  value = (a0 + a1 * cos(view_theta) + a2 * exp(-a3 * psi)) / (!PI * (a0 + 2*a1/3) + 2*a2*I)
  
  return, double(value)
END

PRO BRUNGER_HOOPER_MODEL, a0, a1, a2, a3, azimuths=return_azimuths, zeniths=return_zeniths, values=return_values, s_theta, s_phi
  sun_theta = s_theta*!DTOR
  sun_phi = s_phi*!DTOR
  
  Gd = 5 ; Diffuse irradiance on horiz. surface
  
  
  ; Initialise arrays
  my_azimuths = intarr(360*90)
  my_zeniths = intarr(360*90)
  my_values = dblarr(360*90)

  FOR phi=0, 360L-1 DO BEGIN
    FOR theta=0, 90L-1 DO BEGIN
      ; Convert the current phi and theta to radians
      view_phi = phi*!DTOR
      view_theta = theta*!DTOR
      
      value = CALCULATE_SKY_VALUE(a0, a1, a2, a3, view_theta, view_phi, sun_theta, sun_phi)
      
      ;value = double(1)
      
      array_index = long((90*phi) + theta)
      
      ; Put the value into the array
      my_values[array_index] = value
      my_azimuths[array_index] = phi
      my_zeniths[array_index] = theta
      
    ENDFOR
  ENDFOR
  
  my_values = my_values / MAX(my_values)
  
  return_values = my_values
  return_azimuths = my_azimuths
  return_zeniths = my_zeniths
  
END

PRO RUN_SKY_RADIANCE_MODEL, k, kt, sun_theta, sun_phi, azimuths=azimuths, zeniths=zeniths, values=values
  k_array = fltarr(9)
  kt_array = fltarr(9)
  parameters = fltarr(9, 9, 4)
  
  k_array = [ 0.95, 0.85, 0.75, 0.65, 0.55, 0.45, 0.35, 0.25, 0.15 ]
  
  kt_array = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85 ]
  
  ; k = 0.95
  parameters[0, 0, *] = [0.1864, 0.1979, 0.0, 1.0]
  parameters[0, 1, *] = [0.2002, 0.1772, 0.0, 1.0]
  parameters[0, 2, *] = [0.138, 0.093, 0.289, 0.9667]
  parameters[0, 3, *] = [0.1508, 0.5472, 0.6659, 1.6755]
  parameters[0, 4, *] = [0.1718, 0.0566, 0.8734, 2.4129]
  parameters[0, 5, *] = [0.2060, -0.0294, 2.9511, 3.7221]
  
  ; k = 0.85
  parameters[1, 0, *] = [0.1431, 0.142, 2.636, 5.525]
  parameters[1, 2, *] = [0.3477, -0.2153, 5.3170, 4.4211]
  parameters[1, 3, *] = [0.2664, -0.1559, 1.7758, 2.8590]
  parameters[1, 4, *] = [0.2139, 0.0307, 1.6099, 3.726]
  parameters[1, 5, *] = [0.1520, 0.1497, 1.8315, 4.6125]
  parameters[1, 6, *] = [0.1151, 0.1805, 2.2284, 4.1553]
  
  ; k = 0.75
  parameters[2, 2, *] = [0.3687, -0.2927, 2.6268, 2.8413]
  parameters[2, 3, *] = [0.2684, -0.1645, 4.5224, 4.0842]
  parameters[2, 4, *] = [0.2019, -0.1275, 1.4096, 2.2453]
  parameters[2, 5, *] = [0.1870, -0.0632, 1.2819, 2.5932]
  parameters[2, 6, *] = [0.1842, 0.0253, 1.3080, 3.1127]
  parameters[2, 7, *] = [0.1566, 0.3003, 1.8486, 14.744]
  
  ; k = 0.65
  parameters[3, 2, *] = [0.3851, -0.2726, 4.1962, 5.259]
  parameters[3, 3, *] = [0.2843, -0.1645, 5.2960, 4.3678]
  parameters[3, 4, *] = [0.2713, -0.1837, 2.822, 3.486]
  parameters[3, 5, *] = [0.1597, -0.1715, 1.2964, 1.9183]
  parameters[3, 6, *] = [0.2088, -0.0520, 1.3225, 2.8364]
  parameters[3, 7, *] = [0.1273, -0.0500, 1.5961, 2.0993]
  
  ; k = 0.55
  parameters[4, 2, *] = [0.6079, -0.4838, 11.078, 4.588]
  parameters[4, 3, *] = [0.2892, -0.1953, 2.1346, 3.7268]
  parameters[4, 4, *] = [0.2819, -0.1945, 3.8606, 3.7447]
  parameters[4, 5, *] = [0.2465, -0.1245, 2.9163, 4.0760]
  parameters[4, 6, *] = [0.2070, -0.0927, 1.1098, 2.5586]
  parameters[4, 7, *] = [0.2477, -0.0711, 1.5836, 3.450]
  
  ; k = 0.45
  parameters[5, 3, *] = [0.2337, -0.1015, 11.792, 5.3698]
  parameters[5, 4, *] = [0.2822, -0.1842, 6.0300, 4.5241]
  parameters[5, 5, *] = [0.2916, -0.2065, 2.7327, 3.7624]
  parameters[5, 6, *] = [0.2583, -0.1654, 1.9525, 3.3769]
  parameters[5, 7, *] = [0.2457, -0.1398, 1.512, 2.964]
  parameters[5, 8, *] = [0.2315, -0.2028, 1.5803, 2.3229]
  
  ; k = 0.35
  parameters[6, 4, *] = [0.3162, -0.2039, 6.2226, 5.8975]
  parameters[6, 5, *] = [0.3006, -0.2172, 4.5443, 4.2660]
  parameters[6, 6, *] = [0.2871, -0.2184, 2.6467, 3.594]
  parameters[6, 7, *] = [0.2491, -0.2224, 1.5992, 2.6404]
  parameters[6, 8, *] = [0.2510, 0.0907, 0.9733, 2.6775]
  
  ; k = 0.25
  parameters[7, 5, *] = [0.3417, -0.2574, 4.1918, 43268]
  parameters[7, 6, *] = [0.3153, -0.2338, 3.8860, 4.3620]
  parameters[7, 7, *] = [0.3071, -0.2576, 2.3127, 3.5189]
  parameters[7, 8, *] = [0.2971, -0.3126, 1.3594, 2.397]
  
  ; k = 0.15
  parameters[8, 6, *] = [0.3360, -0.2600, 4.2481, 4.3727]
  parameters[8, 7, *] = [0.3243, -0.3003, 1.9157, 3.2680]
  parameters[8, 8, *] = [0.3061, -0.4531, 1.612, 2.319]
      
  
  ; Choose the a0, a1, a2 and a3 parameters using the given k and kt values
  k_index = WHERE(k_array EQ k)
  kt_index = WHERE(kt_array EQ kt)
  
  IF k_index EQ -1 OR kt_index EQ -1 THEN BEGIN
    Message, "Invalid k or kt parameter selected"
    return
  ENDIF
  
  params = parameters[k_index, kt_index, *]
  
  print, "IN RUN_SKY_RADIANCE_MODEL"
  print, "Sun Theta = ", sun_theta
  print, "Sun Phi = ", sun_phi
  
  BRUNGER_HOOPER_MODEL, params[0], params[1], params[2], params[3], azimuths=azimuths, zeniths=zeniths, values=values, sun_theta, sun_phi 
  
END

PRO GET_MODEL_DATA, sun_azimuth, sun_zenith, dgratio, aot, azimuths=azimuths, zeniths=zeniths, values=values, title=title_string
  k_array = [ 0.95, 0.85, 0.75, 0.65, 0.55, 0.45, 0.35, 0.25, 0.15 ]
  kt_array = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85 ]
  
  distance_away = MIN(ABS(k_array - dgratio), k_nearest_index)
  distance_away = MIN(ABS(kt_array - (1 - aot)), kt_nearest_index)
  
  print, "SUN ZENITH = ", sun_zenith
  print, "SUN AZIMUTH = ", sun_azimuth
  
  RUN_SKY_RADIANCE_MODEL, k_array[k_nearest_index], kt_array[kt_nearest_index], sun_zenith, sun_azimuth, azimuths=azimuths, zeniths=zeniths, values=values
  
  title_string = "Modelled Sky: k = " + STRCOMPRESS(string(k_array[k_nearest_index]), /REMOVE_ALL) + " kt = " + STRCOMPRESS(string(kt_array[kt_nearest_index]), /REMOVE_ALL)
END

PRO SHOW_MODEL_DATA, sun_azimuth, sun_zenith, dgratio, aot, surface=surface, map=map
  print, "In Show Model Data. DGRatio = ", dgratio
  robin = dgratio
  print, "Robin = ", robin
  GET_MODEL_DATA, sun_azimuth, sun_zenith, robin, aot, azimuths=azimuths, zeniths=zeniths, values=values, title=title_string
  
  if KEYWORD_SET(surface) then begin
    SURFACE, POLAR_SURFACE(values, zeniths*!DTOR, azimuths*!DTOR), color=FSC_COLOR("black")
    XYOUTS, 0.5, 0.9, title_string, /NORMAL, ALIGNMENT=0.5, color=FSC_Color("black")
  endif else if keyword_set(map) then begin
    MAP_PLOT_DATA, azimuths, zeniths, values, title_string
  endif
END

FUNCTION CALCULATE_RMSE, sun_azimuth, sun_zenith, dgratio, aot, measured_azimuths, measured_zeniths, measured_dns
    ; Run the model with the parameters of D:G ratio and AOT
    GET_MODEL_DATA, sun_azimuth, sun_zenith, dgratio, aot, azimuths=modelled_azimuths, zeniths=modelled_zeniths, values=modelled_values
    
    small_modelled_array = fltarr(N_ELEMENTS(measured_dns))
    
    ; Generalise the modelled values into just values for the locations at which measurements were taken
    FOR i=0, N_ELEMENTS(measured_dns)-1 DO BEGIN
      current_az = measured_azimuths[i]
      current_zen = measured_zeniths[i]
      
      modelled_array_index = (90 * current_az) + current_zen
      
      small_modelled_array[i] = modelled_values[modelled_array_index]
    ENDFOR
        
    ;POLAR_SURFACE_PLOT, measured_azimuths, measured_zeniths, small_modelled_array
    
    ; Calculate the RMSE value
    difference = measured_dns - small_modelled_array
    sq_difference = difference^2
    mean_sq_difference = MEAN(sq_difference, /NAN)
    rmse = sqrt(mean_sq_difference)
    
    return, rmse
END

; This is a test procedure which allows this file to be run independently, producing the output of the model
; for whatever parameters are given below. Very handy for testing!
;PRO SKY_RADIANCE_MODEL
  ;RUN_SKY_RADIANCE_MODEL, 0.25, 0.75, 30, 180, azimuths=azimuths, zeniths=zeniths, values=values
  ;SURFACE, POLAR_SURFACE(values, zeniths*!DTOR, azimuths*!DTOR)
;END