CC=clang
CFLAGS=

SRC_DIRECTORY=src

BUILD_DIRECTORY=build

all: clean default

default: base-count

base-count:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/base-count.s -o $(BUILD_DIRECTORY)/base-count

clean:
	rm -f $(BUILD_DIRECTORY)/base-count
