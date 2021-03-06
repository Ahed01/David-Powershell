# listing 4 - Configuring the build script

# psake uses the PROPERTIES statement to define build script properties
# the scriptblock supplied to the PROPERTIES statement is used to initialize
#   each task when the build script is run.

# in this listing, a single property named CONFIG is defined:
properties {                                                            
    $config = 'Debug';                                                  
};

task -name PackageZip -depends Build -action {
    import-module pscx;
    
    # properties are available inside of psake task action scriptblocks
    # in this case, the CONFIG property is being used to locate the build output
    dir ./MyProject/bin/$config | write-zip -output ./MyProject.zip;
}

task –name Build –action { 
    exec { 
        # here the CONFIG property is being used to toggle the Configuration of the build
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Build
    }
}

task –name Clean –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Clean
    }
}

task –name Rebuild -depends Clean,Build; 
task –name Default -depends Build;
