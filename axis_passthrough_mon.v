`timescale 1ns/1ps
module axis_passthrough_mon
       #
      (
       parameter WIDTH = 32'd48,
       parameter TUSER_WIDTH = 32'd1
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
//
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] line_cnt;
(* DONT_TOUCH = "yes", s="true",keep="true" *) (*MARK_DEBUG="TRUE"*)reg [15:0] col_cnt;

always@(posedge aclk)
begin
   if(
     (s_axis_tvalid ==1'b1) && 
     (s_axis_tlast==1'b1) && 
     (m_axis_tready ==1'b1)
     ) begin
      col_cnt <= 0;
   end
   else if (
           (s_axis_tvalid ==1'b1)  
           && (m_axis_tready==1'b1)
            ) 
      begin
      col_cnt <= col_cnt+1;
      end
end

always@(posedge aclk)
begin
   if(
     (s_axis_tvalid ==1'b1)
      && (s_axis_tlast==1'b1)
       && (m_axis_tready ==1'b1)
       ) begin
      line_cnt <= line_cnt+1;
   end
   else if 
     (
       (s_axis_tvalid ==1'b1)
     && (m_axis_tready==1'b1)
     && (m_axis_tuser[0]==1'b1) 
     )
      begin
      line_cnt <= 0;     
   end
end
////////////////
endmodule
