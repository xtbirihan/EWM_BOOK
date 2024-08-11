class ZCL_DLV_UI_SCREEN definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_DLV_UI_SCREEN .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DLV_UI_SCREEN IMPLEMENTATION.


  METHOD /scwm/if_ex_dlv_ui_screen~define_item_extension.

    IF iv_transaction EQ /scwm/if_ex_dlv_ui_screen=>sc_ta_prdo.
      ev_repid = 'SAPLZEWM_CUSTOM_FIELD'.
      ev_dynnr = 0100.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
