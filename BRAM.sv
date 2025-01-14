module BRAM(input clk);

    (* ram_style = "block" *) logic [2:0] bram [640 * 480 - 1: 0];
    logic rw = 0;
    logic out;
    
    always_ff@(posedge clk) begin 
        if(rw) bram[1][1] <= 0;
        
        else out <= bram[1][1];
        rw <= !rw;
    end
endmodule
