FUNCTION zsort_zst2_exceptions.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZSORT) TYPE  ZRF_SORT
*"----------------------------------------------------------------------


  CONSTANTS:lc_buscon(3)   VALUE '9PA',
            lc_execstep(2) VALUE '18'.
  DATA:
    lv_shortcut TYPE /scwm/de_shortcut,
    ls_exccode  TYPE /scwm/s_iexccode,
    lv_fcode    TYPE /scwm/de_fcode.

  BREAK-POINT ID zrf_sort.

* 1checks&initializations
  IF zsort-source_hu IS INITIAL .
    RETURN.
  ENDIF.
* getshortcut
  CALL METHOD /scwm/cl_rf_bll_srvc=>get_shortcut
    RECEIVING
      rv_shortcut = lv_shortcut.

* CreateinstanceofExceptionobject
  CALL METHOD /scwm/cl_exception_appl=>create_exception_object
    RECEIVING
      rp_excep = DATA(lo_excep).

*2 verifyexceptioncodeenteredbytheuser
  ls_exccode-exccode = lv_shortcut.
  CALL METHOD /scwm/cl_exception_appl=>verify_exception_code
    EXPORTING
      is_appl_item_data = zsort
      iv_lgnum          = zsort-lgnum
      iv_buscon         = lc_buscon
      iv_execstep       = lc_execstep
      ip_excep          = lo_excep
    CHANGING
      cs_exccode        = ls_exccode.

* Exceptioncodeisnotmaintainedincustomizing
  IF ls_exccode-valid <> abap_true.
* exceptioncodeisnotallowed
    MESSAGE e003(/scwm/exception) WITH ls_exccode-exccode.
    RETURN.
  ENDIF.
*3 handleexceptions
  CASE ls_exccode-iprcode.
    WHEN wmegc_iprcode_list.
* 4handleexceptioncode”list”
      CALL FUNCTION '/SCWM/RSRC_EXCEPTION_LIST_FILL'
        EXPORTING
          iv_lgnum     = zsort-lgnum
          iv_buscon    = lc_buscon
          iv_exec_step = lc_execstep.

      lv_fcode = wmegc_iprcode_list.
      /scwm/cl_rf_bll_srvc=>set_fcode( lv_fcode ).
      /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_background ).

      CALL METHOD /scwm/cl_rf_bll_srvc=>set_field
        EXPORTING
          iv_field = '/SCWM/S_RF_SCRELM-SHORTCUT'.
    WHEN wmegc_iprcode_skfd.
* 5handleexceptioncode”Skipverificationfield”
      zsort-matnr_verif = zsort-matnr."verifytheproduct
      /scwm/cl_rf_bll_srvc=>set_prmod( /scwm/cl_rf_bll_srvc=>c_prmod_foreground ).
    WHEN OTHERS.
      MESSAGE e003(/scwm/exception) WITH lv_shortcut.
* exceptioncodeisnotallowed
  ENDCASE.
  CALL METHOD /scwm/cl_rf_bll_srvc=>clear_shortcut.

ENDFUNCTION.
