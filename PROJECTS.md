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

```bash
bmhelper create --project_name project_test
```

This command will create a project with the name **project_test** in the current directory. The project will be created with the default configuration. The default configuration is defined in the *bmhelper* tool and can be changed with the *make menuconfig* command (or any other command that can be used to configure the Kconfig file).

Additionally, the **bmhelper create** command can be used to create a project starting from a working example. To get the list of available examples, use the following command:

```bash
bmhelper create --list-examples
```

To duplicate an example, use the following command:

```bash
bmhelper create --project_name project_test --example example_name
```

where **example_name** is the name of an example in the list of examples.

### Project configuration

The project configuration is defined in the **Kconfig** file. The **Kconfig** file is a text file that defines the configuration possibilities of the project. It is similar to the **Kconfig** file used in the Linux kernel. With a kconfig compatible tool the **Kconfig** file can be used to generate the specific configuration.

For example, the **make menuconfig** command will open a menu that allows you to configure the project. The menu is similar to the menu used to configure the Linux kernel. The menu is divided into several sections. Each section contains a set of configuration. The details of each configuration are described in the help of the menu. The menu is used to configure the **.config** file. The **.config** file is used by the project Makefile to configure the project and carry out the operations. 

```bash
make menuconfig
```

If preffered, it is possible to use a **local.mk** file to configure the project. The **local.mk** file is a text file that defines the configuration of the project directly specifying the variables. The project Makefile created by **bmhelper** will either use the **.config** file or the **local.mk** file to configure the project. The **.config** file has priority over the **local.mk** file. The **local.mk** file is useful when you want to configure the project with a script or with a tool that does not support the **.config** file.

Details on the configuration variables are described in the **Configuration variables** section.

### Project validation

The bmhelper tool can be used to validate the project configuration. The validation is performed with the following command:

```bash
make validate
```

The validation process checks the configuration variables and the project files. For each one of them the following color codes are used:

- **green** : the variable or file is present and valid
- **yellow** : the (optional) variable or file is not present 
- **magenta** : the (mandatory) variable or file is not present but bmhelper can create it with default values
- **red** : the (mandatory) variable or file is either not present or invalid

### Project apply

The project configuration is applied with the following command:

```bash
make apply
```

The apply process creates the project files and directories. The files and directories are created in the working directory. The working directory is defined by the **WORKING_DIR** variable. The default working directory is the current directory. 
For the items marked as **magenta** in the validation process, the apply process will ask for confirmation before creating the file or directory with the default values. For the items marked as **red** in the validation process, the apply process will fail.

### Generic targets

After creating and appling a project, you can use the **make** command to generate firmware and perform other operations. The **make** command can be used with several targets. The targets are defined in the **Makefile** file and are described in the following sections.

The following targets are available for any type of project independently of the board/toolchain:

| **Command** | **Description** |
|--------|--------|
| `make bondmachine` | Create the Bondmachine and all its connecting processors. Starting from the specific source file and source tool, the Bondmachine is created and save as JSON file. |
| `make clean` | Clean the project directory. |
| `make show` | Use graphviz to visualize the architecture generated. |
| `make hdl` | Generate the source HDL code (i.e. working_dir/bondmachine.sv, working_dir/bondmachine.vhd) |

Staring from the **hdl** target, several workflow are available depending on several factors like the board, the toolchain, the use as accelerator or as stand-alone project.

### Stand-alone workflow

Stand-alone projects only require the FPGA board to run.
The following targets are available for stand-alone projects:

| **Command** | **Description** |
|--------|--------|
| `make synthesis` | Start the project synthesis |
| `make implementation` | Start the project implementation |
| `make bitstream` | Start the project bitstream generation |
| `make program` | Program the board if connected |

### SoC Accelerator workflow

SoC Accelerator projects require a board with a SoC
processor to run. The SoC processor is connected to the FPGA fabric and can be used to run the BondMachine. Examples of SoC processors are the ARM processors in the Zynq SoC or the Cyclone V SoC.

The following targets are available for SoC accelerator projects:

| **Command** | **Description** |
|--------|--------|
| `make design_synthesis` | Start the project synthesis |
| `make design_implementation` | Start the project implementation |
| `make design_bitstream` | Start the project bitstream generation |
| `make kernel_module` | Create the kernel module which runs on custom buildroot linux distribution |
| `make buildroot` | Create the custom buildroot linux sdcard-image |
| `make deploy` | Deploy the bitstream, kernel module and eventually the application on the board |

### PCie Accelerator workflow (Xilinx)

PCie Accelerator projects require a board with a PCie interface to run. The PCie interface is used to connect the FPGA to the host PC. The host PC can be used to run the BondMachine. Examples of PCie boards are the Xilinx Alveo boards.

The following targets are available for PCie accelerator projects:

| **Command** | **Description** |
|--------|--------|
| `make xclbin` | Create the xclbin file |
| `make deploy_xclbin` | Deploy the xclbin file and eventually the application on the host |

## Configuration variables

Wether you are reading variables from the **Kconfig** file or from the **.mk** files, the syntax is the same. The following is the list of the most commonly used variables:

| **Variable** | **type** | **description** |
|--------|:--------:|--------:|
| `ALTERA_BOARD_MAX1000` | KConfig Only | Board selection max1000 |
| `ALTERA_BOARD_DE0NANO` | KConfig Only | Board selection de0nano |
| `BASM_DEBUG` | boolean | enable or not debug of basm |
| `BM_REGRESSION` | KConfig Only | missing |
| `BOARD` | KConfig Only | Board type |
| `BOARDLESS_PROJECT` | KConfig only | enable or not debug of basm |
| `GENERAL_TYPE` | KConfig only | general project type |
| `GENERAL_TYPE_BOARDLESS` | KConfig only | project without board |
| `GENERAL_TYPE_BOARD` | KConfig only | project with board |
| `HDL_REGRESSION` | filename | missing |
| `PROJECT_TYPE_BONDGO` | KConfig Only | BondGo project |
| `PROJECT_TYPE_NEURALBOND` | KConfig Only | Neural Network project |
| `PROJECT_TYPE_MELBOND` | KConfig Only | Melbond project |
| `PROJECT_TYPE_BASM` | KConfig Only | sBASM project |
| `PROJECT_TYPE_MULTI` | KConfig Only | Root project aggregator for multiple project |
| `MULTI_TARGET` | string | Target to exec in case of multiple projects |
| `MULTI_TYPE` | string | Type of aggregation |
| `MULTI_TEMPLATE_DIR` | directory | directory of template to clone |
| `MULTI_TEMPLATE_DESC` | filename | multifilename description json file |
| `LATTICE_BOARD_ICE40LP1K` | Kconfig Only | Board selection Lattice ice40lp1k |
| `LATTICE_BOARD_ICEFUN` | Kconfig Only | Board selection Lattice icefun |
| `LATTICE_BOARD_ICEBREAKER` | Kconfig Only | Board selection Lattice icebreaker |
| `LATTICE_BOARD_ICESUGARNANO` | Kconfig Only | Board selection Lattice icesugarnano |
| `SELECT_PROJECT_TYPE` | KConfig Only | select project type |
| `SELECT_TOOLCHAIN` | KConfig Only | select toolchain |
| `SELECT_XILINX_BOARD` | KConfig Only | select board |
| `REGRESSION_TEST` | KConfig Only | missing description |
| `REGRESSION_TEST_BM` | KConfig Only | missing |
| `REGRESSION_TEST_HDL` | KConfig Only | missing |
| `REGRESSION_TEST_SIM` | KConfig Only | missing |
| `ROOTDIR` | string | Directory storing the board-specific files |
| `SIM_REGRESSION` | KConfig Only | missing |
| `SOURCE_GO` | filename | bondgo source |
| `SOURCE_NEURALBOND` | filename | neuralbond source file |
| `SOURCE_MELBOND` | filename | melnond source file |
| `SOURCE_BASM` | filenames | basm source file |
| `TOOLCHAIN` | string | FPGA tools |
| `TOOLCHAIN_ALTERA` | Kconfig Only | select altera toolchain |
| `TOOLCHAIN_LATTICE` | Kconfig Only | select lattice toolchain |
| `TOOLCHAIN_XILINX` | Kconfig Only | select xilinx toolchain |
| `UART_MAPFILE` | filename | support for UART |
| `UART_SUPPORT` | boolean | support for UART |
| `WORKING_DIR` | directory | Working directory path |
| `XILINX_BOARD_BASYS3` | Kconfig Only | Board selection basys3 |
| `XILINX_BOARD_ZEDBOARD` | KConfig Only | Board selection zedboard |
| `XILINX_BOARD_ZC702` | KConfig Only | Board selection zc702 |
| `XILINX_BOARD_KC705` | KConfig Only | Board selection kc705 |
| `XILINX_BOARD_EBAZ4205` | KConfig Only | Board selection ebaz4205 |
