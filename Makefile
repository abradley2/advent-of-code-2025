DAYS = 	\
	src/day_01 src/day_02 src/day_03 src/day_04 \
	src/day_05 src/day_06 src/day_07 src/day_08 \
	src/day_09 src/day_10 src/day_11 src/day_12

setup: $(DAYS)

src/day_%:
	@cp -r src/template $@