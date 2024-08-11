*&---------------------------------------------------------------------*
*& Report z_change_tu
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_change_tu.

*1 select TU by S&R activity
PARAMETERS: p_tu_sr TYPE /scwm/de_tu_sr_act_num OBLIGATORY.

START-OF-SELECTION.

  "*2 get TU
  TRY.
      BREAK-POINT.
      DATA(lo_bom) = /scwm/cl_sr_bom=>get_instance( ).
      DATA(lo_bo_tu) = lo_bom->get_bo_tu_by_act_id( p_tu_sr   ).
      lo_bo_tu->get_data(
        IMPORTING
          es_bo_tu_data = DATA(ls_tu)
      ).
      "*3 change TU
      ls_tu-zz_myown_field = 'TEST'.
      lo_bo_tu->set_tu_data( ls_tu ).
      lo_bom->save( ).
    CATCH /scwm/cx_sr_error INTO DATA(lo_sr_error).
      ROLLBACK WORK.
      /scwm/cl_tm=>cleanup( ).
      RETURN.
  ENDTRY.
  COMMIT WORK AND WAIT.
  /scwm/cl_tm=>cleanup( ).
