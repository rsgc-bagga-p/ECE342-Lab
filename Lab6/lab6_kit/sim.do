proc build {proj} {
  if {$proj == "pt1"} {
    vlog part1/*.sv part1/cpu/*.sv part1/hvl/*.sv
  } elseif {$proj == "pt2"} {
    puts "pt2 testbench has not yet been configured, look inside sim.do"
  } elseif {$proj == "pt3"} {
    vlog part3/lda/common/*.sv part3/lda/lda/*.sv part3/lda/lda_asc/*.sv part3/hvl/*.sv
  } else {
    puts "invalid part selected (pt1|pt2|pt3)"
  }
}


if {$1 == "-r"} {
  build $2
  restart -f
} else {
  build $1
  vsim -gUNIT="$2" -novopt tb_top
}
