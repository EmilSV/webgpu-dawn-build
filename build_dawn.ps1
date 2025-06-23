param(
    [string]$sha,
    [string]$outputFolder = ".\dawn_build_output",
    # x86, x64, arm64
    [string]$architecture = "x64",
    [switch]$skipDependencies = $false
)

$outputFolder = [IO.Path]::GetFullPath($outputFolder)

$osWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
$osMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
$osLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)



# Write-Host "installing dependencies..."
write-host "installing dependencies..."


if (-not $skipDependencies) {
    if ($osWindows) {

        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "winget not found. Installing winget..."
            
                Write-Host "Failed to find winget automatically. Please install it manually from Microsoft Store or GitHub."
                Write-Host "Download from: https://github.com/microsoft/winget-cli/releases"
                exit 1
        }
        else {
            Write-Host "winget is already installed."
        }

        # Accept source agreements non-interactively
        winget source update --disable-interactivity
        
        # Install packages with all non-interactive flags
        winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
        winget install -e --id Kitware.CMake --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
        winget install -e --id Python.Python.3.9 --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
        winget install -e --id Microsoft.VisualStudio.2022.BuildTools --accept-source-agreements --accept-package-agreements --silent --disable-interactivity

        # Wait a moment for VS Build Tools to install before modifying
        Start-Sleep -Seconds 30

        Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe" `
            -ArgumentList "modify", `
                        "--installPath", "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools", `
                        "--add", "Microsoft.VisualStudio.Component.Windows11SDK.26100", `
                        "--quiet", `
                        "--wait" `
            -Wait
    }
    elseif ($osMacOS) {
        brew install cmake
        brew install python@3.9
    }
    elseif ($osLinux) {
        # For Linux, we assume a Debian-based distribution (like Ubuntu)
        sudo apt-get install -y git cmake python3 python3-pip python3-venv clang libx11-dev libx11-xcb-dev libxcb1-dev
    }
}

git clone https://dawn.googlesource.com/dawn

Set-Location dawn

try {

    git checkout $sha

    if ($osWindows) {
        cmake `
            -B dawn_build_$architecture `
            -A $architecture `
            -D DAWN_FETCH_DEPENDENCIES=ON `
            -D CMAKE_BUILD_TYPE=Release `
            -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
            -D CMAKE_POLICY_DEFAULT_CMP0092=NEW `
            -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
            -D ABSL_MSVC_STATIC_RUNTIME=ON `
            -D DAWN_BUILD_SAMPLES=OFF `
            -D DAWN_BUILD_TESTS=OFF `
            -D DAWN_ENABLE_D3D12=ON `
            -D DAWN_ENABLE_D3D11=ON `
            -D DAWN_ENABLE_NULL=OFF `
            -D DAWN_ENABLE_DESKTOP_GL=OFF `
            -D DAWN_ENABLE_OPENGLES=OFF `
            -D DAWN_ENABLE_VULKAN=ON `
            -D DAWN_USE_GLFW=OFF `
            -D DAWN_ENABLE_SPIRV_VALIDATION=OFF `
            -D DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG=OFF `
            -D DAWN_BUILD_MONOLITHIC_LIBRARY=ON `
            -D TINT_BUILD_TESTS=OFF `
            -D TINT_BUILD_SPV_READER=ON `
            -D TINT_BUILD_SPV_WRITER=ON `
            -D TINT_BUILD_CMD_TOOLS=ON `

        Set-Variable -Name "CL" -Value "/Wv:18"
        cmake --build dawn_build_$architecture --config Release --target webgpu_dawn
    }
    elseif ($osMacOS) {

        cmake `
            -B dawn_build `
            -D DAWN_FETCH_DEPENDENCIES=ON `
            -D CMAKE_BUILD_TYPE=Release `
            -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
            -D CMAKE_POLICY_DEFAULT_CMP0092=NEW `
            -D BUILD_SHARED_LIBS=OFF `
            -D BUILD_SAMPLES=OFF `
            -D DAWN_BUILD_TESTS=OFF `
            -D DAWN_ENABLE_NULL=OFF `
            -D DAWN_ENABLE_OPENGLES=OFF `
            -D DAWN_ENABLE_METAL=ON `
            -D DAWN_USE_GLFW=OFF `
            -D DAWN_BUILD_SAMPLES=OFF `
            -D TINT_BUILD_TESTS=OFF `
            -D DAWN_BUILD_MONOLITHIC_LIBRARY=ON `

        cmake --build dawn_build --config Release --target webgpu_dawn
    }
    elseif ($osLinux) {

        cmake `
            -B dawn_build `
            -D DAWN_FETCH_DEPENDENCIES=ON `
            -D CMAKE_BUILD_TYPE=Release `
            -D CMAKE_CXX_COMPILER=clang++ `
            -D CMAKE_C_COMPILER=clang `
            -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
            -D CMAKE_POLICY_DEFAULT_CMP0092=NEW `
            -D DAWN_BUILD_SAMPLES=OFF `
            -D DAWN_BUILD_TESTS=OFF `
            -D DAWN_ENABLE_D3D12=OFF `
            -D DAWN_ENABLE_D3D11=OFF `
            -D DAWN_ENABLE_NULL=OFF `
            -D DAWN_ENABLE_DESKTOP_GL=OFF `
            -D DAWN_ENABLE_OPENGLES=OFF `
            -D DAWN_ENABLE_VULKAN=ON `
            -D DAWN_USE_GLFW=OFF `
            -D DAWN_ENABLE_SPIRV_VALIDATION=OFF `
            -D DAWN_BUILD_MONOLITHIC_LIBRARY=ON `
            -D TINT_BUILD_TESTS=OFF `

        cmake --build dawn_build --config Release --target webgpu_dawn
    }

    write-host "build finished"

    If (!(test-path -PathType container $outputFolder)) {
        write-host "creating output folder"
        New-Item -ItemType Directory -Path $outputFolder
    }


    write-host "copying files to output folder"
    if ($osWindows) {

        #copy header to output folder"
        Copy-Item .\dawn_build_$architecture\gen\include\dawn\webgpu.h "$outputFolder\webgpu.h"
        #copy lib to output folder"
        Copy-Item .\dawn_build_$architecture\src\dawn\native\Release\webgpu_dawn.lib "$outputFolder\webgpu_dawn.lib"
        #copy dll to output folder"
        Copy-Item .\dawn_build_$architecture\Release\webgpu_dawn.dll "$outputFolder\webgpu_dawn.dll"
    }
    elseif ($osMacOS) {
        #copy header to output folder"
        Copy-Item .\dawn_build\gen\include\dawn\webgpu.h "$outputFolder\webgpu.h"
        #copy dylib to output folder"
        Copy-Item .\dawn_build\src\dawn\native\libwebgpu_dawn.dylib "$outputFolder\libwebgpu_dawn.dylib"
    }

    elseif ($osLinux) {
        #copy header to output folder"
        Copy-Item .\dawn_build\gen\include\dawn\webgpu.h "$outputFolder\webgpu.h"
        #copy so to output folder"
        Copy-Item .\dawn_build\src\dawn\native\libwebgpu_dawn.so "$outputFolder\libwebgpu_dawn.so"
    }
}
catch {
    write-host "An error occurred during the build process: $_"
    Set-Location ..
    exit 1
}

Set-Location ..