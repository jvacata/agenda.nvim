# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

agenda.nvim is a Neovim plugin for personal productivity (tasks, kanban, notes, journaling). Currently in active development with task management implemented.

## Commands

**Run tests:**
```bash
make test_local
```

Tests use Plenary/Busted and run headlessly via `nvim --headless`. Tests are in `tests/` directory.

## Architecture

The codebase follows an MVC pattern with clear separation

**Data flow:** User command → main controller routes → task controller loads from service → render controller updates views → user actions update models → service persists to disk.

## Important notes
- Follow Neovim plugin conventions.
- Use Lua best practices.
- KISS principle.
- Write modular, testable code.
- Document functions with comments.
- Don't write unused code
- Must run tests before committing changes.
