module Mouse_Input(input reset,
    input PS2Clk, PS2Data, 
    output logic [7:0]x, logic [7:0]y,
    output logic x_pos, x_neg,
    output logic y_pos, y_neg,
    output logic left,
    output logic right);
    
    int Mouse_Counter = 0;
    logic [43:0] out;
    logic parity;
    logic valid;
    logic start;
    logic [43:0]led;
    
    always_ff@(posedge PS2Clk) begin
        if(Mouse_Counter <= 42) Mouse_Counter <= Mouse_Counter + 1;
        else Mouse_Counter <= 0;
    end
    
    always_ff@(negedge PS2Clk) begin
        out[Mouse_Counter] <= PS2Data;
    end
    
    assign start = !out[0] && !out[11] && !out[22] && !out[33];
    assign parity = (~^out[8:1] == out[9]) && (~^out[19:12] == out[20]) && (~^out[30:23] == out[31]) && (~^out[41:34] == out[42]);
    assign stop = out[10] && out[21] && out[32] && out[43];
    
    assign valid = start && parity && stop;
    
    always@(*)begin
        if(valid && (Mouse_Counter == 42)) begin 
            led <= out;
        end
        if(reset) led <= 0;
    end
    
    assign x = led[19:12];
    assign y = led[30:23];
    assign left = led[1];
    assign right = led[2];
    assign x_pos = (x > 5) ? led[5] : 0;
    assign x_neg = (((~x + 1) > 5) && valid) ? !led[5] : 0;
    assign y_pos = (y > 5) ? led[6] : 0;
    assign y_neg = (((~y + 1) > 5) && valid) ? !led[6] : 0;


endmodule
