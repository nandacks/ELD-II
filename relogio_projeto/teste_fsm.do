# teste de verificacao de comportamento da fsm

vlib rtl_work
vmap work rtl_work
vcom -93 -work work {sync_keys.vhd}
vcom -93 -work work {timer_hora_carga.vhd}
vcom -93 -work work {bin2bcd.vhd}
vcom -93 -work work {timer_hora_carga/top_timer_de2_115.vhd}
vcom -93 -work work {bcd2ssd.vhd}
vcom -93 -work work {blink.vhd}
vcom -93 -work work {fsm_relogio.vhd}

vsim work.fsm_relogio
add wave -position insertpoint  sim:/fsm_relogio/*

# gera clk que começa em 1 vai para 0 em 50 ns repetindo a cada 100 ns
force -freeze sim:/fsm_relogio/clk 1 0, 0 {50 ns} -r 100 ns

# rst e valores padrao
force -freeze sim:/fsm_relogio/adjust 0 0
force -freeze sim:/fsm_relogio/plus 0 0
force -freeze sim:/fsm_relogio/less 0 0
force -freeze sim:/fsm_relogio/hour_in 00000 0
force -freeze sim:/fsm_relogio/min_in 000000 0
force -freeze sim:/fsm_relogio/seg_in 000000 0
force -freeze sim:/fsm_relogio/reset 1 0
run 150 ns
force -freeze sim:/fsm_relogio/reset 0 0
run 100 ns

# teste de transicao com ajuste
force -freeze sim:/fsm_relogio/adjust 1 0
run 100 ns
force -freeze sim:/fsm_relogio/adjust 0 0
run 200 ns

# inc hora
force -freeze sim:/fsm_relogio/hour_in 01010 0
force -freeze sim:/fsm_relogio/plus 1 0
run 100 ns
force -freeze sim:/fsm_relogio/plus 0 0
run 200 ns

# dec hora
force -freeze sim:/fsm_relogio/less 1 0 
run 100 ns
force -freeze sim:/fsm_relogio/less 0 0 
run 200 ns

# transita para min
force -freeze sim:/fsm_relogio/adjust 1 0
run 100 ns
force -freeze sim:/fsm_relogio/adjust 0 0
run 200 ns

# inc min
force -freeze sim:/fsm_relogio/plus 1 0
run 100 ns
force -freeze sim:/fsm_relogio/plus 0 0
run 200 ns

# dec min
force -freeze sim:/fsm_relogio/less 1 0
run 100 ns
force -freeze sim:/fsm_relogio/less 0 0
run 200 ns

# transita seg
force -freeze sim:/fsm_relogio/adjust 1 0
run 100 ns
force -freeze sim:/fsm_relogio/adjust 0 0
run 200 ns

# inc seg
force -freeze sim:/fsm_relogio/seg_in 111011 0 
force -freeze sim:/fsm_relogio/plus 1 0
run 100 ns
force -freeze sim:/fsm_relogio/plus 0 0
run 200 ns

# dec seg
force -freeze sim:/fsm_relogio/seg_in 000000 0 
force -freeze sim:/fsm_relogio/less 1 0
run 100 ns
force -freeze sim:/fsm_relogio/less 0 0
run 200 ns

# transita idle
force -freeze sim:/fsm_relogio/adjust 1 0
run 100 ns
force -freeze sim:/fsm_relogio/adjust 0 0
run 300 ns

wave zoom full