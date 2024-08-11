class ZCL_HU_BASICS_HUHDR definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_HU_BASICS_HUHDR .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HU_BASICS_HUHDR IMPLEMENTATION.


  method /SCWM/IF_EX_HU_BASICS_HUHDR~CHANGE.
    IF sy-uname ne 'T.BIRIHAN'.
      RETURN.
    ENDIF.

    CS_HUHDR-zz_volume = 10.

  endmethod.
ENDCLASS.
