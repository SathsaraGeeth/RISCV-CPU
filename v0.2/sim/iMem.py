import cocotb
from cocotb.triggers import Timer
from cocotb_tools.runner import get_runner
import os
from pathlib import Path

async def check_mem(dut, addr, expected):
    """Apply address and check memory output"""
    dut.A.value = addr
    await Timer(1, unit="ns")  # allow combinational settle
    result = dut.RD.value.to_unsigned()
    assert result == expected, f"Memory read mismatch at address {addr:#x}: expected {expected:#x}, got {result:#x}"

@cocotb.test()
async def test_iMem(dut):
    cocotb.log.info("Starting iMem test")

    # Example test: read first 8 words
    # Make sure program.txt exists and contains at least 8 hex values
    for i in range(8):
        program_file = Path(__file__).parent.parent.parent / "program.txt"
        lines = program_file.read_text().splitlines()
        line = lines[i].split("//")[0].strip()  # remove comments
        expected = int(line, 16)
        addr = i * 4  # byte address
        await check_mem(dut, addr, expected)

    # You can add more address checks if needed
    cocotb.log.info("iMem test completed successfully.")

def run():
    sim = os.getenv("SIM", "icarus")
    project_dir = Path(__file__).parent.parent
    src = [project_dir / "rtl" / "iMem.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=src,
        hdl_toplevel="iMem",
        always=True,
    )

    runner.test(
        hdl_toplevel="iMem",
        test_module="iMem",
    )

if __name__ == "__main__":
    run()