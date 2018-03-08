vlog part1/*.sv part1/cpu/*.sv hvl/*.sv
vsim -gUNIT="$1" -novopt tb_top
