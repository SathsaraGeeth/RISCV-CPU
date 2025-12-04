import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb_tools.runner import get_runner
import os
from pathlib import Path

async def generate_clock(dut, period_ns=10):
    """Clock generator"""
    cocotb.start_soon(Clock(dut.clk, period_ns, unit="ns").start())

async def write_mem(dut, addr, data):
    dut.A.value = addr
    dut.WD.value = data
    dut.we.value = 1
    await RisingEdge(dut.clk)
    dut.we.value = 0
    await RisingEdge(dut.clk)

async def read_mem(dut, addr):
    dut.A.value = addr
    await RisingEdge(dut.clk)
    return dut.RD.value.to_unsigned()

@cocotb.test()
async def test_dMem(dut):
    cocotb.log.info("Starting dMem test")
    await generate_clock(dut, period_ns=10)

    # Initialize we to 0
    dut.we.value = 0
    await RisingEdge(dut.clk)

    # Write test: write some data to addresses
    test_data = {
        0x00: 0xDEADBEEF,
        0x04: 0x12345678,
        0x10: 0xCAFEBABE,
        0x3C: 0x0BADF00D,
    }

    for addr, data in test_data.items():
        await write_mem(dut, addr, data)

    # Read back and verify
    for addr, expected in test_data.items():
        result = await read_mem(dut, addr)
        cocotb.log.info(f"Read {result:#010x} from address {addr:#04x}")
        assert result == expected, f"Memory mismatch at {addr:#04x}: expected {expected:#010x}, got {result:#010x}"

    # Verify unwritten addresses are zero (optional)
    for addr in range(0, 64*4, 4):
        if addr not in test_data:
            result = await read_mem(dut, addr)
            assert result == 0, f"Expected 0 at address {addr:#04x}, got {result:#010x}"

    cocotb.log.info("dMem test completed successfully.")

def run():
    sim = os.getenv("SIM", "icarus")
    project_dir = Path(__file__).parent.parent
    src = [project_dir / "rtl" / "dMem.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=src,
        hdl_toplevel="dMem",
        always=True,
    )

    runner.test(
        hdl_toplevel="dMem",
        test_module="dMem",
    )

if __name__ == "__main__":
    run()