CC=clang
CFLAGS=

SRC_DIRECTORY=src

BUILD_DIRECTORY=build

all: clean default

default: base-count transcribe

base-count:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/base-count.s -o $(BUILD_DIRECTORY)/base-count

transcribe:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/transcribe.s -o $(BUILD_DIRECTORY)/transcribe

clean:
	rm -f $(BUILD_DIRECTORY)/base-count
	rm -f $(BUILD_DIRECTORY)/transcribe
