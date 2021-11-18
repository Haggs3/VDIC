package alu_pkg;
    `define FLAG_C    4'b1000
    `define FLAG_OF   4'b0100
    `define FLAG_ZERO 4'b0010
    `define FLAG_NEG  4'b0001
    
    `define ERR_DATA  3'b100
    `define ERR_CRC   3'b010
    `define ERR_OP    3'b001

    typedef enum bit {
        DATA_PACKET = 1'b0,
        CMD_PACKET  = 1'b1
    } packet_type_t;
        
    typedef enum bit [1:0] {
        TRANSMISSION_CORRECT = 2'b00,
        TRANSMISSION_ERROR   = 2'b01,
        NO_TRANSMISSION      = 2'b10
    } transmission_result_t;
    
    typedef enum bit [2:0] {
        AND_OP = 3'b000,
        OR_OP  = 3'b001,
        ADD_OP = 3'b100,
        SUB_OP = 3'b101,
        NO_OP  = 3'b111,
        RST_OP = 3'b010
    } operation_t;
    
    typedef struct {
        transmission_result_t result;
        bit [31:0] C;
        bit [3:0] alu_flags;
        bit [2:0] crc3b;
        bit [5:0] err_flags;
        bit parity;
    } transmission_data_t;

endpackage : alu_pkg
