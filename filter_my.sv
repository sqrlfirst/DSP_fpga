module filter_my(
    input           i_clk50M,

    // ADC
    output          o_adc_convst,
    output          o_adc_sck   ,
    output          o_adc_sdi   ,
    input           i_adc_sdo   ,
    // audio codec
    inout           io_ac_adclrck,
    input           i_ac_adcdat  ,
    inout           io_ac_daclrck,
    output          o_ac_dacdat  ,
    output          o_ac_xck     ,
    input           io_ac_bclk      

);

    parameter pDAC_DW = 24;
    // parameter DAC.DATA_WIDTH = pDAC_DW;

    logic               adc_clk;
    logic               adc_slave_clk;
    logic               adc_slave_rn;
    logic               adc_slave_cs_n;
    logic               adc_slave_addr;
    logic               adc_slave_read_n;
    logic               adc_slave_wr_n;
    logic [15:0]        adc_slave_read_data;
    logic [15:0]        adc_slave_wr_data;

    logic               filter_clk;
    logic               filter_rst_n;
    logic [12:0]        filter_ast_sink_data;
    logic               filter_ast_sink_valid;
    logic [1:0]         filter_ast_sink_err;

    logic [26:0]        filter_ast_source_data;
    logic [1:0]         filter_ast_source_err;
    logic               filter_ast_source_valid;
    
    logic               dac_clk;
    logic               dac_rst;
    logic               dac_write;
    logic [pDAC_DW-1:0] dac_write_data;
    logic               dac_full;
    logic               dac_clear;           
    
    // PLL
    

    // ADC module 
    adc_ltc2308_fifo ltc_fifo (
        // avalon slave port 
        .slave_clk              ( adc_slave_clk       ),
        .slave_reset_n          ( adc_slave_rn        ),
        .slave_chipselect_n     ( adc_slave_cs_n      ),
        .slave_addr             ( adc_slave_addr      ),
        .slave_read_n           ( adc_slave_rn        ),
        .slave_wrtie_n          ( adc_slave_wr_n      ),
        .slave_readdata         ( adc_slave_read_data ),
        .slave_wriredata        ( adc_slave_wr_n      ),
        
        .adc_clk                ( adc_clk      ), // max 40mhz
        // adc interface
        .ADC_CONVST             ( o_adc_convst ),
        .ADC_SCK                ( o_adc_sck    ),
        .ADC_SDI                ( o_adc_sdi    ),
        .ADC_SDO                ( i_adc_sdo    )
    );


    // filter
    FIR_mine u_FIR_mine(
        .clk              ( filter_clk             ),
        .reset_n          ( filter_rst_n           ),
        .ast_sink_data    ( filter_ast_sink_data   ),
        .ast_sink_valid   ( filter_ast_sink_valid  ),
        .ast_sink_error   ( filter_ast_sink_err    ),

        .ast_source_data  ( filter_ast_source_data  ),
        .ast_source_valid ( filter_ast_source_valid ),
        .ast_source_error ( filter_ast_source_err   )
    );


    // DAC implementation
    AUDIO_DAC       DAC (
	// host
	    .clk                ( dac_clk        ),
	    .reset              ( dac_rst        ),
	    .write              ( dac_write      ),
	    .writedata          ( dac_write_data ),
	    .full               ( dac_full       ),
	    .clear              ( dac_clear      ),
	// dac
	    .bclk               ( io_ac_bclk    ),
	    .daclrc             ( io_ac_daclrck ),
	    .dacdat             ( o_ac_dacdat   )
    );

    // FSM

    filter_fsm 
    #(
        .pDAC_DW (pDAC_DW )
    )
    u_filter_fsm (
	    .iclk                    (iclk                    ),
        .adc_slave_clk           (adc_slave_clk           ),
        .adc_slave_rn            (adc_slave_rn            ),
        .adc_slave_cs_n          (adc_slave_cs_n          ),
        .adc_slave_addr          (adc_slave_addr          ),
        .adc_slave_read_n        (adc_slave_read_n        ),
        .adc_slave_wr_n          (adc_slave_wr_n          ),
        .adc_slave_read_data     (adc_slave_read_data     ),
        .adc_slave_wr_data       (adc_slave_wr_data       ),
        .filter_rst_n            (filter_rst_n            ),
        .filter_ast_sink_data    (filter_ast_sink_data    ),
        .filter_ast_sink_valid   (filter_ast_sink_valid   ),
        .filter_ast_sink_err     (filter_ast_sink_err     ),
        .filter_ast_source_data  (filter_ast_source_data  ),
        .filter_ast_source_err   (filter_ast_source_err   ),
        .filter_ast_source_valid (filter_ast_source_valid ),
        .dac_rst                 (dac_rst                 ),
        .dac_write               (dac_write               ),
        .dac_write_data          (dac_write_data          ),
        .dac_full                (dac_full                ),
        .dac_clear               (dac_clear               )
    );

endmodule 