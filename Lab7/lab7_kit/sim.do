proc build {} {
  vlog tb.sv cpu/*.sv
}

build
vsim -novopt tb
