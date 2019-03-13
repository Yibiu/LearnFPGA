# 退出当前仿真功能
quit -sim
# 清楚命令行显示信息
.main clear

# 创建目录
vlib 目录名
vlib ./work

# 映射路径
vmap 库名 目录
vmap work ./work

# 添加文件
vlog -work 库名 文件名
vlog -work work ./tb_shift.v
vlog -work work ../design/shift.v

# 启动仿真
vsim -voptargs=+acc 顶层文件路径
vsim -voptargs=+acc work.tb_shift

# 添加波形
add wave tb_shift/tb_lvds_clk
add wave tb_shift/tb_rst_n
add wave tb_shift/tb_lvds_d
add wave tb_shift/tb_o_lvds_d
add wave -divider {name}
add wave tb_shift/shift_inst/*

# 运行
run 运行时间
run 100us




