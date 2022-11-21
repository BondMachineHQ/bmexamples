#!/usr/bin/env python3

import sys
import subprocess
import getopt

working_dir=""
input_file=""
output_file=""
simulation_steps="200"
isforml=False

try:
	opts, args = getopt.getopt(sys.argv[1:], "w:i:o:s:m", ["working_dir=","input_file=","output_file=", "simulation_steps=","ml"])
except  getopt.GetoptError:
	sys.exit(2)

for o, a in opts:
	if o in ("-w", "--working_dir"):
		working_dir = a
	elif o in ("-i", "--input_file"):
		input_file = a
	elif o in ("-o", "--output_file"):
		output_file = a
	elif o in ("-s", "--simulation_steps"):
		simulation_steps = a
	elif o in ("-m", "--ml"):
		isforml = True

if working_dir == "":
	working_dir="working_dir"
if input_file == "":
	input_file="simbatch_input.csv"
if output_file == "":
	output_file=working_dir+"/simbatch_output.csv"

last_step = str(int(simulation_steps) - 1)

# Load the BondMachine inputs
command="bondmachine -bondmachine-file "+working_dir+"/bondmachine.json -list-inputs"
p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
p.wait()
inputs={}
if p.returncode==0:
	while True:
		o = p.stdout.readline().decode()
		if o == '' and p.poll() != None:
			break
		result=o.split()
		if len(result)==2:
			inputs[result[0]]=result[1]

# Load the BondMachine outputs
command="bondmachine -bondmachine-file "+working_dir+"/bondmachine.json -list-outputs"
p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
p.wait()
outputs={}
if p.returncode==0:
	while True:
		o = p.stdout.readline().decode()
		if o == '' and p.poll() != None:
			break
		result=o.split()
		if len(result)==2:
			outputs[result[0]]=result[1]

# print (inputs)
# print (outputs)

# Open the input file
input_file_handle=open(input_file, "r")
output_file_handle=open(output_file, "w")

if isforml:
	for i in range(len(outputs)):
		output_file_handle.write("probability_"+str(i)+",")
	output_file_handle.write("classification\n")

# Read every line of the input file
for line in input_file_handle:
	line=line.strip()
	inputs_values=line.split(",")
	if len(inputs_values)==0:
		continue
	elif len(inputs_values)==len(inputs):
		print ("Running simulation with inputs: "+line)

		# Remove the simbox file
		command="rm -f "+working_dir+"/simboxtemp.json"
		p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
		p.wait()

		# Create the simbox file
		for i in range(len(inputs_values)):
			input_name=inputs[str(i)]
			input_value=inputs_values[i]
			command="simbox -simbox-file "+working_dir+"/simboxtemp.json -add \"absolute:0:set:"+input_name+":"+input_value+"\""
			p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
			p.wait()
			if p.returncode!=0:
				print ("Error setting input "+input_name+" to "+input_value)
				sys.exit(2)

		for output_name in outputs:
			command="simbox -simbox-file "+working_dir+"/simboxtemp.json -add \"absolute:"+last_step+":get:"+outputs[output_name]+":float32\""
			p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
			p.wait()
			if p.returncode!=0:
				print ("Error getting output "+output_name)
				sys.exit(2)

		# Run the simulation
		command="bondmachine -bondmachine-file "+working_dir+"/bondmachine.json -simbox-file "+working_dir+"/simboxtemp.json -sim -sim-interactions "+simulation_steps
		p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
		p.wait()
		if p.returncode!=0:
			print ("Error running simulation")
			sys.exit(2)

		outline=p.stdout.read().decode()

		if isforml:
			import numpy as np
			vals=np.asarray(outline.split(','))
			index=np.argmax(vals)
			output_file_handle.write(outline)
			output_file_handle.write(str(index)+"\n")
		else:
			outline=outline.strip(',')
			output_file_handle.write(outline+"\n")

	else:
		print("Error: The input file has an invalid number of columns")

input_file_handle.close()
output_file_handle.close()
