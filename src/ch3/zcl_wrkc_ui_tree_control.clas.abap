class ZCL_WRKC_UI_TREE_CONTROL definition
  public
  final
  create public .

public section.
  type-pools ICON .

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_WRKC_UI_TREE_CNTRL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WRKC_UI_TREE_CONTROL IMPLEMENTATION.


  METHOD /scwm/if_ex_wrkc_ui_tree_cntrl~change_tree_line.

    DATA: ls_view TYPE /scwm/s_packing_view .

    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.

    IF cs_line-guid_type EQ '07' AND "product line
       cs_line-cat(1) EQ 'Q'. "stock type
      cs_line-icon_node = icon_dispo_level.
    ENDIF.
*    ICON_DISPO_LEVEL
    IF cs_line-guid_type EQ '06' AND "HU line
       cs_line-copst IS NOT INITIAL. " HU completed
      cs_line-icon_node = icon_warehouse.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
