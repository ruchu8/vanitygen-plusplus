## CentOS/Redhat:
# yum install openssl-devel
# yum install libcurl-devel
# yum install check                # Only need if you want to run tests

## Ubuntu:
# apt install build-essential
# apt install libssl-dev
# apt install libpcre3-dev
# apt install libcurl4-openssl-dev
# apt install check                # Only need if you want to run tests

## MacOS:
# brew install openssl@3
# brew install pcre
# brew install check                # Only need if you want to run tests

CFLAGS?=-ggdb -O3 -Wall -Wno-deprecated
LDFLAGS?=
# CFLAGS=-ggdb -Wall -Wno-deprecated -fsanitize=address
# CFLAGS=-ggdb -O3 -Wall -I /usr/local/cuda-10.2/include/

OBJS=vanitygen.o oclvanitygen.o oclvanityminer.o oclengine.o keyconv.o pattern.o util.o groestl.o sha3.o ed25519.o \
     stellar.o base32.o crc16.o bech32.o segwit_addr.o compat.o winglue.o \
     ocled25519engine.o oclvanitygen_ed25519.o
PROGS=vanitygen++ keyconv oclvanitygen++ oclvanityminer

PLATFORM=$(shell uname -s)
ifeq ($(PLATFORM),Darwin)
	OPENCL_LIBS=-framework OpenCL
	LIBS+=-L/opt/homebrew/opt/openssl/lib
	CFLAGS+=-I/opt/homebrew/opt/openssl/include
	LIBS+=-L/opt/homebrew/opt/pcre/lib
	CFLAGS+=-I/opt/homebrew/opt/pcre/include
	LIBS+=-L/opt/homebrew/opt/check/lib
	CFLAGS+=-I/opt/homebrew/opt/check/include
else ifeq ($(PLATFORM),NetBSD)
	LIBS+=`pcre-config --libs`
	CFLAGS+=`pcre-config --cflags`
else ifeq ($(findstring MINGW,$(PLATFORM)),MINGW)
	# MinGW Windows 平台配置
	OPENCL_LIBS=-lOpenCL
	CFLAGS += -D_WIN32
	# Windows系统依赖库，解决WSA/WinCrypto缺失
	SYSLIBS = -lgdi32 -lws2_32 -lcrypt32
	# MSYS2 pcre静态库名称
	PCRE_LIB = -lpcre-8
else
	OPENCL_LIBS=-lOpenCL
	SYSLIBS=
	PCRE_LIB=-lpcre
endif


most: vanitygen++ keyconv

all: $(PROGS)

vanitygen++: vanitygen.o pattern.o util.o groestl.o sha3.o ed25519.o stellar.o base32.o crc16.o simplevanitygen.o bech32.o segwit_addr.o winglue.o
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS) $(PCRE_LIB) -lcrypto -lm -lpthread $(SYSLIBS)

oclvanitygen++: oclvanitygen.o oclengine.o pattern.o util.o groestl.o sha3.o ocled25519engine.o oclvanitygen_ed25519.o stellar.o base32.o crc16.o compat.o winglue.o
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS) $(PCRE_LIB) -lcrypto -lm -lpthread $(OPENCL_LIBS) $(SYSLIBS)

oclvanityminer: oclvanityminer.o oclengine.o pattern.o util.o groestl.o sha3.o winglue.o
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS) $(PCRE_LIB) -lcrypto -lm -lpthread $(OPENCL_LIBS) -lcurl $(SYSLIBS)

ocled25519engine.o: ocled25519engine.c ocled25519engine.h
	$(CC) $(CFLAGS) -c -o $@ $<

oclvanitygen_ed25519.o: oclvanitygen_ed25519.c ocled25519engine.h
	$(CC) $(CFLAGS) -c -o $@ $<

keyconv: keyconv.o util.o groestl.o sha3.o winglue.o
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS) $(PCRE_LIB) -lcrypto -lm -lpthread $(SYSLIBS)

run_tests.o: tests.h util_test.h segwit_addr_test.h pattern_test.h ton_test.h pattern.c pattern.h

run_tests: run_tests.o util.o groestl.o sha3.o bech32.o segwit_addr.o crc16.o winglue.o
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS) $(PCRE_LIB) -lcrypto -lm -lpthread $(OPENCL_LIBS) -lcheck -lsubunit $(SYSLIBS)

test: run_tests
	./run_tests

clean:
	rm -f $(OBJS) $(PROGS) $(TESTS) *.oclbin run_tests
