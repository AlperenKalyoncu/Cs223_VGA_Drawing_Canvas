module VGA_Pattern_Checkerboard#(parameter block_size = 16)(input clk, right, left, up, down, 
output hsync, vsync, 
output reg [3:0]red, logic [3:0]green, logic [3:0]blue);

    reg [5:0]pixels [39:0][29:0];
    logic [2:0]displacement_x = 0;
    logic [2:0]displacement_y = 0;
    logic read = 0;
    
    initial begin
        red <= 0;
        green <= 0;
        blue <= 0;
        
        for(int i = 0; i < 40; i++) begin
            for(int j = 0; j < 30; j++) begin
                pixels[i][j] <= 0;
            end        
        end
    end
    
    clock_generator clock(10000000,clk,clk_out);
    
    always_ff@(posedge clk_out)begin
        if(right) displacement_x <= displacement_x + 1;
        else if(left) displacement_x <= displacement_x - 1;
        if (up) displacement_y <= displacement_y + 1;
        else if(down) displacement_y <= displacement_y - 1;
    end
    always_ff@(clk)begin
        for(int i = 0; i < 40; i++)begin
           for(int j = 0; j < 30; j++) begin
                pixels[i][j] <= ((((i + displacement_x) / 5) % 2) ^ ((j + displacement_y) / 5) % 2) == 1 ? 6'b001100 : 0;
           end  
        end
    end
    
    VGA_Controller controller(clk, pixels, hsync, vsync, red, green, blue);
endmodule
