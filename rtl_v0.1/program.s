# add, sub, and, or, slt, addi, lw, sw, beq, jal
# If successful, it should write the value 25 to address 100

main:   addi x2, x0, 5         # x2 = 5              0x00  00500113
        addi x3, x0, 12        # x3 = 12             0x04  00C00193
        addi x7, x3, -9        # x7 = (12 - 9) = 3   0x08  FF718393
        or   x4, x7, x2        # x4 = (3 OR 5) = 7   0x0C  0023E233
        and  x5, x3, x4        # x5 = (12 AND 7)=4   0x10  0041F2B3
        add  x5, x5, x4        # x5 = 4 + 7 = 11     0x14  004282B3
        beq  x5, x7, end       # shouldn't be taken  0x18  02728863
        slt  x4, x3, x4        # x4 = (12 < 7) = 0   0x1C  0041A233
        beq  x4, x0, around    # should be taken     0x20  00020463
        addi x5, x0, 0         # shouldn't execute   0x24  00000293

around: slt  x4, x7, x2        # x4 = (3 < 5) = 1    0x28  0023A233
        add  x7, x4, x5        # x7 = (1 + 11) = 12  0x2C  005203B3
        sub  x7, x7, x2        # x7 = (12 - 5) = 7   0x30  402383B3
        sw   x7, 84(x3)        # [96] = 7            0x34  0471AA23
        lw   x2, 96(x0)        # x2 = [96] = 7       0x38  06002103
        add  x9, x2, x5        # x9 = (7 + 11) = 18  0x3C  005104B3
        jal  x3, end           # jump to end, x3=0x44 0x40 008001EF
        addi x2, x0, 1         # shouldn't execute   0x44  00100113

end:    add  x2, x2, x9        # x2 = (7 + 18) = 25  0x48  00910133
        sw   x2, 0x20(x3)      # [100] = 25          0x4C  0221A023

done:   beq  x2, x2, done      # infinite loop       0x50  00210063