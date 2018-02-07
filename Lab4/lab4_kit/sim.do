
vlog lda/*/*.sv hvl/*.sv

vsim -gUNIT="$1" -novopt tb_top
