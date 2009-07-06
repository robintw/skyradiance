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
  
  return, value
END

PRO BRUNGER_HOOPER_MODEL, a0, a1, a2, a3, azimuths=azimuths, zeniths=zeniths, values=values, s_theta, s_phi
  sun_theta = s_theta*!DTOR
  sun_phi = s_phi*!DTOR  
  
  ; Initialise arrays
  azimuths = intarr(360*90)
  zeniths = intarr(360*90)
  values = fltarr(360 * 90)

  FOR phi=0, 360-1,30 DO BEGIN
    FOR theta=0, 90-1,18 DO BEGIN
      ; Convert the current phi and theta to radians
      view_phi = phi*!DTOR
      view_theta = theta*!DTOR
      
      value = CALCULATE_VALUE(a0, a1, a2, a3, view_theta, view_phi, sun_theta, sun_phi)
      
      array_index = (90*phi) + theta
      
      ; Put the value into the array
      values[array_index] = value
      azimuths[array_index] = phi
      zeniths[array_index] = theta
      
    ENDFOR
  ENDFOR
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
  
  
    
  
  ; Choose the a0, a1, a2 and a3 parameters using the given k and kt values
  k_index = WHERE(k_array EQ k)
  kt_index = WHERE(kt_array EQ kt)
  
  IF k_index EQ -1 OR kt_index EQ -1 THEN BEGIN
    Message, "Invalid k or kt parameter selected"
    return
  ENDIF
  
  params = parameters[k_index, kt_index, *]
  
  BRUNGER_HOOPER_MODEL, params[0], params[1], params[2], params[3], azimuths=azimuths, zeniths=zeniths, values=values, sun_theta, sun_phi 
  
END

PRO SKY_RADIANCE_MODEL
  RUN_SKY_RADIANCE_MODEL, 0.95, 0.05, 30, 0, azimuths=azimuths, zeniths=zeniths, values=values
  SURFACE, POLAR_SURFACE(values, zeniths*!DTOR, azimuths*!DTOR)
END