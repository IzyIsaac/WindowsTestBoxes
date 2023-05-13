$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="./buildlog.log"

packer build -force -on-error=ask .