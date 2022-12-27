$xml1Path = "samples/star-wars-api/FSharp.Data.GraphQL.Samples.StarWarsApi.fsproj"
[xml]$xml1 = Get-Content -Path $xml1Path
$node = $xml1.SelectSingleNode("//ItemGroup[@Label='ProjectReferences']")
$node.ParentNode.RemoveChild($node) | Out-Null

$xml2Path = "Directory.Build.targets"
[xml]$xml2 = Get-Content -Path $xml2Path
$version = $xml2.SelectSingleNode("//PropertyGroup[@Label='NuGet']/Version").InnerText

[xml]$fsharpPackages = @"
            <ItemGroup Label="PackageReferences">
                <PackageReference Include="FSharp.Data.GraphQL.Server.Middleware" Version="$($version)" />
                <PackageReference Include="FSharp.Data.GraphQL.Server" Version="$($version)" />
                <PackageReference Include="FSharp.Data.GraphQL.Shared" Version="$($version)" />
            </ItemGroup>
"@

$xml3Path = "Packages.props"
[xml]$xml3 = Get-Content -Path $xml3Path
$giraffeVersion = $xml3.SelectSingleNode("//PackageReference[@Update='Giraffe']/@Version")
$xml1.SelectSingleNode("//ItemGroup[@Label='PackageReferences']/PackageReference[@Include='Giraffe']").SetAttribute("Version",$giraffeVersion.Value)
$packageReferences = $xml1.SelectSingleNode("//ItemGroup[@Label='PackageReferences']")
foreach($packageReference in $fsharpPackages.DocumentElement.ChildNodes){
    $innerNode = $xml1.ImportNode($packageReference,$true)
    $packageReferences.AppendChild($innerNode)
}
$xml1.Save($xml1Path)