module Canvas_Mouse(
    input PS2Clk, PS2Data, 
    input clk, size,
    input [2:0] colors, 
    output logic x_pos, x_neg,
    output logic y_pos, y_neg,
    output reg hsync, reg vsync,
    output reg [3:0] red, logic [3:0] green, logic [3:0] blue);
    
    logic [7:0]mouse_x;
    logic [7:0]mouse_y;
    
    logic reset;
    logic reset_a = 0;
    clock_generator clkkkk(300000, clk, reset_clk);
     always_ff @(posedge reset_clk or posedge reset) begin
        if (reset) reset <= 0;
        else reset <= 1;
    end
    
    Mouse_Input mouse(reset, PS2Clk, PS2Data, mouse_x, mouse_y, x_pos, x_neg, y_pos, y_neg, left, right);
    
    logic [9:0] mouse_position_x = 0;
    logic [9:0] mouse_position_y = 0;
    logic read = 0;
    
    reg [2:0] pixels [39:0][29:0]; 
    reg [9:0] h_counter;                  
    reg [9:0] v_counter;      
    logic [9:0] x;
    logic [9:0] y;  

    
    clock_generator clock(70000, clk, slow_clk);
    
    initial begin
        for(int i = 0; i < 40; i++) begin
            for(int j = 0; j < 30; j++) begin
                pixels[i][j] <= 3'b111;
            end        
        end
    end
    
    always_ff@(posedge slow_clk)begin

        if(read)begin
            if(x_neg) mouse_position_x <= mouse_position_x + 1;
            else if(x_pos) mouse_position_x <= mouse_position_x - 1;
            if (y_pos) mouse_position_y <= mouse_position_y + 1;
            else if (y_neg) mouse_position_y <= mouse_position_y - 1;
            
            if(mouse_position_x > 639) mouse_position_x <= 0;
            if(mouse_position_y > 479) mouse_position_y <= 0;
            if(mouse_position_y <= 0) mouse_position_y = 479;
            if(mouse_position_x <= 0) mouse_position_x = 639;
        end
        else if(!read) begin
            if (left) begin
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
    
   clk_wiz_0 instance_name
   (
    .clk_out1(clk_out1),
    .reset(reset_a),
    .locked(locked),
    .clk_in1(clk)
    );   

    always @(posedge clk_out1) begin
        if (h_counter < 799 )
            h_counter <= h_counter + 1;
        else
            h_counter <= 0;

        if (h_counter == 799) begin
            if (v_counter < 524)
                v_counter <= v_counter + 1;
            else
                v_counter <= 0;
        end
    end

    always @(*) begin
        hsync = (h_counter >= 655 && h_counter <= 750 ) ? 0 : 1;
        vsync = (v_counter >= 489 && v_counter <= 490) ? 0 : 1;

        if (h_counter < 640 && v_counter < 480) begin
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
    