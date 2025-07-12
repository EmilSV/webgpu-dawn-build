# WebGPU Dawn Build

This project automates the build process for the WebGPU Dawn project across multiple platforms: Windows, macOS, and Linux. It utilizes a PowerShell script to handle the build configuration and output management.

## Usage

To build the WebGPU Dawn project, follow these steps:

1. **Install Powershell** On Widows you can use the builtin one for macOS and Linux checkout https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell
2. **Clone the Repository**: Clone this repository to your local machine.
3. **Set Up Dependencies**: Ensure that the necessary dependencies are installed. The build script can handle this automatically based on your operating system.
4. **Run the Build Script**: Execute the `build_dawn_v2.ps1` script with the appropriate parameters:
   - `sha`: The commit SHA to check out.
   - `outputFolder`: The folder where the build output will be stored (default is `.\dawn_build_output`).
   - `architecture`: The target architecture (options are `x86`, `x64`, `arm64`, default is `x64` only supported on Windows).
   - `skipDependencies`: A switch to skip the installation of dependencies.

## GitHub Actions

This project includes a GitHub Actions workflow that automatically builds the project whenever a new release is made. The workflow is defined in `.github/workflows/build-release.yml`.