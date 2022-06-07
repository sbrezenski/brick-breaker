set_global_assignment -entity "my_adc" -library "lib_my_adc" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "my_adc" -library "lib_my_adc" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "my_adc" -library "lib_my_adc" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_my_adc" -name SPD_FILE [file join $::quartus(sip_path) "../my_adc.spd"]
set_global_assignment -library "lib_my_adc" -name MISC_FILE [file join $::quartus(sip_path) "../../my_adc.qsys"]

set_global_assignment -library "lib_my_adc" -name MISC_FILE [file join $::quartus(sip_path) "my_adc.vhd"]
