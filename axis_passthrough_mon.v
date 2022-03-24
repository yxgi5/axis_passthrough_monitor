`timescale 1ns/1ps
module axis_passthrough_mon
       #
      (
       parameter WIDTH = 32'd48,
       parameter TUSER_WIDTH = 32'd1,
       parameter FREQ_HZ = 32'd100000000
      )
     (
    input aclk,
    input aresetn,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)output s_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [WIDTH-1:0] s_axis_tdata,//����д����ȲŻ������ý�������ʵʱ�ı�?
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input s_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)(* mark_debug="true" *)input [TUSER_WIDTH-1:0]s_axis_tuser,
    //
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m_axis_tvalid,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)input m_axis_tready,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [WIDTH-1:0] m_axis_tdata,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output m_axis_tlast,
    (* DONT_TOUCH = "yes", s="true",keep="true" *)output [TUSER_WIDTH-1:0]m_axis_tuser
    );
//
assign m_axis_tvalid = s_axis_tvalid;
assign s_axis_tready = m_axis_tready;
assign m_axis_tdata = s_axis_tdata;
assign m_axis_tuser = s_axis_tuser;
assign m_axis_tlast = s_axis_tlast;

reg [31:0] freq_sec_cnt;
reg freq_sec_flag;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        freq_sec_cnt <= 32'd0;
        freq_sec_flag <= 1'b0;
    end
    else
    begin
        if(freq_sec_cnt < FREQ_HZ)
        begin
            freq_sec_cnt <= freq_sec_cnt + 1'b1;
            freq_sec_flag <= 1'b0;
        end
        else
        begin
            freq_sec_cnt <= 32'd0;
            freq_sec_flag <= 1'b1;
        end
    end
end

reg [31:0] fps;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [31:0] fps_cnt;
wire frame_end;
reg [TUSER_WIDTH-1:0] m_axis_tuser_r;
always@(posedge aclk)
begin
    m_axis_tuser_r <= m_axis_tuser;
end
assign frame_end = ~m_axis_tuser_r[0]&m_axis_tuser[0];
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        fps <= 32'd0;
        fps_cnt <= 32'd0;
    end
    else
    begin
        if(freq_sec_flag)
        begin
            fps <= fps_cnt;
            fps_cnt <= 32'd0;
        end
        else
        begin
            if(frame_end)
            begin
               fps_cnt <= fps_cnt +1'b1; 
            end
        end
    end
end


//
reg [15:0] col;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] col_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        col <= 16'b0;
        col_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1)) 
        begin
            col <= col_cnt + 1'b1;
            col_cnt <= 16'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1))
        begin
            col_cnt <= col_cnt + 1'b1;
        end
    end
end

reg [15:0] line;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] line_cnt;
always@(posedge aclk)
begin
    if(!aresetn)
    begin
        line <= 16'b0;
        line_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1))
        begin
            line_cnt <= line_cnt+1;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1) && (m_axis_tuser[0]==1'b1))
        begin
            line <= line_cnt;
            line_cnt <= 16'b0;    
        end
    end
end
////////////////
endmodule
