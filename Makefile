MINIMAL_INIT := ./scripts/minimal_init.vim

test:
	nvim --headless --noplugin -u ${MINIMAL_INIT} \
		-c "PlenaryBustedDirectory lua/ { minimal_init = '${MINIMAL_INIT}' }"

