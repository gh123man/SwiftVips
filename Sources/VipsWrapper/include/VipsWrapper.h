//
//  VipsWrapper.h
//  
//
//  Created by Brian Floersch on 3/23/23.
//

#ifndef VipsWrapper_h
#define VipsWrapper_h

#include <stdio.h>
#include <vips/vips.h>

// Wrapers exist because swift cannot handle varadic in C.

VipsImage *vips_image_new_from_buffer_wrapper(const void *buf, size_t len, const char *option_string);
int vips_resize_wrapper(VipsImage *in, VipsImage **out, double scale);
int vips_premultiply_wrapper(VipsImage *in, VipsImage **out);
int vips_unpremultiply_wrapper(VipsImage *in, VipsImage **out);
int vips_cast_wrapper(VipsImage *in, VipsImage **out, VipsBandFormat bandFormat);
int vips_jpegsave_buffer_wrapper(VipsImage *in, void **buf, size_t *len, gint quality);
int vips_pngsave_buffer_wrapper(VipsImage *in, void **buf, size_t *len, gint compression);

#endif /* VipsWrapper_h */
