/*
 * anti-flash: 1px Wayland overlay that alternates colour every frame.
 *
 * Uses wlr-layer-shell to place a 1×1 surface on the overlay layer
 * (always on top, invisible to alt-tab).  The pixel alternates between
 * two near-black values on each compositor frame callback, ensuring no
 * two consecutive frames are identical — which prevents certain monitors
 * from flashing.
 */

#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#include <wayland-client.h>
#include "layer-shell-client-protocol.h"

/* ------------------------------------------------------------------ */
/* globals                                                             */
/* ------------------------------------------------------------------ */

static struct wl_display    *display;
static struct wl_compositor *compositor;
static struct wl_shm        *shm;
static struct zwlr_layer_shell_v1 *layer_shell;

static struct wl_surface        *surface;
static struct zwlr_layer_surface_v1 *layer_surface;

static int  shm_fd   = -1;
static void *shm_data = MAP_FAILED;

static bool toggle;
static bool configured;
static bool running = true;

/* ------------------------------------------------------------------ */
/* shared-memory buffer (two pixels: one for each state)               */
/* ------------------------------------------------------------------ */

#define PIXEL_SIZE 4          /* ARGB8888 */
#define BUF_PIXELS 2
#define BUF_SIZE   (BUF_PIXELS * PIXEL_SIZE)

static struct wl_buffer *buffers[2];

static int create_shm_file(void)
{
    const char name[] = "/anti-flash-shm";
    int fd = shm_open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
    shm_unlink(name);
    if (fd < 0) return -1;
    if (ftruncate(fd, BUF_SIZE) < 0) { close(fd); return -1; }
    return fd;
}

static bool create_buffers(void)
{
    shm_fd = create_shm_file();
    if (shm_fd < 0) {
        fprintf(stderr, "anti-flash: shm_open: %s\n", strerror(errno));
        return false;
    }

    shm_data = mmap(NULL, BUF_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                     shm_fd, 0);
    if (shm_data == MAP_FAILED) {
        fprintf(stderr, "anti-flash: mmap: %s\n", strerror(errno));
        close(shm_fd);
        return false;
    }

    /*
     * Pixel 0: ARGB = (FF, 00, 00, 00)  — opaque black
     * Pixel 1: ARGB = (FF, 01, 01, 01)  — opaque near-black
     */
    uint32_t *pixels = shm_data;
    pixels[0] = 0xFF000000;
    pixels[1] = 0xFF010101;

    struct wl_shm_pool *pool = wl_shm_create_pool(shm, shm_fd, BUF_SIZE);

    buffers[0] = wl_shm_pool_create_buffer(
        pool, 0 * PIXEL_SIZE, 1, 1, PIXEL_SIZE, WL_SHM_FORMAT_ARGB8888);
    buffers[1] = wl_shm_pool_create_buffer(
        pool, 1 * PIXEL_SIZE, 1, 1, PIXEL_SIZE, WL_SHM_FORMAT_ARGB8888);

    wl_shm_pool_destroy(pool);
    return true;
}

/* ------------------------------------------------------------------ */
/* frame callback — drives the alternation                             */
/* ------------------------------------------------------------------ */

static void frame_done(void *data, struct wl_callback *cb, uint32_t time);

static const struct wl_callback_listener frame_listener = {
    .done = frame_done,
};

static void commit_frame(void)
{
    struct wl_callback *cb = wl_surface_frame(surface);
    wl_callback_add_listener(cb, &frame_listener, NULL);

    wl_surface_attach(surface, buffers[toggle ? 1 : 0], 0, 0);
    wl_surface_damage_buffer(surface, 0, 0, 1, 1);
    wl_surface_commit(surface);
}

static void frame_done(void *data, struct wl_callback *cb, uint32_t time)
{
    (void)data; (void)time;
    wl_callback_destroy(cb);
    toggle = !toggle;
    commit_frame();
}

/* ------------------------------------------------------------------ */
/* layer-surface listener                                              */
/* ------------------------------------------------------------------ */

static void layer_surface_configure(
    void *data, struct zwlr_layer_surface_v1 *ls,
    uint32_t serial, uint32_t w, uint32_t h)
{
    (void)data; (void)w; (void)h;
    zwlr_layer_surface_v1_ack_configure(ls, serial);
    configured = true;
    commit_frame();
}

static void layer_surface_closed(
    void *data, struct zwlr_layer_surface_v1 *ls)
{
    (void)data; (void)ls;
    running = false;
}

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {
    .configure = layer_surface_configure,
    .closed    = layer_surface_closed,
};

/* ------------------------------------------------------------------ */
/* registry                                                            */
/* ------------------------------------------------------------------ */

static void registry_global(
    void *data, struct wl_registry *reg,
    uint32_t name, const char *iface, uint32_t version)
{
    (void)data;
    if (strcmp(iface, wl_compositor_interface.name) == 0)
        compositor = wl_registry_bind(reg, name, &wl_compositor_interface, 4);
    else if (strcmp(iface, wl_shm_interface.name) == 0)
        shm = wl_registry_bind(reg, name, &wl_shm_interface, 1);
    else if (strcmp(iface, zwlr_layer_shell_v1_interface.name) == 0)
        layer_shell = wl_registry_bind(
            reg, name, &zwlr_layer_shell_v1_interface, 1);
}

static void registry_global_remove(
    void *data, struct wl_registry *reg, uint32_t name)
{
    (void)data; (void)reg; (void)name;
}

static const struct wl_registry_listener registry_listener = {
    .global        = registry_global,
    .global_remove = registry_global_remove,
};

/* ------------------------------------------------------------------ */
/* main                                                                */
/* ------------------------------------------------------------------ */

int main(void)
{
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "anti-flash: cannot connect to Wayland display\n");
        return 1;
    }

    struct wl_registry *reg = wl_display_get_registry(display);
    wl_registry_add_listener(reg, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shm || !layer_shell) {
        fprintf(stderr, "anti-flash: missing required globals "
                "(compositor=%p shm=%p layer_shell=%p)\n",
                (void *)compositor, (void *)shm, (void *)layer_shell);
        return 1;
    }

    if (!create_buffers())
        return 1;

    surface = wl_compositor_create_surface(compositor);
    layer_surface = zwlr_layer_shell_v1_get_layer_surface(
        layer_shell, surface, NULL,
        ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY, "anti-flash");

    zwlr_layer_surface_v1_set_size(layer_surface, 1, 1);
    zwlr_layer_surface_v1_set_anchor(layer_surface,
        ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP |
        ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT);
    zwlr_layer_surface_v1_set_exclusive_zone(layer_surface, -1);
    zwlr_layer_surface_v1_add_listener(
        layer_surface, &layer_surface_listener, NULL);

    wl_surface_commit(surface);

    while (running && wl_display_dispatch(display) != -1)
        ;

    /* cleanup */
    if (layer_surface) zwlr_layer_surface_v1_destroy(layer_surface);
    if (surface) wl_surface_destroy(surface);
    if (shm_data != MAP_FAILED) munmap(shm_data, BUF_SIZE);
    if (shm_fd >= 0) close(shm_fd);
    wl_display_disconnect(display);
    return 0;
}
