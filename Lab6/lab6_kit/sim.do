vlog part1/*.sv part1/cpu/*.sv hvl/*.sv part3/lda/*/*.sv
vsim -gUNIT="$1" -novopt tb_top
