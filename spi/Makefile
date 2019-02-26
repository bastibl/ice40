NAME = spi
DEPS = baudgen.v uart_tx.v dividerp1.v spi_flash_reader.v

.PHONY: clean
all: upload

.PHONY: upload
upload: $(NAME).bin
	iceprog $(NAME).bin

.PHONY: blob
blob:
	python -c "print('Hello World'*100)" > blob.txt
	iceprog -o 1M blob.txt
	rm blob.txt

fw: $(NAME).bin

$(NAME).bin: $(NAME).pcf $(NAME).v $(DEPS)
	yosys -p "synth_ice40 -blif $(NAME).blif" -p "write_json $(NAME).json" $(NAME).v $(DEPS)
	nextpnr-ice40 --json $(NAME).json --pcf $(NAME).pcf --asc $(NAME).asc
	icepack -s $(NAME).asc $(NAME).bin

.PHONY: gui
gui: $(NAME).pcf $(NAME).v $(DEPS)
	yosys -p "synth_ice40 -blif $(NAME).blif" -p "write_json $(NAME).json" $(NAME).v $(DEPS)
	nextpnr-ice40 --json $(NAME).json --pcf $(NAME).pcf --asc $(NAME).asc --gui

.PHONY: sim
sim: $(NAME).v $(DEPS) $(NAME)_tb.v $(shell yosys-config --datdir)/ice40/cells_sim.v
	iverilog $^ -o $(NAME)_tb.out
	./$(NAME)_tb.out
	gtkwave $(NAME)_tb.vcd $(NAME)_tb.gtkw &


.PHONY: clean
clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~

