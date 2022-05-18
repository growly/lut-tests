# This is the config used to openlane for synthesis only
set ::env(DESIGN_NAME) "LUT"

#set ::env(SYNTH_DEFINES) "FRACTURABLE PREDECODE_2"
set ::env(SYNTH_DEFINES) ""
set ::env(SYNTH_PARAMETERS) "INPUTS=5"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(CLOCK_TREE_SYNTH) 0
#set ::env(CLOCK_PORT) "config_clk"
set ::env(CLOCK_PORT) ""
# Design config
set ::env(CLOCK_PERIOD) 30
#set ::env(CLOCK_PERIOD) "5.21"
set ::env(SYNTH_STRATEGY) "DELAY 1"

#set ::env(FP_CORE_UTIL) 50
#set ::env(PL_TARGET_DENSITY) 0.99
set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) 0.49

# "Enable logic verification using yosys, for comparing each netlist at each
# stage of the flow with the previous netlist and verifying that they are
# logically equivalent." Logical equivalence checking?
#set ::env(LEC_ENABLE) "1"
#set ::env(FP_WELLTAP_CELL) "sky130_fd_sc_hd__tap*"

set ::env(CELL_PAD) "0"
set ::env(TOP_MARGIN_MULT) 1
set ::env(BOTTOM_MARGIN_MULT) 1
set ::env(LEFT_MARGIN_MULT) 2
set ::env(RIGHT_MARGIN_MULT) 2
#set ::env(FILL_INSERTION) "0"
#set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) "0"
#set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) "0"
#set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) "0"
#set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "0"

set ::env(RT_MAX_LAYER) "met4"
set ::env(GLB_RT_ALLOW_CONGESTION) "1"

#set ::env(CELLS_LEF) "$::env(DESIGN_DIR)/cells.lef"
#
#set ::env(DIE_AREA) "0 0 393.76 27.200000000000003"
#
#set ::env(DIODE_INSERTION_STRATEGY) "0"

set ::env(ROUTING_CORES) 28

set ::env(DESIGN_IS_CORE) "0"
#set ::env(FP_PDN_CORE_RING) "0"
##
#set ::env(PRODUCTS_PATH) "./build/8x32_DEFAULT/products"
#
#set ::env(INITIAL_NETLIST) "$::env(DESIGN_DIR)/RAM8.nl.v"
#set ::env(INITIAL_DEF) "$::env(DESIGN_DIR)/RAM8.placed.def"
#set ::env(INITIAL_SDC) "$::env(BASE_SDC_FILE)"
#
#set ::env(LVS_CONNECT_BY_LABEL) "1"
#
#set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
