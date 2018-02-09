
vlog common/*.sv lda/*/*pkg.sv lda/*/*.sv lda/*/*.v hvl/*.sv

vsim -gUNIT="$1" -novopt tb_top
