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
  wset, info.win_measured_id
  
  time_string = string(datetime, FORMAT='(C(CHI2.2, ":", CMI2.2, ":", CSI2.2))')
  
  IF keyword_set(map) THEN BEGIN
    
    title = "Sky Radiance Distribution: " + FILE_BASENAME(info.dirname) + " " + time_string + " " + wavelengths_array[info.list_index] + "nm"
    MAP_PLOT_DATA, azimuths, zeniths, dns, title
  ENDIF ELSE IF keyword_set(surface) THEN BEGIN
    POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ENDIF
  
  WIDGET_CONTROL, info.label_time, SET_VALUE=STRTRIM(time_string)
  
  ; Erase the previous image
  wset, info.win_image_id
  erase
  
  SHOW_SKY_IMAGE, datetime, info.image_dir
  
  ; Get the Diffuse:Global ratio and set put it into the label widget
  dgratio = GET_D_TO_G_RATIO(datetime, info.sunshine_file)
  WIDGET_CONTROL, info.label_dgratio, SET_VALUE=dgratio
  
END


PRO SKRAMVISPLUS_EVENT, EVENT
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

PRO SKRAMVISPlus
  base = widget_base(col=2, title="Sky Radiance Mapper Visualisation PLUS", TLB_FRAME_ATTR=1)
  
  left_side_base = widget_base(base, row=4)
  
    controls_base = widget_base(left_side_base, row=4)
    
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
    
    metadata_base = widget_base(left_side_base, row=4, /GRID_LAYOUT)
      label_metadata = widget_label(metadata_base, value="Metadata:")
      label_nothing = widget_label(metadata_base, value="")
      label_label_for_time = widget_label(metadata_base, value="Time:")
      label_time = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      label_label_for_dgratio = widget_label(metadata_base, value="D:G ratio:")
      label_dgratio = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      label_label_for_AOT = widget_label(metadata_base, value="AOT:")
      label_AOT = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      
  
    draw_image = widget_draw(left_side_base, xsize=600, ysize=450)
  
    copyright_base = widget_base(left_side_base, row=1)
      label_copyright = widget_label(copyright_base, value="Created by Robin Wilson, University of Southampton, 2009") 
  
  draw_base = widget_base(base, row=2)
    draw_model = widget_draw(draw_base, xsize=600, ysize=450)
    draw_measured = widget_draw(draw_base, xsize=600, ysize=450)
  
  ; Set up info structure
  info = {normalise:0,$
          dirname:'',$
          text_dirname:text_dirname,$
          list_index:'',$
          type:'',$
          wavelength:'',$
          win_measured_id:0,$
          win_modelled_id:0,$
          win_image_id:0,$
          label_dgratio:label_dgratio,$
          label_time:label_time,$
          label_AOT:label_AOT,$
          last_dir_path:"C:\",$
          image_dir:"",$
          sunshine_file:""}
  
  ; Realize the widgets
  widget_control, base, /realize
  
  ; Put window indices into info
  widget_control, draw_measured, get_value=win_measured_id
  widget_control, draw_image, get_value=win_image_id
  widget_control, draw_model, get_value=win_model_id
  info.win_measured_id = win_measured_id
  info.win_image_id = win_image_id
  info.win_modelled_id = win_model_id
 
   ; Ask for location of sunshine data file and sky image directory
  info.sunshine_file = dialog_pickfile(TITLE="Select Sunshine Sensor data file")
  info.image_dir = dialog_pickfile(TITLE="Select image directory", /directory)
  
  infoptr = ptr_new(info)
    
  widget_control, base, set_uvalue=infoptr
  
  ; Erase both draw widgets
  wset, info.win_image_id
  Erase, Color=FSC_Color('white')
  wset, info.win_measured_id
  Erase, Color=FSC_Color('white')
  wset, info.win_modelled_id
  Erase, Color=FSC_Color('white')
  

  ; Start managing events
  xmanager, 'SKRAMVISPlus', base, /no_block
END