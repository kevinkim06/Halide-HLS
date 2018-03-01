`timescale 1ns/1ps

module outstream(
    input       clk,
    input       reset,
    input       start_in,
    input[7:0]  data_in0,
    input       valid,
    output reg  ready,
    input       stop_in
);


integer seed, i;
integer stall;
integer stall2;
integer fp0;
reg     ready_i;
initial begin
    ready_i = 0;
    fp0 = $fopen("out_rtl0.txt");
    @(posedge start_in);
    @(negedge start_in);

    ready_i = 1;
    for(i=0; i< 256*256; i=i+1)
    begin
        stall = $random&1;
        //stall = 0;
        if (stall==1)
        begin
            ready_i = 0;
            stall2 = 1 + $random&31;
            while(stall2>0)
            begin
                stall2 = stall2 - 1;
                @(posedge clk);
            end
            ready_i = 1;
            @(posedge clk);
        end
        else // 1/2 prob: not stall
        begin
            ready_i = 1;
            @(posedge clk);
        end
        while(!valid) @(posedge clk);
    end
    ready_i = 0;
    wait(stop_in);
    $fclose(fp0);
end 

always@(*)
  ready <= ready_i;

integer cnt;
always@(posedge clk)
begin
    if (reset)
    begin
        cnt = 0;
    end
    else if (ready&valid)  // read without loading
    begin
        cnt = cnt + 1;
        $fwrite(fp0, "%d ", data_in0);
        if ((cnt%256)==0) begin
            $fwrite(fp0, "\n");
        end
    end
end

endmodule
