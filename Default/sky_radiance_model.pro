FUNCTION CALCULATE_VALUE, a0, a1, a2, a3, view_theta, view_phi, sun_theta, sun_phi
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

PRO BRUNGER_HOOPER_MODEL, a0, a1, a2, a3, azimuths=azimuths, zeniths=zeniths, values=values
  sun_theta = 30*!DTOR
  sun_phi = 0*!DTOR
  
  Gd = 5 ; Diffuse irradiance on horiz. surface
  
  
  ; Initialise arrays
  azimuths = indgen(360)
  zeniths = indgen(90)
  values = fltarr(360, 90)

  FOR phi=0, 360-1 DO BEGIN
    FOR theta=0, 90-1 DO BEGIN
      ; Convert the current phi and theta to radians
      view_phi = phi*!DTOR
      view_theta = theta*!DTOR
      
      value = CALCULATE_VALUE(a0, a1, a2, a3, view_theta, view_phi, sun_theta, sun_phi)
      
      print, value
      
      ; Put the value into the array
      values[phi, theta] = value
    ENDFOR
  ENDFOR
END

PRO SKY_RADIANCE_MODEL
  k = fltarr(9)
  kt = fltarr(9)
  parameters = fltarr(9, 9, 4)
  
  k = [ 0.95, 0.85, 0.75, 0.65, 0.55, 0.45, 0.35, 0.25, 0.15 ]
  
  kt = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85 ]
  
  parameters[0, 0, *] = [0.1864, 0.1979, 0.0, 1.0]
  parameters[0, 1, *] = [0.2002, 0.1772, 0.0, 1.0]
  parameters[0, 2, *] = [0.138, 0.093, 0.289, 0.9667]
  parameters[0, 3, *] = [0.1508, 0.5472, 0.6659, 1.6755]
  parameters[0, 4, *] = [0.1718, 0.0566, 0.8734, 2.4129]
  parameters[0, 5, *] = [0.2060, -0.0294, 2.9511, 3.7221]
  
  parameters[1, 0, *] = [0.1431, 0.142, 2.636, 5.525]
  parameters[1, 2, *] = [0.3477, -0.2153, 5.3170, 4.4211]
  parameters[1, 3, *] = [0.2664, -0.1559, 1.7758, 2.8590]
  parameters[1, 4, *] = [0.2139, 0.0307, 1.6099, 3.726]
  parameters[1, 5, *] = [0.1520, 0.1497, 1.8315, 4.6125]
  parameters[1, 6, *] = [0.1151, 0.1805, 2.2284, 4.1553]
    
  ; Overcast Sky
  ;a0 = 0.1864
  ;a1 = 0.1979
  ;a2 = 0.0
  ;a3 = 1.0
  
  ; Clear Sky
  ;a0 = 0.3071
  ;a1 = -0.2576
  ;a2 = 2.3127
  ;a3 = 3.5189
  
  ;BRUNGER_HOOPER_MODEL, a0, a1, a2, a3, azimuths=azimuths, zeniths=zeniths, values=values  
  
  params = parameters[0, 5, *]
  
  BRUNGER_HOOPER_MODEL, params[0], params[1], params[2], params[3], azimuths=azimuths, zeniths=zeniths, values=values 
  SURFACE, POLAR_SURFACE(transpose(values), zeniths*!DTOR, azimuths*!DTOR, /grid)
END