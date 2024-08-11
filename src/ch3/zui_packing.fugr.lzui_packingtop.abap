FUNCTION-POOL zui_packing.                  "MESSAGE-ID ..

TABLES: /scwm/s_pack_view_scanner.
DATA: gs_dest_hu   TYPE /scwm/s_huhdr_int,
      gs_source_hu TYPE /scwm/s_huhdr_int,
      go_model     TYPE REF TO /scwm/cl_wm_packing.
* INCLUDE LZUI_PACKINGD...                   " Local class definition
