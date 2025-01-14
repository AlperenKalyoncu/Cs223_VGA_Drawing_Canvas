module VGA_Drawing_Canvas(
    input clk, right, left, up, down, center, size,
    input [2:0] colors,
    output reg hsync, reg vsync,
    output reg [3:0] red, logic [3:0] green, logic [3:0] blue
);
    logic [9:0] mouse_position_x = 0;
    logic [9:0] mouse_position_y = 0;
    logic read = 0;
    
    reg [2:0] pixels [39:0][29:0]; 
    reg [9:0] h_counter;                  
    reg [9:0] v_counter;      
    logic [9:0] x;
    logic [9:0] y;  
    
    clock_generator clock(200000, clk, slow_clk);
    
    initial begin
        for(int i = 0; i < 40; i++) begin
            for(int j = 0; j < 30; j++) begin
                pixels[i][j] <= 3'b111;
            end        
        end
    end
    
    always_ff@(posedge slow_clk)begin
        if(read)begin
            if(left) mouse_position_x <= mouse_position_x + 1;
            else if(right) mouse_position_x <= mouse_position_x - 1;
            if (down) mouse_position_y <= mouse_position_y + 1;
            else if(up) mouse_position_y <= mouse_position_y - 1;
            
            if(mouse_position_x > 639) mouse_position_x <= 0;
            if(mouse_position_y > 479) mouse_position_y <= 0;
            if(mouse_position_y <= 0) mouse_position_y = 479;
            if(mouse_position_x <= 0) mouse_position_x = 639;
        end
        else if(!read) begin
            if (center) begin
                if (size) begin
                    for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++) begin
                        if (mouse_position_x + dx >= 0 && mouse_position_x + dx < 640 && mouse_position_y + dy >= 0 && mouse_position_y + dy < 480) begin
                             pixels[(mouse_position_x >> 4) + dx ][ (mouse_position_y >> 4) + dy] <= colors;
                        end
                    end
                end else begin
                    if (mouse_position_x < 640 && mouse_position_y < 480)begin
                        pixels[(mouse_position_x) >> 4][(mouse_position_y) >> 4] <= colors;
                    end
                end
            end
        end
        read <= !read;
    end

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
    
   clk_wiz_0 instance_name
   (
    .clk_out1(clk_out1),
    .reset(reset),
    .locked(locked),
    .clk_in1(clk)
    );   

    always @(posedge clk_out1) begin
        if (h_counter < 799 )
            h_counter <= h_counter + 1;
        else
            h_counter <= 0;

        if (h_counter == H_TOTAL_CYCLES - 1) begin
            if (v_counter < 524)
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
            if((x >> 4 == mouse_position_x >> 4 && (mouse_position_y >> 4 == y >> 4 || mouse_position_y >> 4 == (y + 4) >> 4  || mouse_position_y >> 4 == (y - 4) >> 4)) || (mouse_position_y >> 4 == y >> 4 && (mouse_position_x >> 4 == (x + 4)>> 4 || mouse_position_x >> 4 == (x - 4) >> 4 )))begin
                red = 4'b0000;
                green = 4'b0000;;
                blue = 4'b0000;
            end
            else begin 
                red[3] = pixels[x >> 4][y >> 4][0];
                green[3] = pixels[x >> 4][y >> 4][1];
                blue[3] = pixels[x >> 4][y >> 4][2];
            end
        end else begin
            x = 0;
            y = 0;
            red = 0;
            green = 0;
            blue = 0;
        end
    end
endmodule