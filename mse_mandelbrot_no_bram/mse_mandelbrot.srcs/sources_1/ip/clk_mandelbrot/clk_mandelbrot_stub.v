// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue Apr 17 19:15:21 2018
// Host        : MACCHI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Jeremie/Dropbox/Master/Cours/Semestre2/LPSC/Labo/Labo/mse_mandelbrot_no_bram/mse_mandelbrot.srcs/sources_1/ip/clk_mandelbrot/clk_mandelbrot_stub.v
// Design      : clk_mandelbrot
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_mandelbrot(ClkMandelxC, reset, PllLockedxSO, 
  ClkSys100MhzxC)
/* synthesis syn_black_box black_box_pad_pin="ClkMandelxC,reset,PllLockedxSO,ClkSys100MhzxC" */;
  output ClkMandelxC;
  input reset;
  output PllLockedxSO;
  input ClkSys100MhzxC;
endmodule
