# listing 6 - using the description parameter

# psake tasks accept a DESCRIPTION string parameter
# these descriptions are viewed when the user requests build script documentation:
#    invoke-psake listing6.ps1 -docs

# it is helpful to focus "public" tasks the user is meant to run by giving them 
#   a specific description, and in turn giving "private" tasks (those that are only
#   meant to be used as dependencies of other tasks) with a generic description

properties {
    $config = 'Debug';     
};

# a generic private description string
$private = '(do not run this task directly)'                             

# the _ValidateConfig task is private, and uses a generic description
task -name _ValidateConfig -description $private -action {                                 
    assert -condition ( 'debug','release' -contains $config ) ` 
        -failureMessage "Unrecognized config property value: $config; valid values include 'debug' and 'release'"                            
}                                                              

# the Build task is public, so its description is explicit
task –name Build -description "Builds out-of-date binaries" -depends ValidateConfig –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Build
    }
}

# the Clean task is public, so its description is explicit
task –name Clean -description "Removes all build artifacts" -depends ValidateConfig  –action { 
    exec { 
        msbuild ./MyProject/MyProject.csproj /p:Configuration=$config /t:Clean
    }
}

# the PackageZip task is public, so its description is explicit
task -name PackageZip -description "Creates a ZIP the project" -depends Build -action {
    import-module pscx;
    dir ./MyProject/bin/$config | write-zip -output ./MyProject.zip;
}

# the Rebuild task is public, so its description is explicit
task –name Rebuild -description "Rebuilds the entire project" -depends Clean,Build; 

task –name Default -depends Build;

