PRO SKY_RADIANCE_MODEL
  
  ; Overcast Sky
  ;a0 = 0.1864
  ;a1 = 0.1979
  ;a2 = 0.0
  ;a3 = 1.0
  
  ; Clear Sky
  a0 = 0.3071
  a1 = -0.2576
  a2 = 2.3127
  a3 = 3.5189
  
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
      
      ; Angular distance (in rads) from observing direction to solar disc direction
      psi = ACOS(sin(view_theta) * sin(sun_theta) * cos(view_phi - sun_phi) + cos(view_theta) * cos(sun_theta))
      
      ; The three main parts of the formula for I
      I1 = (1 + exp(-a3 * !PI/2))/ (a3^2 + 4)
      
      I2 = (1 - (2 * (1 - exp(-a3 * !PI))) / (!PI * a3 * (1 + exp(-a3 * !PI / 2))))
      
      I3 = (2 * sun_theta * sin(sun_theta) - 0.02 * !PI * sin(2 * sun_theta))
      
      ; Putting the three main parts of I together
      I = I1 * (!PI - I2 * I3)
      
      ; Calculate the final value for this point
      value = Gd * (a0 + a1 * cos(view_theta) + a2 * exp(-a3 * psi)) / (!PI * (a0 + 2*a1/3) + 2*a2*I)
      
      ; Put the value into the array
      values[phi, theta] = value
    ENDFOR
  ENDFOR
  
  SURFACE, POLAR_SURFACE(transpose(values), zeniths, azimuths, /grid)
  
  
END