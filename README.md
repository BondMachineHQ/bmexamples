# Projects

A BondMachine project is a directory that contains all the necessary files to generate the firmware for a specific board.
The project is created with the **bmhelper create** command line tool, which is installed with the BondMachine framework. It is configured using a Kconfig file, with commands similar to the Linux kernel (for example: make menuconfig). It is then validated and completed with the **bmhelper validate** and **bmhelper apply** commands.
Once the project is applied, it is possible to generate the firmware and make all the other operations with the **make** command and several targets.

## Project workflow

The project workflow is divided into several steps:
- project creation
- project configuration
- project validation
- project apply
- make targets execution

### Project creation

An enpty project can be created with the following command:

```
bmhelper create --project_name project_test
```

This command will create a project with the name **project_test** in the current directory. The project will be created with the default configuration. The default configuration is defined in the *bmhelper* tool and can be changed with the *make menuconfig* command (or any other command that can be used to configure the Kconfig file).

### Project configuration

The project configuration is defined in the **Kconfig** file. The **Kconfig** file is a text file that defines the configuration possibilities of the project. It is similar to the **Kconfig** file used in the Linux kernel. With a kconfig compatible tool the **Kconfig** file can be used to generate the specific configuration.

For example, the **make menuconfig** command will open a menu that allows you to configure the project. The menu is similar to the menu used to configure the Linux kernel. The menu is divided into several sections. Each section contains a set of configuration. The details of each configuration are described in the help of the menu. The menu is used to configure the **.config** file. The **.config** file is used by the project Makefile to configure the project and carry out the operations. 

```bash
make menuconfig
```

If preffered, it is possible to use a **local.mk** file to configure the project. The **local.mk** file is a text file that defines the configuration of the project directly specifying the variables. The project Makefile created by **bmhelper** will either use the **.config** file or the **local.mk** file to configure the project. The **.config** file has priority over the **local.mk** file. The **local.mk** file is useful when you want to configure the project with a script or with a tool that does not support the **.config** file.

Details on the configuration variables are described in the **Configuration variables** section.

### Project validation

WIP

### Project apply

WIP

### Firmware generation and other targets

After creating and appling a project, you can use the **make** command to generate firmware and perform other operations. The **make** command can be used with several targets. The targets are defined in the **Makefile** file and are described in the following sections.

```
make bondmachine

Create the Bondmachine and all its connecting processors.
You can view a diagram of the Bondmachine just created with the following instructions:
```

```
make show

Use graphviz to visualize the architecture generated. 
```

```
make hdl

Generate the source HDL code (i.e. working_dir/bondmachine.sv, working_dir/bondmachine.vhd)
```

The first workflow commands are:

```
make synthesis

Start the project synthesis
```

```
make implementation

Start the project implementation
```

```
make bitstream

Start the project bitstream generation
```

```
make program

program the board if connected
```

The second workflow commands are:

```
make design_synthesis

Start the project synthesis
```

```
make design_implementation

Start the project implementation
```

```
make design_bitstream

Start the project bitstream generation
```

```
make kernel_module

Create the kernel module which runs on custom buildroot linux distribution
```

```
make buildroot

Create the custom buildroot linux sdcard-image.
```

## Configuration variables

Wether you are reading variables from the **Kconfig** file or from the **.mk** files, the syntax is the same. The following is the list of the most commonly used variables:

| Variable              | type          | description               |
| --------              | --------      | --------                  |
| `DEPLOY_DIR`            | mandatory     | target directory          |
| `DEPLOY_TARGET`         | mandatory     | target board              |
| `DEPLOY_DIR`            | mandatory     | target user on the board  |
| `DEPLOY_GROUP`          | mandatory     | target group on the board |



| Variable              | type          | description       |
| --------              | --------      | --------          |
| `WORKING_DIR`           | mandatory     | directory name where the project is build (default) working_dir   |
| `CURRENT_DIR`           | mandatory     | current directory where you exec the makefile commands (default) $(shell pwd)   |
| `SOURCE_NEURALBOND`     | optional      | json file that describes the neural network you want to deploy on FPGA   |
| `NEURALBOND_LIBRARY`    | optional      | library of assembly neurons necessary to build the neural network on FPGA   |
| `NEURALBOND_ARGS`       | optional      | set of arguments to customize the neural network   |
| `BMINFO`                | mandatory     | json file   |
| `BOARD`                 | mandatory     | the target board for which you want to synthesize the firmware   |
| `MAPFILE`               | mandatory     | json file   |
| `SHOWARGS`              | optional      | variables to display in different ways the bondmachine graph  |
| `SHOWRENDERER`          | mandatory     | ... |
| `VERILOG_OPTIONS`       | mandatory     | ... |
