set ip_directory "ip_repo"
set project_name "bmaccelerator"
set ip_name "bondmachineip"
set project_dir "bmaccelerator"
set part_number "xc7z020clg484-1"

hsi open_hw_design ${project_dir}/bm_design_wrapper.xsa
hsi set_repo_path device-tree-xlnx
hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
hsi generate_target -dir dts
hsi close_hw_design bm_design_wrapper

exit