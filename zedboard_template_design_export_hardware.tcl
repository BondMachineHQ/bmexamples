set ip_directory "ip_repo"
set project_name "bmaccelerator"
set ip_name "bondmachineip"
set project_dir "bmaccelerator"
set part_number "xc7z020clg484-1"

open_project ${project_dir}/${project_name}.xpr
write_hw_platform -fixed -force  -include_bit -file ${project_name}/bm_design_wrapper.xsa
exit
