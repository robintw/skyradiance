PRO SKY_RADIANCE_MODEL_V2
  
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


  Gd = 5 ; Diffuse irradiance on horiz. surface
  
  
  ; Initialise arrays
  azimuths = indgen(360)
  zeniths = indgen(90)
  values = fltarr(360, 90)
  
  sun_theta = 0 ; Sun zenith angle
  sun_phi = 0; Sun azimuth angle
  
  ; For each azimuth
  FOR phi=0, 360-1 DO BEGIN
    ; For each zenith
    FOR theta=0, 90-1 DO BEGIN
    
    view_phi = phi*!DTOR ; Viewing azimuth
    view_theta = theta*!DTOR ; Viewing zenith
    
    ; Angular distance from sun to viewing point
    psi = ACOS(SIN(view_theta) * SIN(sun_theta) * COS(view_phi - sun_phi) + COS(view_theta) * cos(sun_theta))
    
    ; Three main parts of I
    
    I_part1 = (1 + EXP(-a3*!PI/2)) / (a3^2 + 4)
    
    I_part2 = (1 - (2 * (1 - EXP(-a3*!PI))) / (!PI*a3*(1 + EXP(-a3*!PI/2))))
    
    I_part3 = (2 * sun_theta * sin(sun_theta) - 0.02*!PI * SIN(2 * sun_theta))
    
    I = I_part1 * (!PI - I_part2 * I_part3)
    
    value = Gd * (a0 + a1 * COS(view_theta) + a2*EXP(-a3 * psi)) / (!PI * (a0 + 2 * a1 / 3) + 2 * a2 * I)
    
    values[phi, theta] = value
    ENDFOR
  ENDFOR
    
  SURFACE, POLAR_SURFACE(transpose(values), zeniths, azimuths, /grid)
END  