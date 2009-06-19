PRO PolarSurfaceTest
; Define radius and Theta:  
R = FINDGEN(50) / 50.0  
THETA = FINDGEN(50) * (2 * !PI / 50.0)  
  
; Make a function (tilted circle):  
Z = R # SIN(THETA)  
  
; Show it:  
SURFACE, POLAR_SURFACE(Z, R, THETA, /GRID)  

END