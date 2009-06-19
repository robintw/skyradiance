@Polar_Plot_Data
@Get_Sky_Data
@Map_Plot_Data
@Polar_Surface_Plot

PRO RUN_PROGRAM
  ; Get the sky data from the text files into a usable form
  GET_SKY_DATA, 268, azimuths=azimuths, zeniths=zeniths, dns=dns
  
  ; --- Visualisation routines are below: uncomment the appropriate one ---
  
  ;Polar_Plot_Data, azimuths, zeniths, dns
  
  MAP_PLOT_DATA, azimuths, zeniths, dns
  
  ;POLAR_SURFACE_PLOT, azimuths, zeniths, dns
      
END