action = "simulation"
target = "xilinx"
vcom_opt = "-2008"

syn_device = "xc7a200t"
sim_tool = "modelsim"
top_module = "delta_sigma_tb"

machine_pkg = "uvx_130M"

modules = {"local" : ["../../","../../ip_cores/general-cores/","../../sim/test_pkg/"]}

files = ["delta_sigma_tb.vhd"]
