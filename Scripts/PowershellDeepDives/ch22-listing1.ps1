# listing 1 - a minimal psake build script

# a psake build script is a collection of build tasks

# individual tasks are created using the TASK function
# each task MUST have a name
# a task MAY have an ACTION scriptblock that defines what that task does

task –name Build –action { write-host 'running task build' }

task –name Clean –action { write-host 'running task clean' }

# tasks MAY depend on other tasks by listed task names in their DEPENDS parameter

task –name Rebuild -depends Clean,Build –action { 
    write-host 'running task rebuild' 
}; 

# the DEFAULT task name is special:
# 1. every psake script MUST have a default task
# 2. the default task MUST NOT have an action defined; it can only depend on other tasks
task –name default -depends Build;

# note: the -name and -action parameter names are OPTIONAL; you can omit these parameter
#   names when defining an action-based task; e.g., the build task could be written as:
# task Build { write-host 'running task build' }