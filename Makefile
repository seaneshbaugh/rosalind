CC=clang
CFLAGS=

SRC_DIRECTORY=src

BUILD_DIRECTORY=build

all: clean default

default: base-count transcribe reverse-complement

base-count:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/base-count.s -o $(BUILD_DIRECTORY)/base-count

transcribe:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/transcribe.s -o $(BUILD_DIRECTORY)/transcribe

reverse-complement:
	$(CC) $(CFLAGS) $(SRC_DIRECTORY)/reverse-complement.s -o $(BUILD_DIRECTORY)/reverse-complement

clean:
	rm -f $(BUILD_DIRECTORY)/base-count
	rm -f $(BUILD_DIRECTORY)/transcribe
	rm -f $(BUILD_DIRECTORY)/reverse-complement
