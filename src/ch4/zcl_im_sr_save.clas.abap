CLASS zcl_im_sr_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /scwm/if_ex_sr_save .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_IM_SR_SAVE IMPLEMENTATION.


  METHOD /scwm/if_ex_sr_save~before_save.

    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.
    LOOP AT it_bo_tu ASSIGNING FIELD-SYMBOL(<fs_bo_tu>).

      IF <fs_bo_tu>-bo_ref IS NOT BOUND.
        CONTINUE.
      ENDIF.
      TRY.
          <fs_bo_tu>-bo_ref->get_data(
            IMPORTING
              ev_objstate   = DATA(lv_state)
              et_ident      = DATA(lt_ident)
          ).
        CATCH /scwm/cx_sr_error INTO DATA(lo_cx_sr_error).
      ENDTRY.

      "* 1.check changing indicator of object
      IF   lv_state NE wmesr_objstate_new AND
           lv_state NE wmesr_objstate_chg.
        CONTINUE.
      ENDIF.

      "* * 2.determine context
      IF <fs_bo_tu>-bo_ref->get_sr_act_state( ) NE wmesr_act_state_active.
        CONTINUE.
      ENDIF.

      IF <fs_bo_tu>-bo_ref->get_status_change_by_id( wmesr_status_check_in ) NE abap_true.
        CONTINUE.
      ENDIF.

      "* 3.check for pager
      IF NOT line_exists( lt_ident[ idart = 'P' ] ) OR lt_ident[ idart = 'P' ]-ident IS INITIAL.
        DATA(lv_check) = 1."no pager
      ENDIF.

      "* 4.check for lic_plate
      TRY.
          <fs_bo_tu>-bo_ref->get_data(
            IMPORTING
              es_bo_tu_data = DATA(ls_bo_tu_data)
              ).
        CATCH /scwm/cx_sr_error INTO lo_cx_sr_error.
      ENDTRY.

      IF ( ls_bo_tu_data-lic_plate = '' OR ls_bo_tu_data-lic_plate_country = '' ) AND lv_check = 1.
        lv_check = 3."no pager and no lic_plate
      ELSEIF ( ls_bo_tu_data-lic_plate = '' OR
      ls_bo_tu_data-lic_plate_country = '' ).
        lv_check = 2 ."no lic_plate
      ENDIF.

      "* 5.raise message
      CASE lv_check.
        WHEN 1. "no pager
          MESSAGE e361(zyewm) INTO DATA(lv_msg).
        WHEN 2. "no lic_plate
          MESSAGE e362(zyewm) INTO lv_msg.
        WHEN 3."”no pager and lic_plate
          MESSAGE e363(zyewm) INTO lv_msg.
      ENDCASE.

      "* 6.add message to current log and raise exception
      IF lv_check IS NOT INITIAL.
        /scwm/cl_sr_bom=>so_log->add_message( ).
        RAISE EXCEPTION TYPE /scwm/cx_sr_error.
      ENDIF.
      CLEAR: lv_msg, lv_check.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
