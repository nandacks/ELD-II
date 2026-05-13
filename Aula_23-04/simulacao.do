# Reinicia a simulação para o tempo zero
restart -f

# Adiciona os sinais na Wave (se já não estiverem lá)
add wave -position insertpoint sim:/ex_latch/*

# Configura a exibição para Decimal Sinalizado (melhor para conferir o projeto)
property wave -radix signed /ex_latch/a
property wave -radix signed /ex_latch/b

# ---------------------------------------------------------
# 1. SINAIS POSITIVOS
# ---------------------------------------------------------
# a > b (10 > 5) -> gt=1
force -freeze sim:/ex_latch/a 10#10 0
force -freeze sim:/ex_latch/b 10#5 0
run 100ns

# a = b (7 = 7) -> eq=1
force -freeze sim:/ex_latch/a 10#7 0
force -freeze sim:/ex_latch/b 10#7 0
run 100ns

# a < b (3 < 8) -> lt=1
force -freeze sim:/ex_latch/a 10#3 0
force -freeze sim:/ex_latch/b 10#8 0
run 100ns

# ---------------------------------------------------------
# 2. SINAIS NEGATIVOS
# ---------------------------------------------------------
# a > b (-5 > -10) -> gt=1
force -freeze sim:/ex_latch/a 10#-5 0
force -freeze sim:/ex_latch/b 10#-10 0
run 100ns

# a = b (-12 = -12) -> eq=1
force -freeze sim:/ex_latch/a 10#-12 0
force -freeze sim:/ex_latch/b 10#-12 0
run 100ns

# a < b (-20 < -5) -> lt=1
force -freeze sim:/ex_latch/a 10#-20 0
force -freeze sim:/ex_latch/b 10#-5 0
run 100ns

# ---------------------------------------------------------
# 3. MISTURADOS (POSITIVOS E NEGATIVOS)
# ---------------------------------------------------------
# a > b (2 > -5) -> gt=1
force -freeze sim:/ex_latch/a 10#2 0
force -freeze sim:/ex_latch/b 10#-5 0
run 100ns

# a < b (-10 < 1) -> lt=1
force -freeze sim:/ex_latch/a 10#-10 0
force -freeze sim:/ex_latch/b 10#1 0
run 100ns

# Ajusta o zoom para ver todos os testes
wave zoom full