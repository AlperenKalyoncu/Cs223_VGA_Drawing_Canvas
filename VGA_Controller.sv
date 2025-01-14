module VGA_Controller(
    input wire clk,
    input reg [5:0]pixels[39:0][29:0],         
    output reg hsync,       
    output reg vsync,       
    output reg [3:0] red, logic [3:0] green, logic [3:0] blue);

    localparam H_SYNC_CYCLES = 96;        
    localparam H_BACK_PORCH = 48;         
    localparam H_ACTIVE_VIDEO = 640;      
    localparam H_FRONT_PORCH = 16;        
    localparam H_TOTAL_CYCLES = 800;      
   
    localparam V_SYNC_CYCLES = 2;         
    localparam V_BACK_PORCH = 33;         
    localparam V_ACTIVE_VIDEO = 480;      
    localparam V_FRONT_PORCH = 10;        
    localparam V_TOTAL_CYCLES = 525;      

    reg [9:0] h_counter;                  
    reg [9:0] v_counter;      
    logic [9:0] x;
    logic [9:0] y;    
    
   clk_wiz_0 instance_name
   (
    .clk_out1(clk_out1),
    .reset(reset),
    .locked(locked),
    .clk_in1(clk)
    );   

    always @(posedge clk_out1) begin
        if (h_counter < H_TOTAL_CYCLES - 1)
            h_counter <= h_counter + 1;
        else
            h_counter <= 0;

        if (h_counter == H_TOTAL_CYCLES - 1) begin
            if (v_counter < V_TOTAL_CYCLES - 1)
                v_counter <= v_counter + 1;
            else
                v_counter <= 0;
        end
    end

    always @(*) begin
        hsync = (h_counter >= 655 && h_counter <= 750 ) ? 0 : 1;
        vsync = (v_counter >= 489 && v_counter <= 490) ? 0 : 1;

        if (h_counter < H_ACTIVE_VIDEO && v_counter < V_ACTIVE_VIDEO) begin
            x = h_counter;
            y = v_counter;
            red[3:2] = pixels[x >> 4][y >> 4][1:0];
            green[3:2] = pixels[x >> 4][y >> 4][3:2];
            blue[3:2] = pixels[x >> 4][y >> 4][5:4];
        end else begin
            x = 0;
            y = 0;
            red = 0;
            green = 0;
            blue = 0;
        end
    end
endmodule
