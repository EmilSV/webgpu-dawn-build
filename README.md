# WebGPU Dawn Build

This project automates the build process for the WebGPU Dawn project across multiple platforms: Windows, macOS, and Linux. It utilizes a PowerShell script to handle the build configuration and output management.

## Project Structure

- **.github/workflows/build-release.yml**: Contains the GitHub Actions workflow configuration to automate the build process on release.
- **build_dawn_v2.ps1**: A PowerShell script that automates the build process. It includes parameters for the commit SHA, output folder, architecture, and an option to skip dependencies.
- **action_args.json**: A JSON file that specifies the SHA of the commit to be checked out during the build process.
- **README.md**: Documentation for the project.

## Usage

To build the WebGPU Dawn project, follow these steps:

1. **Clone the Repository**: Clone this repository to your local machine.
2. **Set Up Dependencies**: Ensure that the necessary dependencies are installed. The build script can handle this automatically based on your operating system.
3. **Run the Build Script**: Execute the `build_dawn_v2.ps1` script with the appropriate parameters:
   - `sha`: The commit SHA to check out (found in `action_args.json`).
   - `outputFolder`: The folder where the build output will be stored (default is `.\dawn_build_output`).
   - `architecture`: The target architecture (options are `x86`, `x64`, `arm64`, default is `x64` only supported on Windows).
   - `skipDependencies`: A switch to skip the installation of dependencies.

## GitHub Actions

This project includes a GitHub Actions workflow that automatically builds the project whenever a new release is made. The workflow is defined in `.github/workflows/build-release.yml`.