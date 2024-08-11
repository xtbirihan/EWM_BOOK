*----------------------------------------------------------------------*
***INCLUDE LZEWM_CUSTOM_FIELDI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PRDO_SCREEN_PAI  INPUT
*&---------------------------------------------------------------------*
MODULE prdo_screen_pai INPUT.
 /scwm/cl_dlv_ui_badi_mgmt=>pai_item( iv_transaction = /scwm/if_ex_dlv_ui_screen=>sc_ta_prdo ).
ENDMODULE.
