FUNCTION zsort_zst1_enter.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZSORT) TYPE  ZRF_SORT
*"----------------------------------------------------------------------

  DATA: lt_rng_idplate TYPE rseloption,
        ls_rng_idplate TYPE rsdsselopt,
        lt_huitm       TYPE /scwm/tt_huitm_int,
        ls_huitm       TYPE /scwm/s_huitm_int,
        lv_lines       TYPE sy-tabix,
        lv_open_to     TYPE xfeld.

  BREAK-POINT ID zrf_sort.

  CLEAR: zsort-source_hu, zsort-guid_stock.
  IF zsort-idplate IS INITIAL.
    MESSAGE 'Enter a stock identification' TYPE 'E'.
  ENDIF.


* check if ID is a valid stock identification
  ls_rng_idplate-low = zsort-idplate.
  ls_rng_idplate-sign = 'I'.
  ls_rng_idplate-option = 'EQ'.
  APPEND ls_rng_idplate TO lt_rng_idplate.


  CALL FUNCTION '/SCWM/HU_SELECT_QUAN'
    EXPORTING
      iv_lgnum     = zsort-lgnum
      ir_idplate   = lt_rng_idplate
    IMPORTING
      et_huitm     = lT_HUITM
    EXCEPTIONS
      wrong_input  = 1
      not_possible = 2
      OTHERS       = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DELETE lt_huitm WHERE vsi <> wmegc_physical_stock.

  READ TABLE lt_huitm INTO ls_huitm
  WITH KEY idplate = zsort-idplate.
  IF sy-subrc IS NOT INITIAL.
    CLEAR: zsort-idplate.
    MESSAGE 'Stock Identification not found' TYPE 'E'.
    RETURN.
  ENDIF.

* validations

  CALL FUNCTION '/SCWM/CHECK_OPEN_TO'
    EXPORTING
      iv_hu    = ls_huitm-guid_parent
      iv_lgnum = zsort-lgnum
    IMPORTING
      ev_exist = lv_open_to
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF lv_open_to IS NOT INITIAL.
    MESSAGE 'Open Task exists for pick-HU' TYPE 'E'.
  ENDIF.

* set technical fields in RF application
  zsort-source_hu = ls_huitm-guid_parent.
  zsort-guid_stock = ls_huitm-guid_stock.
ENDFUNCTION.
