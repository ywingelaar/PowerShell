﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Get-ItemProperty" {
    $currentDirectory = Split-Path $here -Leaf
    $parentDirectory  = Split-Path $here/.. -Leaf
    $isWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)

    if ($isWindows)
    {
        $tempDirectory = "~/testfolder"
        $testProvider  = "C"
    }
    else
    {
        $tempDirectory = "/tmp/testfolder"
        $testProvider  = "/"
    }

    New-Item $tempDirectory -ItemType Directory -Force
    $testfile = $tempDirectory + [System.IO.Path]::DirectorySeparatorChar + "testfile1"

    New-Item $testfile -ItemType file -Force

    It "Should be able to be called on in the current directory" {
        $(Get-ItemProperty $here).Name | Should Be $currentDirectory
    }

    It "Should be able to be called on a parent directory" {
        (Get-ItemProperty $here/..).Name | Should Be $parentDirectory
    }

    It "Should be able to be called on a directory using the path switch" {
        { Get-ItemProperty -Path $tempDirectory } | Should Not Throw
    }

    It "Should be able to be called on a file using the path switch" {
        { Get-ItemProperty -Path $testfile } | Should Not Throw
    }

    It "Should be able to access a property using the Path and name switches" {
        { Get-ItemProperty -Path $testfile -Name fullname } | Should Not Throw

        $output = Get-ItemProperty -Path $testfile -Name fullname

        $output.PSPath | Should Not BeNullOrEmpty

        $output.PSDrive | Should Be $testprovider

        $output.PSProvider.Name | Should Be "FileSystem"
    }

    It "Should be able to use the gp alias without error" {
        { gp . }  | Should Not Throw
        { gp .. } | Should Not Throw
    }

    It "Should have the same results between alias and cmdlet" {
        $alias  = gp -Path $testfile -Name fullname
        $cmdlet = Get-ItemProperty -Path $testfile -Name fullname

        $alias.PSPath          | Should Be $cmdlet.PSPath
        $alias.PSDrive         | Should Be $cmdlet.PSDrive
        $alias.PSProvider.Name | Should Be $cmdlet.PSProvider.Name
    }

    Remove-Item $tempDirectory -Recurse -Force
}
