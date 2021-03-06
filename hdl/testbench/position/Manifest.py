action = "simulation"
sim_tool = "modelsim"
vcom_opt = "-2008"
top_module = "position_tb"

target = "xilinx"
syn_device = "xc7a200t"

machine_pkg = "uvx_250M" # uvx_130M uvx_250M sirius_130M sirius_250M

modules = {"local" : ["../../",
                        "../../ip_cores/general-cores/","../../sim/test_pkg/"]}

files = ["position_tb.vhd", "blk_mem_gen_v8_2.vhd"]
