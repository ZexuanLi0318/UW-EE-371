# NOTES:
#  - The most important thing is locating where all of the files
#    are and specifying the correct paths (absolute or relative)
#    in the commands below.
#  - You will also need to make sure that your current directory
#    (cd) in ModelSim is the directory containing this .do file.


# Create work library
vlib work


# Compile Verilog
#  - All Verilog files that are part of this design should have
#    their own "vlog" line below.
vlog "./seg7.sv"
vlog "./task1.sv"
vlog "./ram32x3.v"
vlog "./task2.sv"
vlog "./task2_top_level.sv"
vlog "./clock_divider.sv"
vlog "./ram32x3port2.v"
vlog "./DE1_SoC.sv"



# Call vsim to invoke simulator
#  - Make sure the last item on the line is the correct name of
#    the testbench module you want to execute.
#  - If you need the altera_mf_ver library, add "-Lf altera_mf_lib"
#    (no quotes) to the end of the vsim command
#vsim -voptargs="+acc" -t 1ps -lib work task1_testbench -Lf altera_mf_ver
#vsim -voptargs="+acc" -t 1ps -lib work task2_testbench
#vsim -voptargs="+acc" -t 1ps -lib work task2_top_level_testbench -Lf altera_mf_ver
vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench -Lf altera_mf_ver

# Source the wave do file
#  - This should be the file that sets up the signal window for
#    the module you are testing.
#do task1_wave.do
#do task2_wave.do
#do DE1_SoC_wave.do
#do task2_top_level_wave.do
do DE1_SoC_task3_wave.do



# Set the window types
view wave
view structure
view signals


# Run the simulation
run -all


# End
