module line_buffer #(
    parameter integer M = 3,        // Number of channels
    parameter integer W = 512,       // Width of each Image
    parameter integer n = 4,          // Input Tile size
    parameter integer m = 2         // Output tiles, which is also the Stride
)(
    input                   i_clk,
    input                   i_rst,
    input  [7:0]            i_data,
    input                   i_data_valid,
    output reg [M*n*8-1:0] o_data,
    input                   output_needs_to_be_read
);

    // Calculate pointer width based on M*W
    localparam PNTR_WIDTH = $clog2(M*W);

    // Internal signals
    reg [7:0] line [0:M*W-1];       // Line buffer memory
    reg [PNTR_WIDTH-1:0] wrPntr;   // Write pointer
    reg [PNTR_WIDTH-1:0] rdPntr;   // Read pointer
    integer i,j;

    // Write pointer logic
    always @(posedge i_clk) begin
        if (i_rst)
            wrPntr <= 0;
        else if (i_data_valid)
            wrPntr <= wrPntr + 1;
    end


    // Write data to line buffer
    always @(posedge i_clk) begin
        if (i_data_valid)
            line[wrPntr] <= i_data;
    end


    // Read data from line buffer
    always @(*) begin
        o_data = {M*n*8{1'b0}}; // Default value
        for (i = 0; i < M; i = i + 1) begin
            for (j = 0; j < n; j = j + 1) begin
                // we are reading n pixels from each channel and storing them in o_data
                // o_data is a 1D array of size M*n*8
                o_data[((M-1-i)*n*8 + (n-1-j)*8) +: 8] = line[i*W + rdPntr + j];
            end
        end
    end

    // Read pointer logic
    always @(posedge i_clk) begin
        if (i_rst)
            rdPntr <= 0;
        else if (output_needs_to_be_read)
            rdPntr <= rdPntr + m;
    end

endmodule



// This works already

// module line_buffer (
//     input                   i_clk,
//     input                   i_rst,
//     input  [7:0]            i_data,
//     input                   i_data_valid,
//     output reg [M*n*8-1:0]  o_data,
//     input                   output_needs_to_be_read
// );

//     parameter integer M = 3 ;
//     parameter integer W = 512 ;
//     parameter integer n = 4 ;
//     parameter PNTR_WIDTH = (M*W <= 1) ? 1 :
//                         (M*W <= 2) ? 2 :
//                         (M*W <= 4) ? 3 :
//                         (M*W <= 8) ? 4 :
//                         (M*W <= 16) ? 5 :
//                         (M*W <= 32) ? 6 :
//                         (M*W <= 64) ? 7 :
//                         (M*W <= 128) ? 8 :
//                         (M*W <= 256) ? 9 :
//                         (M*W <= 512) ? 10 :
//                         (M*W <= 1024) ? 11 :
//                         (M*W <= 2048) ? 12 :
//                         (M*W <= 4096) ? 13 :
//                         (M*W <= 8192) ? 14 :
//                         (M*W <= 16384) ? 15 :
//                         (M*W <= 32768) ? 16 :
//                         (M*W <= 65536) ? 17 :
//                         (M*W <= 131072) ? 18 :
//                         (M*W <= 262144) ? 19 :
//                         (M*W <= 524288) ? 20 :
//                         (M*W <= 1048576) ? 21 :
//                         (M*W <= 2097152) ? 22 :
//                         (M*W <= 4194304) ? 23 :
//                         (M*W <= 8388608) ? 24 :
//                         (M*W <= 16777216) ? 25 :
//                         (M*W <= 33554432) ? 26 :
//                         (M*W <= 67108864) ? 27 :
//                         (M*W <= 134217728) ? 28 :
//                         (M*W <= 268435456) ? 29 :
//                         (M*W <= 536870912) ? 30 :
//                         (M*W <= 1073741824) ? 31 : 32;

//     integer i;
//     integer j;

//     // if M=3, W=512, n=4, PNTR_WIDTH=10
//     reg [7:0] line [M*W-2:0];       //line buffer
//     reg [PNTR_WIDTH-1:0] wrPntr;    // Write pointer
//     reg [PNTR_WIDTH-1:0] rdPntr;    // Read pointer

//     always @(posedge i_clk)
//         begin
//             if(i_rst)
//                 wrPntr <= 'd0;
//             else if(i_data_valid)
//                 wrPntr <= wrPntr + 'd1;
//         end

//     always @(posedge i_clk)
//         begin
//             if(i_data_valid)
//                 line[wrPntr] <= i_data;
//         end


//     always @(*)
//         begin
//             o_data = {M*n*8 { 1'b0 }}; 
//             for(i=0;i<M;i=i+1)
//                 begin
//                     for(j=0;j<n;j=j+1)
//                         begin
//                             o_data[((M-1-i)*n*8 + (n-1-j)*8) +: 8] = line[i*W + rdPntr + j];
//                         end
//                 end
//         end

//     always @(posedge i_clk)
//         begin
//             if(i_rst)
//                 rdPntr <= 'd0;
//             else if(output_needs_to_be_read)
//                 rdPntr <= rdPntr + 'd1;
//         end


// endmodule