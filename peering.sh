# This shellscript will iterate through a resourcegroup name (defined as rgname),
# iterate the vnets, and peer all the vnets with spoke in the name to the vnet with hub
# in the name.

# select resourcegroup
rgname="rg-spokeautomation-airs-01"
# dump vnets in the resource group into the array vnets
vnets=$(az network vnet list --resource-group $rgname --output yaml | grep name | cut -d ':' -f 2 | sed 's/[[:space:]]//g')
# iterate through vnets for the hub first and store the name and id in appropriate variables
for vnet in $vnets; do
    if [[ $vnet =~ "hub" ]]
    then
        hubid=$(az network vnet show --resource-group $rgname --name $vnet --query id --out tsv)
        hubname=$vnet
    fi
done
# iterate through the vnets for the spokes and attach each spoke to the hub
for vnet in $vnets; do
    if [[ $vnet =~ "spoke" ]]
    then
        spokeid=$(az network vnet show --resource-group $rgname --name $vnet --query id --out tsv)
        spokename=$vnet
        az network vnet peering create --name $hubname-To-$spokename --resource-group $rgname --vnet-name $hubname --remote-vnet $spokeid --allow-vnet-access --output yaml
        az network vnet peering create --name $spokename-to-$hubname --resource-group $rgname --vnet-name $spokename --remote-vnet $hubid --allow-vnet-access --output yaml
    fi
done