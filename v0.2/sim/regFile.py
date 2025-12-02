import cocotb
from cocotb.triggers import FallingEdge, Timer
from cocotb_tools.runner import get_runner
import os
from pathlib import Path

async def generate_clock(dut, period_ns = 10):
    while True:
        dut.clk.value = 0
        await Timer(period_ns / 2, unit ='ns')
        dut.clk.value = 1
        await Timer(period_ns / 2, unit ='ns')

@cocotb.test()
async def test_register_file(dut):
    cocotb.start_soon(generate_clock(dut, period_ns=10))

    # Reset
    dut.rst_n.value = 0
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    await FallingEdge(dut.clk)

    # Write data to register 5
    dut.we3.value = 1
    dut.A3.value = 5
    dut.WD3.value = 0xABCD1234
    await FallingEdge(dut.clk)
    dut.we3.value = 0
    await FallingEdge(dut.clk)

    # Read from all registers and print values and verify
    for reg in range(32):
        dut.A1.value = reg
        dut.A2.value = reg
        await FallingEdge(dut.clk)
        rd1 = dut.RD1.value.integer
        rd2 = dut.RD2.value.integer
        cocotb.log.info(f"Register {reg}: RD1 = 0x{rd1:08X}, RD2 = 0x{rd2:08X}")
        if reg == 5:
            assert rd1 == 0xABCD1234, f"Expected 0xABCD1234, got 0x{rd1:08X}"
            assert rd2 == 0xABCD1234, f"Expected 0xABCD1234, got 0x{rd2:08X}"
        else:
            assert rd1 == 0, f"Expected 0, got 0x{rd1:08X}"
            assert rd2 == 0, f"Expected 0, got 0x{rd2:08X}"

    cocotb.log.info("Register file test completed.")

def run():
    sim = os.getenv("SIM", "icarus")
    project_dir = Path(__file__).parent.parent
    src = [project_dir / "rtl" / "regFile.sv"]

    runner = get_runner(sim)
    runner.build(sources = src,
                 hdl_toplevel = "regFile",
                 always = True,)
    
    runner.test(hdl_toplevel = "regFile",
                test_module = "regFile",)
    
if __name__ == "__main__":
    run()