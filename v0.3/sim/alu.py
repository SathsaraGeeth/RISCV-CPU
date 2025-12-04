import cocotb
from cocotb.triggers import Timer
from cocotb_tools.runner import get_runner
import os
from pathlib import Path

# ALU opcodes (match RTL)
ADD  = 0b0000
SUB  = 0b0001
AND  = 0b0010
OR   = 0b0011
XOR  = 0b0100
SLL  = 0b0101
SRL  = 0b0110
SRA  = 0b0111
SLT  = 0b1000
SLTU = 0b1001


async def apply_and_check(dut, A, B, op, expected):
    """Helper to apply inputs & verify result"""
    dut.A.value = A
    dut.B.value = B
    dut.alu_ctrl.value = op
    await Timer(1, units="ns")  # allow combinational settle

    result = dut.RESULT.value.integer
    assert result == expected, f"ALU opcode={op:04b}: expected {expected:#x}, got {result:#x}"


@cocotb.test()
async def test_alu(dut):
    cocotb.log.info("Starting ALU tests")

    # Test vectors
    A = 0x12
    B = 0x05

    # ADD
    await apply_and_check(dut, A, B, ADD, A + B)

    # SUB
    await apply_and_check(dut, A, B, SUB, A - B)

    # AND
    await apply_and_check(dut, A, B, AND, A & B)

    # OR
    await apply_and_check(dut, A, B, OR, A | B)

    # XOR
    await apply_and_check(dut, A, B, XOR, A ^ B)

    # SLL
    await apply_and_check(dut, A, B, SLL, A << (B & 0x1F))

    # SRL
    await apply_and_check(dut, A, B, SRL, A >> (B & 0x1F))

    # SRA
    def signed(value):
        return value - 0x100000000 if value & 0x80000000 else value

    def arithmetic_shift_right(val, shamt):
        return (signed(val) >> shamt) & 0xFFFFFFFF

    expected = arithmetic_shift_right(0xFFFFFFF0, B & 0x1F)
    await apply_and_check(dut, 0xFFFFFFF0, B, SRA, expected)
    
    # SLT (signed)
    await apply_and_check(dut, -5 & 0xFFFFFFFF, 3, SLT, 1)
    await apply_and_check(dut, 3, -5 & 0xFFFFFFFF, SLT, 0)

    # SLTU
    await apply_and_check(dut, 3, 7, SLTU, 1)
    await apply_and_check(dut, 7, 3, SLTU, 0)

    cocotb.log.info("ALU test completed successfully.")


def run():
    sim = os.getenv("SIM", "icarus")
    project_dir = Path(__file__).parent.parent
    src = [project_dir / "rtl" / "alu.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=src,
        hdl_toplevel="alu",
        always=True,
    )

    runner.test(
        hdl_toplevel="alu",
        test_module="alu",
    )


if __name__ == "__main__":
    run()