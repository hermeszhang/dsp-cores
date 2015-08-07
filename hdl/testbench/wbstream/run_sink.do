vsim -l output.log -t 1ps -L unisim work.wb_stream_sink_tb -voptargs="+acc"
add wave \
sim:/wb_stream_sink_tb/*
add wave sim:/wb_stream_sink_tb/DUT/r_mid_tgd
add wave sim:/wb_stream_sink_tb/DUT/r_snk_stall_o
add wave sim:/wb_stream_sink_tb/DUT/en_rd
add wave  \
sim:/wb_stream_sink_tb/DUT/r_mid_tgd \
sim:/wb_stream_sink_tb/DUT/r_mid
assertion action -cond fail -exec exit
onbreak quit
-- run -all
run 3 us
config wave -signalnamewidth 1
wave zoomfull
radix -hexadecimal
