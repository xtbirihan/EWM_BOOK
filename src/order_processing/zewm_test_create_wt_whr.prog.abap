*&---------------------------------------------------------------------*
*& Report zewm_test_create_wt_whr
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_test_create_wt_whr.


DATA: lv_docno    TYPE /scdl/dl_docno_int.
DATA: lt_ltap_vb  TYPE /scwm/tt_ltap_vb,
      lt_bapiret  TYPE bapirettab,
      lv_severity TYPE bapi_mtype.


PARAMETERS: p_lgnum TYPE /scwm/lgnum MEMORY ID /scwm/lgn OBLIGATORY.

SELECT-OPTIONS: s_docno FOR lv_docno.

*DATA: lt_sdocno LIKE TABLE OF s_docno.

START-OF-SELECTION.

  /scwm/cl_tm=>set_lgnum( p_lgnum ).

  "Prepare Selection of Outbound Delivery Orders
  " Delivery number
  DATA(lt_selection) = VALUE /scwm/dlv_selection_tab( FOR ls_sel IN s_docno[]
                                                          ( fieldname =  /scdl/if_dl_logfname_c=>sc_docno_h
                                                            sign      = ls_sel-sign
                                                            option    = ls_sel-option
                                                            low       = ls_sel-low
                                                            high      = ls_sel-high  )  ).
  BREAK-POINT.

  " Adjust selection table for wildcard searches
  /scwm/cl_dlv_ui_services=>modify_wildcard_selections(
    CHANGING
      ct_selections_prd = lt_selection
  ).

* Select data
  DATA(lo_prd) = /scwm/cl_dlv_management_prd=>get_instance( ).

  TRY.
      lo_prd->query(
        EXPORTING
          iv_whno                     = p_lgnum
          it_selection                = lt_selection
          iv_doccat                   = /scdl/if_dl_doc_c=>sc_doccat_out_prd
          is_read_options             = VALUE #( data_retrival_only = abap_true mix_in_object_instances = abap_true )
          is_include_data             = VALUE #( )
        IMPORTING
          et_items                    = DATA(lt_items)
      ).
    CATCH /scdl/cx_delivery.
      RETURN.
  ENDTRY.

* Create WT to be shown in UI
  DATA(lt_prepare_whr_int) =  VALUE /scwm/tt_to_prepare_whr_int(
                                FOR <fs_items> IN lt_items
                                  (  rdoccat   = <fs_items>-doccat
                                     rdocid    = <fs_items>-docid
                                     ritmid    = <fs_items>-itemid  ) ).


  CALL FUNCTION '/SCWM/TO_PREP_WHR_UI_INT'
    EXPORTING
      iv_lgnum           = p_lgnum
      iv_mode            = wmegc_whr_mode_dia
      iv_process         = wmegc_whr_proc_pi
      it_prepare_whr_int = lt_prepare_whr_int
    IMPORTING
      et_ltap_vb         = lt_ltap_vb
      et_bapiret         = lt_bapiret
      ev_severity        = lv_severity.
  IF lv_severity CA wmegc_severity_ea.
    "error handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.

* Show WTs in UI
  "Show WTs(lt_ltap_vb) and errors(lt_bapiret) in your own program
  "In this example we simply use class cl_demo_output as illustration
*  cl_demo_output=>display( lt_ltap_vb ).

* The user decided to save the results using your custom UI.
* We proceed saving the WTs on Database.
  DATA: lv_tanum TYPE /scwm/tanum .
  CALL FUNCTION '/SCWM/TO_POST'
    EXPORTING
      iv_update_task = abap_True
      iv_commit_work = abap_true
    IMPORTING
      ev_tanum       = lv_tanum
      ev_severity    = lv_severity
*     ev_lognr       = ev_lognr
*     et_ltap_vb     = et_ltap_vb
*     et_ltap_err    = et_ltap_err
      et_bapiret     = lt_bapiret.

  IF lv_severity CA wmegc_severity_ea.
    "error handling
    "inform the user about issues during posting of WTs in your program (e.g. MESSAGE…)
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.
  /scwm/cl_tm=>cleanup( ).
