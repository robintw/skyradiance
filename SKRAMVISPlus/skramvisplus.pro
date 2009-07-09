@GET_SUNSHINE_DATA
@GET_D_TO_G_RATIO
@GET_SKY_DATA
@MAP_PLOT_DATA
@POLAR_SURFACE_PLOT
@SHOW_SKY_IMAGE
@GET_AOT_DATA
@SKY_RADIANCE_MODEL
@GET_CIMEL_DATA
 
; Routine called by SKRAMVISPLUSEVENT which displays a dialog box to the user asking them to select a directory
; where the McGonigle data is located. This location is then displayed in a textbox and saved into the info
; structure.
PRO SET_BROWSED_TEXT, infoptr
  ; Dereference the info pointer
  info = *infoptr

  ; Display a directory selection dialog box, with a starting location of the last place the user was looking
  directory = dialog_pickfile(/DIRECTORY, PATH=info.last_dir_path)
  
  ; Set the textbox to the directory selected by the user
  widget_control, info.text_dirname, set_value=directory
   
  ; Store the directory in the info parameter, as well as storing the last used directory path
  info.dirname = directory
  info.last_dir_path = directory
  
  ; Save the details back to the info pointer
  *infoptr = info
END

; Routine which calls all the visualisation functions. This is called by SKRAMVISPlusEvent which passes it a
; reference to the info structure, keywords telling it whether to plot the data using MAP_PLOT_DATA or
; POLAR_SURFACE_PLOT
PRO VISUALISE_DATA, infoptr, MAP=MAP, SURFACE=SURFACE
  ; Dereference info pointer, so that data from it can be accessed
  info = *infoptr
  
  ; Get the line number in the McGonigle file of the wavelength which has been selected
  line_nums_array = [108, 268, 431, 926, 1523]
  line_number = line_nums_array[info.list_index]
  
  wavelengths_array = [" 380", " 440", " 500", " 675", " 870"]
  
  ; Get the McGonigle data from the directory selected by the user
  GET_SKY_DATA, info.dirname, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, normalise=info.normalise, datetime=datetime, sun_azimuth=sun_azimuth, sun_zenith=sun_zenith
  
  ; Get the Diffuse:Global ratio and put it into the label widget
  dgratio = GET_D_TO_G_RATIO(datetime, info.sunshine_file)
  WIDGET_CONTROL, info.label_dgratio, SET_VALUE=STRCOMPRESS(string(dgratio, FORMAT="(f5.3)"), /REMOVE_ALL)
  
  ; Get the AOT data and put it into the label widget
  aot = GET_CIMEL_DATA(info.microtops_file, wavelengths_array[info.list_index], datetime)
  WIDGET_CONTROL, info.label_AOT, SET_VALUE=STRCOMPRESS(string(aot, FORMAT="(f5.3)"), /REMOVE_ALL)
  
  ; Set the plot window to be the window for plotting the measured data
  wset, info.win_measured_id
  
  ; Create the time and date strings from the datetime passed back from GET_SKY_DATA
  time_string = string(datetime, FORMAT='(C(CHI2.2, ":", CMI2.2, ":", CSI2.2))')
  date_string = string(datetime, FORMAT='(C(CDI2.2, "/", CMI2.2, "/", CYI2.2))') 
  
  IF keyword_set(map) THEN BEGIN
    ; If the user clicked the map button then plot the data as a contour map
    title = "Sky Radiance Distribution: " + FILE_BASENAME(info.dirname) + " " + time_string + " " + wavelengths_array[info.list_index] + "nm"
    MAP_PLOT_DATA, azimuths, zeniths, dns, title
    
    ; Set the plot window to the modelled data window and show the model data
    wset, info.win_modelled_id
    ; The procedure below is called with the SURFACE keyword even though it should be displayed as a map
    ; because the model data gives an error when plotted with the MAP_PLOT_DATA function.
    SHOW_MODEL_DATA, sun_azimuth, sun_zenith, dgratio, aot, /SURFACE
  ENDIF ELSE IF keyword_set(surface) THEN BEGIN
    ; If the user clicked the surface button then plot the data as a surface
    POLAR_SURFACE_PLOT, azimuths, zeniths, dns
    
    ; Set the plot window to the modelled data window and show the model data
    wset, info.win_modelled_id
    SHOW_MODEL_DATA, sun_azimuth, sun_zenith, dgratio, aot, /SURFACE
  ENDIF
  
  ; Display the time and date in the GUI
  WIDGET_CONTROL, info.label_time, SET_VALUE=STRCOMPRESS(time_string, /REMOVE_ALL)
  WIDGET_CONTROL, info.label_date_string, SET_VALUE=STRCOMPRESS(date_string, /REMOVE_ALL)
  
  ; Erase the previous image, to make sure that no image is displayed if there is none available (rather than
  ; an old one).
  wset, info.win_image_id
  erase
  
  ; Display the JPEG of the sky image
  SHOW_SKY_IMAGE, datetime, info.image_dir  
  
  ; The commented out code below calculates the RMSE between the model and the measured data
  ; and displays it in the GUI. To work it will need the widgets for the RMSE display uncommenting too
  ; (see below).
  ;rmse = CALCULATE_RMSE(sun_azimuth, sun_zenith, dgratio, aot, azimuths, zeniths, dns)
  ;WIDGET_CONTROL, info.label_rmse, SET_VALUE=STRCOMPRESS(string(rmse), /REMOVE_ALL)
END

; The event handler routine for SKRAMVISPlus
PRO SKRAMVISPLUS_EVENT, EVENT
  ; Get the info structure from the uvalue of the base widget
  widget_control, event.top, get_uvalue=infoptr
  info = *infoptr
  
  ; Get the uvalue of the widget that caused the event
  widget_control, event.id, get_uvalue=widget
  
  if (STRPOS(widget, "List") ne -1) THEN BEGIN
    ; If the event is from the list box then set the remember the list_index which was clicked
    info.list_index = event.index
    *infoptr = info
  ENDIF ELSE IF (STRPOS(widget, "Checkbox") ne -1) THEN BEGIN
    ; If the event is from the checkbox then remember whether it was set or unset
    info.normalise = event.select
    *infoptr = info
  ENDIF ELSE IF (STRPOS(widget, "Button") ne -1) THEN BEGIN
    ; If the event is from a button then decide what to do based on the button
    CASE widget OF
      "MapButton": Visualise_Data, infoptr, /MAP
      "SurfaceButton": Visualise_Data, infoptr, /SURFACE
      "BrowseButton": Set_Browsed_Text, infoptr
    ENDCASE
  ENDIF  
END

; Main procedure for SKRAMVISPlus. Creates the widget tree and realizes it. Sets up the info structure, and
; then passes control over to the event handler.
PRO SKRAMVISPlus
  base = widget_base(col=2, title="Sky Radiance Mapper Visualisation PLUS")
  
  left_side_base = widget_base(base, row=4)
  
    controls_base = widget_base(left_side_base, row=4)
    
      filename_base = widget_base(controls_base, col=3)
        label_dirname = widget_label(filename_base, value="Directory:")
        text_dirname = widget_text(filename_base, uvalue="FilenameText", xsize=85)
        button_browse = widget_button(filename_base, value="Browse", uvalue="BrowseButton")
      
      parameters_base = widget_base(controls_base, col=3)
        label_wavelengths = widget_label(parameters_base, value="Wavelength:")
        wavelength_list = string([380, 440, 500, 675, 870])
        list = widget_list(parameters_base, value=wavelength_list, ysize=5, uvalue="List")
      
      checkbox_base = widget_base(parameters_base, /NONEXCLUSIVE)
        checkbox_normalise = widget_button(checkbox_base, value="Normalise", uvalue="NormaliseCheckbox")
      
      button_base = widget_base(controls_base, row=1)
        button_map = widget_button(button_base, value="Show Contour Plot", uvalue="MapButton")
        button_surface = widget_button(button_base, value="Show Surface Plot", uvalue="SurfaceButton")
    
    ; Widgets to display the metadata. Uncomment the bottom two rows to allow the RMSE displaying code to work
    metadata_base = widget_base(left_side_base, row=4, /GRID_LAYOUT)
      label_label_for_date = widget_label(metadata_base, value="Date:")
      label_date_string = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      label_label_for_time = widget_label(metadata_base, value="Time:")
      label_time = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      label_label_for_dgratio = widget_label(metadata_base, value="D:G ratio:")
      label_dgratio = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      label_label_for_AOT = widget_label(metadata_base, value="AOT:")
      label_AOT = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      ;label_label_for_RMSE = widget_label(metadata_base, value="RMSE:")
      ;label_RMSE = widget_label(metadata_base, value="", /DYNAMIC_RESIZE)
      
  
    draw_image = widget_draw(left_side_base, xsize=600, ysize=450)
  
    copyright_base = widget_base(left_side_base, row=1)
      label_copyright = widget_label(copyright_base, value="Created by Robin Wilson, University of Southampton, 2009") 
  
  draw_base = widget_base(base, row=2)
    draw_model = widget_draw(draw_base, xsize=600, ysize=450)
    draw_measured = widget_draw(draw_base, xsize=600, ysize=450)
  
  ; Set up info structure. Uncomment the field for label_RMSE to allow the RMSE code to work again
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
          label_date_string:label_date_string,$
          label_time:label_time,$
          label_AOT:label_AOT,$
          ;label_RMSE:label_RMSE,$
          last_dir_path:"C:\",$
          image_dir:"",$
          sunshine_file:"",$
          microtops_file:""}
  
  ; Realize the widgets (ie. actually create the GUI on screen)
  widget_control, base, /realize
  
  ; Put window indices into info. These are later used as parameters to the wset command to 
  ; set the draw control in which to plot the graphs.
  widget_control, draw_measured, get_value=win_measured_id
  widget_control, draw_image, get_value=win_image_id
  widget_control, draw_model, get_value=win_model_id
  info.win_measured_id = win_measured_id
  info.win_image_id = win_image_id
  info.win_modelled_id = win_model_id
 
   ; Ask for location of data files
  info.sunshine_file = dialog_pickfile(TITLE="Select Sunshine Sensor data file")
  info.microtops_file = dialog_pickfile(TITLE="Select Cimel data file")
  info.image_dir = dialog_pickfile(TITLE="Select sky image directory", /directory)
  
  ; Create a pointer to the info structure and put that in the uvalue of the top level base widget
  infoptr = ptr_new(info)
  widget_control, base, set_uvalue=infoptr
  
  
  ; Erase all draw widgets and set their color to be white
  wset, info.win_image_id
  Erase, Color=FSC_Color('white')
  wset, info.win_measured_id
  Erase, Color=FSC_Color('white')
  wset, info.win_modelled_id
  Erase, Color=FSC_Color('white')
  
  ; Start managing events
  xmanager, 'SKRAMVISPlus', base, /no_block
END