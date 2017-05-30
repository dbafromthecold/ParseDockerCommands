Skip to content
This repository
Search
Pull requests
Issues
Marketplace
Gist
 @dbafromthecold
 Sign out
 Watch 0
  Star 0
  Fork 0 dbafromthecold/parsedockercommands
 Code  Issues 0  Pull requests 0  Projects 0  Wiki  Settings Insights 
Branch: master Find file Copy pathparsedockercommands/queryrepo
95a52ad  4 minutes ago
@dbafromthecold dbafromthecold Update queryrepo
1 contributor
RawBlameHistory     
58 lines (48 sloc)  2.12 KB
# path to docker.exe and IP of docker host
$docker = "C:\Program Files\Docker\Docker\resources\bin\Docker.exe"
$dockerhost = "tcp://XX.XX.XX.XX:2375"

# path to certs generated by instructions on my blog 
# https://dbafromthecold.com/2017/02/22/remotely-administering-the-docker-engine-on-windows-server-2016/
# or via https://hub.docker.com/r/stefanscherer/dockertls-windows/
$certpath = ".........."

$tlscacert = "--tlscacert=$certpath\ca.pem"
$tlscert = "--tlscert=$certpath\server-cert.pem"
$tlskey = "--tlskey=$certpath\server-key.pem"

$images = . $docker --tlsverify $tlscacert $tlscert $tlskey -H $dockerhost images 
$containers = . $docker --tlsverify $tlscacert $tlscert $tlskey -H $dockerhost ps -a

$imagearray = @()
$containerarray = @()

foreach($image in $images){    
    $image = $image | 
        ConvertFrom-String -Delimiter "[ ]{2,}" -PropertyNames Repository, Tag, ImageID, Created, VirtualSize |
            where-object {$_.Repository -ne "REPOSITORY"} 

        if($image){
                $row = New-Object psobject @{
                    Repository = $image.Repository;
                    Tag = $image.Tag 
                    ImageID = $image.ImageID
                    Created = $image.Created
                    VirtualSize = $image.VirtualSize
            }
        }   
        $imagearray += $row
    }
 
foreach($container in $containers){
    $container = $container |
        ConvertFrom-String -Delimiter "[ ]{2,}" -PropertyNames "ContainerID","Image","Command","Created","Status","Ports","Names" |
            where-object {$_.ContainerID -ne "CONTAINER ID"} 
            
            if($container){
                $row = New-Object psobject @{
                        ContainerID = $container.ContainerID 
                        Image = $container.Image 
                        Command = $container.Command 
                        Created = $container.Created 
                        Status = $container.Status
                        Ports = $container.Ports
                        Names = $container.Names
                }
            }
        $containerarray += $row
    }

# $imagearray        
# $containerarray
Contact GitHub API Training Shop Blog About
© 2017 GitHub, Inc. Terms Privacy Security Status Help