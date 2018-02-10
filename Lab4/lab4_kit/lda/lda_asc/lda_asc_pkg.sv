package lda_asc_pkg;

  typedef enum
  {
    MODE,
    STATUS,
    GO,
    START_P,
    END_P,
    COLOR,
    NONE
  } lda_reg_t;

  function automatic logic [31:0] assign_readdata
  (
    lda_reg_t rd_sel,
    logic mode,
    logic status,
    logic [8:0] x0,
    logic [8:0] x1,
    logic [7:0] y0,
    logic [7:0] y1,
    logic [2:0] color
  );

    begin
      case (rd_sel)
        MODE:    return {'0,mode};
        STATUS:  return {'0,status};
        GO:      return {'0};
        START_P: return {'0,y0,x0};
        END_P:   return {'0,y1,x1};
        COLOR:   return {'0,color};
        NONE:    return {'0};
        default: return {'0};
      endcase
    end

  endfunction

endpackage
