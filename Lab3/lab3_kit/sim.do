
vlog de1soc_top.sv common/*.sv ui/*.sv lda/*.sv hvl/*.sv

vsim -gUNIT="$1" -novopt tb_top
