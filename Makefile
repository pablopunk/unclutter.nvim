MINIMAL_INIT := ./scripts/minimal_init.vim
DOC_GEN_SCRIPT := ./scripts/docs.lua
PLUGIN_DIR := lua/


test:
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory ${PLUGIN_DIR} { minimal_init = '${MINIMAL_INIT}' }"

docs:
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "luafile ${DOC_GEN_SCRIPT}" -c 'qa'
