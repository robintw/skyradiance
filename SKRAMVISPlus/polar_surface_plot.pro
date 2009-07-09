; Plots the given azimuths, zeniths and dns (provided in an irregularly gridded format
; (ie. dns is one dimensional) in a polar surface plot.
PRO POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ; Convert the azimuths to radians
  new_azimuths = azimuths*!dtor
  
  title_string = "Measured Sky"
  
  ; Plot the data as a surface  
  SURFACE, POLAR_SURFACE(dns, zeniths, new_azimuths), color=1
  
  ; Draw the title, centred above the plot
  XYOUTS, 0.5, 0.9, title_string, /NORMAL, ALIGNMENT=0.5, color=FSC_Color("black")
END