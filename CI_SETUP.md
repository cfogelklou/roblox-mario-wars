# CI/CD and Static Analysis Setup

This document describes the static analysis tools and CI/CD pipeline configured for the Roblox Mario Wars project.

## Tools Overview

### 1. StyLua - Code Formatter
StyLua is a Lua code formatter that ensures consistent code style across the project.

**Configuration**: `stylua.toml`

**Usage**:
```bash
# Check if code is formatted correctly
stylua --check src tests

# Auto-format all code
stylua src tests
```

**Features**:
- 120 character line width
- Unix line endings
- Tab indentation
- Consistent quote style

### 2. Selene - Linter
Selene is a Lua linter with Roblox-specific support that catches common errors and enforces best practices.

**Configuration**: `selene.toml`

**Usage**:
```bash
# Run linter on all source files
selene src tests
```

**Checks**:
- Unused variables
- Undefined variables
- Variable shadowing
- Incorrect standard library usage
- Duplicate keys
- Empty conditionals

### 3. Luau - Type Checker
Luau is Roblox's typed Lua variant that provides static type checking.

**Configuration**: `.luaurc`

**Features**:
- Strict language mode
- Comprehensive lint rules
- Type inference
- Unknown global detection

### 4. Rojo - Project Builder
Rojo syncs your project structure to Roblox and can build place files.

**Configuration**: `default.project.json`

**Usage**:
```bash
# Build the Roblox place file
rojo build default.project.json --output MarioWars.rbxl

# Generate sourcemap for analysis tools
rojo sourcemap default.project.json --output sourcemap.json

# Start live sync server (for development)
rojo serve default.project.json
```

## Tool Installation

All tools are managed via Aftman (a toolchain manager for Roblox projects).

### Install Aftman
```bash
# Follow instructions at: https://github.com/LPGhatguy/aftman
```

### Install Project Tools
```bash
# Install all tools defined in aftman.toml
aftman install
```

This will install:
- `rojo` - Roblox project sync tool
- `stylua` - Code formatter
- `selene` - Linter

## GitHub Actions CI Pipeline

The CI pipeline runs automatically on:
- Pushes to `main`, `master`, `develop`, or `claude/**` branches
- Pull requests to `main`, `master`, or `develop`

### CI Jobs

#### 1. Lint and Type Check
- Installs all tools via Aftman
- Checks code formatting with StyLua
- Runs Selene linter
- Verifies Rojo project structure

#### 2. Format Check
- Dedicated job to verify code formatting
- Provides clear error messages if formatting is incorrect

#### 3. Build
- Builds the Roblox place file (`MarioWars.rbxl`)
- Uploads the built file as an artifact (available for 7 days)

#### 4. Summary
- Aggregates results from all jobs
- Provides clear pass/fail status

### Viewing CI Results

1. Go to the "Actions" tab in GitHub
2. Select the workflow run
3. View individual job results
4. Download build artifacts if needed

## Local Development Workflow

### Quick Test Script (Recommended)

**Run all CI checks locally before committing:**

```bash
./scripts/test.sh
```

This script runs all the same checks that GitHub Actions runs:
- ✅ Code formatting verification (StyLua)
- ✅ Linting (Selene)
- ✅ Project structure validation (Rojo)
- ✅ Build verification

**The script will:**
- Show colored output for each check
- Report exactly which tests failed
- Suggest fixes for common issues
- Exit with code 0 if all tests pass, 1 if any fail

### Manual Testing (Alternative)

If you prefer to run checks individually:

```bash
# Format your code
stylua src tests

# Check for linting issues
selene src tests

# Verify the project structure
rojo sourcemap default.project.json --output sourcemap.json

# Verify the project builds
rojo build default.project.json --output MarioWars.rbxl
```

### Pre-commit Checklist
- [ ] `./scripts/test.sh` passes (or all individual checks pass)
- [ ] Code is formatted (`stylua src tests`)
- [ ] No linting errors (`selene src tests`)
- [ ] Project builds successfully
- [ ] Tests pass (when running in Roblox Studio)

## Testing

### Unit Tests
Tests are written using the TestEZ framework and located in the `tests/` directory.

**Current Tests**:
- `tests/GameConfig.spec.lua` - Configuration validation tests
- `tests/init.spec.lua` - Main test runner

### Running Tests
Tests must be run inside Roblox Studio:

1. Open the place file in Roblox Studio
2. Install TestEZ plugin (if not already installed)
3. Run the test suite from the plugin

**Note**: Automated test execution in CI is not currently configured as it requires a Roblox server environment. This could be added using tools like:
- [run-in-roblox](https://github.com/roblox-aurora/rbx-run)
- Roblox's internal testing infrastructure

## Troubleshooting

### "stylua: command not found"
Run `aftman install` to install all required tools.

### Formatting check fails in CI
Run `stylua src tests` locally to auto-format your code, then commit the changes.

### Selene reports false positives
Update `selene.toml` to adjust rule severity or add exceptions.

### Build fails
- Ensure `default.project.json` is valid JSON
- Check that all required files exist in the paths specified
- Verify Rojo version compatibility

## Future Enhancements

Potential improvements to the CI/CD pipeline:

1. **Automated Testing**: Integrate run-in-roblox or similar tool to execute TestEZ tests in CI
2. **Type Coverage**: Add type annotations to all modules and enforce type checking
3. **Code Coverage**: Track test coverage metrics
4. **Performance Benchmarks**: Add performance regression testing
5. **Automatic Deployment**: Deploy to Roblox on successful builds
6. **Dependabot**: Automated dependency updates for Aftman tools

## Resources

- [StyLua Documentation](https://github.com/JohnnyMorganz/StyLua)
- [Selene Documentation](https://kampfkarren.github.io/selene/)
- [Luau Documentation](https://luau-lang.org/)
- [Rojo Documentation](https://rojo.space/)
- [Aftman Documentation](https://github.com/LPGhatguy/aftman)
- [TestEZ Documentation](https://roblox.github.io/testez/)
