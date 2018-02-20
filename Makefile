program_NAME := c_NIFS
program_SRCS := $(wildcard *.c)
program_OBJS := ${program_SRCS:.c=.o}
program_INCLUDE_DIRS := ./lib/c_src, ./lib/c_src/asn1
program_LIBRARIES := sodium

MIX = mix
CFLAGS = -g -O3 -ansi -Wall -Werror -Wextra -Wno-unused-parameter -Wno-missing-field-initializers
CFLAGS += $(foreach includedir,$(program_INCLUDE_DIRS),-I$(includedir))
LDFLAGS += $(foreach library,$(program_LIBRARIES),-l$(library))

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

.PHONY: all clean distclean

all: $(program_NAME)

$(program_NAME):
	$(MIX) compile

$(program_NAME): $(program_OBJS)
	$(LINK.cc) $(program_OBJS) -o $(program_NAME)

priv/crypto_nifs.so: lib/c_src/crypto_nifs.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ lib/c_src/crypto_nifs.c

clean:
	$(MIX) clean
	@- $(RM) $(program_NAME)
	@- $(RM) $(program_OBJS)
