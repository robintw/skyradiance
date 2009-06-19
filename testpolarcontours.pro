PRO TestPolarContours
; Create a vector of radii:  
r = [1, 2, 3, 1, 2, 3]
  
; Create a vector of Thetas:  
theta = [45, 45, 45, 270, 270, 270]
  
; Create some data values to be contoured:  
z = [5, 10, 7, 5, 5, 5]

c_labels = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

; Create the polar contour plot:  
POLAR_CONTOUR, z, theta, r, c_labels=c_labels
END
