from cpu import cpu_test, run_test
if __name__ == "__main__":
    run_test()

@cpu_test
async def test_step_by_step(cpu):
    program = {
        0:  0x00500113,  # addi x2, x0, 5
        1:  0x00C00193,  # addi x3, x0, 12
        2:  0xFF718393,  # addi x7, x3, -9
        3:  0x0023E233,  # or x4, x7, x2
        4:  0x0041F2B3,  # and x5, x3, x4
        5:  0x004282B3,  # add x5, x5, x4
        6:  0x02728863,  # beq x5, x7, end
        7:  0x0041A233,  # slt x4, x3, x4
        8:  0x00020463,  # beq x4, x0, around
        9:  0x00000293,  # addi x5, x0, 0
        10: 0x0023A233,  # slt x4, x7, x2
        11: 0x005203B3,  # add x7, x4, x5
        12: 0x402383B3,  # sub x7, x7, x2
        13: 0x0471AA23,  # sw x7, 84(x3)
        14: 0x06002103,  # lw x2, 96(x0)
        15: 0x005104B3,  # add x9, x2, x5
        16: 0x008001EF,  # jal x3, end
        17: 0x00100113,  # addi x2, x0, 1
        18: 0x00910133,  # add x2, x2, x9
        19: 0x0221A023,  # sw x2, 0x20(x3)
        20: 0x00210063,  # beq x2, x2, donesim
    }

    await cpu.load_run(program, verbose="v")
