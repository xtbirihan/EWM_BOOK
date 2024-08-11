FUNCTION ZRF_H1_TMPL_TEMPLATE_CALL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------

  DATA lv_tmpl_num TYPE sy-dynnr.

  lv_tmpl_num = /scwm/cl_rf_bll_srvc=>get_tmpl_num( ).

  IF /scwm/cl_rf_dynpro_srvc=>get_popup_webgui( ) = abap_false.
    CALL SCREEN lv_tmpl_num.
  ELSE.
    "DISPLAY_MESSAGE must be displayed as popup to trigger a sound
    CALL SCREEN lv_tmpl_num STARTING AT 1 1.
    /scwm/cl_rf_dynpro_srvc=>set_popup_webgui( iv_popup_webgui = abap_false ).
  ENDIF.

ENDFUNCTION.
