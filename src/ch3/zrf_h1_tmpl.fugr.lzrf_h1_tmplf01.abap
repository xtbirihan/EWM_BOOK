*----------------------------------------------------------------------*
***INCLUDE /SCWM/LRF_TMPLF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_etd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_etd .

  DATA: l_applic TYPE /scwm/de_applic,
        l_disp_prf TYPE /scwm/de_disp_prf,
        l_pres_prf TYPE /scwm/de_pres_prf,
        l_prsn_prf TYPE /scwm/de_prsn_prf,
        l_push_btn_qty TYPE /scwm/de_pushb_qty,
        l_fnkey_qty TYPE /scwm/de_fnkey_qty,
        l_ltrans TYPE /scwm/de_ltrans,
        l_ltrans_simu TYPE /scwm/de_ltrans,
        l_step TYPE /scwm/de_step,
        l_state TYPE /scwm/de_state,
        l_scr_sqnc TYPE /scwm/de_scr_sqnce,
        l_scr_progr TYPE /scwm/de_scr_progr,
        l_scr_num TYPE /scwm/de_scr_num,
        l_scr_type type /scwm/de_scr_type.

***  DATA(lv_cloud_system) = CAST /scwm/if_tm_global_info( /scwm/cl_tm_factory=>get_service( /scwm/cl_tm_factory=>sc_globals ) )->is_s4h_cloud( ).
***  IF lv_cloud_system = abap_true.
***    RETURN.
***  ENDIF.

* Capture the Screens technical information.
  l_applic = /scwm/cl_rf_bll_srvc=>get_applic( ).
  l_disp_prf = /scwm/cl_rf_bll_srvc=>get_disp_prf( ).
  l_pres_prf = /scwm/cl_rf_bll_srvc=>get_pres_prf( ).
  l_prsn_prf = /scwm/cl_rf_bll_srvc=>get_prsn_prf( ).
  l_push_btn_qty = /scwm/cl_rf_bll_srvc=>get_pushb_qty( ).
  l_fnkey_qty = /scwm/cl_rf_bll_srvc=>get_fnkey_qty( ).
  l_ltrans = /scwm/cl_rf_bll_srvc=>get_ltrans_real( ).
  l_ltrans_simu = /scwm/cl_rf_bll_srvc=>get_ltrans( ).
  l_step = /scwm/cl_rf_bll_srvc=>get_step( ).
  l_state = /scwm/cl_rf_bll_srvc=>get_state( ).
* To harmonize with other program corrections we set the state to default
* value.For example in FORM delete_rf_customizing implements the "Undo"
* functionality in wizard, the code before deleting of the screen changes
* set the state:
*   IF g_flow_param-state IS INITIAL.
*    g_flow_param-state = '******'.
*  ENDIF.
* If we don't set the default value ******, the screen will be saved with
* state =  SPACE, and the delete does'nt find the entry in the table
* /SCWM/TSTEP_SCR. --> Undo functionality dies'nt work.
  IF l_state IS INITIAL.
    l_state = '******'. " Set the default state value
  ENDIF.
  l_scr_sqnc = /scwm/cl_rf_bll_srvc=>get_scr_sqnce( ).
*  l_scr_progr = /scwm/cl_rf_bll_srvc=>get_tmpl_progr( ).
*  l_scr_num = /scwm/cl_rf_bll_srvc=>get_tmpl_num( ).
  l_scr_progr = /SCWM/CL_RF_DYNPRO_SRVC=>mv_scr_progr.
  l_scr_num   = /SCWM/CL_RF_DYNPRO_SRVC=>mv_scr_num.

  IF l_step = 'RFMENU'.
    l_scr_type = 'RFMENU'.
  ELSE.
    l_scr_type = 'SCREEN'.
  ENDIF.

* Call the ETD Dialog.
    CALL FUNCTION '/SCWM/RF_START_ETD'
      EXPORTING
        iv_applic       = l_applic
        iv_disp_prf     = l_disp_prf
        iv_pres_prf     = l_pres_prf
        iv_prsn_prf     = l_prsn_prf
        iv_push_btn_qty = l_push_btn_qty
        iv_fnkey_qty    = l_fnkey_qty
        iv_ltrans       = l_ltrans
        iv_ltrans_simu  = l_ltrans_simu
        iv_step         = l_step
        iv_state        = l_state
        iv_scr_sqnc     = l_scr_sqnc
        iv_scr_progr    = l_scr_progr
        iv_scr_num      = l_scr_num
        iv_scr_type     = l_scr_type.


  ENDFORM.                    " call_etd
