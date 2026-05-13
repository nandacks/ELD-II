.do

# 1. Prepara a biblioteca e compila o arquivo
vlib work
#vcom -93 flipflop.vhd
vsim work.flipflop

# 2. Adiciona os sinais ao gráfico Wave
add wave -position insertpoint sim:/flipflop/*

# --- Sequência de Testes ---

# Início: Resetando o Flip-Flop
force -freeze sim:/flipflop/reset 1 0
force -freeze sim:/flipflop/d 1 0
force -freeze sim:/flipflop/e 1 0
run 50ns

# Retira o Reset e desativa o Enable (Q deve continuar em '0')
force -freeze sim:/flipflop/reset 0 0
force -freeze sim:/flipflop/e 0 0
force -freeze sim:/flipflop/clk 0 0, 1 25ns -repeat 50ns
run 100ns

# Ativa o Enable (Agora
