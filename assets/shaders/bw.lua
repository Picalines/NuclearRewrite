return love.graphics.newShader([[

    extern float size;

    vec4 effect( vec4 color, Image texture, vec2 uv, vec2 screen_coords ) {
        vec4 pixel = Texel(texture, uv) * color;
        number av = ( pixel.r + pixel.g + pixel.b ) / 3.0;

        pixel.r = pixel.r + ( av - pixel.r ) * size;
        pixel.g = pixel.g + ( av - pixel.g ) * size;
        pixel.b = pixel.b + ( av - pixel.b ) * size;

        return pixel;
    }
]])