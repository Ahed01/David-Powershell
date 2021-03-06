# listing 5 - Validating property values as a build task

# it's a good idea to validate build properties as part of the build.
# it's also a good idea to use a build task for this purpose.

properties {
    $config = 'Debug';     
};

# the ValidateConfig psake task ensures that the CONFIG property value is an appropriate value.
# this produces a more consumable and helpful error than allowing MSBUILD to fail with an invalid configuration.
task -name ValidateConfig -action {                                 

    # the psake ASSERT statement accepts a CONDITION parameter; if this parameter evaluates to something PowerShell 
    #   considers $false, the string in the FAILUREMESSAGE parameter is thrown as an exception, stopping the build.
    assert -condition ( 'debug','release' -contains $config ) ` 
        -failureMessage "Unrecognized config property value: $config; valid values include 'debug' and 'release'"                            
}                                                              

# the Build task now depends on the ValidateConfig task
task –name Build -depends ValidateConfig –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Build
    }
}

# the Clean task now depends on the ValidateConfig task
task –name Clean -depends ValidateConfig  –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Clean
    }
}

# PackageZip already depends on Build (which depends on ValidateConfig)
task -name PackageZip -depends Build -action {
    import-module pscx;
    dir ./MyProject/bin/$config | write-zip -output ./MyProject.zip;
}

task –name Rebuild -depends Clean,Build; 
task –name Default -depends Build;

