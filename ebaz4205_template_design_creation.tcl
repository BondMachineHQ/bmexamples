set ip_directory "ip_repo"
set project_name "bmaccelerator"
set ip_name "bondmachineip"
set project_dir "bmaccelerator"
set part_number "xc7z010clg400-1"

create_project -force ${project_name} ${project_dir} -part ${part_number}
set_property ip_repo_paths ${ip_directory} [current_project]
update_ip_catalog
create_bd_design "bm_design"
open_bd_design ${project_dir}/${project_name}.srcs/sources_1/bd/bm_design/bm_design.bd
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
endgroup

startgroup
set_property -dict [list CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 24 .. 25}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1}] [get_bd_cells processing_system7_0]
make_bd_intf_pins_external  [get_bd_intf_pins processing_system7_0/MDIO_ETHERNET_0]
make_bd_pins_external  [get_bd_pins processing_system7_0/ENET0_GMII_TX_EN]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
set_property -dict [list CONFIG.IN0_WIDTH.VALUE_SRC USER CONFIG.IN1_WIDTH.VALUE_SRC PROPAGATED] [get_bd_cells xlconcat_0]
set_property -dict [list CONFIG.NUM_PORTS {1} CONFIG.IN0_WIDTH {3}] [get_bd_cells xlconcat_0]
set_property -dict [list CONFIG.IN0_WIDTH {4}] [get_bd_cells xlconcat_0]
make_bd_pins_external  [get_bd_pins xlconcat_0/dout]
set_property name enet0_gmii_txd [get_bd_ports dout_0]
connect_bd_net [get_bd_pins processing_system7_0/ENET0_GMII_TXD] [get_bd_pins xlconcat_0/In0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1
set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells xlconcat_1]
set_property -dict [list CONFIG.IN1_WIDTH.VALUE_SRC USER CONFIG.IN0_WIDTH.VALUE_SRC USER] [get_bd_cells xlconcat_1]
set_property -dict [list CONFIG.NUM_PORTS {2} CONFIG.IN0_WIDTH {4} CONFIG.IN1_WIDTH {4}] [get_bd_cells xlconcat_1]
connect_bd_net [get_bd_pins processing_system7_0/ENET0_GMII_RXD] [get_bd_pins xlconcat_1/dout]
make_bd_pins_external  [get_bd_pins xlconcat_1/In0]
set_property name enet0_gmii_rxd [get_bd_ports In0_0]
make_bd_pins_external  [get_bd_pins processing_system7_0/ENET0_GMII_RX_CLK]
make_bd_pins_external  [get_bd_pins processing_system7_0/ENET0_GMII_RX_DV]
make_bd_pins_external  [get_bd_pins processing_system7_0/ENET0_GMII_TX_CLK]
endgroup

startgroup
create_bd_cell -type ip -vlnv bondmachine.fisica.unipg.it:user:${ip_name}:1.0 ${ip_name}_0
save_bd_design
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/${ip_name}_0/S00_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins ${ip_name}_0/S00_AXI]
validate_bd_design
endgroup

ipx::edit_ip_in_project -upgrade true -name ${ip_name}_v1_0_project -directory ${project_dir}/${project_name}.tmp/${ip_name}_v1_0_project ${ip_directory}/${ip_name}_1.0/component.xml
update_compile_order -fileset sources_1
add_files -norecurse -scan_for_includes ${ip_directory}/${ip_name}_1.0/hdl/bondmachine.sv
update_compile_order -fileset sources_1
ipx::open_ipxact_file ${ip_directory}/${ip_name}_1.0/component.xml
ipx::merge_project_changes hdl_parameters [ipx::current_core]
set_property core_revision 4 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog -rebuild
close_project
close_project

open_project ${project_dir}/${project_name}.xpr
open_bd_design ${project_dir}/${project_name}.srcs/sources_1/bd/bm_design/bm_design.bd
upgrade_ip -vlnv bondmachine.fisica.unipg.it:user:${ip_name}:1.0 [get_ips  bm_design_${ip_name}_0_0] -log ip_upgrade.log
export_ip_user_files -of_objects [get_ips bm_design_${ip_name}_0_0] -no_script -sync -force -quiet
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/${ip_name}_0/S00_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins ${ip_name}_0/S00_AXI]

startgroup
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup

connect_bd_net [get_bd_pins ${ip_name}_0/interrupt] [get_bd_pins processing_system7_0/IRQ_F2P]

startgroup
make_bd_pins_external  [get_bd_pins bondmachineip_0/btnC]
endgroup

set_property name btnC [get_bd_ports btnC_0]

save_bd_design
validate_bd_design
make_wrapper -files [get_files ${project_dir}/${project_name}.srcs/sources_1/bd/bm_design/bm_design.bd] -top
update_compile_order -fileset sources_1
add_files -norecurse -scan_for_includes ${project_dir}/${project_name}.srcs/sources_1/bd/bm_design/hdl/bm_design_wrapper.v
update_compile_order -fileset sources_1
add_files -fileset constrs_1 -norecurse ebaz4205.xdc
update_compile_order -fileset sources_1

close_project
exit
