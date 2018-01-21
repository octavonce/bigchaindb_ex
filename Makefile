MIX = mix
CFLAGS = -g -O3 -ansi -pedantic -Wall -Werror -Wextra -Wno-unused-parameter -Wno-missing-field-initializers

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH) 

ifeq ($(wildcard deps/libsodium),)
	LIBSODIUM_PATH = ../libsodium
else
	LIBSODIUM_PATH = deps/libsodium
endif

CFLAGS += -I$(LIBSODIUM_PATH)/src

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

.PHONY: all crypto_nifs clean

all: crypto_nifs

crypto_nifs:
	$(MIX) compile

priv/crypto_nifs.so: lib/c_src/crypto_nifs.c
	$(MAKE) -C $(LIBSODIUM_PATH) libsodium.a
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ lib/c_src/crypto_nifs.c $(LIBSODIUM_PATH)/libsodium.a

clean:
	$(MIX) clean
	$(MAKE) -C $(LIBSODIUM_PATH) clean
	$(RM) priv/crypto_nifs.so