import cocotb
from cocotb.triggers import RisingEdge, Timer
import os
from pathlib import Path
from cocotb_tools.runner import get_runner
import cocotb



class CPU:
    def __init__(self, dut, period=10):
        self.dut = dut
        self.period = period
        cocotb.start_soon(self.clk_gen())
        

    @property
    def pc(self):
        return hex(self.dut.PCReg.Q.value)
    @property
    def registers(self):
        return {len(self.dut.RegFile.Regs)-1-i: hex(r.value) for i, r in enumerate(self.dut.RegFile.Regs)}
    @property
    def imem(self):
        return {len(self.dut.IMem.RAM)-1-i: hex(mem.value) for i, mem in enumerate(self.dut.IMem.RAM)}
    @property
    def dmem(self):
        return {len(self.dut.DMem.RAM)-1-i: hex(mem.value) for i, mem in enumerate(self.dut.DMem.RAM)}
    @property
    def signals(self): 
        return {name: getattr(self.dut, name) for name in dir(self.dut) if not name.startswith("_")}
    
    def dump_registers(self):
        return self.registers
    def dump_imem(self):
        return self.imem
    def dump_dmem(self):
        return self.dmem
    def dump_signals(self):
        return self.signals

    def write_dmem(self, addr, value):
        self.dut.DMem.RAM[addr].value = value
    def read_dmem(self, addr):
        return hex(self.dut.DMem.RAM[addr].value)
    def write_imem(self, addr, value):
        self.dut.IMem.RAM[addr].value = value
    def read_imem(self, addr):
        return hex(self.dut.IMem.RAM[addr].value)
    def write_register(self, reg, value):
        self.dut.RegFile.Regs[reg].value = value
    def read_register(self, reg):
        return hex(self.dut.RegFile.Regs[reg].value)
    def read_pc(self):
        return hex(self.dut.PCReg.Q.value)
    def write_pc(self, value):
        self.dut.PCReg.Q.value = value
    
    async def clk_gen(self):
        while True:
            self.dut.clk.value = 0
            await Timer(self.period // 2, unit="ns")
            self.dut.clk.value = 1
            await Timer(self.period // 2, unit="ns")

    async def reset(self, cycles=2):
        self.dut.rst_n.value = 0
        for _ in range(cycles):
            await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)

    async def step(self):
        await RisingEdge(self.dut.clk)

    async def run_cycles(self, n):
        for _ in range(n):
            await RisingEdge(self.dut.clk)

    def load_program(self, program):
        for addr, instr in program.items():
            self.write_imem(addr, instr)
    
    async def load_run_vv(self, program):
        self.load_program(program)
        print("Starting Program Execution...\n")
        print("PC:", self.read_pc())
        print("Registers:", self.dump_registers())
        print("Data Memory:", self.dump_dmem())
        await RisingEdge(self.dut.clk)
        await self.reset()
        print("Instruction Memory:", self.dump_imem())
        print("\nRunning...\n")
        i = 0
        prv_pc = None
        while int(self.read_pc(), 16) < len(program) * 4:
            curr_pc = self.read_pc()
            if curr_pc == prv_pc:
                print("Stuck at PC:", curr_pc)
                break
            prv_pc = curr_pc
            await self.run_cycles(1)
            print(f"--- Cycle {i} ---")
            print("PC:", self.read_pc())
            print("Registers:", self.dump_registers())
            print("Data Memory:", self.dump_dmem())
            i += 1


    async def load_run_v(self, program):
        self.load_program(program)
        print("Starting Program Execution...\n")
        print("PC:", self.read_pc())
        print("Registers:", self.dump_registers())
        print("Data Memory:", self.dump_dmem())
        await RisingEdge(self.dut.clk)
        await self.reset()
        print("Instruction Memory:", self.dump_imem())
        print("\nRunning...\n")
        i = 0
        prv_pc = None
        while int(self.read_pc(), 16) < len(program) * 4:
            curr_pc = self.read_pc()
            if curr_pc == prv_pc:
                print("Stuck at PC:", curr_pc)
                break
            prv_pc = curr_pc
            await self.run_cycles(1)

            def format_entry(name, hexval):
                val = int(hexval, 16)
                signed = val if val < 0x80000000 else val - 0x100000000
                return f"{name:>4} = {hexval:>10} | U: {val:>10} | S: {signed:>10}"

            print(f"\n--- Cycle {i} ---")
            print("PC:", self.read_pc())

            print("Registers (non-zero):")
            for k, v in self.dump_registers().items():
                if int(v, 16) != 0:
                    print(" ", format_entry(k, v))

            print("Data Memory (non-zero):")
            for k, v in self.dump_dmem().items():
                if int(v, 16) != 0:
                    print(" ", format_entry(k, v))

            i += 1  

    async def load_run_(self, program):
        self.load_program(program)
        await RisingEdge(self.dut.clk)
        await self.reset()
        i = 0
        while int(self.read_pc(), 16) < len(program) * 4:
            await self.run_cycles(1)
            i += 1

    async def load_run(self, program, verbose = None):
        if verbose == "vv":
            await self.load_run_vv(program)
        elif verbose == "v":
            await self.load_run_v(program)
        else:
            await self.load_run_(program)


def run_test():
    sim = os.getenv("SIM", "verilator")
    project_dir = Path(__file__).parent.parent
    rtl_dir = project_dir / "rtl"
    src = [
        str(rtl_dir / "singleCycleCPU.sv"),
        str(rtl_dir / "mux2.sv"),
        str(rtl_dir / "mux3.sv"),
        str(rtl_dir / "register.sv"),
        str(rtl_dir / "regFile.sv"),
        str(rtl_dir / "iMem.sv"),
        str(rtl_dir / "dMem.sv"),
        str(rtl_dir / "adder.sv"),
        str(rtl_dir / "alu.sv"),
        str(rtl_dir / "extend.sv"),
        str(rtl_dir / "decoder.sv"),
    ]

    runner = get_runner(sim)
    runner.build(
        sources=src,
        hdl_toplevel="singleCycleCPU",
        always=True,
    )
    runner.test(
        hdl_toplevel="singleCycleCPU",
        test_module=["cpu", "test"],
    )

if __name__ == "__main__":
    run_test()

def cpu_test(fn):
    @cocotb.test()
    async def wrapped(dut):
        cpu = CPU(dut)
        await cpu.reset()
        return await fn(cpu)
    return wrapped
