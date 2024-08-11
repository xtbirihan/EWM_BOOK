*&---------------------------------------------------------------------*
*& Report zewm_test_hu_selection
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_test_hu_selection.

TABLES: /scwm/s_quan_att.

PARAMETERS: p_lgnum TYPE /scwm/lgnum MEMORY ID /scwm/lgn OBLIGATORY.
SELECT-OPTIONS: sr_idplt FOR /scwm/s_quan_att-idplate.

DATA: lt_huhdr TYPE /scwm/tt_huhdr_int,
      lt_huitm TYPE /scwm/tt_huitm_int.

START-OF-SELECTION.
  DATA(lr_idplate) =  CORRESPONDING rseloption( sr_idplt[] ).
  /scwm/cl_tm=>set_lgnum( p_lgnum ).
  BREAK-POINT.
  CALL FUNCTION '/SCWM/HU_SELECT_GEN'
    EXPORTING
      iv_lgnum        = p_lgnum
      ir_idplate      = lr_idplate
      iv_filter_items = abap_true
    IMPORTING
      et_huhdr        = lt_huhdr
      et_huitm        = lt_huitm
    EXCEPTIONS
      wrong_input     = 1
      not_possible    = 2
      error           = 3
      OTHERS          = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  "Show the results in your own program
  "In this example we simply use class cl_demo_output as illustration
  cl_demo_output=>display( lt_huhdr ).
  cl_demo_output=>display( lt_huitm ).


  /scwm/cl_tm=>cleanup( ).
