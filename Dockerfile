FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    iverilog \
    gtkwave \
    make \
    && rm -rf /var/lib/apt/lists/*

COPY run-testbench /run-testbench
RUN sed -i 's/\r$//' /run-testbench && chmod +x /run-testbench

WORKDIR /mips

CMD ["bash"]
