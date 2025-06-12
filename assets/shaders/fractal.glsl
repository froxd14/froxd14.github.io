#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

// Complex number operations
vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 csqr(vec2 z) {
    return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

float mandelbrot(vec2 c) {
    vec2 z = vec2(0.0);
    float iterations = 0.0;
    
    for (int i = 0; i < 100; i++) {
        if (dot(z, z) > 4.0) break;
        z = csqr(z) + c;
        iterations += 1.0;
    }
    
    return iterations;
}

// Enhanced Julia set with time-based morphing
float julia(vec2 z) {
    // Dynamic Julia constant that changes over time
    vec2 c = vec2(
        0.7885 * cos(u_time * 0.3),
        0.7885 * sin(u_time * 0.2)
    );
    
    float iterations = 0.0;
    
    for (int i = 0; i < 80; i++) {
        if (dot(z, z) > 4.0) break;
        z = csqr(z) + c;
        iterations += 1.0;
    }
    
    return iterations;
}

// Burning ship fractal variation
float burningShip(vec2 c) {
    vec2 z = vec2(0.0);
    float iterations = 0.0;
    
    for (int i = 0; i < 60; i++) {
        if (dot(z, z) > 4.0) break;
        z = vec2(abs(z.x), abs(z.y));
        z = csqr(z) + c;
        iterations += 1.0;
    }
    
    return iterations;
}

// Dynamic color palette with time-based cycling
vec3 getColor(float t) {
    // Normalize the iteration count
    t = t / 100.0;
    
    // Time-based color cycling
    float timeOffset = u_time * 0.5;
    
    // Multiple color waves for rich, dynamic colors
    vec3 color1 = vec3(
        0.5 + 0.5 * sin(t * 6.28 + timeOffset),
        0.5 + 0.5 * sin(t * 6.28 + timeOffset + 2.09),
        0.5 + 0.5 * sin(t * 6.28 + timeOffset + 4.18)
    );
    
    vec3 color2 = vec3(
        0.5 + 0.5 * cos(t * 12.56 + timeOffset * 1.3),
        0.5 + 0.5 * cos(t * 12.56 + timeOffset * 1.3 + 1.57),
        0.5 + 0.5 * cos(t * 12.56 + timeOffset * 1.3 + 3.14)
    );
    
    // Blend the two color patterns
    return mix(color1, color2, 0.5 + 0.3 * sin(u_time * 0.7));
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    
    // Dynamic zoom and pan
    float zoom = 2.0 + 1.5 * sin(u_time * 0.1);
    uv *= zoom;
    
    // Subtle rotation over time
    float angle = u_time * 0.05;
    mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    uv = rotation * uv;
    
    // Pan the view slightly
    uv += vec2(sin(u_time * 0.08) * 0.3, cos(u_time * 0.06) * 0.2);
    
    // Blend multiple fractals for complexity
    float fractal1 = julia(uv);
    float fractal2 = mandelbrot(uv * 0.8);
    float fractal3 = burningShip(uv * 1.2 + vec2(0.5, 0.3));
    
    // Combine fractals with different weights
    float combined = fractal1 * 0.6 + fractal2 * 0.3 + fractal3 * 0.1;
    
    // Apply smooth coloring
    vec3 color = getColor(combined);
    
    // Add some brightness variation
    float brightness = 1.0 + 0.2 * sin(u_time * 0.4);
    color *= brightness;
    
    // Enhance contrast
    color = pow(color, vec3(0.8));
    
    // Add subtle vignette effect
    float dist = length(gl_FragCoord.xy / u_resolution.xy - 0.5);
    color *= 1.0 - dist * 0.3;
    
    gl_FragColor = vec4(color, 1.0);
}