set ip_directory "ip_repo"
set project_name "bmaccelerator"
set ip_name "bondmachineip"
set project_dir "bmaccelerator"
set part_number "xc7z020clg484-1"

open_project ${project_dir}/${project_name}.xpr
update_compile_order -fileset sources_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
exit
