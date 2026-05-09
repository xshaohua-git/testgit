// 8 位 最小 CPU
// 全部由 LUT + 触发器 构成
module tiny_cpu_8bit(
    input clk,
    input rst_n
);

// ==============================
// 1. 程序计数器 PC (4bit)
// ==============================
reg [3:0] pc;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc <= 4'd0;
    else
        pc <= pc_next;
end

// ==============================
// 2. 指令存储器 ROM (LUT)
// ==============================
wire [7:0] inst;
reg [7:0] rom[0:15];

// 示例程序：循环累加
initial begin
    rom[0] = 8'b0000_0101;  // MOV A, #5
    rom[1] = 8'b0001_0001;  // ADD A, #1
    rom[2] = 8'b0010_0001;  // SUB A, #1
    rom[3] = 8'b0100_0000;  // JMP 0
end

assign inst = rom[pc];

wire [3:0] opcode  = inst[7:4];  // 操作码
wire [3:0] operand = inst[3:0];  // 立即数/地址

// ==============================
// 3. 8 位累加器 A (D触发器)
// ==============================
reg [7:0] reg_a;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        reg_a <= 8'd0;
    else if (reg_we)
        reg_a <= alu_out;
end

// ==============================
// 4. ALU (纯 LUT 组合逻辑)
// ==============================
reg [7:0] alu_out;

always @(*) begin
    case (opcode)
        4'b0000: alu_out = {4'd0, operand};      // MOV
        4'b0001: alu_out = reg_a + {4'd0, operand}; // ADD
        4'b0010: alu_out = reg_a - {4'd0, operand}; // SUB
        default: alu_out = reg_a;
    endcase
end

// ==============================
// 5. 控制单元 CU (巨型 LUT)
// ==============================
reg        reg_we;
reg [3:0]  pc_next;

always @(*) begin
    // 默认：PC+1，不写寄存器
    pc_next = pc + 1'd1;
    reg_we  = 1'b0;

    case (opcode)
        4'b0000: reg_we = 1'b1;  // MOV
        4'b0001: reg_we = 1'b1;  // ADD
        4'b0010: reg_we = 1'b1;  // SUB
        4'b0100: pc_next = operand; // JMP
    endcase
end

endmodule

