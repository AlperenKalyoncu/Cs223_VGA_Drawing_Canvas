`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Bilkent University
// Engineer: Dilara Erbenzer
// 
// Create Date: 12/14/2024 03:48:16 PM
// Design Name: VGA Controller
// Module Name: vga_cnt
// Project Name: Project
//////////////////////////////////////////////////////////////////////////////////


module vga_cnt(
    input logic clk, output logic Hsync, logic Vsync, 
    logic [3:0] Red, logic [3:0] Green, logic [3:0] Blue);
    
    logic PCLK;
    int clk_count = 0, line = 0;
    always_ff @ (posedge PCLK) begin

        // horizontal sync settings
        if (line < 480) begin
            Vsync <= 1;
            // horizontal sync settings
            if (clk_count < 640) begin
                Hsync <= 1;
            if (((clk_count / 40) % 2) == ((line / 40) % 2)) begin
                // yellow
                Red = 4'b1111;
                Green = 4'b1111;
                Blue = 4'b0000;
            end 
            else begin
                // pink
                Red = 4'b1111;
                Green = 4'b0000;
                Blue = 4'b1111;
            end
        end 
            else begin
                if (clk_count >= 656 && clk_count < 656 + 96) begin
                    Hsync <= 0;
                end
                else if (clk_count >= 656 + 96 && clk_count < 656 + 96 + 48) begin
                    Hsync <= 1;
                end
                Red <= 0;
                Green <= 0;
                Blue <= 0;
                        
            end
        end
        else begin
            Red <= 0;
            Green <= 0;
            Blue <= 0;
            Hsync <= 0;
            if (line >= 490 && line < 492) begin
                Vsync <= 0;
            end
            else if (line >= 492 && line < 525) begin
                Vsync <= 1;
            end
        end
        
        clk_count++;
        if (clk_count == 800) begin
            clk_count = 0;
            line++; 
            if (line >= 525) begin
                line = 0;
            end
        end
    end
    
endmodule