#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#endif

uniform mat4 MVPMatrix;
COMPAT_ATTRIBUTE vec2 VertexCoord;
COMPAT_ATTRIBUTE vec2 TexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;

uniform float side;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 p = VertexCoord;
    p.x += (VertexCoord.y - 0.5) * side;

    gl_Position = MVPMatrix * vec4(p.xy, 0.0, 1.0);
    v_tex = TexCoord;
    v_col = COLOR;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define COMPAT_TEXTURE texture2D
#define FragColor gl_FragColor
#endif

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_tex;
uniform float lowerLeftLift;
uniform float leftSize;
uniform float imageBottomY;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 uv = v_tex;
    float lift = max(lowerLeftLift, 0.0);
    float size = max(leftSize, 0.001);
    float leftWeight = 1.0 - clamp(uv.x / size, 0.0, 1.0);
    float baseShift = lift * leftWeight;
    float bottomY = clamp(imageBottomY, 0.0, 1.0);

    vec2 sampleUV = uv;

    if (bottomY < 0.5)
    {
        // A base está em y=0. A região visível começa em baseShift.
        // Remapeia essa região para a textura inteira, evitando o corte.
        float newHeight = max(1.0 - baseShift, 0.001);
        if (uv.y < baseShift)
        {
            FragColor = vec4(0.0);
            return;
        }
        sampleUV.y = (uv.y - baseShift) / newHeight;
    }
    else
    {
        // A base está em y=1. A região visível termina em 1-baseShift.
        // Remapeia a região para conservar a imagem inteira.
        float newHeight = max(1.0 - baseShift, 0.001);
        if (uv.y > 1.0 - baseShift)
        {
            FragColor = vec4(0.0);
            return;
        }
        sampleUV.y = uv.y / newHeight;
    }

    sampleUV = clamp(sampleUV, 0.0, 1.0);
    FragColor = COMPAT_TEXTURE(u_tex, sampleUV) * v_col;
}

#endif
