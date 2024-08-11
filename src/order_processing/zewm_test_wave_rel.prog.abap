*&---------------------------------------------------------------------*
*& Report zewm_test_wave_rel
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_test_wave_rel.

PARAMETERS: p_lgnum TYPE /scwm/lgnum OBLIGATORY,
            p_wave  TYPE /scwm/de_wave.

DATA: lt_wavehdr  TYPE /scwm/tt_wavehdr_int,
      lt_bapiret  TYPE bapiret2_t,
      lv_severity TYPE bapi_mtype.
DATA: lt_waveitm TYPE /scwm/tt_waveitm_int,
      lt_ltap_vb TYPE /scwm/tt_ltap_vb,
      lt_missing TYPE /scwm/tt_missing_sim.
DATA: lt_ordim_o TYPE /scwm/tt_ordim_o_int.

START-OF-SELECTION.


  /scwm/cl_tm=>cleanup( iv_lgnum = p_lgnum ).

* Check wave existence

  DATA(lt_wave) = VALUE /scwm/tt_wave_no( ( lgnum = p_lgnum wave = p_wave )  ).

  CALL FUNCTION '/SCWM/WAVE_SELECT_EXT'
    EXPORTING
      iv_lgnum    = p_lgnum
      iv_rdoccat  = wmegc_doccat_pdo
      it_wave     = lt_wave
    IMPORTING
      et_wavehdr  = lt_wavehdr
      et_bapiret  = lt_bapiret
      ev_severity = lv_severity.

  IF lv_severity CA 'EA' OR lt_wavehdr IS INITIAL.
    "wave doesn't exit
    MESSAGE e003(/scwm/wave) WITH p_lgnum p_wave.
    RETURN.
  ENDIF.

* Run Wave Simulation
  CALL FUNCTION '/SCWM/WAVE_SIMULATE_EXT'
    EXPORTING
      iv_lgnum           = p_lgnum
      iv_rdoccat         = wmegc_doccat_pdo
      it_wave_no         = lt_wave
      iv_simulate_single = abap_true
      iv_background      = abap_true
    IMPORTING
      et_waveitm         = lt_waveitm
      et_ltap_vb         = lt_ltap_vb
      et_missing         = lt_missing.

* Show results on UI
  "show WTs(lt_ltap_vb) and missing items(lt_missing) in your own UI

* User decides to proceed with wave release
  CALL FUNCTION '/SCWM/WAVE_RELEASE_EXT'
    EXPORTING
      it_wave_no     = lt_wave
      iv_commit_work = abap_true
    IMPORTING
      et_ordim_o     = lt_ordim_o
      et_bapiret     = lt_bapiret
      ev_severity    = lv_severity.

  IF lv_severity CA 'EAX'.
    "Error Handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
  ENDIF.

* Reset global variables
  /scwm/cl_tm=>cleanup( ).
