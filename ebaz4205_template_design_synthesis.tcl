set ip_directory "ip_repo"
set project_name "bmaccelerator"
set ip_name "bondmachineip"
set project_dir "bmaccelerator"
set part_number "xc7z010clg400-1"

open_project ${project_dir}/${project_name}.xpr
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
exit
