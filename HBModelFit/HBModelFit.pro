@GET_SUNSHINE_DATA
@GET_D_TO_G_RATIO
@GET_SKY_DATA
@MAP_PLOT_DATA
@POLAR_SURFACE_PLOT
@SHOW_SKY_IMAGE
 

PRO SET_BROWSED_TEXT, infoptr
  info = *infoptr

  directory = dialog_pickfile(/DIRECTORY, PATH=info.last_dir_path)
  widget_control, info.text_dirname, set_value=directory
   
  info.dirname = directory
  info.last_dir_path = directory
  
  *infoptr = info
END

; Handler routine called by SKRAMVIS_EVENT. Takes keywords to decide what type of plot to display
; and whether to normalise the data or not.
PRO VISUALISE_DATA, infoptr, MAP=MAP, SURFACE=SURFACE
  ; Dereference info pointer
  info = *infoptr
  
  line_nums_array = [2, 108, 268, 431, 926, 1523, 1749, 2027]
  line_number = line_nums_array[info.list_index]
  
  wavelengths_array = [" 340", " 380", " 440", " 500", " 675", " 870", " 939", " 1020"]
  
  GET_SKY_DATA, info.dirname, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, normalise=info.normalise, datetime=datetime
  
  ; Set the plot window to be the right window
  wset, info.win_contour_id
  
  IF keyword_set(map) THEN BEGIN
    time_string = string(datetime, FORMAT='(C(CHI2.2, ":", CMI2.2, ":", CSI2.2))')
    title = "Sky Radiance Distribution: " + FILE_BASENAME(info.dirname) + " " + time_string + " " + wavelengths_array[info.list_index] + "nm"
    MAP_PLOT_DATA, azimuths, zeniths, dns, title
  ENDIF ELSE IF keyword_set(surface) THEN BEGIN
    POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ENDIF
    
  ; Get the Diffuse:Global ratio and set put it into the label widget
  dgratio = GET_D_TO_G_RATIO(datetime, info.sunshine_file)
  WIDGET_CONTROL, info.label_dgratio, SET_VALUE=dgratio
  
END


PRO HBModelFit_EVENT, EVENT
  ; Get the info structure from the uvalue of the base widget
  widget_control, event.top, get_uvalue=infoptr
  info = *infoptr
  
  ; Get the uvalue of the widget that caused the event
  widget_control, event.id, get_uvalue=widget
  
  
  if (STRPOS(widget, "List") ne -1) THEN BEGIN
    info.list_index = event.index
    *infoptr = info
    print, info.list_index
  ENDIF ELSE IF (STRPOS(widget, "Checkbox") ne -1) THEN BEGIN
    info.normalise = event.select
    *infoptr = info
  ENDIF ELSE IF (STRPOS(widget, "Button") ne -1) THEN BEGIN   
    CASE widget OF
      "MapButton": Visualise_Data, infoptr, /MAP
      "SurfaceButton": Visualise_Data, infoptr, /SURFACE
      "BrowseButton": Set_Browsed_Text, infoptr
    ENDCASE
  ENDIF  
END

PRO HBModelFit
  base = widget_base(col=2, title="Sky Radiance Mapper Visualisation", TLB_FRAME_ATTR=1)
  
  controls_base = widget_base(base, row=4)
  
  filename_base = widget_base(controls_base, col=3)
  label_dirname = widget_label(filename_base, value="Directory:")
  text_dirname = widget_text(filename_base, uvalue="FilenameText", xsize=50)
  button_browse = widget_button(filename_base, value="Browse", uvalue="BrowseButton")
  
  parameters_base = widget_base(controls_base, col=3)
  label_wavelengths = widget_label(parameters_base, value="Wavelength:")
  wavelength_list = string([340, 380, 440, 500, 675, 870, 939, 1020])
  list = widget_list(parameters_base, value=wavelength_list, ysize=8, uvalue="List")
  
  checkbox_base = widget_base(parameters_base, /NONEXCLUSIVE)
  checkbox_normalise = widget_button(checkbox_base, value="Normalise", uvalue="NormaliseCheckbox")
  
  button_base = widget_base(controls_base, row=1)
  button_map = widget_button(button_base, value="Show Contour Plot", uvalue="MapButton")
  button_surface = widget_button(button_base, value="Show Surface Plot", uvalue="SurfaceButton")
  
  copyright_base = widget_base(controls_base, row=1)
  label_copyright = widget_label(copyright_base, value="Created by Robin Wilson, University of Southampton, 2009")
  
  draw_base = widget_base(base, row=3)
  
  draw_contour = widget_draw(draw_base, xsize=600, ysize=450)
  
  dgratio_base = widget_base(draw_base, col=2)
  
  label_label_for_dgratio = widget_label(dgratio_base, value="Diffuse:Global ratio = ")
  label_dgratio = widget_label(dgratio_base, value="", /DYNAMIC_RESIZE)
  
  draw_image = widget_draw(draw_base, xsize=600, ysize=450)
  
  ; Set up info structure
  info = {normalise:0,$
          dirname:'',$
          text_dirname:text_dirname,$
          list:list,$
          list_index:'',$
          type:'',$
          wavelength:'',$
          win_contour_id:0,$
          win_image_id:0,$
          label_dgratio:label_dgratio,$
          last_dir_path:"C:\",$
          image_dir:"",$
          sunshine_file:""}
  
  ; Realize the widgets
  widget_control, base, /realize
  
  ; Put window indices into info
  widget_control, draw_contour, get_value=win_contour_id
  widget_control, draw_image, get_value=win_image_id
  info.win_contour_id = win_contour_id
  info.win_image_id = win_image_id
 
   ; Ask for location of sunshine data file and sky image directory
  info.sunshine_file = dialog_pickfile(TITLE="Select Sunshine Sensor data file")
  
  infoptr = ptr_new(info)
    
  widget_control, base, set_uvalue=infoptr
  
  ; Erase both draw widgets
  wset, info.win_image_id
  erase
  wset, info.win_contour_id
  erase
  

  ; Start managing events
  xmanager, 'HBMODELFIT', base, /no_block
END