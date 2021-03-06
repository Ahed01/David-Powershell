#requires -version 3.0

$hash=[ordered]@{
ModuleName=[string];
DisplayName=[string];
DriverType=[string];
LinkDate=[datetime]
}

$data=driverquery /fo csv | select -Skip 1 | convertfrom-csv -Header $($hash.keys)

for ($i=0;$i -lt $data.count;$i++) {
  foreach ($property in $hash.keys) {
    #update each property with a trimmed version
    $data[$i].$property=$data[$i].$property.Trim() -as $hash.$property
  }
}
#write the data to the pipeline
$data

