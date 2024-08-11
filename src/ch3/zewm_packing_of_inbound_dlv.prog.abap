*&---------------------------------------------------------------------*
*& Report zewm_packing_of_inbound_dlv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_packing_of_inbound_dlv.

TYPE-POOLS:wmegc.
TABLES: /scwm/s_wrk_pack.
DATA: ls_worksttyp    TYPE /scwm/twrktyp,
      lt_docid        TYPE /scwm/tt_docid,
      ls_docid        TYPE /scwm/s_docid,
      ls_workstation  TYPE /scwm/tworkst,
*      lo_pack_ibdl    TYPE REF TO /scwm/cl_dlv_pack_ibdl,
      lv_foreign_lock TYPE xfeld,
      lv_ucomm        TYPE sy-ucomm VALUE 'SAVE'.

*1 SelectionScreen
PARAMETERS: pa_lgnum TYPE /scwm/s_wrk_pack-lgnum OBLIGATORY.
PARAMETERS: pa_wrkst TYPE /scwm/s_wrk_pack-workstation.
PARAMETERS: paprd    TYPE /scwm/s_wrk_pack-docno.

AT SELECTION-SCREEN.
*2 Validate Workcenter and Delivery Document Number

  CALL FUNCTION '/SCWM/TWORKST_READ_SINGLE'
    EXPORTING
      iv_lgnum       = pa_lgnum
      iv_workstation = pa_wrkst
    IMPORTING
      es_workst      = ls_workstation
      es_wrktyp      = ls_worksttyp
    EXCEPTIONS
      error          = 1
      not_found      = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_workstation-save_act = space."not recommended
  ls_worksttyp-tr_004 = abap_true."Auto-Pack

* validate that this workcenter is feasible for inbound packing
  CALL FUNCTION '/SCWM/RF_DOCNO_TO_DOCID'
    EXPORTING
      iv_docno      = paprd
      iv_whr_doccat = wmegc_doccat_pdi
    IMPORTING
      ev_rdocid     = ls_docid-docid
    EXCEPTIONS
      not_found     = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE e000(/scwm/rf_en) WITH paprd.
  ENDIF.

*3 call work center UI

  DATA(lo_pack_ibdl) = NEW /scwm/cl_dlv_pack_ibdl( ).
  APPEND ls_docid TO lt_docid.

  WHILE lv_ucomm = 'SAVE' OR lv_ucomm = 'REFRESH'.
    /scwm/cl_tm=>set_lgnum( ls_workstation-lgnum ).
* calculate the open quantity,but no refresh
    lo_pack_ibdl->init(
      EXPORTING
        iv_lgnum         = ls_workstation-lgnum
        it_docid         = lt_docid
        iv_doccat        = wmegc_doccat_pdi
        iv_no_refresh    = abap_true
        iv_lock_dlv      = abap_true
*        iv_no_quan_check = iv_no_quan_check
*        iv_partial       = iv_partial
      IMPORTING
        ev_foreign_lock  = lv_foreign_lock
*        ev_batch_initial = ev_batch_initial
*        et_doc_lock      = et_doc_lock
*        ev_tw_items      = ev_tw_items
*        ev_asr_mixed     = ev_asr_mixed
*        ev_asr_brfw      = ev_asr_brfw
    ).
    IF  lv_foreign_lock IS NOT INITIAL.
      MESSAGE i097(/scwm/ui_packing).
    ENDIF.

    /scwm/cl_dlv_pack_ibdl=>gv_online = abap_true.
    ls_worksttyp-lgnum = pa_lgnum.
    ls_worksttyp-trtyp = '6'."PackingInbound

    CALL FUNCTION '/SCWM/PACKING_UI'
      EXPORTING
        iv_plan        = abap_True
        iv_model       = lo_pack_ibdl
        iv_display     = space
      IMPORTING
        ev_fcode       = lv_ucomm
      CHANGING
        cs_workstation = ls_workstation
        cs_worksttyp   = ls_worksttyp.
    /scwm/cl_tm=>cleanup( ).
  ENDWHILE.
