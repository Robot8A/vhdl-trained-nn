onerror {resume}
quietly virtual signal -install /neuralnetwork { (context /neuralnetwork )(input0 &input1 &input2 &input3 &input4 &input5 &input6 &input7 )} input
quietly WaveActivateNextPane {} 0
add wave -noupdate /neuralnetwork/clk
add wave -noupdate /neuralnetwork/reset
add wave -noupdate /neuralnetwork/state
add wave -noupdate -radix float32 /neuralnetwork/final_result0
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input0
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input1
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input2
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input3
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input4
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input5
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input6
add wave -noupdate -expand -group input -color Yellow -radix float32 -radixshowbase 0 /neuralnetwork/input7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6015 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 349
configure wave -valuecolwidth 68
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1814739 ps} {2072909 ps}
