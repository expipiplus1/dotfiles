{ lib, config, pkgs, ... }@inputs:

let
  keyboardDebounce = pkgs.runCommandCC "keyboard-debounce" {
    preferLocalBuild = true;
    allowSubstitutes = false;
  } ''
    mkdir -p $out/bin
    cat > code.c << 'EOF'
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <linux/input.h>
    #include <linux/uinput.h>
    #include <sys/time.h>
    #include <dirent.h>
    #include <errno.h>

    #define DEBOUNCE_MS 100
    #define VENDOR_ID 0x1189
    #define PRODUCT_ID 0x8890
    #define MAX_KEYS 256

    #define BITS_PER_LONG (sizeof(long) * 8)
    #define NBITS(x) ((((x)-1)/BITS_PER_LONG)+1)
    #define OFF(x)  ((x)%BITS_PER_LONG)
    #define BIT(x)  (1UL<<OFF(x))
    #define LONG(x) ((x)/BITS_PER_LONG)
    #define test_bit(bit, array) ((array[LONG(bit)] >> OFF(bit)) & 1)

    // Keys to exclude from debouncing (volume dial)
    int excluded_keys[] = {
        KEY_VOLUMEUP,    // 115
        KEY_VOLUMEDOWN,  // 114
        -1  // Sentinel
    };

    long long last_event_time[MAX_KEYS] = {0};

    long long current_time_ms() {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        return (long long)tv.tv_sec * 1000 + tv.tv_usec / 1000;
    }

    int is_excluded(int key_code) {
        for (int i = 0; excluded_keys[i] != -1; i++) {
            if (excluded_keys[i] == key_code) {
                return 1;
            }
        }
        return 0;
    }

    int has_key(int fd, int key) {
        unsigned long key_bits[NBITS(KEY_MAX)];
        memset(key_bits, 0, sizeof(key_bits));

        if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(key_bits)), key_bits) < 0) {
            return 0;
        }
        return test_bit(key, key_bits);
    }

    int find_device() {
        DIR *dir = opendir("/dev/input");
        if (!dir) {
            perror("Cannot open /dev/input");
            return -1;
        }

        struct dirent *entry;
        printf("Searching for device (vendor: 0x%x, product: 0x%x) with KEY_PLAYPAUSE...\n", 
               VENDOR_ID, PRODUCT_ID);

        while ((entry = readdir(dir)) != NULL) {
            if (strncmp(entry->d_name, "event", 5) != 0) continue;

            char path[256];
            snprintf(path, sizeof(path), "/dev/input/%s", entry->d_name);

            int fd = open(path, O_RDONLY);
            if (fd < 0) {
                printf("Cannot open %s: %s\n", path, strerror(errno));
                continue;
            }

            struct input_id id;
            if (ioctl(fd, EVIOCGID, &id) == 0) {
                printf("Checking %s: vendor=0x%x, product=0x%x", 
                       path, id.vendor, id.product);

                if (id.vendor == VENDOR_ID && id.product == PRODUCT_ID) {
                    int has_playpause = has_key(fd, KEY_PLAYPAUSE);
                    printf(" - has KEY_PLAYPAUSE: %s\n", has_playpause ? "YES" : "NO");

                    if (has_playpause) {
                        printf("Found correct device: %s\n", path);
                        closedir(dir);
                        return fd;
                    }
                } else {
                    printf("\n");
                }
            }
            close(fd);
        }
        closedir(dir);
        return -1;
    }

    int main() {
        printf("Starting keyboard debounce service...\n");

        int fd_in = find_device();
        if (fd_in < 0) {
            fprintf(stderr, "ERROR: Keyboard not found (vendor: 0x%x, product: 0x%x) with KEY_PLAYPAUSE\n", 
                    VENDOR_ID, PRODUCT_ID);
            return 1;
        }

        printf("Opening /dev/uinput...\n");
        int fd_out = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
        if (fd_out < 0) {
            perror("ERROR: Cannot open /dev/uinput");
            close(fd_in);
            return 1;
        }

        printf("Setting up virtual device...\n");

        ioctl(fd_out, UI_SET_EVBIT, EV_KEY);
        ioctl(fd_out, UI_SET_EVBIT, EV_SYN);
        ioctl(fd_out, UI_SET_EVBIT, EV_MSC);
        ioctl(fd_out, UI_SET_EVBIT, EV_REP);

        for (int i = 0; i < KEY_MAX; i++) {
            ioctl(fd_out, UI_SET_KEYBIT, i);
        }

        ioctl(fd_out, UI_SET_MSCBIT, MSC_SCAN);

        struct uinput_setup usetup = {0};
        usetup.id.bustype = BUS_USB;
        usetup.id.vendor = VENDOR_ID;
        usetup.id.product = PRODUCT_ID;
        strcpy(usetup.name, "Debounced Keyboard");

        if (ioctl(fd_out, UI_DEV_SETUP, &usetup) < 0) {
            perror("ERROR: UI_DEV_SETUP failed");
            close(fd_in);
            close(fd_out);
            return 1;
        }

        if (ioctl(fd_out, UI_DEV_CREATE) < 0) {
            perror("ERROR: UI_DEV_CREATE failed");
            close(fd_in);
            close(fd_out);
            return 1;
        }

        usleep(100000);

        printf("Grabbing input device...\n");
        if (ioctl(fd_in, EVIOCGRAB, 1) < 0) {
            perror("ERROR: EVIOCGRAB failed");
            ioctl(fd_out, UI_DEV_DESTROY);
            close(fd_in);
            close(fd_out);
            return 1;
        }

        printf("Successfully started! Debouncing with %dms threshold.\n", DEBOUNCE_MS);
        printf("Excluded keys (no debounce): VOLUMEUP, VOLUMEDOWN, MUTE\n");
        printf("Waiting for events...\n");
        fflush(stdout);

        struct input_event ev;
        ssize_t bytes;
        while ((bytes = read(fd_in, &ev, sizeof(ev))) == sizeof(ev)) {
            if (ev.type == EV_KEY) {
                // Check if this key should be excluded from debouncing
                if (is_excluded(ev.code)) {
                    // Always forward excluded keys immediately
                    if (write(fd_out, &ev, sizeof(ev)) < 0) {
                        perror("Write failed");
                    }
                } else {
                    // Apply debouncing to other keys
                    long long now = current_time_ms();
                    long long diff = now - last_event_time[ev.code];

                    if (ev.value == 0 || diff > DEBOUNCE_MS) {
                        if (write(fd_out, &ev, sizeof(ev)) < 0) {
                            perror("Write failed");
                        }
                        if (ev.value == 1) {
                            last_event_time[ev.code] = now;
                        }
                    }
                }
            } else {
                // Forward all non-key events
                if (write(fd_out, &ev, sizeof(ev)) < 0) {
                    perror("Write failed");
                }
            }
        }

        printf("Read loop ended (bytes=%zd), cleaning up...\n", bytes);
        ioctl(fd_out, UI_DEV_DESTROY);
        close(fd_in);
        close(fd_out);
        return 0;
    }
    EOF

    $CC -o $out/bin/keyboard-debounce code.c
  '';

in lib.internal.simpleModule inputs "debounce" {
  systemd.services.keyboard-debounce = {
    description = "Keyboard Debounce Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${keyboardDebounce}/bin/keyboard-debounce";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
