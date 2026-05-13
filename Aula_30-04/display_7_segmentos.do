.DO

# Limpa o console e prepara a biblioteca
vlib work
vcom -93 display.vhd
vsim work.display

# Adiciona os sinais ao Wave
add wave -position insertpoint sim:/display/*
# Configura o formato para Hexadecimal ou Binário para facilitar a leitura
property wave -radix hexadecimal /display/bcd
property wave -radix binary /display/ssd

# --- Sequência de Testes (0 a 9) ---

force -freeze sim:/display/BCD 0000 0
run 50ns

force -freeze sim:/display/BCD 0001 0
run 50ns

force -freeze sim:/display/BCD 0010 0
run 50ns

force -freeze sim:/display/BCD 0011 0
run 50ns

force -freeze sim:/display/BCD 0100 0
run 50ns

force -freeze sim:/display/BCD 0101 0
run 50ns

force -freeze sim:/display/BCD 0110 0
run 50ns

force -freeze sim:/display/BCD 0111 0
run 50ns

force -freeze sim:/display/BCD 1000 0
run 50ns

force -freeze sim:/display/BCD 1001 0
run 50ns

# Força um valor fora de BCD para testar o "others"
force -freeze sim:/display/BCD 1111 0
run 50ns

# Ajusta o zoom para ver tudo
wave zoom full
