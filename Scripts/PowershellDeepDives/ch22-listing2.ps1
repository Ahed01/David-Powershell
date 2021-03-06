# listing2 - MyProject Visual Studio build script

# this script demonstrates how to recreate Visual Studio build targets in psake
# these tasks simply delegate work to the MSBUILD build engine

task –name Build –action { 
    
    # the EXEC statement is a psake function.  it requires a scriptblock.
    # EXEC is used to wrap calls to "legacy" console applications (like MSBUILD)
    #   that use exit codes to communicate success or failure.  EXEC translates 
    #   these exit codes into first-class PowerShell exceptions, ensuring that
    #   if these legacy applications fail, the build will fail as well.
    
    exec {                                                               
        msbuild ./MyProject/MyProject.csproj /t:Build                    
    }                                                                    
}

task –name Clean –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /t:Clean
    }
}

task –name Rebuild -depends Clean,Build; 
task –name Default -depends Build;    
