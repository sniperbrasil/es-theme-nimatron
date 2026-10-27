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
    vec2 p;
    // Invertido: inclina para a esquerda
    p.x = VertexCoord.x - (VertexCoord.y - 0.5) * side;
    p.y = VertexCoord.y;

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

uniform float lowerRightLift;
uniform float rightSize;

COMPAT_VARYING vec2 v_tex;
COMPAT_VARYING vec4 v_col;

void main(void)
{
    vec2 distorted = v_tex;

    float size = max(rightSize, 0.001);
    
    // INVERTIDO: calcula da direita pra esquerda
    // x=1.0 (direita) = influência 1.0, x=0.0 (esquerda) = 0.0
    float rightInfluence = 1.0 - clamp((1.0 - distorted.x) / size, 0.0, 1.0);

    float bottomInfluence = clamp(distorted.y, 0.0, 1.0);
    float lowerRightWeight = rightInfluence * bottomInfluence;

    distorted.y += lowerRightLift * lowerRightWeight;

    if (distorted.x < 0.0 || distorted.x > 1.0 ||
        distorted.y < 0.0 || distorted.y > 1.0)
    {
        FragColor = vec4(0.0);
        return;
    }

    FragColor = COMPAT_TEXTURE(u_tex, distorted) * v_col;
}

#endif