//
//  VipsWrapper.c
//  
//
//  Created by Brian Floersch on 3/23/23.
//

#include "VipsWrapper.h"

void hello() {
    printf("hi");
}

VipsImage *vips_image_new_from_buffer_wrapper(const void *buf, size_t len, const char *option_string) {
    return vips_image_new_from_buffer(buf, len, option_string, NULL);
}

int vips_resize_wrapper(VipsImage *in, VipsImage **out, double scale) {
    return vips_resize(in, out, scale, NULL);
}

int vips_premultiply_wrapper(VipsImage *in, VipsImage **out) {
    return vips_premultiply(in, out, NULL);
}

int vips_unpremultiply_wrapper(VipsImage *in, VipsImage **out) {
    return vips_unpremultiply(in, out, NULL);
}

int vips_cast_wrapper(VipsImage *in, VipsImage **out, VipsBandFormat bandFormat) {
    return vips_cast(in, out, bandFormat, NULL);
}

int vips_jpegsave_buffer_wrapper(VipsImage *in, void **buf, size_t *len, gint quality) {
    return vips_jpegsave_buffer(in, buf, len, "Q", quality, NULL);
}

int vips_pngsave_buffer_wrapper(VipsImage *in, void **buf, size_t *len, gint compression) {
    return vips_pngsave_buffer(in, buf, len, "compression", compression, NULL);
}
