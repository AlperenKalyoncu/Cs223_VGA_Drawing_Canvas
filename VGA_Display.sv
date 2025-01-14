module VGA_Display(
    input wire clk,  
    output reg hsync, vsync,
    output reg [3:0] red, logic [3:0] green, logic [3:0] blue);
    
    reg Active;
    logic [9:0] x;
    logic [9:0] y;
    reg [5:0]pixels[39:0][29:0];
    
    initial begin
        red <= 4'b1111;
        green <= 0;
        blue <= 4'b1111;
        
        for(int i = 0; i < 40; i++) begin
            for(int j = 0; j < 30; j++) begin
                pixels[i][j] <= 6'b101101;
            end        
        end     
    end
    
    VGA_Controller controller(clk, pixels, hsync, vsync, red, green, blue);
endmodule