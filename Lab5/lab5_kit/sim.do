vlog hdl/*.sv hvl/*.sv
vsim -gUNIT="$1" -gTFILE="$2" -novopt tb_top
