module filter_fsm #(
    parameter pDAC_DW = 24

)(
    input           iclk,
    // adc
    output              adc_slave_clk,
    output              adc_slave_rn,
    output              adc_slave_cs_n,
    output              adc_slave_addr,
    output              adc_slave_read_n,
    output              adc_slave_wr_n,
    input [15:0]        adc_slave_read_data,
    output [15:0]       adc_slave_wr_data,
    // filter
    output               filter_rst_n,
    output [12:0]        filter_ast_sink_data,
    output               filter_ast_sink_valid,
    output [1:0]         filter_ast_sink_err,

    input [26:0]        filter_ast_source_data,
    input [1:0]         filter_ast_source_err,
    input               filter_ast_source_valid,
    // dac

    output               dac_rst,
    output               dac_write,
    output [pDAC_DW-1:0] dac_write_data,
    input               dac_full,
    output               dac_clear
);



endmodule 