# Instructions for AI Agents (Claude)

This document contains important instructions for AI agents working on this codebase.

## ⚠️ CRITICAL: Definition of "Done"

**IMPORTANT:** A task is NOT considered complete until ALL of the following criteria are met:

### 1. All Local Tests Must Pass

Before marking any task as complete, you **MUST** run the local test script and ensure all checks pass:

```bash
./scripts/test.sh
```

This script runs the same checks as the CI pipeline:
- ✅ Code formatting check (StyLua)
- ✅ Linting check (Selene)
- ✅ Project structure validation (Rojo sourcemap)
- ✅ Build verification (Rojo build)

**If ANY test fails, the task is NOT complete.**

### 2. Code Quality Standards

All code must meet these standards:

- **Formatted**: All Lua files must be formatted with StyLua
  - Run: `stylua src tests` to auto-format
  - Configuration: `stylua.toml`

- **Linted**: No linting errors from Selene
  - Configuration: `selene.toml`
  - Fix all warnings and errors before committing

- **Type-Safe**: Follow Luau best practices
  - Configuration: `.luaurc`
  - Use proper types where possible

### 3. Commit and Push

- All changes must be committed with clear, descriptive commit messages
- Changes must be pushed to the appropriate branch
- Follow the git development branch requirements in the task description

### 4. CI Must Pass

- After pushing, verify that the GitHub Actions CI workflow passes
- The CI runs the same checks as `./scripts/test.sh`
- If CI fails, fix the issues and push again

## Workflow for Completing Tasks

Follow this workflow for every task:

```bash
# 1. Make your code changes
# ... edit files ...

# 2. Format your code
stylua src tests

# 3. Run local tests
./scripts/test.sh

# 4. If tests fail, fix issues and repeat step 3

# 5. Once all tests pass, commit
git add -A
git commit -m "Descriptive commit message"

# 6. Push to branch
git push -u origin <branch-name>

# 7. Verify CI passes in GitHub Actions
```

## Common Issues and Solutions

### StyLua Formatting Failures

**Problem:** `stylua --check` reports formatting issues

**Solution:**
```bash
stylua src tests
```

This will automatically format all files to comply with the project's style rules.

### Selene Linting Errors

**Problem:** Selene reports warnings or errors

**Solution:**
1. Review each error carefully
2. Fix the code issues (unused variables, undefined variables, etc.)
3. For false positives, update `selene.toml` configuration
4. Re-run: `./scripts/test.sh`

### Rojo Build Failures

**Problem:** Rojo can't build the project

**Solution:**
1. Check that `default.project.json` is valid JSON
2. Verify all file paths in the project configuration exist
3. Ensure no syntax errors in Lua files
4. Check Rojo version compatibility: `rojo --version`

### Missing Tools

**Problem:** `./scripts/test.sh` reports missing tools

**Solution:**
```bash
# Install all tools via aftman
aftman install

# Or install aftman first:
# https://github.com/LPGhatguy/aftman
```

## Testing Infrastructure

### Local Testing
- **Script:** `./scripts/test.sh`
- **Purpose:** Run all CI checks locally before committing
- **Required Tools:** StyLua, Selene, Rojo (installed via aftman)

### CI/CD Pipeline
- **Location:** `.github/workflows/ci.yml`
- **Triggers:** Push to main branches, all PRs
- **Jobs:**
  1. Lint and Type Check
  2. Format Check
  3. Build Project
  4. Summary

### Unit Tests
- **Framework:** TestEZ
- **Location:** `tests/` directory
- **Current Tests:**
  - `GameConfig.spec.lua` - Configuration validation
  - `init.spec.lua` - Test runner

## Project-Specific Guidelines

### Roblox Best Practices

1. **Use Roblox Services Properly**
   - Always use `game:GetService()` instead of `game.ServiceName`
   - Example: `game:GetService("Players")` not `game.Players`

2. **Handle Asynchronous Operations**
   - Use `task.spawn()` for concurrent operations
   - Use `task.wait()` instead of `wait()`
   - Properly handle delays and timing

3. **Client-Server Communication**
   - Use RemoteEvents for client-to-server communication
   - Validate all inputs from clients on the server
   - Never trust client data

4. **Memory Management**
   - Clean up connections when done
   - Disconnect events properly
   - Avoid memory leaks

### Code Organization

- **ModuleScripts:** Reusable code goes in `ReplicatedStorage`
- **Server Scripts:** Game logic goes in `ServerScriptService`
- **Client Scripts:** UI and client-side detection in `StarterPlayer` and `StarterGui`
- **Tests:** All tests go in `tests/` directory

### Documentation

- Update `README.md` when adding major features
- Update `CI_SETUP.md` when changing CI/CD configuration
- Add inline comments for complex logic
- Write clear commit messages explaining the "why"

## Resources

- **Project README:** [README.md](README.md)
- **CI/CD Documentation:** [CI_SETUP.md](CI_SETUP.md)
- **Roblox Documentation:** https://create.roblox.com/docs
- **StyLua:** https://github.com/JohnnyMorganz/StyLua
- **Selene:** https://kampfkarren.github.io/selene/
- **Rojo:** https://rojo.space/
- **Aftman:** https://github.com/LPGhatguy/aftman

## Remember

> **A task is only complete when `./scripts/test.sh` passes with no errors.**

Do not mark tasks as complete, commit changes, or tell the user a task is done until all tests pass.
