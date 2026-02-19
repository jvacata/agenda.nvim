.PHONY: test

test:
	nvim --headless --noplugin -u scripts/minimal.vim -c "PlenaryBustedDirectory tests/ { minimal_init = './scripts/minimal.vim', sequential = true }"

test_local:
	nvim --headless --noplugin -u scripts/minimal_local.vim -c "PlenaryBustedDirectory tests/ { minimal_init = './scripts/minimal_local.vim', sequential = true }"
