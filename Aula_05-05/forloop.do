restart -f

add wave -position insertpoint sim:/forloop/*

force -freeze sim:/forloop/a 11110000 0
run 100ns

force -freeze sim:/forloop/a 11111000 0
run 100ns

wave zoom full